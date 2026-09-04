;####################################################################
;# Bank0D.asm -- sprite routines and bosses.
;#
;# 151 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank0DMacros(StartBank, EndBank)
%BANK_START(<StartBank>)
DATATABLE_RT00_SMW_Map16Data:	%DATATABLE_RT00_SMW_Map16Data(NULLROM)						; $0D8000
ROUTINE_SMW_ProcessExtendedObjects:	%ROUTINE_SMW_ProcessExtendedObjects(NULLROM)					; $0DA100
ROUTINE_SMW_ProcessStandardAndTilesetSpecificObjects:	%ROUTINE_SMW_ProcessStandardAndTilesetSpecificObjects(NULLROM)			; $0DA40F
ROUTINE_SMW_ProcessGrasslandObjects:	%ROUTINE_SMW_ProcessGrasslandObjects(NULLROM)					; $0DA44B
ROUTINE_SMW_ExtendedObj00_ScreenExit:	%ROUTINE_SMW_ExtendedObj00_ScreenExit(NULLROM)					; $0DA512
ROUTINE_SMW_ExtendedObj01_ScreenJump:	%ROUTINE_SMW_ExtendedObj01_ScreenJump(NULLROM)					; $0DA53D
ROUTINE_SMW_ExtendedObjXX_Generic1TileObject:	%ROUTINE_SMW_ExtendedObjXX_Generic1TileObject(NULLROM)				; $0DA548
ROUTINE_SMW_ExtendedObj42_TopLeftSlope:	%ROUTINE_SMW_ExtendedObj42_TopLeftSlope(NULLROM)				; $0DA652
ROUTINE_SMW_ExtendedObjXX_PurpleTriangle:	%ROUTINE_SMW_ExtendedObjXX_PurpleTriangle(NULLROM)				; $0DA671
ROUTINE_SMW_ExtendedObj46_MidwayBar:	%ROUTINE_SMW_ExtendedObj46_MidwayBar(NULLROM)					; $0DA68E
ROUTINE_SMW_PreserveLevelDataPointerInObjects:	%ROUTINE_SMW_PreserveLevelDataPointerInObjects(NULLROM)			; $0DA6B1
ROUTINE_SMW_RestoreLevelDataPointerInObjects:	%ROUTINE_SMW_RestoreLevelDataPointerInObjects(NULLROM)				; $0DA6BA
ROUTINE_SMW_ExtendedObj47_Door:	%ROUTINE_SMW_ExtendedObj47_Door(NULLROM)					; $0DA6CD
ROUTINE_SMW_ExtendedObjXX_LargeBush:	%ROUTINE_SMW_ExtendedObjXX_LargeBush(NULLROM)					; $0DA6EE
ROUTINE_SMW_ExtendedObj4A_ClimbingNetDoor:	%ROUTINE_SMW_ExtendedObj4A_ClimbingNetDoor(NULLROM)				; $0DA7B1
ROUTINE_SMW_ExtendedObj86_GoalSign:	%ROUTINE_SMW_ExtendedObj86_GoalSign(NULLROM)					; $0DA7E3
ROUTINE_SMW_ExtendedObj91_VerticalLevelSteepLeftSlope:	%ROUTINE_SMW_ExtendedObj91_VerticalLevelSteepLeftSlope(NULLROM)		; $0DA809
ROUTINE_RT01_SMW_HandleVerticalSubScreenCrossingForCurrentObject:	%ROUTINE_RT01_SMW_HandleVerticalSubScreenCrossingForCurrentObject(NULLROM)	; $0DA82A
ROUTINE_SMW_ExtendedObj93_VerticalLevelNormalLeftSlope:	%ROUTINE_SMW_ExtendedObj93_VerticalLevelNormalLeftSlope(NULLROM)		; $0DA83E
ROUTINE_SMW_ExtendedObj95_VerticalLevelVerySteepLeftSlope:	%ROUTINE_SMW_ExtendedObj95_VerticalLevelVerySteepLeftSlope(NULLROM)		; $0DA877
DATATABLE_RT00_SMW_BitTable:	%DATATABLE_RT00_SMW_BitTable(NULLROM)						; $0DA8A6
DATATABLE_SMW_Bank0DItemMemoryIndexes:	%DATATABLE_SMW_Bank0DItemMemoryIndexes(NULLROM)				; $0DA8AE
ROUTINE_RT00_SMW_StandardObjXX_Generic1RepeatedTileObject:	%ROUTINE_RT00_SMW_StandardObjXX_Generic1RepeatedTileObject(NULLROM)		; $0DA8B4
ROUTINE_SMW_HandleHorizontalSubScreenCrossingForCurrentObject:	%ROUTINE_SMW_HandleHorizontalSubScreenCrossingForCurrentObject(NULLROM)	; $0DA95B
ROUTINE_RT00_SMW_HandleVerticalSubScreenCrossingForCurrentObject:	%ROUTINE_RT00_SMW_HandleVerticalSubScreenCrossingForCurrentObject(NULLROM)	; $0DA97D
ROUTINE_SMW_GoDownLeftAndUpdateLevelDataPointerInObjects:	%ROUTINE_SMW_GoDownLeftAndUpdateLevelDataPointerInObjects(NULLROM)		; $0DA992
ROUTINE_SMW_GoDownRightAndUpdateLevelDataPointerInObjects:	%ROUTINE_SMW_GoDownRightAndUpdateLevelDataPointerInObjects(NULLROM)		; $0DA9B4
ROUTINE_SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects:	%ROUTINE_SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects(NULLROM)	; $0DA9D6
ROUTINE_SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects:	%ROUTINE_SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects(NULLROM)	; $0DA9EF
ROUTINE_SMW_SetMap16HighByteForCurrentObject:	%ROUTINE_SMW_SetMap16HighByteForCurrentObject(NULLROM)				; $0DAA08
ROUTINE_SMW_StandardObj0F_VerticalPipes:	%ROUTINE_SMW_StandardObj0F_VerticalPipes(NULLROM)				; $0DAA12
ROUTINE_SMW_StandardObj10_HorizontalPipes:	%ROUTINE_SMW_StandardObj10_HorizontalPipes(NULLROM)				; $0DAAA4
ROUTINE_SMW_StandardObj11_BulletShooter:	%ROUTINE_SMW_StandardObj11_BulletShooter(NULLROM)				; $0DAB0D
ROUTINE_RT00_SMW_StandardObj12_Slopes:	%ROUTINE_RT00_SMW_StandardObj12_Slopes(NULLROM)				; $0DAB3E
ROUTINE_SMW_FillInSlopeTileAir:	%ROUTINE_SMW_FillInSlopeTileAir(NULLROM)					; $0DABF7
ROUTINE_RT01_SMW_StandardObj12_Slopes:	%ROUTINE_RT01_SMW_StandardObj12_Slopes(NULLROM)				; $0DAC21
ROUTINE_SMW_StandardObj13_GroundEdgesAndVine:	%ROUTINE_SMW_StandardObj13_GroundEdgesAndVine(NULLROM)				; $0DB039
ROUTINE_SMW_StandardObj21_WideScaleGroundLedge:	%ROUTINE_SMW_StandardObj21_WideScaleGroundLedge(NULLROM)			; $0DB1C8
ROUTINE_SMW_StandardObj15_MidwayAndGoalPoint:	%ROUTINE_SMW_StandardObj15_MidwayAndGoalPoint(NULLROM)				; $0DB212
ROUTINE_SMW_ExtendedObj41_YoshiCoin:	%ROUTINE_SMW_ExtendedObj41_YoshiCoin(NULLROM)					; $0DB2CA
ROUTINE_SMW_StandardObj16_PurpleCoins:	%ROUTINE_SMW_StandardObj16_PurpleCoins(NULLROM)				; $0DB336
ROUTINE_SMW_StandardObj17_RopeAndCloudLine:	%ROUTINE_SMW_StandardObj17_RopeAndCloudLine(NULLROM)				; $0DB3BB
ROUTINE_SMW_StandardObj18_WaterWithAnimatedSurface:	%ROUTINE_SMW_StandardObj18_WaterWithAnimatedSurface(NULLROM)			; $0DB3DB
ROUTINE_SMW_StandardObj1C_DonutBridge:	%ROUTINE_SMW_StandardObj1C_DonutBridge(NULLROM)				; $0DB42B
ROUTINE_SMW_StandardObj1D_ClimbingNetWithBottomEdge:	%ROUTINE_SMW_StandardObj1D_ClimbingNetWithBottomEdge(NULLROM)			; $0DB461
ROUTINE_SMW_StandardObj1E_ClimbingNetWithSideEdge:	%ROUTINE_SMW_StandardObj1E_ClimbingNetWithSideEdge(NULLROM)			; $0DB49C
ROUTINE_SMW_StandardObj1F_SkinnyVerticalPipeBoneLog:	%ROUTINE_SMW_StandardObj1F_SkinnyVerticalPipeBoneLog(NULLROM)			; $0DB51F
ROUTINE_SMW_StandardObj20_SkinnyHorizontalPipeBoneLog:	%ROUTINE_SMW_StandardObj20_SkinnyHorizontalPipeBoneLog(NULLROM)		; $0DB547
ROUTINE_SMW_ExtendedObj68_CloudFringeBottomAndRightEdge:	%ROUTINE_SMW_ExtendedObj68_CloudFringeBottomAndRightEdge(NULLROM)		; $0DB569
ROUTINE_SMW_ExtendedObj8E_YellowSwitchBlock:	%ROUTINE_SMW_ExtendedObj8E_YellowSwitchBlock(NULLROM)				; $0DB583
ROUTINE_SMW_GrasslandObj3F_SmallBushes:	%ROUTINE_SMW_GrasslandObj3F_SmallBushes(NULLROM)				; $0DB5A8
ROUTINE_SMW_GrasslandObj3C_ArchLedge:	%ROUTINE_SMW_GrasslandObj3C_ArchLedge(NULLROM)					; $0DB5E8
ROUTINE_SMW_GrasslandObj3D_TopCloudFridge:	%ROUTINE_SMW_GrasslandObj3D_TopCloudFridge(NULLROM)				; $0DB6C1
ROUTINE_SMW_ExtendedObj88_RightTreeBranch:	%ROUTINE_SMW_ExtendedObj88_RightTreeBranch(NULLROM)				; $0DB6E1
ROUTINE_SMW_GrasslandObj3E_SideCloudFridges:	%ROUTINE_SMW_GrasslandObj3E_SideCloudFridges(NULLROM)				; $0DB6F5
ROUTINE_SMW_GrasslandObj39_RightFacingDiagonalPipe:	%ROUTINE_SMW_GrasslandObj39_RightFacingDiagonalPipe(NULLROM)			; $0DB72F
ROUTINE_SMW_GrasslandObjXX_DiagonalLedge:	%ROUTINE_SMW_GrasslandObjXX_DiagonalLedge(NULLROM)				; $0DB7AA
ROUTINE_SMW_GrasslandObj32_BlueSwitchBlocks:	%ROUTINE_SMW_GrasslandObj32_BlueSwitchBlocks(NULLROM)				; $0DB916
ROUTINE_SMW_GrasslandObj37_SmallTreeTrunk:	%ROUTINE_SMW_GrasslandObj37_SmallTreeTrunk(NULLROM)				; $0DB962
ROUTINE_SMW_GrasslandObj36_LargeTreeTrunk:	%ROUTINE_SMW_GrasslandObj36_LargeTreeTrunk(NULLROM)				; $0DB9C0
ROUTINE_SMW_GrasslandObj35_ForestGround:	%ROUTINE_SMW_GrasslandObj35_ForestGround(NULLROM)				; $0DBA0A
ROUTINE_SMW_GrasslandObj34_ForestGroundEdges:	%ROUTINE_SMW_GrasslandObj34_ForestGroundEdges(NULLROM)				; $0DBA44
ROUTINE_SMW_GrasslandObj33_ForestTreeTop:	%ROUTINE_SMW_GrasslandObj33_ForestTreeTop(NULLROM)				; $0DBA7C
ROUTINE_SMW_GrasslandObj30_IcyVerticalPipe:	%ROUTINE_SMW_GrasslandObj30_IcyVerticalPipe(NULLROM)				; $0DBB2C
ROUTINE_RT01_SMW_StandardObjXX_Generic1RepeatedTileObject:	%ROUTINE_RT01_SMW_StandardObjXX_Generic1RepeatedTileObject(NULLROM)		; $0DBB63
INLINEDATATABLE_RT39_SMW_EmptySpace:	%INLINEDATATABLE_RT39_SMW_EmptySpace(NULLROM)					; $0DBB68
DATATABLE_RT01_SMW_Map16Data:	%DATATABLE_RT01_SMW_Map16Data(NULLROM)						; $0DBC00
ROUTINE_SMW_ProcessCastleObjects:	%ROUTINE_SMW_ProcessCastleObjects(NULLROM)					; $0DC190
ROUTINE_SMW_ExtendedObj4B_ConveyorEndTile1:	%ROUTINE_SMW_ExtendedObj4B_ConveyorEndTile1(NULLROM)				; $0DC257
ROUTINE_SMW_ExtendedObj84_CastleEntrance:	%ROUTINE_SMW_ExtendedObj84_CastleEntrance(NULLROM)				; $0DC26B
ROUTINE_SMW_ExtendedObj90_LargeBossDoor:	%ROUTINE_SMW_ExtendedObj90_LargeBossDoor(NULLROM)				; $0DC318
ROUTINE_SMW_CastleObj3D_Escalator:	%ROUTINE_SMW_CastleObj3D_Escalator(NULLROM)					; $0DC341
ROUTINE_SMW_CastleObj3E_HorizontalLineOfSpikes:	%ROUTINE_SMW_CastleObj3E_HorizontalLineOfSpikes(NULLROM)			; $0DC42C
ROUTINE_SMW_CastleObj3F_VerticalLineOfSpikes:	%ROUTINE_SMW_CastleObj3F_VerticalLineOfSpikes(NULLROM)				; $0DC44C
ROUTINE_SMW_CastleObj3C_StoneBlock:	%ROUTINE_SMW_CastleObj3C_StoneBlock(NULLROM)					; $0DC46F
ROUTINE_SMW_CastleObj3B_GrassLedge:	%ROUTINE_SMW_CastleObj3B_GrassLedge(NULLROM)					; $0DC4C9
ROUTINE_SMW_CastleObj36_LargeSpikedPillar:	%ROUTINE_SMW_CastleObj36_LargeSpikedPillar(NULLROM)				; $0DC4EF
ROUTINE_SMW_CastleObj35_RockWallBackground:	%ROUTINE_SMW_CastleObj35_RockWallBackground(NULLROM)				; $0DC58A
ROUTINE_SMW_CastleObj34_VerticalDoubleEndedPipe:	%ROUTINE_SMW_CastleObj34_VerticalDoubleEndedPipe(NULLROM)			; $0DC5D8
INLINEDATATABLE_RT40_SMW_EmptySpace:	%INLINEDATATABLE_RT40_SMW_EmptySpace(NULLROM)					; $0DC620
DATATABLE_RT02_SMW_Map16Data:	%DATATABLE_RT02_SMW_Map16Data(NULLROM)						; $0DC800
ROUTINE_SMW_ProcessRopeObjects:	%ROUTINE_SMW_ProcessRopeObjects(NULLROM)					; $0DCD90
ROUTINE_SMW_ExtendedObjXX_LineGuideQuarterLargeCircle:	%ROUTINE_SMW_ExtendedObjXX_LineGuideQuarterLargeCircle(NULLROM)		; $0DCE57
ROUTINE_SMW_ExtendedObjXX_LineGuideQuarterSmallCircle:	%ROUTINE_SMW_ExtendedObjXX_LineGuideQuarterSmallCircle(NULLROM)		; $0DCE90
ROUTINE_SMW_ExtendedObj70_BitOfCanvas1:	%ROUTINE_SMW_ExtendedObj70_BitOfCanvas1(NULLROM)				; $0DCEA6
ROUTINE_SMW_ExtendedObj55_HorizontalLineGuideEnd:	%ROUTINE_SMW_ExtendedObj55_HorizontalLineGuideEnd(NULLROM)			; $0DCEBE
ROUTINE_SMW_ExtendedObj56_VerticalLineGuideEnd:	%ROUTINE_SMW_ExtendedObj56_VerticalLineGuideEnd(NULLROM)			; $0DCED8
ROUTINE_SMW_RopeObj36_HorizontalConveyorRope:	%ROUTINE_SMW_RopeObj36_HorizontalConveyorRope(NULLROM)				; $0DCEF0
ROUTINE_SMW_CastleObj37_HorizontalLineGuide:	%ROUTINE_SMW_CastleObj37_HorizontalLineGuide(NULLROM)				; $0DCF10
ROUTINE_SMW_CastleObj38_VerticalLineGuide:	%ROUTINE_SMW_CastleObj38_VerticalLineGuide(NULLROM)				; $0DCF30
ROUTINE_SMW_RopeObj3A_SlopedLineGuide:	%ROUTINE_SMW_RopeObj3A_SlopedLineGuide(NULLROM)				; $0DCF53
ROUTINE_SMW_RopeObj3B_VerySteepSlopedLineGuide:	%ROUTINE_SMW_RopeObj3B_VerySteepSlopedLineGuide(NULLROM)			; $0DD070
ROUTINE_SMW_RopeObj3C_MushroomTop:	%ROUTINE_SMW_RopeObj3C_MushroomTop(NULLROM)					; $0DD103
ROUTINE_SMW_RopeObj3D_MushroomColumn:	%ROUTINE_SMW_RopeObj3D_MushroomColumn(NULLROM)					; $0DD145
ROUTINE_SMW_RopeObj3E_HorizontalLog:	%ROUTINE_SMW_RopeObj3E_HorizontalLog(NULLROM)					; $0DD182
ROUTINE_SMW_RopeObj3F_VerticalLog:	%ROUTINE_SMW_RopeObj3F_VerticalLog(NULLROM)					; $0DD1A5
ROUTINE_SMW_RopeObj35_ColumnWithPlantOnTop:	%ROUTINE_SMW_RopeObj35_ColumnWithPlantOnTop(NULLROM)				; $0DD1CB
ROUTINE_SMW_RopeObj32_LogBridge:	%ROUTINE_SMW_RopeObj32_LogBridge(NULLROM)					; $0DD24C
INLINEDATATABLE_RT41_SMW_EmptySpace:	%INLINEDATATABLE_RT41_SMW_EmptySpace(NULLROM)					; $0DD282
DATATABLE_RT03_SMW_Map16Data:	%DATATABLE_RT03_SMW_Map16Data(NULLROM)						; $0DD400
ROUTINE_SMW_ProcessUndergroundObjects:	%ROUTINE_SMW_ProcessUndergroundObjects(NULLROM)				; $0DD990
ROUTINE_SMW_ExtendedObj60_CaveLavaInnerCorner:	%ROUTINE_SMW_ExtendedObj60_CaveLavaInnerCorner(NULLROM)			; $0DDA57
ROUTINE_SMW_ExtendedObj75_CanvasTile1:	%ROUTINE_SMW_ExtendedObj75_CanvasTile1(NULLROM)				; $0DDA61
ROUTINE_SMW_ExtendedObj7C_BitOfCanvas1:	%ROUTINE_SMW_ExtendedObj7C_BitOfCanvas1(NULLROM)				; $0DDA7A
ROUTINE_SMW_ExtendedObj7F_TorpedoLauncher:	%ROUTINE_SMW_ExtendedObj7F_TorpedoLauncher(NULLROM)				; $0DDA9E
ROUTINE_SMW_UndergroundObj38_RightLavaEdge:	%ROUTINE_SMW_UndergroundObj38_RightLavaEdge(NULLROM)				; $0DDAC4
ROUTINE_SMW_UndergroundObj39_SlopedCaveLava:	%ROUTINE_SMW_UndergroundObj39_SlopedCaveLava(NULLROM)				; $0DDAF2
ROUTINE_SMW_UndergroundObj3A_CaveLavaWithTop:	%ROUTINE_SMW_UndergroundObj3A_CaveLavaWithTop(NULLROM)				; $0DDCA9
ROUTINE_SMW_UndergroundObj3D_CeilingLedge:	%ROUTINE_SMW_UndergroundObj3D_CeilingLedge(NULLROM)				; $0DDCEA
ROUTINE_SMW_UndergroundObj3E_CeilingEdges:	%ROUTINE_SMW_UndergroundObj3E_CeilingEdges(NULLROM)				; $0DDD26
ROUTINE_SMW_UndergroundObj3F_SolidDirt:	%ROUTINE_SMW_UndergroundObj3F_SolidDirt(NULLROM)				; $0DDD5C
ROUTINE_SMW_UndergroundObj3C_VerySteepSlope:	%ROUTINE_SMW_UndergroundObj3C_VerySteepSlope(NULLROM)				; $0DDD87
ROUTINE_SMW_UndergroundObj37_LargeCanvas:	%ROUTINE_SMW_UndergroundObj37_LargeCanvas(NULLROM)				; $0DDEDC
ROUTINE_SMW_ExtendedObj71_Canvas1:	%ROUTINE_SMW_ExtendedObj71_Canvas1(NULLROM)					; $0DE05E
ROUTINE_SMW_UndergroundObj36_4SidedGround:	%ROUTINE_SMW_UndergroundObj36_4SidedGround(NULLROM)				; $0DE12C
INLINEDATATABLE_RT42_SMW_EmptySpace:	%INLINEDATATABLE_RT42_SMW_EmptySpace(NULLROM)					; $0DE186
DATATABLE_RT04_SMW_Map16Data:	%DATATABLE_RT04_SMW_Map16Data(NULLROM)						; $0DE300
ROUTINE_SMW_ProcessGhostHouseObjects:	%ROUTINE_SMW_ProcessGhostHouseObjects(NULLROM)					; $0DE890
ROUTINE_SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner:	%ROUTINE_SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner(NULLROM)		; $0DE957
ROUTINE_SMW_ExtendedObj5F_LargeBackgroundArea:	%ROUTINE_SMW_ExtendedObj5F_LargeBackgroundArea(NULLROM)			; $0DE971
ROUTINE_SMW_ExtendedObj61_GhostHouseClock:	%ROUTINE_SMW_ExtendedObj61_GhostHouseClock(NULLROM)				; $0DE98F
ROUTINE_SMW_ExtendedObj64_TopRightCobweb:	%ROUTINE_SMW_ExtendedObj64_TopRightCobweb(NULLROM)				; $0DE9E1
ROUTINE_SMW_ExtendedObj66_GhostHouseTopRightToBottomLeftBeam2:	%ROUTINE_SMW_ExtendedObj66_GhostHouseTopRightToBottomLeftBeam2(NULLROM)	; $0DEA1E
ROUTINE_SMW_ExtendedObj49_GhostHouseExit:	%ROUTINE_SMW_ExtendedObj49_GhostHouseExit(NULLROM)				; $0DEA71
ROUTINE_SMW_ExtendedObj80_GhostHouseEntrance:	%ROUTINE_SMW_ExtendedObj80_GhostHouseEntrance(NULLROM)				; $0DEADE
ROUTINE_SMW_ExtendedObj85_YoshisHouse:	%ROUTINE_SMW_ExtendedObj85_YoshisHouse(NULLROM)				; $0DEB93
ROUTINE_SMW_ExtendedObj97_SwitchPalaceRightAndBottomEdgeTile:	%ROUTINE_SMW_ExtendedObj97_SwitchPalaceRightAndBottomEdgeTile(NULLROM)		; $0DEC5C
ROUTINE_SMW_ExtendedObj81_Seaweed:	%ROUTINE_SMW_ExtendedObj81_Seaweed(NULLROM)					; $0DEC66
ROUTINE_SMW_ExtendedObj8A_GreenSwitchPalaceSwitch:	%ROUTINE_SMW_ExtendedObj8A_GreenSwitchPalaceSwitch(NULLROM)			; $0DEC7E
ROUTINE_SMW_ExtendedObj8F_GhostHouseWindow:	%ROUTINE_SMW_ExtendedObj8F_GhostHouseWindow(NULLROM)				; $0DECC1
ROUTINE_RT00_SMW_GhostHouseObj35_BrickBackground:	%ROUTINE_RT00_SMW_GhostHouseObj35_BrickBackground(NULLROM)			; $0DECC6
ROUTINE_SMW_GhostHouseObj37_HorizontalBackgroundLogAndRailing:	%ROUTINE_SMW_GhostHouseObj37_HorizontalBackgroundLogAndRailing(NULLROM)	; $0DED09
ROUTINE_SMW_GhostHouseObj38_WoodenLedge:	%ROUTINE_SMW_GhostHouseObj38_WoodenLedge(NULLROM)				; $0DED43
ROUTINE_SMW_GhostHouseObj39_VerticalBackgroundLog:	%ROUTINE_SMW_GhostHouseObj39_VerticalBackgroundLog(NULLROM)			; $0DED65
ROUTINE_SMW_GhostHouseObj3A_SolidBrickWallAndVerticalLineOfSpikes:	%ROUTINE_SMW_GhostHouseObj3A_SolidBrickWallAndVerticalLineOfSpikes(NULLROM)	; $0DED95
ROUTINE_SMW_GhostHouseObj3B_BonusGameLedge:	%ROUTINE_SMW_GhostHouseObj3B_BonusGameLedge(NULLROM)				; $0DEDB9
ROUTINE_SMW_GhostHouseObj3C_SwitchPalaceCeiling:	%ROUTINE_SMW_GhostHouseObj3C_SwitchPalaceCeiling(NULLROM)			; $0DEDDB
ROUTINE_SMW_GhostHouseObj3D_SwitchPalaceLedge:	%ROUTINE_SMW_GhostHouseObj3D_SwitchPalaceLedge(NULLROM)			; $0DEE17
ROUTINE_SMW_GhostHouseObj3E_SwitchPalaceRightFacingWall:	%ROUTINE_SMW_GhostHouseObj3E_SwitchPalaceRightFacingWall(NULLROM)		; $0DEE52
ROUTINE_SMW_GhostHouseObj3F_SwitchPalaceLeftFacingWall:	%ROUTINE_SMW_GhostHouseObj3F_SwitchPalaceLeftFacingWall(NULLROM)		; $0DEE89
ROUTINE_SMW_GhostHouseObj34_WoodLedgeOnColumn:	%ROUTINE_SMW_GhostHouseObj34_WoodLedgeOnColumn(NULLROM)			; $0DEEC0
ROUTINE_SMW_GhostHouseObj33_Cloud:	%ROUTINE_SMW_GhostHouseObj33_Cloud(NULLROM)					; $0DEF45
ROUTINE_SMW_GhostHouseObj32_GrassLedge2:	%ROUTINE_SMW_GhostHouseObj32_GrassLedge2(NULLROM)				; $0DEF67
ROUTINE_SMW_GhostHouseObj31_WoodCrate:	%ROUTINE_SMW_GhostHouseObj31_WoodCrate(NULLROM)				; $0DEFA2
ROUTINE_SMW_GhostHouseObj30_GrassLedge1:	%ROUTINE_SMW_GhostHouseObj30_GrassLedge1(NULLROM)				; $0DF02B
ROUTINE_RT01_SMW_GhostHouseObj35_BrickBackground:	%ROUTINE_RT01_SMW_GhostHouseObj35_BrickBackground(NULLROM)			; $0DF066
ROUTINE_SMW_GhostHouseObj2E_HorizontalLineOfSpikes:	%ROUTINE_SMW_GhostHouseObj2E_HorizontalLineOfSpikes(NULLROM)			; $0DF06B
INLINEDATATABLE_RT43_SMW_EmptySpace:	%INLINEDATATABLE_RT43_SMW_EmptySpace(NULLROM)					; $0DF08A
DATATABLE_SMW_CreditsEnemyNames:	%DATATABLE_SMW_CreditsEnemyNames(NULLROM)					; $0DF300
INLINEDATATABLE_RT44_SMW_EmptySpace:	%INLINEDATATABLE_RT44_SMW_EmptySpace(NULLROM)					; $0DFE9F
%BANK_END(<EndBank>)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SetMap16HighByteForCurrentObject(Address)
namespace SMW_SetMap16HighByteForCurrentObject
%InsertMacroAtXPosition(<Address>)

; A short routine which stores 01 to the high byte of the current index in
; the map16 table. Used liberally throughout SMW's object generation code.
Page01:
	LDA.b #$01			; This one is FAR too short to put any comments on.
	STA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	RTS

; A short routine which stores 00 to the high byte of the current index in
; the map16 table. Used liberally throughout SMW's object generation code.
Page00:
	LDA.b #$00
	STA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_HandleVerticalSubScreenCrossingForCurrentObject(Address)
namespace SMW_HandleVerticalSubScreenCrossingForCurrentObject
%InsertMacroAtXPosition(<Address>)

; The subroutine that allows objects to go across subscreen boundaries in
; horizontal levels without glitching.
HorizontalLevel:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$10			; | Increase pointer
	STA.b !RAM_SMW_Blocks_SubScrPos	;/
	TAY				;\
	BCC.b .Return			;/ Check for screen boundaries
.Entry2:
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;\
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; | Update pointer
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
	STA.b !RAM_SMW_Misc_ScratchRAM05	; Update preserved pointer
.Return:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_HandleVerticalSubScreenCrossingForCurrentObject(Address)
namespace SMW_HandleVerticalSubScreenCrossingForCurrentObject
%InsertMacroAtXPosition(<Address>)

VerticalLevel:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$10			; | Update position
	STA.b !RAM_SMW_Blocks_SubScrPos	;/
	TAY				;\
	BCC.b .Return			;/ Check for boundary
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;\
	CLC				; |
	ADC.b #$02			; | Update pointer if needed (they're smarter than I thought, they didn't touch $6B, but it's still called INC)
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
.Return:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_HandleHorizontalSubScreenCrossingForCurrentObject(Address)
namespace SMW_HandleHorizontalSubScreenCrossingForCurrentObject
%InsertMacroAtXPosition(<Address>)

; The subroutine that enables most objects to go across screen boundaries in
; horizontal levels without glitching. (It doesn't work in vertical levels.)
; It also stores the value of A to [$6B],y. (Forgot to include that info
; before.)
Main:
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	; Add block
Entry2:
	INY				; Increase index
	TYA				;\
	AND.b #$0F			; | Check whether we hit a horizontal screen boundary
	BNE.b Return0DA97C		;/
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataLo				;\ LM: This routine is modified to account for custom level dimensions (3.00+)
	CLC									;|
	ADC.b #$B0								;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo				;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo				;|
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi				;|
	ADC.b #$01								;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi				;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi				;/
	INC.w !RAM_SMW_Blocks_ScreenToPlaceNextObject	; Increase screen number
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	AND.b #$F0			; | Load new index
	TAY				;/
Return0DA97C:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_PreserveLevelDataPointerInObjects(Address)
namespace SMW_PreserveLevelDataPointerInObjects
%InsertMacroAtXPosition(<Address>)

; A routine that backs up the low and high bytes of the Map16 data pointers.
; It stores $6B and $6C in $04 and $05.
Main:
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi
	STA.b !RAM_SMW_Misc_ScratchRAM05
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RestoreLevelDataPointerInObjects(Address)
namespace SMW_RestoreLevelDataPointerInObjects
%InsertMacroAtXPosition(<Address>)

; A routine that restores the low and high bytes of the Map16 pointers [$6B]
; and [$6E] from scratch RAM. Used in conjunction with $0DA6B1.
Main:
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
	STA.w !RAM_SMW_Blocks_ScreenToPlaceNextObject
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessExtendedObjects(Address)
namespace SMW_ProcessExtendedObjects
%InsertMacroAtXPosition(<Address>)

Main:
	SEP.b #$30					; Optimization: Unecessary SEP.b #$30
	JSR.w Sub			; Run main code (why not just end the routines with RTLs? SMW's code is confusing sometimes...)
	RTL

Sub:
	SEP.b #$30					; Optimization: Another unecessary SEP.b #$30
	LDA.b !RAM_SMW_Blocks_SizeOrType	; Load object size (i.e. extended object number)
	TAX				; Put in X too since some objects share codes
	JSL.l SMW_ExecutePtr_Long	; and go to the correct address (why go to a 24bit address when the return is 16bit anyways? Morons...)

; Pointers to extended objects, 3 bytes per pointer, although the bank byte
; is always 0D. Extended objects 02-0F and 98-FF are unused, so they could
; be repointed (which is essentially what Extended Objects +14 and ObjecTool
; do).
ExtendedObjectPtrs:
	dl SMW_ExtendedObj00_ScreenExit_Main
	dl SMW_ExtendedObj01_ScreenJump_Main
	dl SMW_ExtendedObj02_Unused_Main			;\ Crash: These all crash the game if loaded.
	dl SMW_ExtendedObj03_Unused_Main			;| LM: Hijacks the pointer for object 02 to point to $0DE1B0 (?.??+)
	dl SMW_ExtendedObj04_Unused_Main			;| Also hijacks the pointer for object 01 and 03 (3.00+)
	dl SMW_ExtendedObj05_Unused_Main			;|
	dl SMW_ExtendedObj06_Unused_Main			;|
	dl SMW_ExtendedObj07_Unused_Main			;|
	dl SMW_ExtendedObj08_Unused_Main			;|
	dl SMW_ExtendedObj09_Unused_Main			;|
	dl SMW_ExtendedObj0A_Unused_Main			;|
	dl SMW_ExtendedObj0B_Unused_Main			;|
	dl SMW_ExtendedObj0C_Unused_Main			;|
	dl SMW_ExtendedObj0D_Unused_Main			;|
	dl SMW_ExtendedObj0E_Unused_Main			;|
	dl SMW_ExtendedObj0F_Unused_Main			;/
	dl SMW_ExtendedObj10_SmallDoor_Main
	dl SMW_ExtendedObj11_Invisible1upBlock_Main	; Invisible ? block (1-UP)
	dl SMW_ExtendedObj12_InvisibleNoteBlock_Main
	dl SMW_ExtendedObj13_TopLeftCornerEdge1_Main	; Top left corner edge tile 1
	dl SMW_ExtendedObj14_TopRightCornerEdge1_Main	; Top right corner edge tile 1
	dl SMW_ExtendedObj15_SmallPSwitchDoor_Main	; Small POW door
	dl SMW_ExtendedObj16_InvisiblePSwitchBlock_Main	; Invisible POW ? block
	dl SMW_ExtendedObj17_GreenStarBlock_Main
	dl SMW_ExtendedObj18_3upMoon_Main
	dl SMW_ExtendedObj19_1upCheckpoint1_Main	; Invisible 1-UP #1
	dl SMW_ExtendedObj1A_1upCheckpoint2_Main	; Invisible 1-UP #2
	dl SMW_ExtendedObj1B_1upCheckpoint3_Main	; Invisible 1-UP #3
	dl SMW_ExtendedObj1C_1upCheckpoint4_Main	; Invisible 1-UP #4
	dl SMW_ExtendedObj1D_RedBerry_Main
	dl SMW_ExtendedObj1E_PinkBerry_Main
	dl SMW_ExtendedObj1F_GreenBerry_Main
	dl SMW_ExtendedObj20_SpinningTurnBlock_Main	; Always turning block
	dl SMW_ExtendedObj21_BottomRightMidwayGateTile_Main	; Bottom right of midway point (unused)
	dl SMW_ExtendedObj22_BottomRightMidwayGateTile_Main	; Bottom right of midway point (unused)
	dl SMW_ExtendedObj23_NoteBlockWithPowerUp_Main	; Note block (flower/feather/star)
	dl SMW_ExtendedObj24_ONOFFBlock_Main
	dl SMW_ExtendedObj25_DirectionalCoinBlock_Main	; Direction coins ? block
	dl SMW_ExtendedObj26_NoteBlock_Main
	dl SMW_ExtendedObj27_4WayNoteBlock_Main	; Note block, bounce on all sides
	dl SMW_ExtendedObj28_TurnBlockWithFlower_Main	; Turn block (Flower)
	dl SMW_ExtendedObj29_TurnBlockWithFeather_Main	; Turn block (Feather)
	dl SMW_ExtendedObj2A_TurnBlockWithStar_Main	; Turn block (Star)
	dl SMW_ExtendedObj2B_TurnBlockWithCoinStar21upVine_Main	; Turn block (Star 2/1-UP/Vine)
	dl SMW_ExtendedObj2C_TurnBlockWithMultipleCoins_Main	; Turn block (Multiple coins)
	dl SMW_ExtendedObj2D_TurnBlockWithCoin_Main	; Turn block (Coin)
	dl SMW_ExtendedObj2E_TurnBlockWithNothing_Main	; Turn block (Nothing)
	dl SMW_ExtendedObj2F_TurnBlockWithPSwitch_Main	; Turn block (POW)
	dl SMW_ExtendedObj30_QuestionBlockWithFlower_Main	; ? block (Flower)
	dl SMW_ExtendedObj31_QuestionBlockWithFeather_Main	; ? block (Feather)
	dl SMW_ExtendedObj32_QuestionBlockWithStar_Main	; ? block (Star)
	dl SMW_ExtendedObj33_QuestionBlockWithCoinStar2_Main	; ? block (Star 2)
	dl SMW_ExtendedObj34_QuestionBlockWithMultipleCoins_Main	; ? block (Multiple coins)
	dl SMW_ExtendedObj35_QuestionBlockWithKeyWingsBalloonShell_Main	; ? block (Key/Wings/Balloon/Shell)
	dl SMW_ExtendedObj36_QuestionBlockWithYoshi_Main	; ? block (Yoshi)
	dl SMW_ExtendedObj37_QuestionBlockWithShell_Main	; ? block (Shell)
	dl SMW_ExtendedObj38_QuestionBlockWithShell_Main	; ? block (Shell)
	dl SMW_ExtendedObj39_SolidTurnBlockWithSideFeather_Main	; Turn block, unbreakable (Feather)
	dl SMW_ExtendedObj3A_TopLeftCornerEdge2_Main	; Top left corner edge tile 2
	dl SMW_ExtendedObj3B_TopRightCornerEdge2_Main	; Top right corner edge tile 2
	dl SMW_ExtendedObj3C_TopLeftCornerEdge3_Main	; Top left corner edge tile 3
	dl SMW_ExtendedObj3D_TopRightCornerEdge3_Main	; Top right corner edge tile 3
	dl SMW_ExtendedObj3E_TopLeftCornerEdge4_Main	; Top left corner edge tile 4
	dl SMW_ExtendedObj3F_TopRightCornerEdge4_Main	; Top right corner edge tile 4
	dl SMW_ExtendedObj40_GlassBlock_Main	; Transculent block
	dl SMW_ExtendedObj41_YoshiCoin_Main
	dl SMW_ExtendedObj42_TopLeftSlope_Main
	dl SMW_ExtendedObj43_TopRightSlope_Main
	dl SMW_ExtendedObj44_LeftFacingTriangle_Main	; Purple triangle, left
	dl SMW_ExtendedObj45_RightFacingTriangle_Main	; Purple triangle, right
	dl SMW_ExtendedObj46_MidwayBar_Main	; Midway point rope
	dl SMW_ExtendedObj47_Door_Main
	dl SMW_ExtendedObj48_PSwitchDoor_Main	; Invisible POW door
	dl SMW_ExtendedObj49_GhostHouseExit_Main
	dl SMW_ExtendedObj4A_ClimbingNetDoor_Main
	dl SMW_ExtendedObj4B_ConveyorEndTile1_Main
	dl SMW_ExtendedObj4C_ConveyorEndTile2_Main
	dl SMW_ExtendedObj4D_LineGuideTopLeftQuarterLargeCircle_Main	; Line guide, top left 1/4 large circle
	dl SMW_ExtendedObj4E_LineGuideTopRightQuarterLargeCircle_Main	; Line guide, top right 1/4 large circle
	dl SMW_ExtendedObj4F_LineGuideBottomLeftQuarterLargeCircle_Main	; Line guide, bottom left 1/4 large circle
	dl SMW_ExtendedObj50_LineGuideBottomRightQuarterLargeCircle_Main	; Line guide, bottom right 1/4 large circle
	dl SMW_ExtendedObj51_LineGuideTopLeftQuarterSmallCircle_Main	; Line guide, top left 1/4 small circle
	dl SMW_ExtendedObj52_LineGuideTopRightQuarterSmallCircle_Main	; Line guide, top right 1/4 small circle
	dl SMW_ExtendedObj53_LineGuideBottomLeftQuarterSmallCircle_Main	; Line guide, bottom left 1/4 small circle
	dl SMW_ExtendedObj54_LineGuideBottomRightQuarterSmallCircle_Main	; Line guide, bottom right 1/4 small circle
	dl SMW_ExtendedObj55_HorizontalLineGuideEnd_Main	; Line guide end, for horizontal line
	dl SMW_ExtendedObj56_VerticalLineGuideEnd_Main	; Line guide end, for vertical line
	dl SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner_Main	; Switch palace bottom right corner tile
	dl SMW_ExtendedObj58_SwitchPalaceBottomLeftInnerCorner_Main	; Switch palace bottom left corner tile
	dl SMW_ExtendedObj59_SwitchPalaceTopRightInnerCorner_Main	; Switch palace top right corner tile
	dl SMW_ExtendedObj5A_SwitchPalaceTopLeftInnerCorner_Main	; Switch palace top left corner tile
	dl SMW_ExtendedObj5B_BitOfBrickBackground1_Main	; Bit of brick background tile 1
	dl SMW_ExtendedObj5C_BitOfBrickBackground2_Main	; Bit of brick background tile 2
	dl SMW_ExtendedObj5D_BitOfBrickBackground3_Main	; Bit of brick background tile 3
	dl SMW_ExtendedObj5E_BitOfBrickBackground4_Main	; Bit of brick background tile 4
	dl SMW_ExtendedObj5F_LargeBackgroundArea_Main
	dl SMW_ExtendedObj60_CaveLavaInnerCorner_Main	; Lava/mud top right corner edge
	dl SMW_ExtendedObj61_GhostHouseClock_Main
	dl SMW_ExtendedObj62_GhostHouseTopLeftToBottomRightBeam1_Main
	dl SMW_ExtendedObj63_GhostHouseTopRightToBottomLeftBeam1_Main
	dl SMW_ExtendedObj64_TopRightCobweb_Main	; Ghost house cobweb, top right
	dl SMW_ExtendedObj65_TopLeftCobweb_Main	; Ghost house cobweb, top left
	dl SMW_ExtendedObj66_GhostHouseTopRightToBottomLeftBeam2_Main
	dl SMW_ExtendedObj67_GhostHouseTopLeftToBottomRightBeam2_Main
	dl SMW_ExtendedObj68_CloudFringeBottomAndRightEdge_Main
	dl SMW_ExtendedObj69_CloudFringeBottomAndLeftEdge_Main
	dl SMW_ExtendedObj6A_CloudFringeBottomRight_Main
	dl SMW_ExtendedObj6B_CloudFringeBottomLeft_Main
	dl SMW_ExtendedObj6C_CloudFringeOnWhiteBottomAndRightEdge_Main
	dl SMW_ExtendedObj6D_CloudFringeOnWhiteBottomAndLeftEdge_Main
	dl SMW_ExtendedObj6E_CloudFringeOnWhiteBottomRight_Main
	dl SMW_ExtendedObj6F_CloudFringeOnWhiteBottomLeft_Main
	dl SMW_ExtendedObj70_BitOfCanvas1_Main	; Bit of canvass 1
	dl SMW_ExtendedObj71_Canvas1_Main	; Canvass 1
	dl SMW_ExtendedObj72_Canvas2_Main	; Canvass 2
	dl SMW_ExtendedObj73_Canvas3_Main	; Canvass 3
	dl SMW_ExtendedObj74_Canvas4_Main	; Canvass 4
	dl SMW_ExtendedObj75_CanvasTile1_Main	; Canvass tile 1
	dl SMW_ExtendedObj76_CanvasTile2_Main	; Canvass tile 2
	dl SMW_ExtendedObj77_CanvasTile3_Main	; Canvass tile 3
	dl SMW_ExtendedObj78_CanvasTile4_Main	; Canvass tile 4
	dl SMW_ExtendedObj79_CanvasTile5_Main	; Canvass tile 5
	dl SMW_ExtendedObj7A_CanvasTile6_Main	; Canvass tile 6
	dl SMW_ExtendedObj7B_CanvasTile7_Main	; Canvass tile 7
	dl SMW_ExtendedObj7C_BitOfCanvas1_Main	; Bit of canvas 2
	dl SMW_ExtendedObj7D_BitOfCanvas2_Main	; Bit of canvas 3
	dl SMW_ExtendedObj7E_BitOfCanvas3_Main	; Bit of canvas 4
	dl SMW_ExtendedObj7F_TorpedoLauncher_Main
	dl SMW_ExtendedObj80_GhostHouseEntrance_Main
	dl SMW_ExtendedObj81_Seaweed_Main	; Water weed
	dl SMW_ExtendedObj82_BigBush1_Main
	dl SMW_ExtendedObj83_BigBush2_Main
	dl SMW_ExtendedObj84_CastleEntrance_Main
	dl SMW_ExtendedObj85_YoshisHouse_Main
	dl SMW_ExtendedObj86_GoalSign_Main	; Arrow sign
	dl SMW_ExtendedObj87_GreenSwitchBlock_Main	; ! block, green
	dl SMW_ExtendedObj88_RightTreeBranch_Main	; Tree branch, left
	dl SMW_ExtendedObj89_LeftTreeBranch_Main	; Tree branch, right
	dl SMW_ExtendedObj8A_GreenSwitchPalaceSwitch_Main	; Switch, green
	dl SMW_ExtendedObj8B_YellowSwitchPalaceSwitch_Main	; Switch, yellow
	dl SMW_ExtendedObj8C_BlueSwitchPalaceSwitch_Main	; Switch, blue
	dl SMW_ExtendedObj8D_RedSwitchPalaceSwitch_Main	; Switch, red
	dl SMW_ExtendedObj8E_YellowSwitchBlock_Main	; ! block, yellow
	dl SMW_ExtendedObj8F_GhostHouseWindow_Main
	dl SMW_ExtendedObj90_LargeBossDoor_Main
	dl SMW_ExtendedObj91_VerticalLevelSteepLeftSlope_Main	; Steep left slope (vert. lev.)
	dl SMW_ExtendedObj92_VerticalLevelSteepRightSlope_Main	; Steep right slope (vert. lev.)
	dl SMW_ExtendedObj93_VerticalLevelNormalLeftSlope_Main	; Normal left slope (vert. lev.)
	dl SMW_ExtendedObj94_VerticalLevelNormalRightSlope_Main	; Normal right slope (vert. lev.)
	dl SMW_ExtendedObj95_VerticalLevelVerySteepLeftSlope_Main	; Very steep left slope (vert. lev.)
	dl SMW_ExtendedObj96_VerticalLevelVerySteepRightSlope_Main	; Very steep right slope (vert. lev.)
	dl SMW_ExtendedObj97_SwitchPalaceRightAndBottomEdgeTile_Main
	dl SMW_ExtendedObj98_Unused_Main	;\
	dl SMW_ExtendedObj99_Unused_Main	; |
	dl SMW_ExtendedObj9A_Unused_Main	; |
	dl SMW_ExtendedObj9B_Unused_Main	; |
	dl SMW_ExtendedObj9C_Unused_Main	; |
	dl SMW_ExtendedObj9D_Unused_Main	; |
	dl SMW_ExtendedObj9E_Unused_Main	; |
	dl SMW_ExtendedObj9F_Unused_Main	; |
	dl SMW_ExtendedObjA0_Unused_Main	; |
	dl SMW_ExtendedObjA1_Unused_Main	; |
	dl SMW_ExtendedObjA2_Unused_Main	; |
	dl SMW_ExtendedObjA3_Unused_Main	; |
	dl SMW_ExtendedObjA4_Unused_Main	; |
	dl SMW_ExtendedObjA5_Unused_Main	; |
	dl SMW_ExtendedObjA6_Unused_Main	; |
	dl SMW_ExtendedObjA7_Unused_Main	; |
	dl SMW_ExtendedObjA8_Unused_Main	; |
	dl SMW_ExtendedObjA9_Unused_Main	; |
	dl SMW_ExtendedObjAA_Unused_Main	; |
	dl SMW_ExtendedObjAB_Unused_Main	; |
	dl SMW_ExtendedObjAC_Unused_Main	; |
	dl SMW_ExtendedObjAD_Unused_Main	; |
	dl SMW_ExtendedObjAE_Unused_Main	; |
	dl SMW_ExtendedObjAF_Unused_Main	; |
	dl SMW_ExtendedObjB0_Unused_Main	; |
	dl SMW_ExtendedObjB1_Unused_Main	; |
	dl SMW_ExtendedObjB2_Unused_Main	; |
	dl SMW_ExtendedObjB3_Unused_Main	; |
	dl SMW_ExtendedObjB4_Unused_Main	; |
	dl SMW_ExtendedObjB5_Unused_Main	; |
	dl SMW_ExtendedObjB6_Unused_Main	; |
	dl SMW_ExtendedObjB7_Unused_Main	; |
	dl SMW_ExtendedObjB8_Unused_Main	; |
	dl SMW_ExtendedObjB9_Unused_Main	; |
	dl SMW_ExtendedObjBA_Unused_Main	; |
	dl SMW_ExtendedObjBB_Unused_Main	; |
	dl SMW_ExtendedObjBC_Unused_Main	; |
	dl SMW_ExtendedObjBD_Unused_Main	; |
	dl SMW_ExtendedObjBE_Unused_Main	; |
	dl SMW_ExtendedObjBF_Unused_Main	; |
	dl SMW_ExtendedObjC0_Unused_Main	; |
	dl SMW_ExtendedObjC1_Unused_Main	; |
	dl SMW_ExtendedObjC2_Unused_Main	; |
	dl SMW_ExtendedObjC3_Unused_Main	; |
	dl SMW_ExtendedObjC4_Unused_Main	; |
	dl SMW_ExtendedObjC5_Unused_Main	; |
	dl SMW_ExtendedObjC6_Unused_Main	; |
	dl SMW_ExtendedObjC7_Unused_Main	; |
	dl SMW_ExtendedObjC8_Unused_Main	; |
	dl SMW_ExtendedObjC9_Unused_Main	; |
	dl SMW_ExtendedObjCA_Unused_Main	; |
	dl SMW_ExtendedObjCB_Unused_Main	; |
	dl SMW_ExtendedObjCC_Unused_Main	; | Unused (will create two garbage tiles each)
	dl SMW_ExtendedObjCD_Unused_Main	; |
	dl SMW_ExtendedObjCE_Unused_Main	; |
	dl SMW_ExtendedObjCF_Unused_Main	; |
	dl SMW_ExtendedObjD0_Unused_Main	; |
	dl SMW_ExtendedObjD1_Unused_Main	; |
	dl SMW_ExtendedObjD2_Unused_Main	; |
	dl SMW_ExtendedObjD3_Unused_Main	; |
	dl SMW_ExtendedObjD4_Unused_Main	; |
	dl SMW_ExtendedObjD5_Unused_Main	; |
	dl SMW_ExtendedObjD6_Unused_Main	; |
	dl SMW_ExtendedObjD7_Unused_Main	; |
	dl SMW_ExtendedObjD8_Unused_Main	; |
	dl SMW_ExtendedObjD9_Unused_Main	; |
	dl SMW_ExtendedObjDA_Unused_Main	; |
	dl SMW_ExtendedObjDB_Unused_Main	; |
	dl SMW_ExtendedObjDC_Unused_Main	; |
	dl SMW_ExtendedObjDD_Unused_Main	; |
	dl SMW_ExtendedObjDE_Unused_Main	; |
	dl SMW_ExtendedObjDF_Unused_Main	; |
	dl SMW_ExtendedObjE0_Unused_Main	; |
	dl SMW_ExtendedObjE1_Unused_Main	; |
	dl SMW_ExtendedObjE2_Unused_Main	; |
	dl SMW_ExtendedObjE3_Unused_Main	; |
	dl SMW_ExtendedObjE4_Unused_Main	; |
	dl SMW_ExtendedObjE5_Unused_Main	; |
	dl SMW_ExtendedObjE6_Unused_Main	; |
	dl SMW_ExtendedObjE7_Unused_Main	; |
	dl SMW_ExtendedObjE8_Unused_Main	; |
	dl SMW_ExtendedObjE9_Unused_Main	; |
	dl SMW_ExtendedObjEA_Unused_Main	; |
	dl SMW_ExtendedObjEB_Unused_Main	; |
	dl SMW_ExtendedObjEC_Unused_Main	; |
	dl SMW_ExtendedObjED_Unused_Main	; |
	dl SMW_ExtendedObjEE_Unused_Main	; |
	dl SMW_ExtendedObjEF_Unused_Main	; |
	dl SMW_ExtendedObjF0_Unused_Main	; |
	dl SMW_ExtendedObjF1_Unused_Main	; |
	dl SMW_ExtendedObjF2_Unused_Main	; |
	dl SMW_ExtendedObjF3_Unused_Main	; |
	dl SMW_ExtendedObjF4_Unused_Main	; |
	dl SMW_ExtendedObjF5_Unused_Main	; |
	dl SMW_ExtendedObjF6_Unused_Main	; |
	dl SMW_ExtendedObjF7_Unused_Main	; |
	dl SMW_ExtendedObjF8_Unused_Main	; |
	dl SMW_ExtendedObjF9_Unused_Main	; |
	dl SMW_ExtendedObjFA_Unused_Main	; |
	dl SMW_ExtendedObjFB_Unused_Main	; |
	dl SMW_ExtendedObjFC_Unused_Main	; |
	dl SMW_ExtendedObjFD_Unused_Main	; |
	dl SMW_ExtendedObjFE_Unused_Main	; |
	dl SMW_ExtendedObjFF_Unused_Main	;/

namespace off
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj02_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj03_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj04_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj05_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj06_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj07_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj08_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj09_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj0A_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj0B_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj0C_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj0D_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj0E_Unused_Main)
	%SetDuplicateOrNullPointer($000000, SMW_ExtendedObj0F_Unused_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessStandardAndTilesetSpecificObjects(Address)
namespace SMW_ProcessStandardAndTilesetSpecificObjects
%InsertMacroAtXPosition(<Address>)

; The routine that loads normal (i.e. not extended) objects. $0DA41E-$0DA44A
; (45 bytes) are the pointers to the main object routines for each tileset.
; (Even though not all objects are tileset-specific, SMW's code treats them
; as if they all were.)
Main:
	SEP.b #$30				; Optimization: Unecessary SEP.b #$30
	JSR.w Sub			; Call local routine
	RTL

Sub:
	SEP.b #$30				; Optimization: Another unecessary SEP.b #$30
	LDA.w !RAM_SMW_Misc_LevelTilesetSetting	;\
	JSL.l SMW_ExecutePtr_Long	;/ Run one of those codes depending on the tileset (are all objects tileset specific?)

TilesetPtrs:
	dl SMW_ProcessGrasslandObjects_Main	; Tileset 0 (Normal 1)
	dl SMW_ProcessCastleObjects_Main	; Tileset 1 (Castle 1)
	dl SMW_ProcessRopeObjects_Main		; Tileset 2 (Rope 1)
	dl SMW_ProcessUndergroundObjects_Main	; Tileset 3 (Underground 1)
	dl SMW_ProcessGhostHouseObjects_Main	; Tileset 4 (Switch Palace 1)
	dl SMW_ProcessGhostHouseObjects_Main	; Tileset 5 (Ghost House 1)
	dl SMW_ProcessRopeObjects_Main		; Tileset 6 (Rope 2)
	dl SMW_ProcessGrasslandObjects_Main	; Tileset 7 (Normal 2)
	dl SMW_ProcessRopeObjects_Main		; Tileset 8 (Rope 3)
	dl SMW_ProcessUndergroundObjects_Main	; Tileset 9 (Underground 2)
	dl SMW_ProcessUndergroundObjects_Main	; Tileset A (Switch Palace 2)
	dl SMW_ProcessUndergroundObjects_Main	; Tileset B (Castle 2)
	dl SMW_ProcessGrasslandObjects_Main	; Tileset C (Cloud/Forest)
	dl SMW_ProcessGhostHouseObjects_Main	; Tileset D (Ghost House 2)
	dl SMW_ProcessUndergroundObjects_Main	; Tileset E (Underground 3)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessGrasslandObjects(Address)
namespace SMW_ProcessGrasslandObjects
%InsertMacroAtXPosition(<Address>)

Main:
	SEP.b #$30				; Optimization: Unecessary SEP.b #$30
	LDX.b !RAM_SMW_Blocks_ObjectNumber	; Load object number
	DEX				; We'll never see object number 0, so change the index to it won't clutter the table
	TXA				;\
	JSL.l SMW_ExecutePtr_Long	;/ and call the correct subroutine

; Pointers to normal (i.e. not extended) objects, for tilesets 0, 7, and C.
; Object 00 is not included (because normal object 00 is simply *all*
; extended objects); these pointers are for objects 01-3F.
GrasslandPtrs:
	dl SMW_StandardObj01_DarkBlueWater_Main	; Water (Blue)
	dl SMW_StandardObj02_InvisibleCoinBlocks_Main
	dl SMW_StandardObj03_InvisibleNoteBlocks_Main
	dl SMW_StandardObj04_InvisiblePSwitchCoins_Main	; Invisible POW coins
	dl SMW_StandardObj05_Coins_Main
	dl SMW_StandardObj06_WalkThroughDirt_Main
	dl SMW_StandardObj07_VariableColorWater_Main	; Water (Other color)
	dl SMW_StandardObj08_NoteBlocks_Main
	dl SMW_StandardObj09_TurnBlocks_Main
	dl SMW_StandardObj0A_CoinBlocks_Main
	dl SMW_StandardObj0B_ThrowBlocks_Main
	dl SMW_StandardObj0C_Munchers_Main	; Black piranha plants
	dl SMW_StandardObj0D_CementBlocks_Main
	dl SMW_StandardObj0E_UsedBlocks_Main	; Brown blocks
	dl SMW_StandardObj0F_VerticalPipes_Main
	dl SMW_StandardObj10_HorizontalPipes_Main
	dl SMW_StandardObj11_BulletShooter_Main
	dl SMW_StandardObj12_Slopes_Main
	dl SMW_StandardObj13_GroundEdgesAndVine_Main	; Ledge edges
	dl SMW_StandardObj14_Ledge_Main	; Ground ledge
	dl SMW_StandardObj15_MidwayAndGoalPoint_Main	; Midway/Goal point
	dl SMW_StandardObj16_PurpleCoins_Main	; Blue coins
	dl SMW_StandardObj17_RopeAndCloudLine_Main	; Rope/Clouds
	dl SMW_StandardObj18_WaterWithAnimatedSurface_Main	; Water surface (ani)
	dl SMW_StandardObj19_WaterWithNormalSurface_Main	; Water surface (not ani)
	dl SMW_StandardObj1A_CastleLavaWithAnimatedSurface_Main	; Lava surface (ani)
	dl SMW_StandardObj1B_ClimbingNetWithTopEdge_Main	; Net top edge
	dl SMW_StandardObj1C_DonutBridge_Main
	dl SMW_StandardObj1D_ClimbingNetWithBottomEdge_Main	; Net bottom edge
	dl SMW_StandardObj1E_ClimbingNetWithSideEdge_Main	; Net vertical edge
	dl SMW_StandardObj1F_SkinnyVerticalPipeBoneLog_Main	; Vert. Pipe/Bone/Log
	dl SMW_StandardObj20_SkinnyHorizontalPipeBoneLog_Main	; Horiz. Pipe/Bone/Log
	dl SMW_StandardObj21_WideScaleGroundLedge_Main	; Long ground ledge
	dl SMW_StandardObj22_DirectTilePage0_Main					; LM: direct Map16, page 0 ($0DF08A); Config/CustomTiles.asm
	dl SMW_StandardObj23_DirectTilePage1_Main					; LM: direct Map16, page 1 ($0DF08E); Config/CustomTiles.asm
	dl SMW_StandardObj24_Unused_Main					; LM: old GFX list bypass ($0DF0E0)
	dl SMW_StandardObj25_Unused_Main					; LM: old GFX list bypass ($0DF0F0)
	dl SMW_StandardObj26_MusicBypass_Main					; LM: music bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj27_DirectTiles_Main					; LM: direct Map16, pages 00-3F ($0DF150); Config/CustomTiles.asm
	dl SMW_StandardObj28_TimeLimitBypass_Main					; LM: time limit bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj29_DirectTilesHighPages_Main					; LM: direct Map16, pages 40-7F ($0DFF50); Config/CustomTiles.asm
	dl SMW_StandardObj2A_Unused_Main
	dl SMW_StandardObj2B_Unused_Main
	dl SMW_StandardObj2C_Unused_Main
	dl SMW_StandardObj2D_UserDefined_Main
	dl SMW_GrasslandObj2E_Unused_Main	;\
	dl SMW_GrasslandObj2F_Unused_Main	;/ These could've been tileset specific, but Nintendo didn't have that many ideas for them.
	dl SMW_GrasslandObj30_IcyVerticalPipe_Main	; Ice blue vertical pipe
	dl SMW_GrasslandObj31_IcyTurnBlocks_Main	; Ice blue turn tiles
	dl SMW_GrasslandObj32_BlueSwitchBlocks_Main
	dl SMW_GrasslandObj33_ForestTreeTop_Main
	dl SMW_GrasslandObj34_ForestGroundEdges_Main	; Solid left/right and top edge (forest)
	dl SMW_GrasslandObj35_ForestGround_Main	; Ledge (forest)
	dl SMW_GrasslandObj36_LargeTreeTrunk_Main	; Large tree trunk (forest)
	dl SMW_GrasslandObj37_SmallTreeTrunk_Main	; Small tree trunk (forest)
	dl SMW_GrasslandObj38_RedSwitchBlocks_Main
	dl SMW_GrasslandObj39_RightFacingDiagonalPipe_Main
	dl SMW_GrasslandObj3A_LeftFacingDiagonalLedge_Main
	dl SMW_GrasslandObj3B_RightFacingDiagonalLedge_Main
	dl SMW_GrasslandObj3C_ArchLedge_Main
	dl SMW_GrasslandObj3D_TopCloudFridge_Main	; Top cloud fringe
	dl SMW_GrasslandObj3E_SideCloudFridges_Main	; Left/right cloud fringe
	dl SMW_GrasslandObj3F_SmallBushes_Main	; Bushes 1 through 5
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessCastleObjects(Address)
namespace SMW_ProcessCastleObjects
%InsertMacroAtXPosition(<Address>)

Main:
	SEP.b #$30				; Optimization: Unecessary SEP.b #$30
	LDX.b !RAM_SMW_Blocks_ObjectNumber	; Load object number
	DEX				; We'll never see object number 0, so change the index to it won't clutter the table
	TXA				;\
	JSL.l SMW_ExecutePtr_Long	;/ and call the correct subroutine

; Pointers to normal (i.e. not extended) objects, for tileset 1. Object 00
; is not included (because normal object 00 is simply *all* extended
; objects); these pointers are for objects 01-3F.
CastlePtrs:
	dl SMW_StandardObj01_DarkBlueWater_Main	; Water (Blue)
	dl SMW_StandardObj02_InvisibleCoinBlocks_Main
	dl SMW_StandardObj03_InvisibleNoteBlocks_Main
	dl SMW_StandardObj04_InvisiblePSwitchCoins_Main	; Invisible POW coins
	dl SMW_StandardObj05_Coins_Main
	dl SMW_StandardObj06_WalkThroughDirt_Main
	dl SMW_StandardObj07_VariableColorWater_Main	; Water (Other color)
	dl SMW_StandardObj08_NoteBlocks_Main
	dl SMW_StandardObj09_TurnBlocks_Main
	dl SMW_StandardObj0A_CoinBlocks_Main
	dl SMW_StandardObj0B_ThrowBlocks_Main
	dl SMW_StandardObj0C_Munchers_Main	; Black piranha plants
	dl SMW_StandardObj0D_CementBlocks_Main
	dl SMW_StandardObj0E_UsedBlocks_Main	; Brown blocks
	dl SMW_StandardObj0F_VerticalPipes_Main
	dl SMW_StandardObj10_HorizontalPipes_Main
	dl SMW_StandardObj11_BulletShooter_Main
	dl SMW_StandardObj12_Slopes_Main
	dl SMW_StandardObj13_GroundEdgesAndVine_Main	; Ledge edges
	dl SMW_StandardObj14_Ledge_Main	; Ground ledge
	dl SMW_StandardObj15_MidwayAndGoalPoint_Main	; Midway/Goal point
	dl SMW_StandardObj16_PurpleCoins_Main	; Blue coins
	dl SMW_StandardObj17_RopeAndCloudLine_Main	; Rope/Clouds
	dl SMW_StandardObj18_WaterWithAnimatedSurface_Main	; Water surface (ani)
	dl SMW_StandardObj19_WaterWithNormalSurface_Main	; Water surface (not ani)
	dl SMW_StandardObj1A_CastleLavaWithAnimatedSurface_Main	; Lava surface (ani)
	dl SMW_StandardObj1B_ClimbingNetWithTopEdge_Main	; Net top edge
	dl SMW_StandardObj1C_DonutBridge_Main
	dl SMW_StandardObj1D_ClimbingNetWithBottomEdge_Main	; Net bottom edge
	dl SMW_StandardObj1E_ClimbingNetWithSideEdge_Main	; Net vertical edge
	dl SMW_StandardObj1F_SkinnyVerticalPipeBoneLog_Main	; Vert. Pipe/Bone/Log
	dl SMW_StandardObj20_SkinnyHorizontalPipeBoneLog_Main	; Horiz. Pipe/Bone/Log
	dl SMW_StandardObj21_WideScaleGroundLedge_Main	; Long ground ledge
	dl SMW_StandardObj22_DirectTilePage0_Main					; LM: direct Map16, page 0 ($0DF08A); Config/CustomTiles.asm
	dl SMW_StandardObj23_DirectTilePage1_Main					; LM: direct Map16, page 1 ($0DF08E); Config/CustomTiles.asm
	dl SMW_StandardObj24_Unused_Main					; LM: old GFX list bypass ($0DF0E0)
	dl SMW_StandardObj25_Unused_Main					; LM: old GFX list bypass ($0DF0F0)
	dl SMW_StandardObj26_MusicBypass_Main					; LM: music bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj27_DirectTiles_Main					; LM: direct Map16, pages 00-3F ($0DF150); Config/CustomTiles.asm
	dl SMW_StandardObj28_TimeLimitBypass_Main					; LM: time limit bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj29_DirectTilesHighPages_Main					; LM: direct Map16, pages 40-7F ($0DFF50); Config/CustomTiles.asm
	dl SMW_StandardObj2A_Unused_Main
	dl SMW_StandardObj2B_Unused_Main
	dl SMW_StandardObj2C_Unused_Main
	dl SMW_StandardObj2D_UserDefined_Main
	dl SMW_CastleObj2E_Unused_Main	;\
	dl SMW_CastleObj2F_Unused_Main	; |
	dl SMW_CastleObj30_Unused_Main	; |
	dl SMW_CastleObj31_Unused_Main	; | These could've been tileset specific, but Nintendo didn't have that many ideas for them.
	dl SMW_CastleObj32_Unused_Main	; |
	dl SMW_CastleObj33_Unused_Main	;/
	dl SMW_CastleObj34_VerticalDoubleEndedPipe_Main	; Those weird double ended pipes that Mario can walk through the middles of
	dl SMW_CastleObj35_RockWallBackground_Main
	dl SMW_CastleObj36_LargeSpikedPillar_Main	; Large spikes
	dl SMW_CastleObj37_HorizontalLineGuide_Main	; Horizontal line guide lines
	dl SMW_CastleObj38_VerticalLineGuide_Main	; Vertical line guide lines
	dl SMW_CastleObj39_BlueSwitchBlocks_Main
	dl SMW_CastleObj3A_RedSwitchBlocks_Main
	dl SMW_CastleObj3B_GrassLedge_Main
	dl SMW_CastleObj3C_StoneBlock_Main	; Stone block wall
	dl SMW_CastleObj3D_Escalator_Main	; Conveyors
	dl SMW_CastleObj3E_HorizontalLineOfSpikes_Main	; Horizontal rows of spikes
	dl SMW_CastleObj3F_VerticalLineOfSpikes_Main	; Vertical rows of spikes / vertical columns
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessRopeObjects(Address)
namespace SMW_ProcessRopeObjects
%InsertMacroAtXPosition(<Address>)

Main:
	SEP.b #$30				; Optimization: Unecessary SEP.b #$30
	LDX.b !RAM_SMW_Blocks_ObjectNumber	; Load object number
	DEX				; We'll never see object number 0, so change the index to it won't clutter the table
	TXA				;\
	JSL.l SMW_ExecutePtr_Long	;/ and call the correct subroutine

; Pointers to normal (i.e. not extended) objects, for tilesets 2, 6, and 8.
; Object 00 is not included (because normal object 00 is simply *all*
; extended objects); these pointers are for objects 01-3F.
RopePtrs:
	dl SMW_StandardObj01_DarkBlueWater_Main	; Water (Blue)
	dl SMW_StandardObj02_InvisibleCoinBlocks_Main
	dl SMW_StandardObj03_InvisibleNoteBlocks_Main
	dl SMW_StandardObj04_InvisiblePSwitchCoins_Main	; Invisible POW coins
	dl SMW_StandardObj05_Coins_Main
	dl SMW_StandardObj06_WalkThroughDirt_Main
	dl SMW_StandardObj07_VariableColorWater_Main	; Water (Other color)
	dl SMW_StandardObj08_NoteBlocks_Main
	dl SMW_StandardObj09_TurnBlocks_Main
	dl SMW_StandardObj0A_CoinBlocks_Main
	dl SMW_StandardObj0B_ThrowBlocks_Main
	dl SMW_StandardObj0C_Munchers_Main	; Black piranha plants
	dl SMW_StandardObj0D_CementBlocks_Main
	dl SMW_StandardObj0E_UsedBlocks_Main	; Brown blocks
	dl SMW_StandardObj0F_VerticalPipes_Main
	dl SMW_StandardObj10_HorizontalPipes_Main
	dl SMW_StandardObj11_BulletShooter_Main
	dl SMW_StandardObj12_Slopes_Main
	dl SMW_StandardObj13_GroundEdgesAndVine_Main	; Ledge edges
	dl SMW_StandardObj14_Ledge_Main	; Ground ledge
	dl SMW_StandardObj15_MidwayAndGoalPoint_Main	; Midway/Goal point
	dl SMW_StandardObj16_PurpleCoins_Main	; Blue coins
	dl SMW_StandardObj17_RopeAndCloudLine_Main	; Rope/Clouds
	dl SMW_StandardObj18_WaterWithAnimatedSurface_Main	; Water surface (ani)
	dl SMW_StandardObj19_WaterWithNormalSurface_Main	; Water surface (not ani)
	dl SMW_StandardObj1A_CastleLavaWithAnimatedSurface_Main	; Lava surface (ani)
	dl SMW_StandardObj1B_ClimbingNetWithTopEdge_Main	; Net top edge
	dl SMW_StandardObj1C_DonutBridge_Main
	dl SMW_StandardObj1D_ClimbingNetWithBottomEdge_Main	; Net bottom edge
	dl SMW_StandardObj1E_ClimbingNetWithSideEdge_Main	; Net vertical edge
	dl SMW_StandardObj1F_SkinnyVerticalPipeBoneLog_Main	; Vert. Pipe/Bone/Log
	dl SMW_StandardObj20_SkinnyHorizontalPipeBoneLog_Main	; Horiz. Pipe/Bone/Log
	dl SMW_StandardObj21_WideScaleGroundLedge_Main	; Long ground ledge
	dl SMW_StandardObj22_DirectTilePage0_Main					; LM: direct Map16, page 0 ($0DF08A); Config/CustomTiles.asm
	dl SMW_StandardObj23_DirectTilePage1_Main					; LM: direct Map16, page 1 ($0DF08E); Config/CustomTiles.asm
	dl SMW_StandardObj24_Unused_Main					; LM: old GFX list bypass ($0DF0E0)
	dl SMW_StandardObj25_Unused_Main					; LM: old GFX list bypass ($0DF0F0)
	dl SMW_StandardObj26_MusicBypass_Main					; LM: music bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj27_DirectTiles_Main					; LM: direct Map16, pages 00-3F ($0DF150); Config/CustomTiles.asm
	dl SMW_StandardObj28_TimeLimitBypass_Main					; LM: time limit bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj29_DirectTilesHighPages_Main					; LM: direct Map16, pages 40-7F ($0DFF50); Config/CustomTiles.asm
	dl SMW_StandardObj2A_Unused_Main
	dl SMW_StandardObj2B_Unused_Main
	dl SMW_StandardObj2C_Unused_Main
	dl SMW_StandardObj2D_UserDefined_Main
	dl SMW_RopeObj2E_Unused_Main	;\
	dl SMW_RopeObj2F_Unused_Main	; |
	dl SMW_RopeObj30_Unused_Main	; | These could've been tileset specific, but Nintendo didn't have that many ideas for them.
	dl SMW_RopeObj31_Unused_Main	;/
	dl SMW_RopeObj32_LogBridge_Main
	dl SMW_RopeObj33_BlueSwitchBlocks_Main
	dl SMW_RopeObj34_RedSwitchBlocks_Main
	dl SMW_RopeObj35_ColumnWithPlantOnTop_Main	; Plants on columns
	dl SMW_RopeObj36_HorizontalConveyorRope_Main	; Horizontal conveyors
	dl SMW_RopeObj37_SlopedConveyorRope_Main	; Diagonal conveyors
	dl SMW_RopeObj38_HorizontalLineGuide_Main	; Horizontal guide lines
	dl SMW_RopeObj39_VerticalLineGuideAndMushroomStalk_Main	; Vertical guide lines / vertical column
	dl SMW_RopeObj3A_SlopedLineGuide_Main	; Normal/steep/ON/OFF guide lines
	dl SMW_RopeObj3B_VerySteepSlopedLineGuide_Main	; Very steep guide lines
	dl SMW_RopeObj3C_MushroomTop_Main	; Mushroom ledge
	dl SMW_RopeObj3D_MushroomColumn_Main
	dl SMW_RopeObj3E_HorizontalLog_Main
	dl SMW_RopeObj3F_VerticalLog_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessUndergroundObjects(Address)
namespace SMW_ProcessUndergroundObjects
%InsertMacroAtXPosition(<Address>)

Main:
	SEP.b #$30				; Optimization: Unecessary SEP.b #$30
	LDX.b !RAM_SMW_Blocks_ObjectNumber	; Load object number
	DEX				; We'll never see object number 0, so change the index to it won't clutter the table
	TXA				;\
	JSL.l SMW_ExecutePtr_Long	;/ and call the correct subroutine

; Pointers to normal (i.e. not extended) objects, for tilesets 3, 9, A, B,
; and E. Object 00 is not included (because normal object 00 is simply *all*
; extended objects); these pointers are for objects 01-3F.
UndergroundPtrs:
	dl SMW_StandardObj01_DarkBlueWater_Main	; Water (Blue)
	dl SMW_StandardObj02_InvisibleCoinBlocks_Main
	dl SMW_StandardObj03_InvisibleNoteBlocks_Main
	dl SMW_StandardObj04_InvisiblePSwitchCoins_Main	; Invisible POW coins
	dl SMW_StandardObj05_Coins_Main
	dl SMW_StandardObj06_WalkThroughDirt_Main
	dl SMW_StandardObj07_VariableColorWater_Main	; Water (Other color)
	dl SMW_StandardObj08_NoteBlocks_Main
	dl SMW_StandardObj09_TurnBlocks_Main
	dl SMW_StandardObj0A_CoinBlocks_Main
	dl SMW_StandardObj0B_ThrowBlocks_Main
	dl SMW_StandardObj0C_Munchers_Main	; Black piranha plants
	dl SMW_StandardObj0D_CementBlocks_Main
	dl SMW_StandardObj0E_UsedBlocks_Main	; Brown blocks
	dl SMW_StandardObj0F_VerticalPipes_Main
	dl SMW_StandardObj10_HorizontalPipes_Main
	dl SMW_StandardObj11_BulletShooter_Main
	dl SMW_StandardObj12_Slopes_Main
	dl SMW_StandardObj13_GroundEdgesAndVine_Main	; Ledge edges
	dl SMW_StandardObj14_Ledge_Main	; Ground ledge
	dl SMW_StandardObj15_MidwayAndGoalPoint_Main	; Midway/Goal point
	dl SMW_StandardObj16_PurpleCoins_Main	; Blue coins
	dl SMW_StandardObj17_RopeAndCloudLine_Main	; Rope/Clouds
	dl SMW_StandardObj18_WaterWithAnimatedSurface_Main	; Water surface (ani)
	dl SMW_StandardObj19_WaterWithNormalSurface_Main	; Water surface (not ani)
	dl SMW_StandardObj1A_CastleLavaWithAnimatedSurface_Main	; Lava surface (ani)
	dl SMW_StandardObj1B_ClimbingNetWithTopEdge_Main	; Net top edge
	dl SMW_StandardObj1C_DonutBridge_Main
	dl SMW_StandardObj1D_ClimbingNetWithBottomEdge_Main	; Net bottom edge
	dl SMW_StandardObj1E_ClimbingNetWithSideEdge_Main	; Net vertical edge
	dl SMW_StandardObj1F_SkinnyVerticalPipeBoneLog_Main	; Vert. Pipe/Bone/Log
	dl SMW_StandardObj20_SkinnyHorizontalPipeBoneLog_Main	; Horiz. Pipe/Bone/Log
	dl SMW_StandardObj21_WideScaleGroundLedge_Main	; Long ground ledge
	dl SMW_StandardObj22_DirectTilePage0_Main					; LM: direct Map16, page 0 ($0DF08A); Config/CustomTiles.asm
	dl SMW_StandardObj23_DirectTilePage1_Main					; LM: direct Map16, page 1 ($0DF08E); Config/CustomTiles.asm
	dl SMW_StandardObj24_Unused_Main					; LM: old GFX list bypass ($0DF0E0)
	dl SMW_StandardObj25_Unused_Main					; LM: old GFX list bypass ($0DF0F0)
	dl SMW_StandardObj26_MusicBypass_Main					; LM: music bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj27_DirectTiles_Main					; LM: direct Map16, pages 00-3F ($0DF150); Config/CustomTiles.asm
	dl SMW_StandardObj28_TimeLimitBypass_Main					; LM: time limit bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj29_DirectTilesHighPages_Main					; LM: direct Map16, pages 40-7F ($0DFF50); Config/CustomTiles.asm
	dl SMW_StandardObj2A_Unused_Main
	dl SMW_StandardObj2B_Unused_Main
	dl SMW_StandardObj2C_Unused_Main
	dl SMW_StandardObj2D_UserDefined_Main
	dl SMW_UndergroundObj2E_Unused_Main	;\
	dl SMW_UndergroundObj2F_Unused_Main	; |
	dl SMW_UndergroundObj30_Unused_Main	; |
	dl SMW_UndergroundObj31_Unused_Main	; | These could've been tileset specific, but Nintendo didn't have that many ideas for them.
	dl SMW_UndergroundObj32_Unused_Main	; |
	dl SMW_UndergroundObj33_Unused_Main	;/
	dl SMW_UndergroundObj34_BlueSwitchBlocks_Main
	dl SMW_UndergroundObj35_RedSwitchBlocks_Main
	dl SMW_UndergroundObj36_4SidedGround_Main	; Four-sided edge ground square
	dl SMW_UndergroundObj37_LargeCanvas_Main	; Multiple canvasses (position hardcoded)
	dl SMW_UndergroundObj38_RightLavaEdge_Main	; Right facing mud/lava
	dl SMW_UndergroundObj39_SlopedCaveLava_Main	; Mud/lava slopes
	dl SMW_UndergroundObj3A_CaveLavaWithTop_Main	; Mud/lava with top
	dl SMW_UndergroundObj3B_CaveLava_Main	; Mud/lava tiles
	dl SMW_UndergroundObj3C_VerySteepSlope_Main	; Very steep slopes
	dl SMW_UndergroundObj3D_CeilingLedge_Main	; Upside down ledge
	dl SMW_UndergroundObj3E_CeilingEdges_Main	; Solid edges / solid edges with bottoms
	dl SMW_UndergroundObj3F_SolidDirt_Main
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ProcessGhostHouseObjects(Address)
namespace SMW_ProcessGhostHouseObjects
%InsertMacroAtXPosition(<Address>)

Main:
	SEP.b #$30				; Optimization: Unecessary SEP.b #$30
	LDX.b !RAM_SMW_Blocks_ObjectNumber	; Load object number
	DEX				; We'll never see object number 0, so change the index to it won't clutter the table
	TXA				;\
	JSL.l SMW_ExecutePtr_Long	;/ and call the correct subroutine

; Pointers to normal (i.e. not extended) objects, for tilesets 4, 5, and D.
; Object 00 is not included (because normal object 00 is simply *all*
; extended objects); these pointers are for objects 01-3F.
GhostHousePtrs:
	dl SMW_StandardObj01_DarkBlueWater_Main	; Water (Blue)
	dl SMW_StandardObj02_InvisibleCoinBlocks_Main
	dl SMW_StandardObj03_InvisibleNoteBlocks_Main
	dl SMW_StandardObj04_InvisiblePSwitchCoins_Main	; Invisible POW coins
	dl SMW_StandardObj05_Coins_Main
	dl SMW_StandardObj06_WalkThroughDirt_Main
	dl SMW_StandardObj07_VariableColorWater_Main	; Water (Other color)
	dl SMW_StandardObj08_NoteBlocks_Main
	dl SMW_StandardObj09_TurnBlocks_Main
	dl SMW_StandardObj0A_CoinBlocks_Main
	dl SMW_StandardObj0B_ThrowBlocks_Main
	dl SMW_StandardObj0C_Munchers_Main	; Black piranha plants
	dl SMW_StandardObj0D_CementBlocks_Main
	dl SMW_StandardObj0E_UsedBlocks_Main	; Brown blocks
	dl SMW_StandardObj0F_VerticalPipes_Main
	dl SMW_StandardObj10_HorizontalPipes_Main
	dl SMW_StandardObj11_BulletShooter_Main
	dl SMW_StandardObj12_Slopes_Main
	dl SMW_StandardObj13_GroundEdgesAndVine_Main	; Ledge edges
	dl SMW_StandardObj14_Ledge_Main	; Ground ledge
	dl SMW_StandardObj15_MidwayAndGoalPoint_Main	; Midway/Goal point
	dl SMW_StandardObj16_PurpleCoins_Main	; Blue coins
	dl SMW_StandardObj17_RopeAndCloudLine_Main	; Rope/Clouds
	dl SMW_StandardObj18_WaterWithAnimatedSurface_Main	; Water surface (ani)
	dl SMW_StandardObj19_WaterWithNormalSurface_Main	; Water surface (not ani)
	dl SMW_StandardObj1A_CastleLavaWithAnimatedSurface_Main	; Lava surface (ani)
	dl SMW_StandardObj1B_ClimbingNetWithTopEdge_Main	; Net top edge
	dl SMW_StandardObj1C_DonutBridge_Main
	dl SMW_StandardObj1D_ClimbingNetWithBottomEdge_Main	; Net bottom edge
	dl SMW_StandardObj1E_ClimbingNetWithSideEdge_Main	; Net vertical edge
	dl SMW_StandardObj1F_SkinnyVerticalPipeBoneLog_Main	; Vert. Pipe/Bone/Log
	dl SMW_StandardObj20_SkinnyHorizontalPipeBoneLog_Main	; Horiz. Pipe/Bone/Log
	dl SMW_StandardObj21_WideScaleGroundLedge_Main	; Long ground ledge
	dl SMW_StandardObj22_DirectTilePage0_Main					; LM: direct Map16, page 0 ($0DF08A); Config/CustomTiles.asm
	dl SMW_StandardObj23_DirectTilePage1_Main					; LM: direct Map16, page 1 ($0DF08E); Config/CustomTiles.asm
	dl SMW_StandardObj24_Unused_Main					; LM: old GFX list bypass ($0DF0E0)
	dl SMW_StandardObj25_Unused_Main					; LM: old GFX list bypass ($0DF0F0)
	dl SMW_StandardObj26_MusicBypass_Main					; LM: music bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj27_DirectTiles_Main					; LM: direct Map16, pages 00-3F ($0DF150); Config/CustomTiles.asm
	dl SMW_StandardObj28_TimeLimitBypass_Main					; LM: time limit bypass; Config/HeaderBypasses.asm
	dl SMW_StandardObj29_DirectTilesHighPages_Main					; LM: direct Map16, pages 40-7F ($0DFF50); Config/CustomTiles.asm
	dl SMW_StandardObj2A_Unused_Main
	dl SMW_StandardObj2B_Unused_Main
	dl SMW_StandardObj2C_Unused_Main
	dl SMW_StandardObj2D_UserDefined_Main
	dl SMW_GhostHouseObj2E_HorizontalLineOfSpikes_Main	; Thin horizontal upward spikes
	dl SMW_GhostHouseObj2F_LogBackground_Main
	dl SMW_GhostHouseObj30_GrassLedge1_Main
	dl SMW_GhostHouseObj31_WoodCrate_Main	; Wooden crate
	dl SMW_GhostHouseObj32_GrassLedge2_Main
	dl SMW_GhostHouseObj33_Cloud_Main	; Cloud ledge (I wonder why it's called "ledge" when you can't stand on it)
	dl SMW_GhostHouseObj34_WoodLedgeOnColumn_Main
	dl SMW_GhostHouseObj35_BrickBackground_Main	; Grey bricks background
	dl SMW_GhostHouseObj36_WoodenBlocks_Main
	dl SMW_GhostHouseObj37_HorizontalBackgroundLogAndRailing_Main	; Horizontal log background and hand rails
	dl SMW_GhostHouseObj38_WoodenLedge_Main	; Wood ledge without column
	dl SMW_GhostHouseObj39_VerticalBackgroundLog_Main	; Some vertical log backgrounds
	dl SMW_GhostHouseObj3A_SolidBrickWallAndVerticalLineOfSpikes_Main	; Solid vertical brick edges, vertical rows of spikes, and some likely unused things
	dl SMW_GhostHouseObj3B_BonusGameLedge_Main	; Another ledge (the wood thingies seen in the bonus rooms, like level FD)
	dl SMW_GhostHouseObj3C_SwitchPalaceCeiling_Main	; Upside down ledge (switch palace)
	dl SMW_GhostHouseObj3D_SwitchPalaceLedge_Main	; Ledge (switch palace)
	dl SMW_GhostHouseObj3E_SwitchPalaceRightFacingWall_Main	; Right facing edge (switch palace)
	dl SMW_GhostHouseObj3F_SwitchPalaceLeftFacingWall_Main	; Left facing edge (switch palace)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_Map16Data(Address)
namespace SMW_Map16Data
%InsertMacroAtXPosition(<Address>)

; Every Map16 table is 8 bytes per tile -- four SNES tilemap entries, upper
; left, lower left, upper right, lower right, in TTTTTTTT YXPCCCTT format. One
; file per table; see GFX/Map16/README.md.
Main:
Global:							;\ Note: These are the map16 tiles that are always the same regardless of tileset, with the exception of 1C4-1C7 and 1EC-1EF
	incbin "GFX/Map16/Global.bin"			;| Tiles 000-072, 100-106, 111-132
							;|
GreenPipes:						;|
	incbin "GFX/Map16/GreenPipes.bin"		;| Tiles 133-13A
Global2:						;|
	incbin "GFX/Map16/Global2.bin"			;/ Tiles 13B-152, 16E-1FF

SlopedPipeTiles:
;$0D8A70
	; Tiles 1C4-1C7 and 1EC-1EF. Only used in GFX header 0 and 7.
	incbin "GFX/Map16/SlopedPipeTiles.bin"

VariableColorPipes:
;$0D8AB0
	; The Map16 tiles used by multicolour pipes, besides the default green pipe.
	incbin "GFX/Map16/VariableColorPipes.bin"

YellowPipes:
;$0D8AF0
	incbin "GFX/Map16/YellowPipes.bin"

PurplePipes:
;$0D8B30
	incbin "GFX/Map16/PurplePipes.bin"

; Tiles 073-0FF, 107-110 and 153-16D, used by tilesets 0, 7 and 12.
Grassland:
	incbin "GFX/Map16/Grassland.bin"

Backgrounds:
;$0D9100
	; Background Map16 tiles (pages 0x80 and 0x81 in LM).
	incbin "GFX/Map16/Backgrounds.bin"
namespace off
endmacro

macro DATATABLE_RT01_SMW_Map16Data(Address)
namespace SMW_Map16Data
%InsertMacroAtXPosition(<Address>)

; Tiles 073-0FF, 107-110 and 153-16D, used by tileset 1 only. PAL rev 1 ships
; its own 073-0FF -- two tiles of it differ -- and the same 107-16D as everyone
; else, which is why this table is the one split in two.
Castle:
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	incbin "GFX/Map16/Castle_PALRev1.bin"		; Tiles 073-0FF
else
	incbin "GFX/Map16/Castle.bin"			; Tiles 073-0FF
endif
	incbin "GFX/Map16/Castle_Rest.bin"		; Tiles 107-110, 153-16D
namespace off
endmacro

macro DATATABLE_RT02_SMW_Map16Data(Address)
namespace SMW_Map16Data
%InsertMacroAtXPosition(<Address>)

; Tiles 073-0FF, 107-110 and 153-16D, used by tilesets 2, 6 and 8.
Rope:
	incbin "GFX/Map16/Rope.bin"
namespace off
endmacro

macro DATATABLE_RT03_SMW_Map16Data(Address)
namespace SMW_Map16Data
%InsertMacroAtXPosition(<Address>)

; Tiles 073-0FF, 107-110 and 153-16D, used by tilesets 3, 9, 10, 11 and 14.
Underground:
	incbin "GFX/Map16/Underground.bin"
namespace off
endmacro

macro DATATABLE_RT04_SMW_Map16Data(Address)
namespace SMW_Map16Data
%InsertMacroAtXPosition(<Address>)

; Tiles 073-0FF, 107-110 and 153-16D, used by tilesets 4, 5 and 13.
GhostHouse:
	incbin "GFX/Map16/GhostHouse.bin"
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects(Address)
namespace SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataLo		;\ LM: This routine is rewritten to account for custom level dimensions (3.00+)
	SEC							;|
	SBC.b #$B0						;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo		;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo		;|
	STA.b !RAM_SMW_Misc_ScratchRAM04			;|
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi		;|
	SBC.b #$01						;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi		;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi		;|
	STA.b !RAM_SMW_Misc_ScratchRAM05			;|
	DEC.w !RAM_SMW_Blocks_ScreenToPlaceNextObject		;|
	RTS							;/
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects(Address)
namespace SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataLo		;\ LM: This routine is rewritten to account for custom level dimensions (3.00+)
	CLC							;|
	ADC.b #$B0						;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo		;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo		;|
	STA.b !RAM_SMW_Misc_ScratchRAM04			;|
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi		;|
	ADC.b #$01						;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi		;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi		;|
	STA.b !RAM_SMW_Misc_ScratchRAM05			;|
	INC.w !RAM_SMW_Blocks_ScreenToPlaceNextObject		;|
	RTS							;/
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GoDownLeftAndUpdateLevelDataPointerInObjects(Address)
namespace SMW_GoDownLeftAndUpdateLevelDataPointerInObjects
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$0F			; | Move index a bit
	TAY				;/
	BCC.b CODE_0DA99D		; Check if we hit a horizontal subscreen boundary
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	; Move pointer down if needed
CODE_0DA99D:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$0F			; | Check if we hit a vertical subscreen boundary
	BNE.b CODE_0DA9B1		;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; | Move index down
	TAY				;/
	BCC.b CODE_0DA9AE		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer down if needed
CODE_0DA9AE:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer leftwards
CODE_0DA9B1:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GoDownRightAndUpdateLevelDataPointerInObjects(Address)
namespace SMW_GoDownRightAndUpdateLevelDataPointerInObjects
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$11			; | Move index a bit
	TAY				;/
	BCC.b CODE_0DA9BF		; Check if we hit a horizontal subscreen boundary
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	; Move pointer down if needed
CODE_0DA9BF:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$01			; | Check if we hit a vertical subscreen boundary
	BPL.b CODE_0DA9D3		;/
	TYA				;\
	SEC				; |
	SBC.b #$10			; | Move index back up
	TAY				;/
	BCS.b CODE_0DA9D0		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Update preserved pointer? Waste of time since $0DA9EF does this anyways.
CODE_0DA9D0:
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer rightwards
CODE_0DA9D3:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_RT00_SMW_BitTable(Address)
namespace SMW_BitTable
%InsertMacroAtXPosition(<Address>)

; Bitmasking table. Contains the values $80,$40,$20,$10,$08,$04,$02,$01 So
; masking can be simply done by AND.l $0DA8A6,x
Bank0D:
	db $80,$40,$20,$10,$08,$04,$02,$01	; Useful table if you want tables of one bit/e.g. level instead of one byte/level, but why repeat it this much?
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_Bank0DItemMemoryIndexes(Address)
namespace SMW_Bank0DItemMemoryIndexes
%InsertMacroAtXPosition(<Address>)

Lo:
	db !RAM_SMW_Misc_ItemMemory0Bits-!RAM_SMW_Misc_ItemMemoryBits	; Low bytes of offsets to sprite memory table
	db !RAM_SMW_Misc_ItemMemory1Bits-!RAM_SMW_Misc_ItemMemoryBits
	db !RAM_SMW_Misc_ItemMemory2Bits-!RAM_SMW_Misc_ItemMemoryBits

Hi:
	db (!RAM_SMW_Misc_ItemMemory0Bits-!RAM_SMW_Misc_ItemMemoryBits)>>8	; High bytes of offsets to sprite memory table
	db (!RAM_SMW_Misc_ItemMemory1Bits-!RAM_SMW_Misc_ItemMemoryBits)>>8
	db (!RAM_SMW_Misc_ItemMemory2Bits-!RAM_SMW_Misc_ItemMemoryBits)>>8
namespace off
endmacro

;---------------------------------------------------------------------------

macro DATATABLE_SMW_CreditsEnemyNames(Address)
namespace SMW_CreditsEnemyNames
%InsertMacroAtXPosition(<Address>)

cleartable
incsrc "tables/fonts/AllUppercase.asm"

Main:
Screen01:
if ver_is_japanese(!Define_Global_ROMToAssemble)
	incbin "images/ending/1/layer3.bin"
	%StripeImageHeader(.FishinLakitu, $11, $03, 0, $0000, 3)
	dw "FISHING JUGEM"
.FishinLakituEnd:
	%StripeImageHeader(.ParaBomb, $02, $04, 0, $0000, 3)
	dw "PARA BOM"
.ParaBombEnd:
	%StripeImageHeader(.ParaGoomba, $07, $0B, 0, $0000, 3)
	dw "PARA KURI"
.ParaGoombaEnd:
	%StripeImageHeader(.Lakitu, $13, $0D, 0, $0000, 3)
	dw "JUGEM"
.LakituEnd:
	%StripeImageHeader(.Spiny, $07, $11, 0, $0000, 3)
	dw "TOGEZO"
.SpinyEnd:
	%StripeImageHeader(.Wiggler, $13, $14, 0, $0000, 3)
	dw "HANACHAN"
.WigglerEnd:
	%StripeImageHeader(.BobOmb, $0E, $19, 0, $0000, 3)
	dw "BOMHEI"
.BobOmbEnd:
	db $FF

Screen02:
	incbin "images/ending/2/layer3.bin"
	%StripeImageHeader(.HammerBrother, $05, $04, 0, $0000, 3)
	dw "APPARE"
.HammerBrotherEnd:
	%StripeImageHeader(.SuperKoopa, $15, $08, 0, $0000, 3)
	dw "MANTOGAME"
.SuperKoopaEnd:
	%StripeImageHeader(.Chuck, $18, $12, 0, $0000, 3)
	dw "BUL"
.ChuckEnd:
	%StripeImageHeader(.PirhanaPlant, $04, $16, 0, $0000, 3)
	dw "P-PAKKUN"
.PirhanaPlantEnd:
	%StripeImageHeader(.Lotus, $10, $19, 0, $0000, 3)
	dw "PONKEY"
.LotusEnd:
	db $FF

Screen03:
	incbin "images/ending/3/layer3.bin"
	%StripeImageHeader(.SumoBrother, $07, $04, 0, $0000, 3)
	dw "K"
	dw $2824		;\ Green "."
	dw "K"			;|
	dw $2824		;/
.SumoBrotherEnd:
	%StripeImageHeader(.MontyMole, $17, $07, 0, $0000, 3)
	dw "CHOROPOO"
.MontyMoleEnd:
	%StripeImageHeader(.Pokey, $0F, $0E, 0, $0000, 3)
	dw "SANBO"
.PokeyEnd:
	%StripeImageHeader(.BulletBill, $12, $19, 0, $0000, 3)
	dw "KILLER"
.BulletBillEnd:
	db $FF

Screen04:
	incbin "images/ending/4/layer3.bin"
	%StripeImageHeader(.Rex, $11, $08, 0, $0000, 3)
	dw "DORABON"
.RexEnd:
	%StripeImageHeader(.MegaMole, $03, $0F, 0, $0000, 3)
	dw "INDY"
.MegaMoleEnd:
	%StripeImageHeader(.BanzaiBill, $11, $18, 0, $0000, 3)
	dw "MAGNUM KILLER"
.BanzaiBillEnd:
	db $FF

Screen05:
	incbin "images/ending/5/layer3.bin"
	%StripeImageHeader(.DinoRhino, $05, $06, 0, $0000, 3)
	dw "RAITA"
.DinoRhinoEnd:
	%StripeImageHeader(.DinoTorch, $0E, $0C, 0, $0000, 3)
	dw "CHIBI RAITA"
.DinoTorchEnd:
	%StripeImageHeader(.Koopas, $0E, $13, 0, $0000, 3)
	dw "NOKO NOKO"
.KoopasEnd:
	db $FF

Screen06:
	incbin "images/ending/6/layer3.bin"
	%StripeImageHeader(.SpikeTop, $02, $05, 0, $0000, 3)
	dw "TOGEMET"
.SpikeTopEnd:
	%StripeImageHeader(.Swooper, $12, $05, 0, $0000, 3)
	dw "BASA BASA"
.SwooperEnd:
	%StripeImageHeader(.BuzzyBeetle, $07, $11, 0, $0000, 3)
	dw "MET"
.BuzzyBeetleEnd:
	%StripeImageHeader(.Blargg, $13, $13, 0, $0000, 3)
	dw "UNBABA"
.BlarggEnd:
	db $FF

Screen07:
	incbin "images/ending/7/layer3.bin"
	%StripeImageHeader(.Blurp, $03, $04, 0, $0000, 3)
	dw "BUKU BUKU"
.BlurpEnd:
	%StripeImageHeader(.Urchin, $17, $07, 0, $0000, 3)
	dw "UNIRA"
.UrchinEnd:
	%StripeImageHeader(.PorcuPuffer, $08, $0D, 0, $0000, 3)
	dw "FUGUMANNEN"
.PorcuPufferEnd:
	%StripeImageHeader(.TorpedoTed, $15, $13, 0, $0000, 3)
	dw "TORPEDO"
.TorpedoTedEnd:
	%StripeImageHeader(.RipVanFish, $02, $19, 0, $0000, 3)
	dw "  GOOSKA   "
.RipVanFishEnd:
	db $FF

Screen08:
	incbin "images/ending/8/layer3.bin"
	%StripeImageHeader(.FishinBoo, $14, $06, 0, $0000, 3)
	dw "SPOOK"
.FishinBooEnd:
	%StripeImageHeader(.BooBuddies, $03, $07, 0, $0000, 3)
	dw "TELESA"
.BooBuddiesEnd:
	%StripeImageHeader(.BigBoo, $02, $10, 0, $0000, 3)
	dw "ATOMIC TELESA"
.BigBooEnd:
	%StripeImageHeader(.Eeries, $14, $15, 0, $0000, 3)
	dw "TELESAULS"
.EeriesEnd:
	db $FF

Screen09:
	incbin "images/ending/9/layer3.bin"
	%StripeImageHeader(.Sparky, $0C, $03, 0, $0000, 3)
	dw "KESERAN"
.SparkyEnd:
	%StripeImageHeader(.BonyBeetle, $13, $07, 0, $0000, 3)
	dw "HONE MET"
.BonyBeetleEnd:
	%StripeImageHeader(.DryBones, $04, $09, 0, $0000, 3)
	dw "KARON"
.DryBonesEnd:
	%StripeImageHeader(.Thwomp, $0F, $12, 0, $0000, 3)
	dw "DOSUN"
.ThwompEnd:
	%StripeImageHeader(.Thwimp, $16, $15, 0, $0000, 3)
	dw "COTON"
.ThwimpEnd:
	%StripeImageHeader(.Hothead, $08, $17, 0, $0000, 3)
	dw "PASARAN"
.HotheadEnd:
	db $FF

Screen10:
	incbin "images/ending/10/layer3.bin"
	%StripeImageHeader(.Grinder, $10, $04, 0, $0000, 3)
	dw "GARI GARI"
.GrinderEnd:
	%StripeImageHeader(.BallNChain, $07, $0D, 0, $0000, 3)
	dw "GURU GURU"
.BallNChainEnd:
	%StripeImageHeader(.Fishbone, $0D, $12, 0, $0000, 3)
	dw "FISH BONE"
.FishboneEnd:
	db $FF

Screen11:
	incbin "images/ending/11/layer3.bin"
	%StripeImageHeader(.Reznor, $0D, $0C, 0, $0000, 3)
	dw "BUIBUI"
.ReznorEnd:
	db $FF

Screen12:
	incbin "images/ending/12/layer3.bin"
	%StripeImageHeader(.MechaKoopa, $0B, $0C, 0, $0000, 3)
	dw "MEKA KOOPA"
.MechaKoopaEnd:
	db $FF

Screen13:
	incbin "images/ending/13/layer3.bin"
	%StripeImageHeader(.Morton, $05, $09, 0, $0000, 3)
	dw "MORTON"
.MortonEnd:
	%StripeImageHeader(.Roy, $17, $09, 0, $0000, 3)
	dw "ROY"
.RoyEnd:
	%StripeImageHeader(.Bowser, $0E, $10, 0, $0000, 3)
	dw "KOOPA"
.BowserEnd:
	%StripeImageHeader(.Lemmy, $03, $12, 0, $0000, 3)
	dw "LEMMY"
.LemmyEnd:
	%StripeImageHeader(.Wendy, $19, $12, 0, $0000, 3)
	dw "WENDY"
.WendyEnd:
	%StripeImageHeader(.Iggy, $05, $18, 0, $0000, 3)
	dw "IGGY"
.IggyEnd:
	%StripeImageHeader(.Larry, $17, $18, 0, $0000, 3)
	dw "LARRY"
.LarryEnd:
	%StripeImageHeader(.Ludwig, $0E, $1A, 0, $0000, 3)
	dw "LUDWIG"
.LudwigEnd:
	db $FF

else
	incbin "images/ending/1/layer3.bin"	;!
	%StripeImageHeader(.FishinLakitu, $12, $03, 0, $0000, 3)
	; FISHIN'LAKITU and attributes (sprite name)
	dw "FISHIN'LAKITU"		;!
.FishinLakituEnd:
	%StripeImageHeader(.ParaBomb, $02, $04, 0, $0000, 3)
	; PARA-BOMB and attributes (sprite name)
	dw "PARA-BOMB"
.ParaBombEnd:
	%StripeImageHeader(.ParaGoomba, $07, $0B, 0, $0000, 3)
	; PARA-GOOMBA and attributes (sprite name)
	dw "PARA-GOOMBA"
.ParaGoombaEnd:
	%StripeImageHeader(.Lakitu, $12, $0D, 0, $0000, 3)
	; LAKITU and attributes (sprite name)
	dw "LAKITU"
.LakituEnd:
	%StripeImageHeader(.Spiny, $08, $11, 0, $0000, 3)
	; SPINY and attributes (sprite name)
	dw "SPINY"
.SpinyEnd:
	%StripeImageHeader(.Wiggler, $17, $15, 0, $0000, 3)
	; WIGGLER and attributes (sprite name)
	dw "WIGGLER"
.WigglerEnd:
	%StripeImageHeader(.BobOmb, $0E, $19, 0, $0000, 3)
	; BOB-OMB and attributes (sprite name)
	dw "BOB-OMB"
.BobOmbEnd:
	db $FF

Screen02:
	incbin "images/ending/2/layer3.bin"	;!
	%StripeImageHeader(.AmazingFlying, $01, $04, 0, $0000, 3)
	; AMAZING FLYIN' and attributes (sprite name)
	dw "AMAZING FLYIN'"
.AmazingFlyingEnd:
	%StripeImageHeader(.HammerBrother, $01, $05, 0, $0000, 3)
	; AMAZING FLYIN' HAMMER BROTHER and attributes (sprite name)
	dw "HAMMER BROTHER"
.HammerBrotherEnd:
	%StripeImageHeader(.SuperKoopa, $12, $07, 0, $0000, 3)
	; SUPER KOOPA and attributes (sprite name)
	dw "SUPER KOOPA"
.SuperKoopaEnd:
	%StripeImageHeader(.Chargin, $17, $12, 0, $0000, 3)
	; CHARGIN' and attributes (sprite name)
	dw "CHARGIN'"
.CharginEnd:
	%StripeImageHeader(.Chuck, $18, $13, 0, $0000, 3)
	; CHUCK and attributes (sprite name)
	dw "CHUCK"
.ChuckEnd:
	%StripeImageHeader(.Jumping, $04, $15, 0, $0000, 3)
	; Layer 3 JUMPING PIRHANA PLANT and attributes (sprite name)
	dw "JUMPING"			;!
.JumpingEnd:
	%StripeImageHeader(.PirhanaPlant, $01, $16, 0, $0000, 3)
	dw "PIRHANA PLANT"
.PirhanaPlantEnd:
	%StripeImageHeader(.Volcano, $10, $19, 0, $0000, 3)
	; Layer 3 VOLCANO LOTUS and attributes (sprite name)
	dw "VOLCANO"			;!
.VolcanoEnd:
	%StripeImageHeader(.Lotus, $11, $1A, 0, $0000, 3)
	dw "LOTUS"
.LotusEnd:
	db $FF

Screen03:
	incbin "images/ending/3/layer3.bin"	;!
	%StripeImageHeader(.SumoBrother, $01, $04, 0, $0000, 3)
	; Layer 3 SUMO BROTHER and attributes (sprite name)
	dw "SUMO BROTHER"		;!
.SumoBrotherEnd:
	%StripeImageHeader(.MontyMole, $15, $07, 0, $0000, 3)
	; Layer 3 MONTY MOLE and attributes (sprite name)
	dw "MONTY MOLE"
.MontyMoleEnd:
	%StripeImageHeader(.Pokey, $10, $0E, 0, $0000, 3)
	; Layer 3 POKEY and attributes (sprite name)
	dw "POKEY"
.PokeyEnd:
	%StripeImageHeader(.BulletBill, $0D, $19, 0, $0000, 3)
	; Layer 3 BULLET BILL and attributes (sprite name)
	dw "BULLET BILL"
.BulletBillEnd:
	db $FF				;!

Screen04:
	incbin "images/ending/4/layer3.bin"	;!
	%StripeImageHeader(.Rex, $11, $08, 0, $0000, 3)
	; Layer 3 REX and attributes (sprite name)
	dw "REX"			;!
.RexEnd:
	%StripeImageHeader(.MegaMole, $03, $10, 0, $0000, 3)
	; Layer 3 MEGA MOLE and attributes (sprite name)
	dw "MEGA MOLE"
.MegaMoleEnd:
	%StripeImageHeader(.BanzaiBill, $10, $19, 0, $0000, 3)
	; Layer 3 BANZAI BILL and attributes (sprite name)
	dw "BANZAI BILL"		;!
.BanzaiBillEnd:
	db $FF

Screen05:
	incbin "images/ending/5/layer3.bin"	;!
	%StripeImageHeader(.DinoRhino, $02, $06, 0, $0000, 3)
	; Layer 3 DINO RHINO and attributes (sprite name)
	dw "DINO-RHINO"			;!
.DinoRhinoEnd:
	%StripeImageHeader(.DinoTorch, $09, $0F, 0, $0000, 3)
	; Layer 3 DINO TORCH and attributes (sprite name)
	dw "DINO-TORCH"			;!
.DinoTorchEnd:
	%StripeImageHeader(.Koopas, $10, $19, 0, $0000, 3)
	; Layer 3 KOOPAS and attributes (sprite name)
	dw "KOOPAS"			;!
.KoopasEnd:
	db $FF

Screen06:
	incbin "images/ending/6/layer3.bin"	;!
	%StripeImageHeader(.SpikeTop, $02, $05, 0, $0000, 3)
	; Layer 3 SPIKE TOP and attributes (sprite name)
	dw "SPIKE TOP"			;!
.SpikeTopEnd:
	%StripeImageHeader(.Swooper, $11, $05, 0, $0000, 3)
	; Layer 3 SWOOPERS and attributes (sprite name)
	dw "SWOOPERS"
.SwooperEnd:
	%StripeImageHeader(.BuzzyBeetle, $03, $10, 0, $0000, 3)
	; Layer 3 BUZZY BEETLE and attributes (sprite name)
	dw "BUZZY BEETLE"
.BuzzyBeetleEnd:
	%StripeImageHeader(.Blargg, $12, $13, 0, $0000, 3)
	; Layer 3 BLARGG and attributes (sprite name)
	dw "BLARGG"
.BlarggEnd:
	db $FF

Screen07:
	incbin "images/ending/7/layer3.bin"	;!
	%StripeImageHeader(.Blurp, $04, $04, 0, $0000, 3)
	; Layer 3 BLURPS and attributes (sprite name)
	dw "BLURPS"
.BlurpEnd:
	%StripeImageHeader(.Urchin, $12, $05, 0, $0000, 3)
	; Layer 3 URCHIN and attributes (sprite name)
	dw "URCHIN"
.UrchinEnd:
	%StripeImageHeader(.PorcuPuffer, $07, $0D, 0, $0000, 3)
	; Layer 3 PORCU-PUFFER and attributes (sprite name)
	dw "PORCU-PUFFER"
.PorcuPufferEnd:
	%StripeImageHeader(.TorpedoTed, $12, $12, 0, $0000, 3)
	; Layer 3 TORPEDO TED and attributes (sprite name)
	dw "TORPEDO TED"		;!
.TorpedoTedEnd:
	%StripeImageHeader(.RipVanFish, $02, $18, 0, $0000, 3)
	; Layer 3 RIP VAN FISH and attributes (sprite name)
	dw "RIP VAN FISH"
.RipVanFishEnd:
	db $FF

Screen08:
	incbin "images/ending/8/layer3.bin"	;!
	%StripeImageHeader(.BooBuddies, $03, $05, 0, $0000, 3)
	; Layer 3 "BOO" BUDDIES and attributes (sprite name)
	dw $7886	;\ Hex values draw the left and right " marks
	dw "BOO"	;|
	dw $3886	;|
	dw " BUDDIES"	;/
.BooBuddiesEnd:
	%StripeImageHeader(.FishinBoo, $12, $06, 0, $0000, 3)
	; Layer 3 FISHIN' BOO and attributes (sprite name)
	dw "FISHIN'BOO"			;!
.FishinBooEnd:
	%StripeImageHeader(.BigBoo, $02, $11, 0, $0000, 3)
	; Layer 3 THE BIG "BOO" and attributes (sprite name)
	dw "THE BIG "			;!
	dw $7886	;\ Hex values draw the left and right " marks
	dw "BOO"	;|
	dw $3886	;/
.BigBooEnd:
	%StripeImageHeader(.Eeries, $13, $15, 0, $0000, 3)
	; Layer 3 EERIES and attributes (sprite name)
	dw "EERIES"
.EeriesEnd:
	db $FF

Screen09:
	incbin "images/ending/9/layer3.bin"	;!
	%StripeImageHeader(.Sparky, $0B, $03, 0, $0000, 3)
	; Layer 3 LIL SPARKY and attributes (sprite name)
	dw "LIL SPARKY"
.SparkyEnd:
	%StripeImageHeader(.BonyBeetle, $11, $07, 0, $0000, 3)
	; Layer 3 BONY BEETLE and attributes (sprite name)
	dw "BONY BEETLE"
.BonyBeetleEnd:
	%StripeImageHeader(.DryBones, $02, $09, 0, $0000, 3)
	; Layer 3 DRY BONES and attributes (sprite name)
	dw "DRY BONES"
.DryBonesEnd:
	%StripeImageHeader(.Thwomp, $0F, $12, 0, $0000, 3)
	; Layer 3 THWOMP and attributes (sprite name)
	dw "THWOMP"
.ThwompEnd:
	%StripeImageHeader(.Thwimp, $16, $15, 0, $0000, 3)
	; Layer 3 THWIMP and attributes (sprite name)
	dw "THWIMP"
.ThwimpEnd:
	%StripeImageHeader(.Hothead, $09, $17, 0, $0000, 3)
	; Layer 3 HOTHEAD and attributes (sprite name)
	dw "HOTHEAD"
.HotheadEnd:
	db $FF

Screen10:
	incbin "images/ending/10/layer3.bin"	;!
	%StripeImageHeader(.Grinder, $10, $04, 0, $0000, 3)
	; Layer 3 GRINDER and attributes (sprite name)
	dw "GRINDER"
.GrinderEnd:
	%StripeImageHeader(.BallNChain, $07, $0D, 0, $0000, 3)
	; Layer 3 BALL'N'CHAIN and attributes (sprite name)
	dw "BALL"			;!
	dw $7885		; Draws the backwards '
	dw "N'CHAIN"
.BallNChainEnd:
	%StripeImageHeader(.Fishbone, $0D, $12, 0, $0000, 3)
	; Layer 3 FISHBONE and attributes (sprite name)
	dw "FISHBONE"
.FishboneEnd:
	db $FF

Screen11:
	incbin "images/ending/11/layer3.bin"	;!
	%StripeImageHeader(.Reznor, $0D, $0C, 0, $0000, 3)
	; Layer 3 REZNOR and attributes (sprite name)
	dw "REZNOR"			;!
.ReznorEnd:
	db $FF

Screen12:
	incbin "images/ending/12/layer3.bin"	;!
	%StripeImageHeader(.MechaKoopa, $0B, $0C, 0, $0000, 3)
	; Layer 3 MECHAKOOPAS and attributes (sprite name)
	dw "MECHAKOOPAS"		;!
.MechaKoopaEnd:
	db $FF

Screen13:
	incbin "images/ending/13/layer3.bin"	;!
	%StripeImageHeader(.Morton1, $05, $09, 0, $0000, 3)
	; Layer 3 MORTON KOOPA JR and attributes (sprite name)
	dw "MORTON"
.Morton1End:
	%StripeImageHeader(.Morton2, $04, $0A, 0, $0000, 3)
	dw "KOOPA JR."
.Morton2End:
	%StripeImageHeader(.Roy1, $17, $09, 0, $0000, 3)
	; Layer 3 ROY KOOPA and attributes (sprite name)
	dw "ROY"			;!
.Roy1End:
	%StripeImageHeader(.Roy2, $16, $0A, 0, $0000, 3)
	dw "KOOPA"
.Roy2End:
	%StripeImageHeader(.Bowser, $0D, $10, 0, $0000, 3)
	; Layer 3 BOWSER and attributes (sprite name)
	dw "BOWSER"			;!
.BowserEnd:
	%StripeImageHeader(.Lemmy1, $03, $12, 0, $0000, 3)
	; Layer 3 LEMMY KOOPA and attributes (sprite name)
	dw "LEMMY"			;!
.Lemmy1End:
	%StripeImageHeader(.Lemmy2, $03, $13, 0, $0000, 3)
	dw "KOOPA"
.Lemmy2End:
	%StripeImageHeader(.Wendy1, $19, $12, 0, $0000, 3)
	; Layer 3 WENDY O.KOOPA and attributes (sprite name)
	dw "WENDY"
.Wendy1End:
	%StripeImageHeader(.Wendy2, $18, $13, 0, $0000, 3)
	dw "O.KOOPA"
.Wendy2End:
	%StripeImageHeader(.Iggy1, $06, $18, 0, $0000, 3)
	; Layer 3 IGGY KOOPA and attributes (sprite name)
	dw "IGGY"
.Iggy1End:
	%StripeImageHeader(.Iggy2, $06, $19, 0, $0000, 3)
	dw "KOOPA"			;!
.Iggy2End:
	%StripeImageHeader(.Larry1, $17, $18, 0, $0000, 3)
	; Layer 3 LARRY KOOPA and attributes (sprite name)
	dw "LARRY"
.Larry1End:
	%StripeImageHeader(.Larry2, $17, $19, 0, $0000, 3)
	dw "KOOPA"
.Larry2End:
	%StripeImageHeader(.Ludwig1, $0E, $19, 0, $0000, 3)
	; Layer 3 LUDWIG VON KOOPA and attributes (sprite name)
	dw "LUDWIG"
.Ludwig1End:
	%StripeImageHeader(.Ludwig2, $0D, $1A, 0, $0000, 3)
	dw "VON KOOPA"
.Ludwig2End:
	db $FF

SpecialWorld:
.Unused1:
	dw $FFFF			;!
	%StripeImageHeader(.Pumpkin, $01, $16, 0, $0000, 3)
	; Layer 3 PUMPKIN and attributes (sprite name)
	dw "PUMPKIN"
.PumpkinEnd:
	dw $FFFF
	%StripeImageHeader(.Pidget, $0D, $19, 0, $0000, 3)
	; Layer 3 PIDGIT and attributes (sprite name)
	dw "PIDGIT"
.PidgetEnd:
	dw $FFFF
.Unused2:
	dw $FFFF			;!
	%StripeImageHeader(.MaskKoopa, $0E, $19, 0, $0000, 3)
	; Layer 3 MASK KOOPAS and attributes (sprite name)
	dw "MASK KOOPAS"
.MaskKoopaEnd:
	dw $FFFF

.Unused3:
	dw $FFFF			;!
.Unused4:
	dw $FFFF			;!
.Unused5:
	dw $FFFF			;!
.Unused6:
	dw $FFFF			;!
.Unused7:
	dw $FFFF			;!
.Unused8:
	dw $FFFF			;!
.Unused9:
	dw $FFFF			;!
.Unused10:
	dw $FFFF			;!
endif
cleartable
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj00_ScreenExit(Address)			; Optimization: Poorly optimized routine. Can be shrunk down considerably.
namespace SMW_ExtendedObj00_ScreenExit
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b #$00			;\ Waste some time (you don't need to index an LDA [$00], morons)
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	; |\
	STA.b !RAM_SMW_Blocks_ObjectNumber	; |/ Get destination screen number, store in temporary address
	INY				; |\
	TYA				; | |
	CLC				; | | It's called INC $65
	ADC.b !RAM_SMW_Pointer_Layer1DataLo	; | |
	STA.b !RAM_SMW_Pointer_Layer1DataLo	; |/
	LDA.b !RAM_SMW_Pointer_Layer1DataHi	; |
	ADC.b #$00			; | This big code increments the level data pointer (but why not simply REP #$20 INC $65 SEP #$20?)
	STA.b !RAM_SMW_Pointer_Layer1DataHi	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM0A	;\
	AND.b #$1F			; | Get screen number to X
	TAX				;/
	LDA.b !RAM_SMW_Blocks_ObjectNumber	;\
	STA.w !RAM_SMW_Misc_SubscreenExitEntranceNumberLo,x	;/ Store data from temporary variable in table (why not store directly to here? Morons...)
	LDA.b !RAM_SMW_Misc_ScratchRAM0B	;\
	AND.b #$01			; | Waste some MORE time, and also some RAM this time, this table isn't used ANYWHERE else than in this routine
	STA.w !RAM_SMW_Misc_SubscreenExitProperties,x	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM0B	;\
	LSR				; | Use Secondary Exits flag (finally something that makes sense)
	STA.w !RAM_SMW_Flag_UseSecondaryEntrance	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj01_ScreenJump(Address)
namespace SMW_ExtendedObj01_ScreenJump
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$1F			; The block number already is 0, morons
	STA.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject
	STA.w !RAM_SMW_Blocks_ScreenToPlaceNextObject	; Why two screen number flags? Even MORE moronic time wasting?
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObjXX_Generic1TileObject(Address)
namespace SMW_ExtendedObjXX_Generic1TileObject
%InsertMacroAtXPosition(<Address>)

; Map16 data for extended objects 10-40, low byte. They are in order of
; object number, but the 8th byte is unused (it would be used for object 17,
; but the final byte in the table is used instead). The high byte of the
; first 19 tiles is 00, while the high byte of the rest of the tiles is 01.
Tiles:
	db $1F				; Small door (small mario only)
	db $22				; Invisible 1-UP question block
	db $24				; Invisible note block
	db $42				; Top left corner edge tile 1
	db $43				; Top right corner edge tile 1
	db $27				; Small invisible POW door (small mario only)
	db $29				; Invisible POW question block
	db $25				; Unused (?)
	db $6E				; 3-Up moon
	db $6F				; Invisible 1-Up point #1
	db $70				; Invisible 1-Up point #2
	db $71				; Invisible 1-Up point #3
	db $72				; Invisible 1-Up point #4 (check point)
	db $45				; Red berry
	db $46				; Pink berry
	db $47				; Green berry
	db $48				; Always-turning turn block
	db $36				; Bottom right of midway point (not used?)
	db $37				; Bottom right of midway point (not used?)
	db $11				; Note block, flower/feather/star inside
	db $12				; ON/OFF block, use SP4=3 or 5
	db $14				; Question block with direction coins
	db $15				; Note block, bounce on top & bottom
	db $16				; Note block, bounce on all sides!
	db $17				; Turn block with flower inside
	db $18				; Turn block with feather inside
	db $19				; Turn block with star inside
	db $1A				; Turn block, coin(star 2)/1-UP/vine (X/3)
	db $1B				; Turn block with multiple coins inside
	db $1C				; Turn block with coin inside
	db $29				; Turn block with "nothing" inside
	db $1D				; Turn block with blue/silver POW inside (X/2)
	db $1F				; Question block with flower inside
	db $20				; Question block with feather inside
	db $21				; Question block with star inside
	db $22				; Question block with coin(star 2) inside
	db $23				; Question block with multiple coins inside
	db $25				; Question block, key/wings/balloon/shell (X/4)
	db $26				; Question block with Yoshi/1-UP inside
	db $27				; Question block with green turtle shell inside
	db $28				; Question block with green turtle shell inside
	db $2A				; Unbreakable turn block, side feather inside
	db $DE				; Top left corner edge tile 2
	db $E0				; Top right corner edge tile 2
	db $E2				; Top left corner edge tile 3
	db $E4				; Top right corner edge tile 3
	db $EC				; Top left corner edge tile 4
	db $ED				; Top right corner edge tile 4
	db $2C				; Translucent block, use SP4=4
	db $25				; Unused (?)
	db $2D				; Green Star Block 

; Main creation code for extended objects 10-40. (Extended object 17 uses a
; different pointer, but it jumps to the same routine.)
Main:
	TXA
	SEC
	SBC.b #$10
CODE_0DA57F:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	CPX.b #$18			;\
	BCC.b CODE_0DA5B1		; |
	CPX.b #$1D			; | Some objects have special behavior. This goes elsewhere with the "normal" ones.
	BCS.b CODE_0DA5B1		;/
	LDA.w !RAM_SMW_Overworld_LevelNumberLo	;\
	LSR				; |
	LSR				; |
	LSR				; |
	TAY				; | Get level number to some index tables
	LDA.w !RAM_SMW_Overworld_LevelNumberLo	; |
	AND.b #$07			; |
	TAX				;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	CMP.b #$08			; | The invisible 1up tiles doesn't use this code
	BNE.b CODE_0DA5A7		;/
	LDA.w !RAM_SMW_Flag_CollectedMoons,y	;\
	AND.l SMW_BitTable_Bank0D,x	; | Check the flag for whether the moon has been taken in this level
	BEQ.b CODE_0DA5B1		;/
	BRA.b Return0DA5B0		; Why not use RTS?

CODE_0DA5A7:
	LDA.w !RAM_SMW_Flag_Collected1upCheckpoints,y	;\
	AND.l SMW_BitTable_Bank0D,x	; | Check the flag for whether the invisible 1up has been taken in this level
	BEQ.b CODE_0DA5B1		;/
Return0DA5B0:
	RTS

CODE_0DA5B1:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position of the block
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; |
	CPX.b #$13			; | Check and set which map16 page it uses
	BMI.b CODE_0DA5BF		; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;/
CODE_0DA5BF:
	LDA.l Tiles,x			; Get object number
	STA.b !RAM_SMW_Misc_ScratchRAM0C	; Save it for later use
	CPX.b #$01			;\
	BEQ.b CODE_0DA5F0		; |
	CPX.b #$07			; |
	BEQ.b CODE_0DA5F0		; |
	CPX.b #$32			; | Check whether the object cares about item memory
	BEQ.b CODE_0DA5F0		; | (invisible 1up block, green star block, Yoshi block, and star2/vine/1up does)
	CPX.b #$26			; |
	BEQ.b CODE_0DA5F0		; |
	CPX.b #$1B			; |
	BNE.b CODE_0DA648		;/
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$01			; |
	BEQ.b CODE_0DA5F0		; |
	CMP.b #$04			; |
	BEQ.b CODE_0DA5F0		; | Object 2B (vine/star2/1up mushroom) only cares about item memory on certain X positions
	CMP.b #$07			; |
	BEQ.b CODE_0DA5F0		; |
	CMP.b #$0A			; |
	BEQ.b CODE_0DA5F0		; |
	CMP.b #$0D			; |
	BNE.b CODE_0DA648		;/
CODE_0DA5F0:
	TXA
	PHA
	TYA
	PHA
	LDX.w !RAM_SMW_Misc_ItemMemorySetting
	LDA.b #$F8
	CLC
	ADC.l SMW_Bank0DItemMemoryIndexes_Lo,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b #($1900+!Define_SMW_LowRAMLocation)>>8	; High byte of the item
	ADC.l SMW_Bank0DItemMemoryIndexes_Hi,x	; memory table, which moves
					; with low RAM.
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceNextObject
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$10
	BEQ.b CODE_0DA61B
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ORA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_0DA61B:
	TYA
	AND.b #$08
	BEQ.b CODE_0DA626
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ORA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_0DA626:
	LDA.b !RAM_SMW_Blocks_SubScrPos
	AND.b #$07
	TAX
#LM171Hijack_ItemMemory3Revamp2:
	LDY.b !RAM_SMW_Misc_ScratchRAM0E				;\ LM: Hijacks here to make item memory index 3 not track items collected (1.71+)
	LDA.b (!RAM_SMW_Misc_ScratchRAM08),y				;/
	AND.l SMW_BitTable_Bank0D,x
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	PLA
	TAY
	PLA
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_0DA648
	CPX.b #$07
	BEQ.b Return0DA64C
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$32
	STA.b !RAM_SMW_Misc_ScratchRAM0C
CODE_0DA648:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/ Generate the tile it should generate
Return0DA64C:
	RTS

; The start of the routine for extended object 17, the green star block. It
; loads a hardcoded index to the table at $0DA548.
GreenStarBlockEntry:
	LDA.b #$32			; Make the above routine think we're trying to generate object 42
	JMP.w CODE_0DA57F		; and go to the middle of the Fix Object Number code

namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj10_SmallDoor_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj11_Invisible1upBlock_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj12_InvisibleNoteBlock_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj13_TopLeftCornerEdge1_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj14_TopRightCornerEdge1_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj15_SmallPSwitchDoor_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj16_InvisiblePSwitchBlock_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj18_3upMoon_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj19_1upCheckpoint1_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj1A_1upCheckpoint2_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj1B_1upCheckpoint3_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj1C_1upCheckpoint4_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj1D_RedBerry_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj1E_PinkBerry_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj1F_GreenBerry_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj20_SpinningTurnBlock_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj21_BottomRightMidwayGateTile_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj22_BottomRightMidwayGateTile_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj23_NoteBlockWithPowerUp_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj24_ONOFFBlock_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj25_DirectionalCoinBlock_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj26_NoteBlock_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj27_4WayNoteBlock_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj28_TurnBlockWithFlower_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj29_TurnBlockWithFeather_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj2A_TurnBlockWithStar_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj2B_TurnBlockWithCoinStar21upVine_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj2C_TurnBlockWithMultipleCoins_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj2D_TurnBlockWithCoin_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj2E_TurnBlockWithNothing_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj2F_TurnBlockWithPSwitch_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj30_QuestionBlockWithFlower_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj31_QuestionBlockWithFeather_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj32_QuestionBlockWithStar_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj33_QuestionBlockWithCoinStar2_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj34_QuestionBlockWithMultipleCoins_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj35_QuestionBlockWithKeyWingsBalloonShell_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj36_QuestionBlockWithYoshi_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj37_QuestionBlockWithShell_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj38_QuestionBlockWithShell_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj39_SolidTurnBlockWithSideFeather_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj3A_TopLeftCornerEdge2_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj3B_TopRightCornerEdge2_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj3C_TopLeftCornerEdge3_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj3D_TopRightCornerEdge3_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj3E_TopLeftCornerEdge4_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj3F_TopRightCornerEdge4_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_Main, SMW_ExtendedObj40_GlassBlock_Main)

	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_Generic1TileObject_GreenStarBlockEntry, SMW_ExtendedObj17_GreenStarBlock_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj41_YoshiCoin(Address)
namespace SMW_ExtendedObj41_YoshiCoin
%InsertMacroAtXPosition(<Address>)

; Dragon Coin creation routine. $0DB2DF - Change to 00 to prevent Dragon
; Coins from vanishing when at least 5 have been collected. $0DB328 - Map16
; tile for the upper half of a Yoshi/Dragon Coin. $0DB329 - Change to EA EA
; to make only the lower half of Yoshi/Dragon Coins appear. $0DB332 - Map16
; tile for the lower half of a Yoshi/Dragon Coin. $0DB333 - Change to EA EA
; to make only the upper half of Yoshi/Dragon Coins appear.
Main:
	LDA.w !RAM_SMW_Overworld_LevelNumberLo	;\
	LSR				; |
	LSR				; |
	LSR				; |
	TAY				; |
	LDA.w !RAM_SMW_Overworld_LevelNumberLo	; | Check whether the Yoshi coins in this level has been taken
	AND.b #$07			; |
	TAX				; |
	LDA.w !RAM_SMW_Flag_Collected5YoshiCoins,y	; |
	AND.l SMW_BitTable_Bank0D,x	; |
	BNE.b SMW_StandardObj15_MidwayAndGoalPoint_Return0DB2C9	;/
	LDX.w !RAM_SMW_Misc_ItemMemorySetting
	LDA.b #$F8
	CLC
	ADC.l SMW_Bank0DItemMemoryIndexes_Lo,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b #($1900+!Define_SMW_LowRAMLocation)>>8	; High byte of the item
	ADC.l SMW_Bank0DItemMemoryIndexes_Hi,x	; memory table, which moves
					; with low RAM.
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceNextObject
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$10
	BEQ.b CODE_0DB307
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ORA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_0DB307:
	LDY.b !RAM_SMW_Blocks_SubScrPos
	TYA
	AND.b #$08
	BEQ.b CODE_0DB314
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ORA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_0DB314:
	TYA
	AND.b #$07
	TAX
#LM171Hijack_ItemMemory3Revamp4:
	LDY.b !RAM_SMW_Misc_ScratchRAM0E					;\ LM: Hijacks here to make item memory index 3 not track items collected (1.71+)
	LDA.b (!RAM_SMW_Misc_ScratchRAM08),y					;/
	AND.l SMW_BitTable_Bank0D,x
	BNE.b Return0DB335
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$2D			; | Add top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to next tile
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$2E			; | Add bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
Return0DB335:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj42_TopLeftSlope(Address)
namespace SMW_ExtendedObj42_TopLeftSlope
%InsertMacroAtXPosition(<Address>)

LeftTiles:
	db $D8		; Top left slope
	db $DB		; Top right slope

RightTiles:
	db $DA		; Top left slope
	db $DC		; Top right slope

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position of the block
	TXA				;\
	SEC				; |
	SBC.b #$42			; | Subtract $42 from object number (GAH CHANGE THE 0DA652/ETC INSTEAD, TIMEWASTERS)
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\ GOD why not expand that inline? You're saving ONLY ONE BYTE!
	LDA.l LeftTiles,x		; | Add left block and update pointer
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	LDA.l RightTiles,x		;\
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	; | Add right block (no need to update the pointer this time)
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj42_TopLeftSlope_Main, SMW_ExtendedObj43_TopRightSlope_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObjXX_PurpleTriangle(Address)
namespace SMW_ExtendedObjXX_PurpleTriangle
%InsertMacroAtXPosition(<Address>)

TriangleTiles:
	db $B4,$B5			; Top tiles

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position of the block
	TXA				;\
	SEC				; |
	SBC.b #$44			; | Not another object number subtraction...
	TAX				;/
	LDA.l TriangleTiles,x		;\
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/ Set top tile
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; Not that one again...
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer/index downwards
	LDA.b #$EB			;\
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	; | Set bottom tile
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_PurpleTriangle_Main, SMW_ExtendedObj44_LeftFacingTriangle_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_PurpleTriangle_Main, SMW_ExtendedObj45_RightFacingTriangle_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj46_MidwayBar(Address)
namespace SMW_ExtendedObj46_MidwayBar
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.w !RAM_SMW_Overworld_LevelNumberLo
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_Overworld_LevelTileSettings,x
else
	LDA.l !RAM_SMW_Overworld_LevelTileSettings,x
endif
	AND.b #$40
	BNE.b Return0DA6B0
	LDA.w !RAM_SMW_Flag_GotMidpoint	;\
	BNE.b Return0DA6B0		;/ Check another midway flag
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position again
	DEY								; Glitch: This causes the midway bar to break on subscreen boundries.
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\ (Offtopic: Not ANOTHER four byte routine...)
	LDA.b #$35			; | Set the left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ (Offtopic: There's no way that this code will work around screen boundaries.)
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$38			; | Set right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
Return0DA6B0:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj47_Door(Address)
namespace SMW_ExtendedObj47_Door
%InsertMacroAtXPosition(<Address>)

; Map16 data for the door and P-switch-activated door. In order: Top tile of
; normal door, top tile of P-switch door, bottom tile of normal door, bottom
; tile of P-switch door.
TopTiles:
	db $1F		; Door
	db $27		; Invisible POW door

BottomTiles:
	db $20		; Door
	db $28		; Invisible POW door

; Main creation code for extended objects 47 and 48, the normal door and
; P-switch-activated door. This is also the routine that unused extended
; objects 98-FF point to (they just pull garbage tiles).
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position again
	TXA				;\
	SEC				; |
	SBC.b #$47			; | Load object type
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l TopTiles,x		; | Set top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l BottomTiles,x		; | Set bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj48_PSwitchDoor_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj98_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj99_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj9A_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj9B_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj9C_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj9D_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj9E_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObj9F_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA0_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA1_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA2_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA3_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA4_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA5_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA6_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA7_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA8_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjA9_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjAA_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjAB_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjAC_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjAD_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjAE_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjAF_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB0_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB1_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB2_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB3_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB4_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB5_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB6_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB7_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB8_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjB9_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjBA_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjBB_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjBC_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjBD_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjBE_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjBF_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC0_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC1_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC2_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC3_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC4_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC5_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC6_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC7_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC8_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjC9_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjCA_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjCB_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjCC_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjCD_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjCE_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjCF_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD0_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD1_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD2_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD3_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD4_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD5_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD6_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD7_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD8_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjD9_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjDA_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjDB_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjDC_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjDD_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjDE_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjDF_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE0_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE1_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE2_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE3_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE4_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE5_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE6_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE7_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE8_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjE9_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjEA_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjEB_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjEC_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjED_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjEE_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjEF_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF0_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF1_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF2_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF3_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF4_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF5_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF6_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF7_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF8_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjF9_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjFA_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjFB_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjFC_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjFD_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjFE_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj47_Door_Main, SMW_ExtendedObjFF_Unused_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj49_GhostHouseExit(Address)
namespace SMW_ExtendedObj49_GhostHouseExit
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $A5,$A5,$A4,$A5,$A5,$A4
	db $A7,$A8,$A4,$A7,$A8,$A4
	db $AC,$AD,$A4,$AC,$AD,$A4
	db $AE,$AF,$A4,$AE,$AF,$A4
	db $B0,$B1,$A4,$B0,$B1,$A4
	db $A7,$A8,$A4,$A7,$A8,$A4
	db $A5,$A5,$A5,$A5,$A5,$A4
	db $B4,$B4,$B4,$B4,$B4,$A4
	db $AC,$B2,$AD,$B4,$B4,$A4
	db $B0,$B3,$B1,$B4,$B4,$A4
	db $C1,$C2,$C6,$B4,$B4,$A4
	db $C1,$C2,$C6,$A5,$A5,$A4
	db $C1,$C2,$C6,$A7,$A8,$A4

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$00
CODE_0DEAC3:
	LDA.b #$05			; Width
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_0DEAC7:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; |  Add block
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; | Go to next one and check for end of line
	BPL.b CODE_0DEAC7		;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to next row (I've got reasons to belive that LM renders this one incorrectly!)
	CPX.b #$4E			; Total size
	BNE.b CODE_0DEAC3
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj4A_ClimbingNetDoor(Address)
namespace SMW_ExtendedObj4A_ClimbingNetDoor
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $10,$11,$11,$12
	db $13,$0B,$0B,$15
	db $13,$0B,$0B,$15
	db $16,$17,$17,$18

Main:											; Glitch: This object doesn't set the high byte!
											; Placing it over tiles outside of page 00 will draw the wrong tiles.
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position again... yawn
	LDX.b #$00
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DA7C8:
	LDA.b #$03			; Number of lines
	STA.b !RAM_SMW_Misc_ScratchRAM02
CODE_0DA7CC:
	LDA.l Tiles,x			;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add block
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; | Go to the next one
	BPL.b CODE_0DA7CC		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Reload and move pointer
	CPX.b #$10			; Number of tiles
	BNE.b CODE_0DA7C8
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj4B_ConveyorEndTile1(Address)
namespace SMW_ExtendedObj4B_ConveyorEndTile1
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $07
	db $08

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position yawn
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$4B			; | Fix object number yawn
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add object yawn
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj4B_ConveyorEndTile1_Main, SMW_ExtendedObj4C_ConveyorEndTile2_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObjXX_LineGuideQuarterLargeCircle(Address)
namespace SMW_ExtendedObjXX_LineGuideQuarterLargeCircle
%InsertMacroAtXPosition(<Address>)

; Map16 data for the large circular line guide pieces (low bytes only).
Tiles:
	db $7A,$7B	;\ Line guide, top left 1/4 large circle
	db $7C,$25	;/

	db $7E,$7F	;\ Line guide, top right 1/4 large circle
	db $25,$7D	;/

	db $82,$25	;\ Line guide, bottom left 1/4 large circle
	db $80,$81	;/

	db $25,$83	;\ Line guide, bottom right 1/4 large circle
	db $84,$85	;/

; Main creation code for the large circular line guide pieces.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$4D			; |
	ASL				; | "Fix" object number and multiply by four
	ASL				; |
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DCE74:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add object
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	TXA				; |
	AND.b #$01			; | Go to next object and check for end of line
	BNE.b CODE_0DCE74		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go downwards
	TXA				;\
	AND.b #$03			; | Check for end of object
	BNE.b CODE_0DCE74		;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LineGuideQuarterLargeCircle_Main, SMW_ExtendedObj4D_LineGuideTopLeftQuarterLargeCircle_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LineGuideQuarterLargeCircle_Main, SMW_ExtendedObj4E_LineGuideTopRightQuarterLargeCircle_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LineGuideQuarterLargeCircle_Main, SMW_ExtendedObj4F_LineGuideBottomLeftQuarterLargeCircle_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LineGuideQuarterLargeCircle_Main, SMW_ExtendedObj50_LineGuideBottomRightQuarterLargeCircle_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObjXX_LineGuideQuarterSmallCircle(Address)
namespace SMW_ExtendedObjXX_LineGuideQuarterSmallCircle
%InsertMacroAtXPosition(<Address>)

; Map16 data for the small circular line guide pieces (low bytes).
Tiles:
	db $76		; Line guide, top left 1/4 small circle
	db $77		; Line guide, top right 1/4 small circle
	db $78		; Line guide, bottom left 1/4 small circle
	db $79		; Line guide, bottom right 1/4 small circle

; Main creation code for the small circular line guide pieces.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$51			; | "Fix" object number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add object
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LineGuideQuarterSmallCircle_Main, SMW_ExtendedObj51_LineGuideTopLeftQuarterSmallCircle_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LineGuideQuarterSmallCircle_Main, SMW_ExtendedObj52_LineGuideTopRightQuarterSmallCircle_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LineGuideQuarterSmallCircle_Main, SMW_ExtendedObj53_LineGuideBottomLeftQuarterSmallCircle_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LineGuideQuarterSmallCircle_Main, SMW_ExtendedObj54_LineGuideBottomRightQuarterSmallCircle_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj55_HorizontalLineGuideEnd(Address)
namespace SMW_ExtendedObj55_HorizontalLineGuideEnd
%InsertMacroAtXPosition(<Address>)

; Map16 data for the horizontal line guide end (extended object 55).
Tiles:
	db $96
	db $97

; Main creation code for the horizontal line guide end (extended object 55).
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	; Hi timewasters, is it fun to waste time?
	LDX.b #$00
CODE_0DCEC6:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add block
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;\
	INX				;/ Go to the next one
	CPX.b #$02			;\
	BNE.b CODE_0DCEC6		;/ Check for end of the block
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj56_VerticalLineGuideEnd(Address)
namespace SMW_ExtendedObj56_VerticalLineGuideEnd
%InsertMacroAtXPosition(<Address>)

; Map16 data for the vertical line guide end (extended object 56).
Tiles:
	db $98,$99

; Main creation code for the vertical line guide end (extended object 56).
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	; Hi again, timewasters
	LDX.b #$00
CODE_0DCEE0:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add block
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	CPX.b #$02			; | Go to next and check for ending
	BNE.b CODE_0DCEE0		;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner(Address)
namespace SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $73		; Switch palace bottom right corner tile
	db $74		; Switch palace bottom left corner tile
	db $75		; Switch palace top right corner tile
	db $76		; Switch palace top left corner tile
	db $93		; Bit of brick background tile 1
	db $94		; Bit of brick background tile 2
	db $95		; Bit of brick background tile 3
	db $96		; Bit of brick background tile 4

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$57			; | "Fix" object number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner_Main, SMW_ExtendedObj58_SwitchPalaceBottomLeftInnerCorner_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner_Main, SMW_ExtendedObj59_SwitchPalaceTopRightInnerCorner_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner_Main, SMW_ExtendedObj5A_SwitchPalaceTopLeftInnerCorner_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner_Main, SMW_ExtendedObj5B_BitOfBrickBackground1_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner_Main, SMW_ExtendedObj5C_BitOfBrickBackground2_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner_Main, SMW_ExtendedObj5D_BitOfBrickBackground3_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj57_SwitchPalaceBottomRightInnerCorner_Main, SMW_ExtendedObj5E_BitOfBrickBackground4_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj5F_LargeBackgroundArea(Address)
namespace SMW_ExtendedObj5F_LargeBackgroundArea
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b #$03			; Size of this object
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b #$00
ADDR_0DE977:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$77
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	INY				;\
	BNE.b ADDR_0DE977		;/ Check how many tiles have been added
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;\
	CLC				; |
	ADC.b #$01			; | Increase pointers (it's called INC $6C INC $6F, morons)
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b ADDR_0DE977		;/ Check for end of object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj60_CaveLavaInnerCorner(Address)
namespace SMW_ExtendedObj60_CaveLavaInnerCorner
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; Second page
	LDA.b #$FE			;\
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/ Tile $1FE
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj61_GhostHouseClock(Address)
namespace SMW_ExtendedObj61_GhostHouseClock
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $97,$98,$99		;\ Ghost house clock
	db $9A,$9B,$9C		;|
	db $9D,$9E,$9F		;/

	db $86,$87,$25		;\ Ghost house top left to bottom right beam 1
	db $25,$86,$87		;|
	db $25,$25,$86		;/

	db $25,$84,$85		;\ Ghost house top right to bottom left beam 1
	db $84,$85,$25		;|
	db $85,$25,$25		;/

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$61			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	ASL				; |
	ASL				; | "Fix" type and multiply with 9
	ASL				; |
	CLC				; |
	ADC.b !RAM_SMW_Misc_ScratchRAM00	; |
	TAX				;/
	LDA.b #$02			; Size of first row, also height
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DE9C3:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add block
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; | Go to next block
	BPL.b CODE_0DE9C3		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to next row
	LDA.b #$02			; Size of the other rows
	STA.b !RAM_SMW_Misc_ScratchRAM00
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DE9C3		;/ Check for end of object
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj61_GhostHouseClock_Main, SMW_ExtendedObj62_GhostHouseTopLeftToBottomRightBeam1_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj61_GhostHouseClock_Main, SMW_ExtendedObj63_GhostHouseTopRightToBottomLeftBeam1_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj64_TopRightCobweb(Address)
namespace SMW_ExtendedObj64_TopRightCobweb
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $8C,$8D	;\ Ghost house cobweb, top right
	db $25,$8E	;/	

	db $90,$91	;\ Ghost house cobweb, top left
	db $8F,$25	;/

	db $FC,$FD	;\ Ghost house window (8F)
	db $FE,$FF	;/

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$64			; |
	ASL				; | "Fix" type and multiply with 4
	ASL				; |
	TAX				;/
GhostHouseWindowEntry:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position (it's usually loaded before the type is fixed, but whatever)
	LDA.b #$01			; Size of the first row, also height
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DEA00:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add block
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; | Go to the next block
	BPL.b CODE_0DEA00		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to the next row
	LDA.b #$01			; Size of the other row
	STA.b !RAM_SMW_Misc_ScratchRAM00
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DEA00		;/ Check for the end of the object
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj64_TopRightCobweb_Main, SMW_ExtendedObj65_TopLeftCobweb_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj66_GhostHouseTopRightToBottomLeftBeam2(Address)
namespace SMW_ExtendedObj66_GhostHouseTopRightToBottomLeftBeam2
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $25,$25,$7A,$7B	;\ Ghost house top right to bottom left beam 2
	db $25,$7C,$7D,$25	;|
	db $7C,$7D,$25,$25	;|
	db $7D,$25,$25,$25	;/

	db $7E,$7F,$25,$25	;\ Ghost house top left to bottom right beam 2
	db $25,$80,$81,$25	;|
	db $25,$25,$80,$81	;|
	db $25,$25,$25,$80	;/

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$66			; |
	ASL				; |
	ASL				; | "Fix" type and multiply with 16
	ASL				; |
	ASL				; |
	TAX				;/
	LDA.b #$03			; Size of the first row, also height
	STA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
ADDR_0DEA53:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add block
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; | Go to the next block
	BPL.b ADDR_0DEA53		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to the next row
	LDA.b #$03			; Size of the other row
	STA.b !RAM_SMW_Misc_ScratchRAM00
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b ADDR_0DEA53		;/ Check for the end of the object
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj66_GhostHouseTopRightToBottomLeftBeam2_Main, SMW_ExtendedObj67_GhostHouseTopLeftToBottomRightBeam2_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj68_CloudFringeBottomAndRightEdge(Address)
namespace SMW_ExtendedObj68_CloudFringeBottomAndRightEdge
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $91		; Cloud fringe, bottom and right edge
	db $92		; Cloud fringe, bottom and left edge
	db $96		; Cloud fringe, bottom right
	db $97		; Cloud fringe, bottom left
	db $9A		; Cloud fringe on white, bottom and right edge
	db $9B		; Cloud fringe on white, bottom and left edge
	db $9F		; Cloud fringe on white, bottom right
	db $A0		; Cloud fringe on white, bottom left

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position again
	LDA.b !RAM_SMW_Blocks_SizeOrType	; That's a new version, why not TXA?
	SEC				;\
	SBC.b #$68			; | Update block number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add block
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj68_CloudFringeBottomAndRightEdge_Main, SMW_ExtendedObj69_CloudFringeBottomAndLeftEdge_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj68_CloudFringeBottomAndRightEdge_Main, SMW_ExtendedObj6A_CloudFringeBottomRight_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj68_CloudFringeBottomAndRightEdge_Main, SMW_ExtendedObj6B_CloudFringeBottomLeft_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj68_CloudFringeBottomAndRightEdge_Main, SMW_ExtendedObj6C_CloudFringeOnWhiteBottomAndRightEdge_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj68_CloudFringeBottomAndRightEdge_Main, SMW_ExtendedObj6D_CloudFringeOnWhiteBottomAndLeftEdge_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj68_CloudFringeBottomAndRightEdge_Main, SMW_ExtendedObj6E_CloudFringeOnWhiteBottomRight_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj68_CloudFringeBottomAndRightEdge_Main, SMW_ExtendedObj6F_CloudFringeOnWhiteBottomLeft_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj70_BitOfCanvas1(Address)
namespace SMW_ExtendedObj70_BitOfCanvas1
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$51			; | "Fix" object number (it's not used anyways, morons)
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$84			; | Add top tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$85			; | Add bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj71_Canvas1(Address)
namespace SMW_ExtendedObj71_Canvas1
%InsertMacroAtXPosition(<Address>)

Tiles:
.Canvas1:
	db $5C,$5D,$5E,$60		; No, I don't know what those 60's are for
	db $73,$74,$75
	db $73,$74,$75
	db $73,$74,$75
	db $73,$74,$75
	db $76,$76,$76
.Canvas2:
	db $5C,$5D,$5E,$60
	db $77,$78,$79
	db $7A,$7B,$7C
	db $77,$78,$79
	db $7A,$7B,$7C
	db $76,$76,$76
.Canvas3:
	db $5C,$5D,$5E,$60
	db $73,$7D,$75
	db $73,$7E,$75
	db $73,$74,$75
	db $7F,$74,$75
	db $76,$76,$76
.Canvas4:
	db $5C,$5D,$5E,$60
	db $77,$82,$83
	db $7A,$85,$86
	db $81,$78,$79
	db $84,$7B,$7C
	db $76,$76,$76

TileIndex:
	db SMW_ExtendedObj71_Canvas1_Tiles_Canvas1-SMW_ExtendedObj71_Canvas1_Tiles	; Offsets in the table (powers of 19)
	db SMW_ExtendedObj71_Canvas1_Tiles_Canvas2-SMW_ExtendedObj71_Canvas1_Tiles
	db SMW_ExtendedObj71_Canvas1_Tiles_Canvas3-SMW_ExtendedObj71_Canvas1_Tiles
	db SMW_ExtendedObj71_Canvas1_Tiles_Canvas4-SMW_ExtendedObj71_Canvas1_Tiles

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$71			; | "Fix" object number
	TAX				;/
	LDA.l TileIndex,x		;\
	TAX				;/ Multiply with 19 to get index to table
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	LDA.b #$02			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Why not put this later? Spaghetti code...
	LDA.b #$03			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Width of first row
CODE_0DE0C6:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\ \
	LDA.l Tiles,x			; | | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |/
	INX				; |
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; | This code adds the top row of tiles.
	BPL.b CODE_0DE0C6		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Reload pointer and go to next row
CODE_0DE0DB:
	LDA.b #$02			; Width of other rows
	STA.b !RAM_SMW_Misc_ScratchRAM02
CODE_0DE0DF:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\ \
	LDA.l Tiles,x			; |  | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; | /
	INX				; |
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; | This code adds the middle rows.
	BPL.b CODE_0DE0DF		; |
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; | > Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; |
	DEC.b !RAM_SMW_Misc_ScratchRAM01	; |
	BPL.b CODE_0DE0DB		;/
	LDA.b #$02			; Width of the second-to-bottom row
	STA.b !RAM_SMW_Misc_ScratchRAM02
CODE_0DE0FC:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	INX				; | This code adds the second-to-bottom row.
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; |
	BPL.b CODE_0DE0FC		;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$5F			; | Add that 15F tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b #$02			; Width of the bottom row
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to next row
CODE_0DE11C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	INX				; | This code adds the bottom row.
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; |
	BPL.b CODE_0DE11C		;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj71_Canvas1_Main, SMW_ExtendedObj72_Canvas2_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj71_Canvas1_Main, SMW_ExtendedObj73_Canvas3_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj71_Canvas1_Main, SMW_ExtendedObj74_Canvas4_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj75_CanvasTile1(Address)
namespace SMW_ExtendedObj75_CanvasTile1
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $7D		; Canvas Tile 1
	db $7E		; Canvas Tile 2
	db $7F		; Canvas Tile 3
	db $80		; Canvas Tile 4
	db $81		; Canvas Tile 5
	db $82		; Canvas Tile 6
	db $83		; Canvas Tile 7

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$75			; | "Fix" object number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj75_CanvasTile1_Main, SMW_ExtendedObj76_CanvasTile2_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj75_CanvasTile1_Main, SMW_ExtendedObj77_CanvasTile3_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj75_CanvasTile1_Main, SMW_ExtendedObj78_CanvasTile4_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj75_CanvasTile1_Main, SMW_ExtendedObj79_CanvasTile5_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj75_CanvasTile1_Main, SMW_ExtendedObj7A_CanvasTile6_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj75_CanvasTile1_Main, SMW_ExtendedObj7B_CanvasTile7_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj7C_BitOfCanvas1(Address)
namespace SMW_ExtendedObj7C_BitOfCanvas1
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $81		; Bit of canvas 2
	db $82		; Bit of canvas 3
	db $83		; Bit of canvas 4

BottomTiles:
	db $84		; Bit of canvas 2
	db $85		; Bit of canvas 3
	db $86		; Bit of canvas 4

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$7C			; | "Fix" object number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l TopTiles,x		; | Top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to next tile
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l BottomTiles,x		; | Bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj7C_BitOfCanvas1_Main, SMW_ExtendedObj7D_BitOfCanvas2_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj7C_BitOfCanvas1_Main, SMW_ExtendedObj7E_BitOfCanvas3_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj7F_TorpedoLauncher(Address)
namespace SMW_ExtendedObj7F_TorpedoLauncher
%InsertMacroAtXPosition(<Address>)

; Torpedo Ted Launcher: MAP16 tiles
Tiles:
	db $66,$67
	db $68,$69

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$00
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DDAA9:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add object
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	TXA				;/ Go to next object
	AND.b #$01			;\
	BNE.b CODE_0DDAA9		;/ Check for end of line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to next line
	CPX.b #$04
	BNE.b CODE_0DDAA9
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj80_GhostHouseEntrance(Address)
namespace SMW_ExtendedObj80_GhostHouseEntrance
%InsertMacroAtXPosition(<Address>)

; Ghost House entrance: MAP16 blocks
Tiles:
	db $A4,$A6,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
	db $A4,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5
	db $A4,$C0,$A8,$A8,$A8,$A8,$AB,$AB,$A8,$A8
	db $A4,$A6,$AC,$AD,$C0,$AC,$AD,$A6,$AC,$AD
	db $A4,$A6,$AE,$AF,$A6,$AE,$AF,$BF,$AE,$AF
	db $A4,$BF,$B0,$B1,$AB,$B0,$B1,$A6,$B0,$B1
	db $A4,$A6,$AB,$A8,$A9,$A8,$AB,$A9,$A8,$A8
	db $A4,$A5,$A5,$A5,$B5,$B6,$B7,$B8,$B9,$A5
	db $A4,$A7,$A8,$AB,$BA,$BB,$BC,$BD,$BE,$A8
	db $A4,$C0,$AC,$AD,$A6,$AC,$B2,$AD,$BF,$AC
	db $A4,$A7,$AE,$AF,$C0,$AE,$B3,$AF,$AB,$AE
	db $A4,$BF,$B0,$B1,$A6,$C1,$C2,$C3,$A6,$B0
	db $A4,$A5,$A5,$A5,$A5,$C1,$C2,$C3,$C4,$C4
	db $A4,$B4,$B4,$B4,$B4,$C1,$C2,$C3,$C5,$C5

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$00
CODE_0DEB6E:
	LDA.b #$09			; Width
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_0DEB72:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; | Go to next tile
	BNE.b CODE_0DEB72		;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add the last tile on the row
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	INX				;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Go to next line
	CPX.b #$8C			; Total size
	BNE.b CODE_0DEB6E
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj81_Seaweed(Address)
namespace SMW_ExtendedObj81_Seaweed
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $C9
	db $CA

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$00
ADDR_0DEC6C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile (why not unroll this loop?)
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;\
	INX				;/ Go to next tile
	CPX.b #$02			; Height
	BNE.b ADDR_0DEC6C
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObjXX_LargeBush(Address)
namespace SMW_ExtendedObjXX_LargeBush
%InsertMacroAtXPosition(<Address>)

; Map16 data for the big bush
BigBushTiles:
	db $25,$25,$25,$4B,$4D,$4E,$25,$25,$25
	db $25,$25,$54,$49,$49,$5F,$63,$25,$25
	db $25,$25,$57,$49,$49,$52,$4A,$5D,$25
	db $25,$5A,$49,$49,$50,$51,$4A,$60,$25
	db $5A,$49,$49,$49,$53,$4A,$4A,$4A,$63

; Main creation code for extended object 82 (the larger of the two big
; bushes). $0DA71E is the width, minus one. $0DA722 is the height, minus
; one. $0DA732 is the pointer to Map16 tile array (only contains low bytes).
BigBushEntry:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b #$08			; Width
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$04			; Height
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b #$00			; Block we're at
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve the pointer
CODE_0DA72A:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload number of blocks in a row
CODE_0DA72E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l BigBushTiles,x		; |
	JSR.w HandleOverlappingBigBushTiles	; | Add block and go to the next one
	INX				;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BPL.b CODE_0DA72E		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Reload pointer and move it downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DA72A		;/ Check for end of the bush
	RTS

; Map16 data for the small bush
SmallBushTiles:
	db $25,$25,$4B,$4C,$25,$25
	db $25,$54,$49,$5F,$63,$25
	db $25,$57,$49,$52,$4A,$5D
	db $5A,$49,$49,$49,$4F,$60

; Main creation code for extended object 83 (the smaller of the two big
; bushes). $0DA763 is the width, minus one. $0DA767 is the height, minus
; one. $0DA777 is the pointer to Map16 tile array (only contains low bytes).
SmallBushEntry:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b #$05			; Width
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$03			; Height
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b #$00			; Block we're at
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve the pointer
CODE_0DA76F:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload number of blocks in a row
CODE_0DA773:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l SmallBushTiles,x		; |
	JSR.w HandleOverlappingBigBushTiles	; | Add block and go to the next one
	INX				;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BPL.b CODE_0DA773		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Reload pointer and move it downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DA76F		;/ Check for end of the bush
	RTS

; Part of bush object decoding routine.
HandleOverlappingBigBushTiles:
	STA.b !RAM_SMW_Misc_ScratchRAM0F	; Preserve block to be written
	CMP.b #$25			;\
	BNE.b CODE_0DA796		; | If trying to write a blank tile, update the pointer without adding the block
	JMP.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Entry2	;/

CODE_0DA796:
	CMP.b #$49			;\
	BCC.b CODE_0DA7AC		; |
	CMP.b #$54			; | Don't change the single-color ones
	BCC.b CODE_0DA7AC		;/
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	; Check what's about to be overwritten
	CMP.b #$25			;\
	BEQ.b CODE_0DA7AC		;/ If it's the blank one, don't
	CMP.b #$49			;\
	BEQ.b CODE_0DA7AA		;/ Tile 0x49 is the only "bright" one
	INC.b !RAM_SMW_Misc_ScratchRAM0F
CODE_0DA7AA:
	INC.b !RAM_SMW_Misc_ScratchRAM0F
CODE_0DA7AC:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F	;\
	JMP.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Load block number and add it
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LargeBush_BigBushEntry, SMW_ExtendedObj82_BigBush1_Main)

	%SetDuplicateOrNullPointer(SMW_ExtendedObjXX_LargeBush_SmallBushEntry, SMW_ExtendedObj83_BigBush2_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj84_CastleEntrance(Address)
namespace SMW_ExtendedObj84_CastleEntrance
%InsertMacroAtXPosition(<Address>)

; Castle entrance: MAP16 blocks
Tiles:
	db $73,$74,$75,$73,$74,$74,$7B,$79,$7A
	db $79,$7A,$7B,$79,$7A,$7B,$73,$74,$75
	db $73,$74,$74,$74,$75,$73,$77,$77,$78
	db $76,$77,$77,$7A,$7B,$79,$7A,$7A,$7B
	db $79,$7A,$7B,$73,$74,$74,$75,$73,$74
	db $73,$75,$73,$77,$7A,$7A,$7B,$79,$7A
	db $79,$7B,$79,$7B,$7C,$7D,$7D,$7D,$7D
	db $25,$73,$74,$75,$7E,$7F,$7F,$7F,$7F
	db $25,$76,$77,$78,$80,$81,$81,$81,$81
	db $25,$76,$77,$78,$82,$82,$82,$82,$7C
	db $25,$79,$7A,$7B,$83,$84,$84,$85,$80
	db $25,$73,$74,$75,$83,$84,$84,$85,$7C
	db $25,$76,$77,$78,$83,$84,$84,$85,$7E
	db $25,$79,$7A,$7B,$83,$84,$84,$85,$80

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Load position
	LDX.b #$00
CODE_0DC2ED:
	LDA.b #$08			; Width
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_0DC2F1:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	CMP.b #$25			; | \
	BEQ.b CODE_0DC2FE		; | / Don't add the blank tiles for some reason
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
CODE_0DC2FE:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Entry2	;\
	INX				;/ Go to next tile
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DC2F1		;/ Check for end of line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile without checking for tile 25?
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	INX				;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Go to next line
	CPX.b #$7E			;\
	BNE.b CODE_0DC2ED		;/ Check for end of object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj85_YoshisHouse(Address)
namespace SMW_ExtendedObj85_YoshisHouse
%InsertMacroAtXPosition(<Address>)

; Tilemap of Yoshi's House. Change EB to D3 at $0DEB85, $0DEB89, $0DEBBE,
; $0DEBC6, $0DEBCC, $0DEBD0 and $0DEBDA to remove Berries from Yoshi's
; House, or to 45 to make them work without placing berry objects on top of
; them.
Tiles:
	db $25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$25,$CB,$CC,$25,$25,$25
	db $25,$CD,$CE,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$CF,$D0,$D1,$25
	db $25,$D2,$EB,$D3,$D3,$D3,$EB,$D3,$D3,$D3,$D3,$EB,$D3,$D3,$D4,$25
	db $25,$D5,$D3,$EB,$D3,$D3,$D3,$D3,$D3,$EB,$D3,$D3,$D3,$EB,$D6,$25
	db $25,$D5,$D3,$D3,$D3,$D3,$D3,$EB,$D3,$D3,$D3,$D3,$D3,$D3,$D6,$25
	db $25,$D7,$D8,$D9,$D8,$D8,$D9,$D8,$D8,$D9,$D8,$DA,$DB,$D8,$DC,$25
	db $25,$25,$25,$DD,$25,$25,$DD,$25,$25,$DD,$25,$CB,$CC,$25,$25,$25
	db $25,$25,$DE,$DD,$25,$25,$DD,$25,$25,$DD,$25,$CB,$CC,$25,$25,$25
	db $25,$DF,$E0,$E1,$25,$25,$DD,$25,$25,$DD,$25,$E2,$E3,$E4,$25,$25
	db $E5,$E5,$E6,$DD,$E5,$E5,$DD,$E5,$E5,$DD,$E5,$E7,$E8,$E9,$E5,$E5

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos
	LDX.b #$00
CODE_0DEC37:
	LDA.b #$0F			; Width
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_0DEC3B:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; | Go to next tile
	BNE.b CODE_0DEC3B		;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add the last tile on the row
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	INX				;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Go to next line
	CPX.b #$A0			; Total size
	BNE.b CODE_0DEC37
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj86_GoalSign(Address)
namespace SMW_ExtendedObj86_GoalSign
%InsertMacroAtXPosition(<Address>)

; Goal Arrow sign: MAP16 tiles
Tiles:
	db $66,$67
	db $68,$69

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos
	LDX.b #$00
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
CODE_0DA7EE:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add block
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	TXA				;/ Move to the next one
	AND.b #$01			; Width... almost
	BNE.b CODE_0DA7EE
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Reload and change pointer
	CPX.b #$04			; Number of tiles
	BNE.b CODE_0DA7EE
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj88_RightTreeBranch(Address)
namespace SMW_ExtendedObj88_RightTreeBranch
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $C1,$C2

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$88			; | "Fix" object number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add block
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj88_RightTreeBranch_Main, SMW_ExtendedObj89_LeftTreeBranch_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj8A_GreenSwitchPalaceSwitch(Address)
namespace SMW_ExtendedObj8A_GreenSwitchPalaceSwitch
%InsertMacroAtXPosition(<Address>)

; Low bytes of the Map16 tiles used when generating extended objects 8A
; through 8D, the Green, Yellow, Blue, and Red switch palace switches. The
; creation code at $0DEC8E puts them all on page 0.
Tiles:
	db $EC,$ED
	db $EE,$EF			; Green switch

	db $F0,$F1
	db $F2,$F3			; Yellow switch

	db $F4,$F5
	db $F6,$F7			; Blue switch

	db $F8,$F9
	db $FA,$FB			; Red switch

; Main object creation code for Extended objects 8A through 8D, the Green,
; Yellow, Blue, and Red switch palace switches. The code at $0DEC96 (6 bytes
; long) keeps the objects from being generated if the associated flag (at
; $7E1F27) is set. The hack at $00EEB2 will keep them from becoming solid if
; this code is changed. The Map16 tiles used (on page 0) are at $0DEC7E.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	SEC				; |
	SBC.b #$8A			; | "Fix" object number
	TAX				;/
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.w !RAM_SMW_Flag_ActivatedGreenSwitch,x
else
	LDA.l !RAM_SMW_Flag_ActivatedGreenSwitch,x
endif
	BNE.b Return0DECC0
	TXA				;\
	ASL				; |
	ASL				; | Multiply object number with 4
	TAX				;/
	LDA.b #$01			; Size (both width and height)
	STA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Preserve sizes
CODE_0DECA6:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width
CODE_0DECAA:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; | Go to next one and check for end of the line
	BPL.b CODE_0DECAA		;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;\
	DEC.b !RAM_SMW_Misc_ScratchRAM01	; | Go to next row and check for end of the object
	BPL.b CODE_0DECA6		;/
Return0DECC0:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj8A_GreenSwitchPalaceSwitch_Main, SMW_ExtendedObj8B_YellowSwitchPalaceSwitch_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj8A_GreenSwitchPalaceSwitch_Main, SMW_ExtendedObj8C_BlueSwitchPalaceSwitch_Main)
	%SetDuplicateOrNullPointer(SMW_ExtendedObj8A_GreenSwitchPalaceSwitch_Main, SMW_ExtendedObj8D_RedSwitchPalaceSwitch_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj8E_YellowSwitchBlock(Address)
namespace SMW_ExtendedObj8E_YellowSwitchBlock
%InsertMacroAtXPosition(<Address>)

; Main creation code for the yellow and green switch blocks. $0DB583 - Start
; of the code for the green block. $0DB587 - Map16 tiles (on page 1) for the
; filled-in blocks. $0DB589 - Map16 tiles (on page 0) for the outline
; blocks. $0DB58B - Start of the code for the yellow block. $0DB592 - Change
; F0 to D0, to invert the Green and Yellow Switch Palace blocks (solid
; before the Switch Palce, passable afterwards).
Main:
	LDX.b #$01			; Index points to the yellow one
	BNE.b CODE_0DB58D 		; Note: Probably an NES coding leftover, considering that the SNES has a BRA.b instruction.

ActiveTiles:
	db $6A				; Green switch block (always feather)
	db $6B				; Yellow switch block (always mushroom)

InactiveTiles:
	db $6A				; Green switch block (always feather)
	db $6B				; Yellow switch block (always mushroom)

GreenSwitchBlockEntry:
	LDX.b #$00			; Index points to the green one
CODE_0DB58D:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.w !RAM_SMW_Flag_ActivatedGreenSwitch,x	;\
	BNE.b CODE_0DB59E		;/ Check whether the switch has been hit and go to the correct place
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l InactiveTiles,x		; | Add outline block
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS

CODE_0DB59E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l ActiveTiles,x		; | Add solid block
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj8E_YellowSwitchBlock_GreenSwitchBlockEntry, SMW_ExtendedObj87_GreenSwitchBlock_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj8F_GhostHouseWindow(Address)
namespace SMW_ExtendedObj8F_GhostHouseWindow
%InsertMacroAtXPosition(<Address>)

Main:
	LDX.b #$08			; Set offset to 8
	JMP.w SMW_ExtendedObj64_TopRightCobweb_GhostHouseWindowEntry	; and "steal" the ghost house cobwebs code
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj90_LargeBossDoor(Address)
namespace SMW_ExtendedObj90_LargeBossDoor
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $98,$99
	db $9A,$9B
	db $9C,$9C

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Load position
	LDX.b #$00
	LDA.b #$01			; Width
	STA.b !RAM_SMW_Misc_ScratchRAM00
CODE_0DC326:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Reload size
CODE_0DC32A:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add object
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;/ Go to next tile
	BPL.b CODE_0DC32A		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Check for end of line
	CPX.b #$06			; Total size
	BNE.b CODE_0DC326
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj91_VerticalLevelSteepLeftSlope(Address)
namespace SMW_ExtendedObj91_VerticalLevelSteepLeftSlope
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $AA		; Steep left slope (vertical level compatible)
	db $AF		; Steep right slope (vertical level compatible)

BottomTiles:
	db $E2		; Steep left slope (vertical level compatible)
	db $E4		; Steep right slope (vertical level compatible)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Posi... you know
	TXA				;\
	SEC				; |
	SBC.b #$91			; | "Fix" object number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopTiles,x		; | Store top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_VerticalLevel	; Update pointer
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l BottomTiles,x		; | Store bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj91_VerticalLevelSteepLeftSlope_Main, SMW_ExtendedObj92_VerticalLevelSteepRightSlope_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj93_VerticalLevelNormalLeftSlope(Address)
namespace SMW_ExtendedObj93_VerticalLevelNormalLeftSlope
%InsertMacroAtXPosition(<Address>)

TopLeftTiles:
	db $96		; Normal left slope (vertical level compatible)
	db $A0		; Normal right slope (vertical level compatible)

TopRightTiles:
	db $9B		; Normal left slope (vertical level compatible)
	db $A5		; Normal right slope (vertical level compatible)

BottomLeftTiles:
	db $DE		; Normal left slope (vertical level compatible)
	db $E6		; Normal right slope (vertical level compatible)

BottomRightTiles:
	db $E6		; Normal left slope (vertical level compatible)
	db $E0		; Normal right slope (vertical level compatible)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position <h1>YAWN</h1>
	TXA				;\
	SEC				; |
	SBC.b #$93			; | "Fix" object number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopLeftTiles,x		; | Top left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopRightTiles,x		; | Top right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_VerticalLevel	; Update pointer
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l BottomLeftTiles,x		; | Bottom left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l BottomRightTiles,x	; | Bottom right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj93_VerticalLevelNormalLeftSlope_Main, SMW_ExtendedObj94_VerticalLevelNormalRightSlope_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj95_VerticalLevelVerySteepLeftSlope(Address)
namespace SMW_ExtendedObj95_VerticalLevelVerySteepLeftSlope
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $CA		; Very steep left slope (vertical level compatible)
	db $CC		; Very steep right slope (vertical level compatible)

MiddleTiles:
	db $CB		; Very steep left slope (vertical level compatible)
	db $CD		; Very steep right slope (vertical level compatible)

BottomTiles:
	db $F1		; Very steep left slope (vertical level compatible)
	db $F2		; Very steep right slope (vertical level compatible)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	TXA				;\
	SEC				; |
	SBC.b #$95			; | "Fix" object number
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopTiles,x		; | Add object
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_VerticalLevel	; Update pointer
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l MiddleTiles,x		; | Add object
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_VerticalLevel	; Update pointer
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l BottomTiles,x		; | Add object
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_ExtendedObj95_VerticalLevelVerySteepLeftSlope_Main, SMW_ExtendedObj96_VerticalLevelVerySteepRightSlope_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_ExtendedObj97_SwitchPalaceRightAndBottomEdgeTile(Address)
namespace SMW_ExtendedObj97_SwitchPalaceRightAndBottomEdgeTile
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; Page 1
	LDA.b #$10			;\
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/ Tile 0x?10 (in this case, it's 0x110)
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_StandardObjXX_Generic1RepeatedTileObject(Address)
namespace SMW_StandardObjXX_Generic1RepeatedTileObject
%InsertMacroAtXPosition(<Address>)

; Map16 data for objects 01-0E, low bytes of tile numbers. The last byte is
; actually used for tileset-specific object 31 when it forms ice-blue turn
; blocks.
Tiles:
	db $02			; Water tiles 1, dark blue
	db $21			; Invisible coin blocks
	db $23			; Invisible jumping note blocks
	db $2A			; Invisible POW coins
	db $2B			; Coins
	db $3F			; Walk-through dirt
	db $03			; Water tiles 2, variable color
	db $13			; Jumping note blocks
	db $1E			; Turn blocks
	db $24			; Coin question blocks
	db $2E			; Throw blocks
	db $2F			; Black piranha plant
	db $30			; Grey cement blocks
	db $32			; Brown "used" blocks
	db $65			; Icy turn blocks

; Main creation code for the objects that are made up of only one Map16 tile
; and can be extended both horizontally and vertically, i.e., objects 01-0E
; and tileset-specific object 31 when it forms ice-blue turn blocks.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Extract width
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Extract height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
CODE_0DA8D8:
	CPX.b #$04			;\
	BNE.b CODE_0DA92E		;/ Only coins cares about sprite memory
	TXA								;\ Optimization: NES code. Use PHX : PHY instead.
	PHA								;|
	TYA								;|
	PHA								;/
	LDX.w !RAM_SMW_Misc_ItemMemorySetting
	LDA.b #$F8
	CLC
	ADC.l SMW_Bank0DItemMemoryIndexes_Lo,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b #($1900+!Define_SMW_LowRAMLocation)>>8	; High byte of the item
	ADC.l SMW_Bank0DItemMemoryIndexes_Hi,x	; memory table, which moves
					; with low RAM.
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceNextObject
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$10
	BEQ.b CODE_0DA907
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ORA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_0DA907:
	TYA
	AND.b #$08
	BEQ.b CODE_0DA912
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ORA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM0E
CODE_0DA912:
	TYA
	AND.b #$07
	TAX
#LM171Hijack_ItemMemory3Revamp3:
	LDY.b !RAM_SMW_Misc_ScratchRAM0E				;\ LM: Hijacks here to make item memory index 3 not track items collected (1.71+)
	LDA.b (!RAM_SMW_Misc_ScratchRAM08),y				;/
	AND.l SMW_BitTable_Bank0D,x
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	PLA								;\ Optimization: NES code. Use PLY : PLX instead.
	TAY								;|
	PLA								;|
	TAX								;/
	LDA.b !RAM_SMW_Misc_ScratchRAM0F
	BEQ.b CODE_0DA92E
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Entry2
	JMP.w CODE_0DA943

CODE_0DA92E:
	LDA.l Tiles,x			;\
	STA.b !RAM_SMW_Misc_ScratchRAM0C	;/ Get object number
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	CPX.b #$07			; |
	BMI.b CODE_0DA93E		; | Set map16 page
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;/
CODE_0DA93E:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add tile
CODE_0DA943:
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM02	; | Check for end of the line
	BPL.b CODE_0DA8D8		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; | Go to next line
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BMI.b Return0DA95A		; | Check for end of the object
	JMP.w CODE_0DA8D8		;/

Return0DA95A:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj01_DarkBlueWater_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj02_InvisibleCoinBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj03_InvisibleNoteBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj04_InvisiblePSwitchCoins_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj05_Coins_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj06_WalkThroughDirt_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj07_VariableColorWater_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj08_NoteBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj09_TurnBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj0A_CoinBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj0B_ThrowBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj0C_Munchers_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj0D_CementBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_Main, SMW_StandardObj0E_UsedBlocks_Main)
namespace off
endmacro

macro ROUTINE_RT01_SMW_StandardObjXX_Generic1RepeatedTileObject(Address)
namespace SMW_StandardObjXX_Generic1RepeatedTileObject
%InsertMacroAtXPosition(<Address>)

IcyTurnBlockEntry:
	LDX.b #$0E			;\
	JMP.w Main			;/ Hijack the this-code-handles-many-objects code

namespace off
	%SetDuplicateOrNullPointer(SMW_StandardObjXX_Generic1RepeatedTileObject_IcyTurnBlockEntry, SMW_GrasslandObj31_IcyTurnBlocks_Main)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj0F_VerticalPipes(Address)
namespace SMW_StandardObj0F_VerticalPipes
%InsertMacroAtXPosition(<Address>)

; Map16 data for vertical pipe ends. There are four 5-byte tables here. The
; first two are for the top of a pipe (the last two bytes are unused), and
; the second two are for the bottom of a pipe (the first two bytes are
; unused).
TopLeftPipeEndTiles:
	db $33		; Vertical pipe, end on top...
	db $37		; ...with exit enabled
	db $39		; Vertical pipe, double ended
	db $00		; Vertical pipe, end on bottom...
	db $00		; ...eith exit enabled

TopRightPipeEndTiles:
	db $34		; Vertical pipe, end on top...
	db $38		; ...with exit enabled
	db $3A		; Vertical pipe, double ended
	db $00		; Vertical pipe, end on bottom...
	db $00		; ...eith exit enabled

BottomLeftPipeEndTiles:
	db $00		; Vertical pipe, end on top...
	db $00		; ...eith exit enabled
	db $39		; Vertical pipe, double ended
	db $33		; Vertical pipe, end on bottom...
	db $37		; ...eith exit enabled

BottomRightPipeEndTiles:
	db $00		; Vertical pipe, end on top...
	db $00		; ...eith exit enabled
	db $3A		; Vertical pipe, double ended
	db $34		; Vertical pipe, end on bottom...
	db $38		; ...eith exit enabled

; Main creation code for the vertical pipe objects. $0DAA5A - The Map16 tile
; number (low byte) for the left side of the vertical pipe with no end.
; $0DAA62 - The Map16 tile number (low byte) for the right side of the
; vertical pipe with no end. $0DAA6C - The Map16 tile number (low byte) for
; the left side of all non-vertical pipes except the one without ends.
; $0DAA74 - The Map16 tile number (low byte) for the right side of all
; non-vertical pipes except the one without ends.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Extract height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Extract type
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	CPX.b #$03			;\
	BPL.b CODE_0DAA52		;/ Don't add the left end for the ones that shouldn't have it (I think)
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopLeftPipeEndTiles,x	; | Add left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopRightPipeEndTiles,x	; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JMP.w CODE_0DAA77

CODE_0DAA52:
	CPX.b #$05			;\
	BNE.b CODE_0DAA68		;/ Check for the endless vertical pipe
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$68								; Note: Set this to #$35 to make the "Vertical pipe, no end" object use non-tileset specific pipe tiles.
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$69								; Note: Set this to #$36 to make the "Vertical pipe, no end" object use non-tileset specific pipe tiles.
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	JMP.w CODE_0DAA77

CODE_0DAA68:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$35			; | Left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$36			; | Right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
CODE_0DAA77:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Go to next row
	CPX.b #$05			;\
	BEQ.b CODE_0DAA85		; |
	CPX.b #$02			; | Check if the object has a special bottom
	BPL.b CODE_0DAA8C		;/
CODE_0DAA85:
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DAA52		; | Check for end of the object (also, it's called RTS, not JMP *insert address of an RTS*)
	JMP.w Return0DAAA3		;/

CODE_0DAA8C:
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DAA68		;/ Check if this is the last tile
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l BottomLeftPipeEndTiles,x	; | Left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l BottomRightPipeEndTiles,x	; | Right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
Return0DAAA3:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj10_HorizontalPipes(Address)
namespace SMW_StandardObj10_HorizontalPipes
%InsertMacroAtXPosition(<Address>)

; Map16 data for the horizontal pipes. There are two tables here, each
; containing the low bytes of the tile numbers and both in order; the first
; two bytes of each table are for the left-facing non-exit-enabled pipe, the
; next two are for the left-facing exit-enabled pipe, the next two are for
; the right-facing non-exit-enabled pipe, and the last two are for the
; right-facing exit-enabled pipe.
EndTiles:
	db $3B		;\ Horizontal pipe, end on left
	db $3C		;/

	db $3B		;\ ...with exit enabled
	db $3F		;/

	db $3B		;\ Horizontal pipe, end on right
	db $3C		;/

	db $3B		;\ ...with exit enabled
	db $3F		;/

ShaftTiles:
	db $3D		;\ Horizontal pipe, end on left
	db $3E		;/

	db $3D		;\ ...with exit enabled
	db $3E		;/

	db $3D		;\ Horizontal pipe, end on right
	db $3E		;/

	db $3D		;\ ...with exit enabled
	db $3E		;/

; Main creation code for the horizontal pipe objects.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Extract size
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$F0			; |
	LSR				; |
	LSR				; | Extract type
	LSR				; |
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DAAC9:
	CPX.b #$04			;\
	BPL.b CODE_0DAADA		;/ Go to another part of the code if it's an end-on-right pipe
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l EndTiles,x		; | Add ending tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DAAE4

CODE_0DAADA:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l ShaftTiles,x		; | Add middle tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DAAE4:
	CPX.b #$04			;\
	BPL.b CODE_0DAAEF		;/ Add end of end-on-right pipes
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DAADA		; | Check for end of line (also, it's called BRA, morons)
	JMP.w CODE_0DAAFC		;/

CODE_0DAAEF:
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BNE.b CODE_0DAAC9		;/ Check for end of line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l EndTiles,x		; | Add ending tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
CODE_0DAAFC:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Reload size
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;\
	INX				;/ Go to the next line
	TXA				;\
	AND.b #$01			; | Check for end of the block
	BNE.b CODE_0DAAC9		;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj11_BulletShooter(Address)
namespace SMW_StandardObj11_BulletShooter
%InsertMacroAtXPosition(<Address>)

; Main creation code for the Bullet Bill shooter object. $0DAB1A, $0DAB27,
; and $0DAB34 control which three Map16 tiles make up the object.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Extract height (the width bits are obviously unused)
	LSR				; |
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$41			; | Add top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;\
	DEX				; | Go to next tile and check for end of the object
	BMI.b Return0DAB3D		;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$42			; | Add middle tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;\
	DEX				; | Go to next tile and check for end of the object
	BMI.b Return0DAB3D		;/
CODE_0DAB30:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$43			; | Add bottom tiles
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;\
	DEX				; | Go to next tile and check for end of the object
	BPL.b CODE_0DAB30		;/
Return0DAB3D:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_StandardObj12_Slopes(Address)
namespace SMW_StandardObj12_Slopes
%InsertMacroAtXPosition(<Address>)

; Main creation code for the slope objects (object 12), minus the code for
; each individual slope. $0DAB50-$0DAB6D are the pointers to the individual
; slope objects.
Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			;/ Get type...
CODE_0DAB42:
	CMP.b #$0A			;\
	BMI.b CODE_0DAB4C		; |
	SEC				; | ...modulo 10 for some reason
	SBC.b #$0A			; |
	JMP.w CODE_0DAB42		;/

CODE_0DAB4C:
	JSL.l SMW_ExecutePtr_Long

SlopesPtrs:
	dl NormalLeftSlope		; Normal slope left
	dl SteepLeftSlope		; Steep slope left
	dl GradualLeftSlope		; Gradual slope left
	dl NormalRightSlope		; Normal slope right
	dl SteepRightSlope		; Steep slope right
	dl GradualRightSlope		; Gradual slope right
	dl UpsideDownNormalLeftSlope	; Normal slope left upside down
	dl UpsideDownNormalRightSlope	; Normal slope right upside down
	dl UpsideDownSteepLeftSlope	; Steep slope left upside down
	dl UpsideDownSteepRightSlope	; Steep slope right upside down

NormalLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; The obligatory position loading!
	LDA.b #$01			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | Number of tiles on the top, I guess
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get size (lol @ storing to $00 twice and not using INC A)
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DAB83:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Reload size
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$96			; | Add top left tile, or whatever I should call it
	JSR.w SMW_FillInSlopeTileAir_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$9B			; | Add to right tile
	JSR.w SMW_FillInSlopeTileAir_Main	;/
	DEX				;\
	DEX				; | Go to next tiles
	BMI.b CODE_0DABB8		;/
CODE_0DAB99:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$DE			; | Add bottom left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$E6			; | Add bottom right tile (identical to 0x03F)
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	JMP.w CODE_0DABB5		;/ Go to next tiles

CODE_0DABAD:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$3F
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
CODE_0DABB5:
	DEX
	BPL.b CODE_0DABAD
CODE_0DABB8:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	INC.b !RAM_SMW_Misc_ScratchRAM02	;\
	INC.b !RAM_SMW_Misc_ScratchRAM02	; | Update size
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;/
	BEQ.b CODE_0DABEC		; Check for last row (that one doesn't contain 0x196 nor 0x19B)
	BPL.b CODE_0DABC8		;\
	JMP.w Return0DABF6		;/ Check for end of the object

CODE_0DABC8:
	LDA.b !RAM_SMW_Blocks_SubScrPos
	CLC
	ADC.b #$0E
	TAY
	BCC.b CODE_0DABD3
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
CODE_0DABD3:
	TYA
	AND.b #$0F
	CMP.b #$0E
	BMI.b CODE_0DABE7
	TYA
	CLC
	ADC.b #$10
	TAY
	BCC.b CODE_0DABE4
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
CODE_0DABE4:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main
CODE_0DABE7:
	STY.b !RAM_SMW_Blocks_SubScrPos
	JMP.w CODE_0DAB83

CODE_0DABEC:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	;\
	DEX				; |
	DEX				; | Update pointers and restart loop
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; |
	JMP.w CODE_0DAB99		;/

Return0DABF6:
	RTS
namespace off
endmacro

macro ROUTINE_RT01_SMW_StandardObj12_Slopes(Address)
namespace SMW_StandardObj12_Slopes
%InsertMacroAtXPosition(<Address>)

SteepLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ It's called STZ, morons
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
CODE_0DAC34:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Load size
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$AA			; | Add top tile
	JSR.w SMW_FillInSlopeTileAir_Main	;/
CODE_0DAC3E:
	DEX				;\
	BMI.b CODE_0DAC57		;/ Go to next tile and check for end of object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$E2			; | Add bottom tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DAC54

CODE_0DAC4C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$3F
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
CODE_0DAC54:
	DEX
	BPL.b CODE_0DAC4C
CODE_0DAC57:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	INC.b !RAM_SMW_Misc_ScratchRAM02	;\
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;/ Update indexes
	BEQ.b CODE_0DAC89		; The last line doesn't have any 0x1AA tile
	BPL.b CODE_0DAC65		;\
	JMP.w Return0DAC91		;/ Check for end of the object

CODE_0DAC65:
	LDA.b !RAM_SMW_Blocks_SubScrPos
	CLC
	ADC.b #$0F
	TAY
	BCC.b CODE_0DAC70
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
CODE_0DAC70:
	TYA
	AND.b #$0F
	CMP.b #$0F
	BNE.b CODE_0DAC84
	TYA
	CLC
	ADC.b #$10
	TAY
	BCC.b CODE_0DAC81
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
CODE_0DAC81:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main
CODE_0DAC84:
	STY.b !RAM_SMW_Blocks_SubScrPos
	JMP.w CODE_0DAC34

CODE_0DAC89:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Load size
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Update pointer
	JMP.w CODE_0DAC3E		; and add line

Return0DAC91:
	RTS

GradualLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b #$03			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | Number of tiles in the first row
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get width
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DACA7:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Reload number of tiles in a row
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$6E			; |
	JSR.w SMW_FillInSlopeTileAir_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$73			; |
	JSR.w SMW_FillInSlopeTileAir_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add the actual slope tiles
	LDA.b #$78			; |
	JSR.w SMW_FillInSlopeTileAir_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$7D			; |
	JSR.w SMW_FillInSlopeTileAir_Main	;/
	DEX				;\
	DEX				; |
	DEX				; | Check if it's the top line
	DEX				; |
	BMI.b CODE_0DAD00		;/
CODE_0DACCF:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$D8			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$DA			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add the "slope assist" tiles
	LDA.b #$E6			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$E6			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	DEX				; |
	DEX				; | Update index
	JMP.w CODE_0DACFD		;/

CODE_0DACF5:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$3F
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
CODE_0DACFD:
	DEX
	BPL.b CODE_0DACF5
CODE_0DAD00:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	CLC				; |
	ADC.b #$04			; | Increase size of future lines
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; Decrease number of lines remaining
	BEQ.b CODE_0DAD37		; Check for last line
	BPL.b CODE_0DAD13		;\
	JMP.w Return0DAD43		;/ Check for end of the object

CODE_0DAD13:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$0C			; | Move pointer either right or left/down
	TAY				;/
	BCC.b CODE_0DAD1E		; Check whether it hit a subscreen boundary
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	; and update the pointer if needed
CODE_0DAD1E:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$0C			; | Check whether it went left/down or right and return if it's left/down
	BMI.b CODE_0DAD32		;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; | Move pointer down
	TAY				;/
	BCC.b ADDR_0DAD2F		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Handle subscreen boundaries
ADDR_0DAD2F:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main	; Go left
CODE_0DAD32:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	JMP.w CODE_0DACA7		; and run the loop again

CODE_0DAD37:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	;\
	DEX				; |
	DEX				; | Update index
	DEX				; |
	DEX				;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	JMP.w CODE_0DACCF		; and run the loop again

Return0DAD43:
	RTS

NormalRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$01			;\
	STX.b !RAM_SMW_Misc_ScratchRAM02	; | Number of actual slope tiles
	STX.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
	JMP.w CODE_0DAD7F		; Go to loop

CODE_0DAD5C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$3F
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX
CODE_0DAD65:
	CPX.b #$03
	BNE.b CODE_0DAD5C
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$E6			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add actual slope tiles
	LDA.b #$E0			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	DEX				; |
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; | Check for end of the object
	BEQ.b Return0DAD9F		;/
CODE_0DAD7F:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$A0			; |
	JSR.w SMW_FillInSlopeTileAir_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add "slope assist" tiles
	LDA.b #$A5			; |
	JSR.w SMW_FillInSlopeTileAir_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	;/ Reload and update pointer
	INC.b !RAM_SMW_Misc_ScratchRAM02	;\
	INC.b !RAM_SMW_Misc_ScratchRAM02	; |
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; | Go to the next line
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; |
	BPL.b CODE_0DADA0		;/
Return0DAD9F:
	RTS

CODE_0DADA0:
	JMP.w CODE_0DAD65		; Random jump to waste 3 bytes + 3 cycles

SteepRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$00			;\
	STX.b !RAM_SMW_Misc_ScratchRAM02	; | Number of actual slope tiles (also, it's called STZ, morons)
	STX.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
	JMP.w CODE_0DADD0		; Go to loop

CODE_0DADBB:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$3F
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX
CODE_0DADC4:
	CPX.b #$01
	BNE.b CODE_0DADBB
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$E4			; | Add slope assist tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DADD0:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b Return0DADEA		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$AF			; | Add actual slope tile
	JSR.w SMW_FillInSlopeTileAir_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	INC.b !RAM_SMW_Misc_ScratchRAM02	;\
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; |
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; | Go to next line
	BPL.b CODE_0DADC4		;/
Return0DADEA:
	RTS

GradualRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$03			;\
	STX.b !RAM_SMW_Misc_ScratchRAM02	;/ Number of actual slope tiles (thanks for forgetting to waste some time with $00)
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
	JMP.w CODE_0DAE36		; Go to loop

CODE_0DAE01:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$3F
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX
CODE_0DAE0A:
	CPX.b #$07
	BNE.b CODE_0DAE01
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$E6			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$E6			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add slope assist tiles
	LDA.b #$DB			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$DC			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	DEX				; |
	DEX				; |
	DEX				; | Check for end of the object
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; |
	BEQ.b Return0DAE69		;/
CODE_0DAE36:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$82			; |
	JSR.w SMW_FillInSlopeTileAir_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$87			; |
	JSR.w SMW_FillInSlopeTileAir_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add actual slope tiles
	LDA.b #$8C			; |
	JSR.w SMW_FillInSlopeTileAir_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$91			; |
	JSR.w SMW_FillInSlopeTileAir_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	CLC				; |
	ADC.b #$04			; |
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | Go to next tile
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; |
	DEC.b !RAM_SMW_Misc_ScratchRAM00	; |
	BPL.b CODE_0DAE6A		;/
Return0DAE69:
	RTS

CODE_0DAE6A:
	JMP.w CODE_0DAE0A		; Another moronic waste-three-bytes-and-cycles code...

UpsideDownNormalLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	ASL				;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | Get width of first line
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Set the Is First Line flag
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Load number of tiles in line
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	JMP.w CODE_0DAE9E		; Go to loop

CODE_0DAE88:
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$C6			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add slope tiles
	LDA.b #$C7			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	DEX				; | Check if it's the last line
	BMI.b CODE_0DAEBD		;/
CODE_0DAE9E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$EE			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add slope assist tiles
	LDA.b #$F0			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	JMP.w CODE_0DAEBA		;/ Go to the next area

CODE_0DAEB2:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$65
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
CODE_0DAEBA:
	DEX
	BPL.b CODE_0DAEB2
CODE_0DAEBD:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\
	BNE.b CODE_0DAECC		; | Check if it's the first line, since we don't want the actual slope tiles on the first row
	INC.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	JMP.w CODE_0DAEF2		; Skip Move Pointer code

CODE_0DAECC:
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	SEC				; |
	SBC.b #$02			; | Update size
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$12			; | Update index
	TAY				;/
	BCC.b CODE_0DAEDE		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer downwards if needed
CODE_0DAEDE:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$02			; | Check if pointer should move downwards
	BPL.b CODE_0DAEF2		;/
	TYA				;\
	SEC				; |
	SBC.b #$10			; | Move pointer back up
	TAY				;/
	BCS.b ADDR_0DAEEF		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Update preserved pointer (isn't that done earlier too?)
ADDR_0DAEEF:
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer forwards
CODE_0DAEF2:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b Return0DAEFB		; | Check for end of the object
	JMP.w CODE_0DAE88		;/

Return0DAEFB:
	RTS

UpsideDownNormalRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	ASL				;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | Get width of first line
	INC.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Set Is First Line flag
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Load number of tiles in line
	JMP.w CODE_0DAF20		; Go to loop

CODE_0DAF17:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$65
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX
CODE_0DAF20:
	CPX.b #$04
	BPL.b CODE_0DAF17
	CPX.b #$02			;\
	BMI.b CODE_0DAF3C		;/ Don't add slope assist tiles in the last line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$F0			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add slope assist tiles
	LDA.b #$EF			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\
	BEQ.b CODE_0DAF4C		;/ Don't add actual slope tiles in top row
CODE_0DAF3C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$C8			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add actual slope tiles
	LDA.b #$C9			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DAF4C:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	SEC				; |
	SBC.b #$02			; | Go to next line
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	TAX				; Reload number of tiles in line
	INC.b !RAM_SMW_Misc_ScratchRAM01	; Clear Is First Line flag
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DAF20		;/ Check for end of the object
	RTS

UpsideDownSteepLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; |
	LSR				; | Get size
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	STA.b !RAM_SMW_Misc_ScratchRAM02	; |
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Set Is First Line flag
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Load number of remaining tiles on the line
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	JMP.w CODE_0DAF88		; Go into loop

CODE_0DAF7B:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Load number of remaining tiles on the line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$C4			; | Add actual slope tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX
	BMI.b CODE_0DAF9E
CODE_0DAF88:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$EC			; | Add slope assist tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DAF9B

CODE_0DAF93:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$65
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
CODE_0DAF9B:
	DEX
	BPL.b CODE_0DAF93
CODE_0DAF9E:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\
	BNE.b CODE_0DAFAF		;/ Don't move pointer rightwards from the right line
	INC.b !RAM_SMW_Misc_ScratchRAM01	; Clear Is First Line flag
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	JMP.w CODE_0DAFD5		; and go to Check For End Of Line code

CODE_0DAFAF:
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	SEC				; |
	SBC.b #$01			; | Update size of line (it's called DEC, morons)
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$11			; | Increase index and check if we hit a horizontal subscreen boundary
	TAY				; |
	BCC.b CODE_0DAFC1		;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	; Move pointer down if needed
CODE_0DAFC1:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$01			; | Check for vertical subscreen boundaries
	BPL.b CODE_0DAFD5		;/
	TYA				;\
	SEC				; |
	SBC.b #$10			; |
	TAY				; | Move pointer back up
	BCS.b CODE_0DAFD2		; |
	JSR.w CODE_0DAFDF		;/
CODE_0DAFD2:
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer rightwards
CODE_0DAFD5:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b Return0DAFDE		; | Check for end of the object
	JMP.w CODE_0DAF7B		;/

Return0DAFDE:
	RTS

CODE_0DAFDF:
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi
	SBC.b #$00
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi
	STA.b !RAM_SMW_Misc_ScratchRAM05
	RTS

UpsideDownSteepRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Set Is First Line flag
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	JMP.w CODE_0DB00B		; Go to loop

CODE_0DB002:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$65
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX
CODE_0DB00B:
	CPX.b #$02
	BPL.b CODE_0DB002
	CPX.b #$01			;\
	BMI.b CODE_0DB01F		;/ Don't add slope assist tiles on the last line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$ED			; | Add slope assist tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\
	BEQ.b CODE_0DB027		;/ Check Is First Line flag
CODE_0DB01F:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$C5			; | Add actual slope tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DB027:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM02	;\
	DEX				; | Update number of remaining lines (wow, you morons know how to use DEX?)
	STX.b !RAM_SMW_Misc_ScratchRAM02	;/
	INC.b !RAM_SMW_Misc_ScratchRAM01	; Clear Is First Line flag
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DB00B		;/ Check for end of the object
	RTS
namespace off
endmacro

;---------------------------------------------------------------------------

macro ROUTINE_SMW_FillInSlopeTileAir(Address)
namespace SMW_FillInSlopeTileAir
%InsertMacroAtXPosition(<Address>)

DATA_0DABF7:
	db $3F,$01,$03			; Table for tiles to change when we're on

DATA_0DABFA:
	db $01,$03,$04			; Table of what number to add when we're on one of those special tiles

; The routine that allows slopes to overlap with dirt tiles. It checks the
; Map16 tile below the current one for certain numbers and adds values to
; the current tile number to change it into the one with dirt behind it.
Main:
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	TXA									;\ Optimization: NES style coding
	PHA									;/
	LDX.b #$02
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
CODE_0DAC05:
	CMP.l DATA_0DABF7,x
	BEQ.b CODE_0DAC11
	DEX
	BPL.b CODE_0DAC05
	JMP.w CODE_0DAC1A

CODE_0DAC11:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\
	CLC				; |
	ADC.l DATA_0DABFA,x		; | Increase tile number
	STA.b !RAM_SMW_Misc_ScratchRAM0C	;/
CODE_0DAC1A:
	PLA									;\ Optimization: NES style coding
	TAX									;/
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	JMP.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; And add the tile (also, I didn't expect you to be smart enough to not use JSR RTS)
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj13_GroundEdgesAndVine(Address)
namespace SMW_StandardObj13_GroundEdgesAndVine
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $40		; Left edge
	db $41		; Right edge
	db $06		; Vine
	db $45		; Solid left and top edge
	db $4B		; Solid left edge
	db $48		; Solid right and top edge
	db $4C		; Solid right edge
	db $01		; Left edge with solid top
	db $03		; Right edge with solid top
	db $B6		; Solid left, very steep top left slope
	db $B7		; Solid right, very steep top left slope
	db $45		; Solid left + top, left facing bottom edge
	db $4B		; Solid left, left facing bottom edge
	db $48		; Solid right + top, right facing bottom edge
	db $4C		; Solid right, right facing bottom edge

MiddleTiles1:
	db $40		; Left edge
	db $41		; Right edge
	db $06		; Vine
	db $4B		; Solid left and top edge
	db $4B		; Solid left edge
	db $4C		; Solid right and top edge
	db $4C		; Solid right edge
	db $40		; Left edge with solid top
	db $41		; Right edge with solid top
	db $4B		; Solid left, very steep top left slope
	db $4C		; Solid right, very steep top left slope
	db $4B		; Solid left + top, left facing bottom edge
	db $4B		; Solid left, left facing bottom edge
	db $4C		; Solid right + top, right facing bottom edge
	db $4C		; Solid right, right facing bottom edge

MiddleTiles2:
	db $40		; Left edge
	db $41		; Right edge
	db $06		; Vine
	db $4B		; Solid left and top edge
	db $4B		; Solid left edge
	db $4C		; Solid right and top edge
	db $4C		; Solid right edge
	db $40		; Left edge with solid top
	db $41		; Right edge with solid top
	db $4B		; Solid left, very steep top left slope
	db $4C		; Solid right, very steep top left slope
	db $4B		; Solid left + top, left facing bottom edge
	db $4B		; Solid left, left facing bottom edge
	db $4C		; Solid right + top, right facing bottom edge
	db $4C		; Solid right, right facing bottom edge

BottomTiles:
	db $FF		; Left edge
	db $FF		; Right edge
	db $FF		; Vine
	db $FF		; Solid left and top edge
	db $FF		; Solid left edge
	db $FF		; Solid right and top edge
	db $FF		; Solid right edge
	db $FF		; Left edge with solid top
	db $FF		; Right edge with solid top
	db $FF		; Solid left, very steep top left slope
	db $FF		; Solid right, very steep top left slope
	db $E2		; Solid left + top, left facing bottom edge
	db $E2		; Solid left, left facing bottom edge
	db $E4		; Solid right + top, right facing bottom edge
	db $E4		; Solid right, right facing bottom edge

; Main creation code for object 13 (vine and edge objects).
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Get type
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	CPX.b #$03			; |
	BMI.b CODE_0DB08E		; | Set correct map16 page
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;/
CODE_0DB08E:
	LDA.l TopTiles,x		;\
	JSR.w CODE_0DB114		; | Add top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer down
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b CODE_0DB0E2		;/ Check if size=0
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	CPX.b #$09
	BPL.b CODE_0DB0AD
	CPX.b #$07
	BPL.b CODE_0DB0B0
	CPX.b #$03
	BMI.b CODE_0DB0B0
CODE_0DB0AD:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
CODE_0DB0B0:
	LDA.l MiddleTiles1,x		;\
	JSR.w CODE_0DB198		; | Add tile-below-top-tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b CODE_0DB0E2		;/ Check for end of the object (except the bottom tile)
CODE_0DB0C0:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	CPX.b #$09
	BPL.b CODE_0DB0CF
	CPX.b #$07
	BPL.b CODE_0DB0D2
	CPX.b #$03
	BMI.b CODE_0DB0D2
CODE_0DB0CF:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
CODE_0DB0D2:
	LDA.l MiddleTiles2,x		;\
	JSR.w CODE_0DB198		; | Add middle tiles
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DB0C0		;/ Check for end of the object (except bottom tile)
CODE_0DB0E2:
	CPX.b #$0B			;\
	BMI.b Return0DB0EF		;/ Check if it's one of the objects with a bottom tile
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l BottomTiles,x		; | Add bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
Return0DB0EF:
	RTS

DATA_0DB0F0:
	db $7D,$7E,$82,$83,$9B,$9C,$A0,$A1
	db $AA,$AB,$AF,$B0,$D8,$DC,$DE,$E0	; If on top of one of these...
	db $E2,$E4

DATA_0DB102:
	db $B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
	db $C0,$C1,$C2,$C3,$D9,$DD,$DF,$E1	; change to the corresponding one of these
	db $E3,$E5

CODE_0DB114:
	CPX.b #$03
	BMI.b CODE_0DB120
	CPX.b #$09
	BMI.b CODE_0DB120
	CPX.b #$0B
	BMI.b Return0DB15B
CODE_0DB120:
	CPX.b #$02
	BEQ.b Return0DB15B
	STX.b !RAM_SMW_Misc_ScratchRAM0B	; Preserve X
	STA.b !RAM_SMW_Misc_ScratchRAM0C	; Preserve tile number
	LDX.b #$11			; Size of tables
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
CODE_0DB12C:
	CMP.l DATA_0DB0F0,x
	BEQ.b CODE_0DB152
	DEX
	BPL.b CODE_0DB12C
	CMP.b #$25			;\
	BEQ.b CODE_0DB14D		;/ If on top of tile 025, don't change anything
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\
	CMP.b #$01			; |
	BEQ.b CODE_0DB14B		; |
	CMP.b #$03			; |
	BEQ.b CODE_0DB14B		; | Only run this check if we're trying to add tile 101, 103, 145, or 148
	CMP.b #$45			; |
	BEQ.b CODE_0DB14B		; |
	CMP.b #$48			; |
	BNE.b CODE_0DB14D		;/
CODE_0DB14B:
	INC.b !RAM_SMW_Misc_ScratchRAM0C
CODE_0DB14D:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	JMP.w CODE_0DB159

CODE_0DB152:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; Set map16 page
	LDA.l DATA_0DB102,x		; Load the tile to use
CODE_0DB159:
	LDX.b !RAM_SMW_Misc_ScratchRAM0B	; Reload X
Return0DB15B:
	RTS

DATA_0DB15C:
	db $6E,$6F,$73,$74,$78,$79,$7D,$7E
	db $82,$83,$87,$88,$8C,$8D,$91,$92
	db $96,$97,$9B,$9C,$A0,$A1,$A5,$A6	; If on top of one of these...
	db $AA,$AB,$AF,$B0,$E2,$E4

DATA_0DB17A:
	db $70,$70,$75,$75,$7A,$7A,$7F,$7F
	db $84,$84,$89,$89,$8E,$8E,$93,$93
	db $98,$98,$9D,$9D,$A2,$A2,$A7,$A7	; change to the corresponding one of these
	db $AC,$AC,$B1,$B1,$E9,$EA

CODE_0DB198:
	CPX.b #$03
	BMI.b CODE_0DB1A4
	CPX.b #$07
	BMI.b Return0DB1C7
	CPX.b #$09
	BPL.b Return0DB1C7
CODE_0DB1A4:
	CPX.b #$02
	BEQ.b Return0DB1C7
	STX.b !RAM_SMW_Misc_ScratchRAM0B	; Preserve X
	STA.b !RAM_SMW_Misc_ScratchRAM0C	; Preserve tile number
	LDX.b #$1D			; Size of tables
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
CODE_0DB1B0:
	CMP.l DATA_0DB15C,x
	BEQ.b CODE_0DB1BE
	DEX
	BPL.b CODE_0DB1B0
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\
	JMP.w CODE_0DB1C5		;/ If no match is found, return

CODE_0DB1BE:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; Set map16 page
	LDA.l DATA_0DB17A,x		; Load the tile to use
CODE_0DB1C5:
	LDX.b !RAM_SMW_Misc_ScratchRAM0B	; Reload X
Return0DB1C7:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj15_MidwayAndGoalPoint(Address)
namespace SMW_StandardObj15_MidwayAndGoalPoint
%InsertMacroAtXPosition(<Address>)

; The Map16 tiles that make up the midway point and goal point objects.
; There are 6 3-byte tables here that are, in order: Top tiles of midway
; point, middle tiles of midway point, bottom tiles of midway point, top
; tiles of goal point, middle tiles of goal point, bottom tiles of goal
; point. You can change $0DB221 to 3A and $0DB223 to 3D to fix the glitched
; tiles at the bottom of the goal point. (They will just appear the same as
; the middle tiles.)
TopMidwayTiles:
	db $2F,$25,$32			; Top tiles of midway point

MiddleMidwayTiles:
	db $30,$25,$33			; Middle tiles of midway point

BottomMidwayTiles:
	db $31,$25,$34			; Bottom tiles of midway point

TopGoalTiles:
	db $39,$25,$3C			; Top tiles of goal point

MiddleGoalTiles:
	db $3A,$25,$3D			; Middle tiles of goal point

BottomGoalTiles:
	db $3B,$25,$3E						; Glitch: These map16 tiles show garbage.

; Main creation code for the midway point/goal point object.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	LDX.b #$00
CODE_0DB23B:
	LDA.l TopMidwayTiles,x		;\
	STA.b !RAM_SMW_Misc_ScratchRAM03	; |
	LDA.b !RAM_SMW_Misc_ScratchRAM02	; |
	BEQ.b CODE_0DB24B		; | Check which tile we need
	LDA.l TopGoalTiles,x		; |
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
CODE_0DB24B:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM03	; | Add top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DB261		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DB261:
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BEQ.b CODE_0DB28F		;/ Check if it's one tile high
CODE_0DB265:
	LDA.l MiddleMidwayTiles,x	;\
	STA.b !RAM_SMW_Misc_ScratchRAM03	; |
	LDA.b !RAM_SMW_Misc_ScratchRAM02	; |
	BEQ.b CODE_0DB275		; | Check which tile we need
	LDA.l MiddleGoalTiles,x		; |
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
CODE_0DB275:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM03	; | Add middle tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DB28B		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DB28B:
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BNE.b CODE_0DB265		;/ Check if we need to add more middle tiles
CODE_0DB28F:
	LDA.l BottomMidwayTiles,x	;\
	STA.b !RAM_SMW_Misc_ScratchRAM03	; |
	LDA.b !RAM_SMW_Misc_ScratchRAM02	; |
	BEQ.b CODE_0DB29F		; | Check which tile we need
	LDA.l BottomGoalTiles,x		; |
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
CODE_0DB29F:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM03	; | Add bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$01			; |
	TAY				; | Check if we hit a subscreen boundary
	AND.b #$0F			; |
	BNE.b CODE_0DB2BB		;/
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer forwards
	LDA.b !RAM_SMW_Blocks_SubScrPos
	AND.b #$F0
	TAY
CODE_0DB2BB:
	STY.b !RAM_SMW_Blocks_SubScrPos
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Reload size
	INX				;\
	CPX.b #$03			; |
	BEQ.b Return0DB2C9		; | Check for end of the object
	JMP.w CODE_0DB23B		;/

Return0DB2C9:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj16_PurpleCoins(Address)
namespace SMW_StandardObj16_PurpleCoins
%InsertMacroAtXPosition(<Address>)

; Optimization: This object could have easily been combined with "StandardObjXX_Generic1RepeatedTileObject" with some minor changes to that routine.

; Main creation code for the purple coins. This is very similar to the code
; at $0DA8C3.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Width
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
ADDR_0DB34A:
	TYA									;\ Optimization: NES style coding
	PHA									;|
	TXA									;|
	PHA									;/
	LDX.w !RAM_SMW_Misc_ItemMemorySetting
	LDA.b #$F8
	CLC
	ADC.l SMW_Bank0DItemMemoryIndexes_Lo,x
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b #($1900+!Define_SMW_LowRAMLocation)>>8	; High byte of the item
	ADC.l SMW_Bank0DItemMemoryIndexes_Hi,x	; memory table, which moves
					; with low RAM.
	STA.b !RAM_SMW_Misc_ScratchRAM09
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceNextObject
	ASL
	ASL
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	AND.b #$10
	BEQ.b ADDR_0DB375
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ORA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM0E
ADDR_0DB375:
	TYA
	AND.b #$08
	BEQ.b ADDR_0DB380
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	ORA.b #$01
	STA.b !RAM_SMW_Misc_ScratchRAM0E
ADDR_0DB380:
	TYA
	AND.b #$07
	TAX
#LM171Hijack_ItemMemory3Revamp5:
	LDY.b !RAM_SMW_Misc_ScratchRAM0E					;\ LM: Hijacks here to make item memory index 3 not track items collected (1.71+)
	LDA.b (!RAM_SMW_Misc_ScratchRAM08),y					;/
	AND.l SMW_BitTable_Bank0D,x
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	PLA									;\ Optimization: NES style coding
	TAX									;|
	PLA									;|
	TAY									;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; Set map16 page (even if the coin has been taken)
	LDA.b #$2C			;\
	STA.b !RAM_SMW_Misc_ScratchRAM0C	;/ Object to generate
	LDA.b !RAM_SMW_Misc_ScratchRAM0F	;\
	BEQ.b ADDR_0DB3A3		;/ Check item memory flag
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	; Update pointer...?
	JMP.w ADDR_0DB3A8		; Skip Add Object code

ADDR_0DB3A3:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add object
ADDR_0DB3A8:
	DEX				;\
	BPL.b ADDR_0DB34A		;/ Check for end of the row
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BMI.b Return0DB3BA		; | Check for end of the object
	JMP.w ADDR_0DB34A		;/

Return0DB3BA:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj17_RopeAndCloudLine(Address)
namespace SMW_StandardObj17_RopeAndCloudLine
%InsertMacroAtXPosition(<Address>)

; Rope: MAP16 block
Tiles:
	db $05			; Rope
	; Clouds: MAP16 block
	db $06			; Clouds

; Main creation code for the rope and cloud objects.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Type
	LSR				; |
	TAX				;/
CODE_0DB3CC:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DB3CC		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj18_WaterWithAnimatedSurface(Address)
namespace SMW_StandardObj18_WaterWithAnimatedSurface
%InsertMacroAtXPosition(<Address>)

; Water with animated surface: MAP16 block (Top)
TopTiles:
	db $00		; Water with animated surface
	; Water with normal surface: MAP16 block (Top)
	db $01		; Water with normal surface
	; Lava with animated surface: MAP16 block (Top)
	db $04		; Mud/lava with animated surface
	; Climbing net with top edge: MAP16 block (Top)
	db $08		; Climbing net with top edge

; Water with animated surface: MAP16 block (Bottom)
BottomTiles:
	db $02		; Water with animated surface
	; Water with normal surface: MAP16 block (Bottom)
	db $03		; Water with normal surface
	; Lava with animated surface: MAP16 block (Bottom)
	db $05		; Mud/lava with animated surface
	; Climbing net with top edge: MAP16 block (Bottom)
	db $0B		; Climbing net with top edge

; Main creation subroutine for objects 18-1B (water with and without
; animated surface, lava, climbing net with top edge). It is also used as
; the default routine for unused objects 22-2D.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	TXA				;\
	SEC				; |
	SBC.b #$17			; | Type
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DB3FD:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l TopTiles,x		; | Add top tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BPL.b CODE_0DB3FD		; | Check for end of the row
	JMP.w CODE_0DB41C		;/

CODE_0DB40E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l BottomTiles,x		; | Add middle tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BPL.b CODE_0DB40E		;/ Check for end of the row
CODE_0DB41C:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DB40E		;/ Check for end of the object
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj19_WaterWithNormalSurface_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj1A_CastleLavaWithAnimatedSurface_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj1B_ClimbingNetWithTopEdge_Main)
; Objects 22, 23, 27, 29 and 2D are the five numbers Lunar Magic gives its
; direct Map16 objects and its reserved user-defined one. On the stock
; cartridge they are aliases of the water object like the rest of the
; span; under Define_SMW_CustomTiles the same five labels are the custom
; tiles' own routines, defined where that block is placed
; (Config/CustomTiles.asm), so the dispatch tables name them either way.
if !Define_SMW_CustomTiles == !FALSE
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj22_DirectTilePage0_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj23_DirectTilePage1_Main)
endif
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj24_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj25_Unused_Main)
; Objects 26 and 28 are the two numbers Lunar Magic gives its music and time
; limit bypasses. On the stock cartridge they are aliases of the water object
; like the rest of the span; under Define_SMW_HeaderBypasses the same two
; labels are the bypasses' own routines, defined where that block is placed
; (Config/HeaderBypasses.asm), so the dispatch tables name them either way.
if !Define_SMW_HeaderBypasses == !FALSE
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj26_MusicBypass_Main)
endif
if !Define_SMW_CustomTiles == !FALSE
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj27_DirectTiles_Main)
endif
if !Define_SMW_HeaderBypasses == !FALSE
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj28_TimeLimitBypass_Main)
endif
if !Define_SMW_CustomTiles == !FALSE
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj29_DirectTilesHighPages_Main)
endif
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj2A_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj2B_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj2C_Unused_Main)
if !Define_SMW_CustomTiles == !FALSE
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_StandardObj2D_UserDefined_Main)
endif
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_GrasslandObj2E_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_GrasslandObj2F_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_CastleObj2E_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_CastleObj2F_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_CastleObj30_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_CastleObj31_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_CastleObj32_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_CastleObj33_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_RopeObj2E_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_RopeObj2F_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_RopeObj30_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_RopeObj31_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_UndergroundObj2E_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_UndergroundObj2F_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_UndergroundObj30_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_UndergroundObj31_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_UndergroundObj32_Unused_Main)
	%SetDuplicateOrNullPointer(SMW_StandardObj18_WaterWithAnimatedSurface_Main, SMW_UndergroundObj33_Unused_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj1C_DonutBridge(Address)
namespace SMW_StandardObj1C_DonutBridge
%InsertMacroAtXPosition(<Address>)

; Donut bridge: MAP16 block (Top)
Tiles:
	db $26				; Top tile
	; Donut bridge: MAP16 block (Bottom)
	db $44				; Bottom tile

; Main creation code for the donut bridge (object 1C).
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Width (the height bits are obviously unused)
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b #$00
CODE_0DB43C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	CPX.b #$00			; |
	BEQ.b CODE_0DB446		; | Set map16 page
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;/
CODE_0DB446:
	LDA.l Tiles,x			;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add tile
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DB43C		;/ Check for end of the row
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Reload width
	INX				;\
	CPX.b #$02			; | Check for end of the object
	BNE.b CODE_0DB43C		;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj1D_ClimbingNetWithBottomEdge(Address)
namespace SMW_StandardObj1D_ClimbingNetWithBottomEdge
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	; | Width
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b CODE_0DB490		;/ Check if it's one tile high
CODE_0DB479:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$0B			; | Add middle tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DB479		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Reload size
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DB479		;/ Check if we're on the last line
CODE_0DB490:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$0E			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DB490		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj1E_ClimbingNetWithSideEdge(Address)
namespace SMW_StandardObj1E_ClimbingNetWithSideEdge
%InsertMacroAtXPosition(<Address>)

SideTiles:
	db $0A
	db $0C

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	LDA.l SideTiles,x		;\
	JSR.w CODE_0DB4D9		;/ Add top tile
	JMP.w CODE_0DB4C0		; Go to loop

CODE_0DB4B7:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l SideTiles,x		; | Add middle tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
CODE_0DB4C0:
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; | Move pointer downwards
	BCC.b CODE_0DB4CA		; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
CODE_0DB4CA:
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DB4B7		;/ Check for end of the object (except bottom tile)
	LDA.l SideTiles,x		;\
	JMP.w CODE_0DB4FE		;/ Add bottom tile

TopCornerTiles:
	db $07,$09			; New tiles if it's on a top edge

TopInnerCornerTiles:
	db $1A,$19			; New tiles if it's on a bottom edge

CODE_0DB4D9:
	STA.b !RAM_SMW_Misc_ScratchRAM0C	; Preserve tile
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	; Load tile we're on
	CMP.b #$08			;\
	BNE.b CODE_0DB4E8		;/ Check if we're on a top edge
	LDA.l TopCornerTiles,x		;\
	JMP.w CODE_0DB4F0		;/ Change to new tile

CODE_0DB4E8:
	CMP.b #$0E			;\
	BNE.b CODE_0DB4F2		;/ Check if we're on a bottom edge
	LDA.l TopInnerCornerTiles,x
CODE_0DB4F0:
	STA.b !RAM_SMW_Misc_ScratchRAM0C
CODE_0DB4F2:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS

BottomCornerTiles:
	db $0D,$0F			; New tiles if it's on a bottom edge

BottomInnerCornerTiles:
	db $1C,$1B			; New tiles if it's on a top edge

CODE_0DB4FE:
	STA.b !RAM_SMW_Misc_ScratchRAM0C	; Preserve tile
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	; Load tile we're on
	CMP.b #$0E			;\
	BNE.b CODE_0DB50D		;/ Check if we're on a bottom edge
	LDA.l BottomCornerTiles,x	;\
	JMP.w CODE_0DB515		;/ Change to new tile

CODE_0DB50D:
	CMP.b #$08			;\
	BNE.b CODE_0DB517		;/ Check if we're on a top edge
	LDA.l BottomInnerCornerTiles,x
CODE_0DB515:
	STA.b !RAM_SMW_Misc_ScratchRAM0C
CODE_0DB517:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM0C	; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj1F_SkinnyVerticalPipeBoneLog(Address)
namespace SMW_StandardObj1F_SkinnyVerticalPipeBoneLog
%InsertMacroAtXPosition(<Address>)

; Vertical pipe/bone/log object creation subroutine. $0DB52E, $0DB536, and
; $0DB543 determine which three Map16 tiles make up the object.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$F0			; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	LSR				; |
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$53			; | Add top tile
	JMP.w CODE_0DB537		;/

CODE_0DB532:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$54
CODE_0DB537:
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEX				;\
	BNE.b CODE_0DB532		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$55			; | Add bottom tiles
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj20_SkinnyHorizontalPipeBoneLog(Address)
namespace SMW_StandardObj20_SkinnyHorizontalPipeBoneLog
%InsertMacroAtXPosition(<Address>)

; Horizontal pipe/bone/log object creation subroutine. $0DB552, $0DB55A, and
; $0DB565 determine which three Map16 tiles make up the object.
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$56			; | Add left tile
	JMP.w CODE_0DB55B		;/

CODE_0DB556:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$57
CODE_0DB55B:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX				;\
	BNE.b CODE_0DB556		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$58			; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_StandardObj21_WideScaleGroundLedge(Address)
namespace SMW_StandardObj21_WideScaleGroundLedge
%InsertMacroAtXPosition(<Address>)

; Main creation code for objects 14 and 21, the normal ledge and wide ground
; ledge. They share most of their code, but the wide ledge begins at
; $0DB1C8, while the normal one begins at $0DB1D4. $0DB1CE - Height of the
; wide ground ledge - 1. The top tile is 100, the rest is 03F.
Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Load width
	TAX				;/
	LDA.b #$02			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Load height
	JMP.w CODE_0DB1E3		; Go to loop

StandardLedgeEntry:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Get width
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Get height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
CODE_0DB1E3:
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
CODE_0DB1E8:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$00			; | Add top tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	CPX.b #$FF			; |
	BNE.b CODE_0DB1E8		; | Check for end of the row
	JMP.w CODE_0DB205		;/

CODE_0DB1F8:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add bottom tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	CPX.b #$FF			; | Check for end of line
	BNE.b CODE_0DB1F8		;/
CODE_0DB205:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	;\
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; | Go to next row
	BPL.b CODE_0DB1F8		;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_StandardObj21_WideScaleGroundLedge_StandardLedgeEntry, SMW_StandardObj14_Ledge_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj30_IcyVerticalPipe(Address)
namespace SMW_GrasslandObj30_IcyVerticalPipe
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$61			; | Add top left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$62			; | Add top right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JMP.w CODE_0DBB59

CODE_0DBB4A:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$63			; | Add middle left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$64			; | Add middle right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
CODE_0DBB59:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEX				;\
	BPL.b CODE_0DBB4A		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj32_BlueSwitchBlocks(Address)
namespace SMW_GrasslandObj32_BlueSwitchBlocks
%InsertMacroAtXPosition(<Address>)

; Main creation code for the red and blue switch blocks. Note that the
; actual object number varies per tileset. (It was really dumb that Nintendo
; did that...oh well.) $0DB916 - Start of the code for the blue block.
; $0DB91A - Map16 tiles (on page 0) for the outline blocks. $0DB91C - Map16
; tiles (on page 1) for the filled-in blocks. $0DB91E - Start of the code
; for the red block. $0DB943 - Change F0 to D0 to invert the Blue and Red
; Switch Palace blocks.
Main:
	LDX.b #$00			; Set tile to blue switch tile
	BEQ.b CODE_0DB920 		; Note: More NES coding

InactiveTiles:
	db $6C				; Blue switch blocks
	db $6D				; Red switch blocks

ActiveTiles:
	db $6C				; Blue switch blocks
	db $6D				; Red switch blocks

RedSwitchBlockEntry:
	LDX.b #$01			; Set tile to red switch tile
CODE_0DB920:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
CODE_0DB930:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Load width
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DB937:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l InactiveTiles,x		; |
	STA.b !RAM_SMW_Misc_ScratchRAM0F	; |
	LDA.w !RAM_SMW_Flag_ActivatedBlueSwitch,x	; |
	BEQ.b CODE_0DB94E		; | Load the tile we need
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.l ActiveTiles,x		; |
	STA.b !RAM_SMW_Misc_ScratchRAM0F	;/
CODE_0DB94E:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F	;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add tile
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BPL.b CODE_0DB937		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DB930		;/ Check for end of the object
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_GrasslandObj32_BlueSwitchBlocks_RedSwitchBlockEntry, SMW_GrasslandObj38_RedSwitchBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_GrasslandObj32_BlueSwitchBlocks_Main, SMW_CastleObj39_BlueSwitchBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_GrasslandObj32_BlueSwitchBlocks_RedSwitchBlockEntry, SMW_CastleObj3A_RedSwitchBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_GrasslandObj32_BlueSwitchBlocks_Main, SMW_RopeObj33_BlueSwitchBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_GrasslandObj32_BlueSwitchBlocks_RedSwitchBlockEntry, SMW_RopeObj34_RedSwitchBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_GrasslandObj32_BlueSwitchBlocks_Main, SMW_UndergroundObj34_BlueSwitchBlocks_Main)
	%SetDuplicateOrNullPointer(SMW_GrasslandObj32_BlueSwitchBlocks_RedSwitchBlockEntry, SMW_UndergroundObj35_RedSwitchBlocks_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj33_ForestTreeTop(Address)
namespace SMW_GrasslandObj33_ForestTreeTop
%InsertMacroAtXPosition(<Address>)

; Forest treetop tilemap (repeated a few times)
Tiles:
	db $B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4
	db $B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4
	db $B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B4,$B5,$B3,$B5,$B3
	db $B3,$B4,$B4,$B5,$B3,$B4,$B4,$B4,$B4,$B5,$B3,$B5,$B6,$B1,$B6,$B1
	db $B1,$B3,$B5,$B6,$B1,$B3,$B5,$B3,$B5,$B6,$B1,$B6,$25,$25,$25,$25
	db $25,$B1,$B6,$25,$25,$B1,$B6,$B1,$B6,$25,$25,$25,$25,$25,$25,$25

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	STA.b !RAM_SMW_Misc_ScratchRAM0F	;/ Copy size
CODE_0DBAE0:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	STA.b !RAM_SMW_Misc_ScratchRAM0E	; | Copy position
	TAY				;/
	LDX.b #$00
	LDA.b #$05			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Height
	LDA.b #$0F			;\
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/ Width of one screen
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DBAF2:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Copy width
CODE_0DBAF6:
	LDA.l Tiles,x			;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add tile
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; | Check for end of the line
	BPL.b CODE_0DBAF6		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM0E	;\
	CLC				; |
	ADC.b #$10			; |
	STA.b !RAM_SMW_Misc_ScratchRAM0E	; | Move pointer downwards one tile
	TAY				; |
	BCC.b CODE_0DBB12		; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
CODE_0DBB12:
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DBAF2		;/ Check for end of this area
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataLo					;\ LM: Modifies this code so this object doesn't glitch up when placed outside a specific Y range. (3.02+)
	CLC										;|
	ADC.b #$B0									;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo					;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo					;|
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi					;|
	ADC.b #$00									;/
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi
	DEC.b !RAM_SMW_Misc_ScratchRAM0F	;\
	BPL.b CODE_0DBAE0		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj34_ForestGroundEdges(Address)
namespace SMW_GrasslandObj34_ForestGroundEdges
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $5F				; Solid left and top edge (forest)
	db $5E				; Solid right and top edge (forest)
	db $10				; Right edge with solid top (forest)
	db $0F				; Left edge with solid top (forest)

BottomTiles:
	db $60				; Solid left and top edge (forest)
	db $5D				; Solid right and top edge (forest)
	db $C5				; Right edge with solid top (forest)
	db $C4				; Left edge with solid top (forest)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopTiles,x		; | Add top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JMP.w CODE_0DBA74

CODE_0DBA67:
	CPX.b #$02			;\
	BPL.b CODE_0DBA6E		;/ Check if it's got a solid left/right edge
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
CODE_0DBA6E:
	LDA.l BottomTiles,x
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
CODE_0DBA74:
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer down
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DBA67		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj35_ForestGround(Address)
namespace SMW_GrasslandObj35_ForestGround
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Width
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DBA1E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$0E			; | Add actual ledge tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DBA1E		; | Check for end of the row
	JMP.w CODE_0DBA37		;/

CODE_0DBA2C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$B8			; | Add dirt tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DBA2C		;/ Check for end of the row
CODE_0DBA37:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DBA2C		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj36_LargeTreeTrunk(Address)
namespace SMW_GrasslandObj36_LargeTreeTrunk
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height (width bits are unused)
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DB9CA:
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	LDX.b #$B9			;\
	JSR.w CODE_0DB9F6		;/ Add 0B9 and 0BA tiles
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b Return0DB9F5		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$BB			; | Add 0BB tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$BC			; | Add 0BC tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DB9CA		;/ Check for end of the object
Return0DB9F5:
	RTS

CODE_0DB9F6:
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;\
	CMP.b #$0E			; | If we're on tile 10E...
	BNE.b CODE_0DBA01		;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDX.b #$0B			;/ add 10B/10C instead
CODE_0DBA01:
	TXA				;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	INX				; | Add tiles
	TXA				; |
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj37_SmallTreeTrunk(Address)
namespace SMW_GrasslandObj37_SmallTreeTrunk
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $BD		; Small tree trunk (forest)
	db $BF		; ...go under tree enabled

BottomTiles:
	db $BE		; Small tree trunk (forest)
	db $C0		; ...go under tree enabled

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DB975:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l TopTiles,x		; | Add upper tile
	JSR.w CODE_0DB997		;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b Return0DB996		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l BottomTiles,x		; | Add lower tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DB975		;/ Check for end of the object
Return0DB996:
	RTS

CODE_0DB997:
	STA.b !RAM_SMW_Misc_ScratchRAM0F	; Preserve tile to add
	CPX.b #$01			;\
	BNE.b CODE_0DB9AE		;/ Check which type of tree trunk it is
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	CMP.b #$B1
	BEQ.b CODE_0DB9A7
	CMP.b #$B6
	BNE.b CODE_0DB9BB
CODE_0DB9A7:
	STA.b !RAM_SMW_Misc_ScratchRAM0F
	INC.b !RAM_SMW_Misc_ScratchRAM0F
	JMP.w CODE_0DB9BB

CODE_0DB9AE:
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;\
	CMP.b #$0E			; | If the one above everything is on top of tile 10E...
	BNE.b CODE_0DB9BB		;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$0D			; | add tile 10D instead
	STA.b !RAM_SMW_Misc_ScratchRAM0F	;/
CODE_0DB9BB:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F	;\
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/ Add the tile
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj39_RightFacingDiagonalPipe(Address)
namespace SMW_GrasslandObj39_RightFacingDiagonalPipe
%InsertMacroAtXPosition(<Address>)

; Map16 data for the diagonal pipe (low bytes only).
Tiles:
	db $C4,$C5
	db $C7,$EC,$ED,$C6
	db $C7,$EE,$59,$5A,$EF
	db $C7,$EE,$59,$5B,$5C

; Main creation code for the diagonal pipe object. $0DB7A6 - The Map16 tile
; (on page 1) at the bottom of the diagonal pipe object. (Default: $EB.)
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b #$01			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Number of tiles in first row
	LDX.b #$00
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DB752:
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload number of tiles in row
CODE_0DB756:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; | Go to next tile
	BPL.b CODE_0DB756		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_GoDownLeftAndUpdateLevelDataPointerInObjects_Main	; Move pointer down and left
	INC.b !RAM_SMW_Misc_ScratchRAM01	;\
	INC.b !RAM_SMW_Misc_ScratchRAM01	;/ Increase size of the next line
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b CODE_0DB79F		;/ Check for end of the object
	CPX.b #$06			;\
	BNE.b CODE_0DB752		;/ Check if the object should keep getting bigger
	DEC.b !RAM_SMW_Misc_ScratchRAM01	; The size of the last lines is 5, not 6
CODE_0DB779:
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width of the line
CODE_0DB77D:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; | Check for end of the row
	BPL.b CODE_0DB77D		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_GoDownLeftAndUpdateLevelDataPointerInObjects_Main	; Move pointer down and left
	CPX.b #$10			;\
	BNE.b CODE_0DB79B		;/ Check if we're at the end of the table
	TXA				;\
	SEC				; |
	SBC.b #$05			; | Decrease X if needed
	TAX				;/
CODE_0DB79B:
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DB779		;/ Check for end of the object
CODE_0DB79F:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Entry2	; Move pointer down
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$EB			; | Add bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObjXX_DiagonalLedge(Address)
namespace SMW_GrasslandObjXX_DiagonalLedge
%InsertMacroAtXPosition(<Address>)

; Main creation code for the left-facing diagonal ledge.
LeftFacingDiagonalLedgeEntry:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Height
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Width
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
	LDX.b #$01			;\
	STX.b !RAM_SMW_Misc_ScratchRAM01	;/ Width of top row (not used)
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$AA
	JSR.w SMW_FillInSlopeTileAir_Main
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l SMW_SetMap16HighByteForCurrentObject_Page00		;\ Glitch: This should be a JSR.w!
else									;|
	LDA.w SMW_SetMap16HighByteForCurrentObject_Page00		;/
endif
	LDA.b #$A1
	JSR.w AddDiagonalBlackLinesToDirt
	JMP.w CODE_0DB7FD

CODE_0DB7D6:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$AA			; | Add slope tile
	JSR.w SMW_FillInSlopeTileAir_Main	;/
	DEX
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$E2			; | Add slope assist tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DB7F2

CODE_0DB7EA:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add dirt tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DB7F2:
	DEX				;\
	BNE.b CODE_0DB7EA		;/ Check if we need any dirt tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A6			; | Add the right tile with the diagonal line
	JSR.w AddDiagonalBlackLinesToDirt	;/
CODE_0DB7FD:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_GoDownLeftAndUpdateLevelDataPointerInObjects_Main	; Move pointer down and left
	INC.b !RAM_SMW_Misc_ScratchRAM01	;\
	INC.b !RAM_SMW_Misc_ScratchRAM01	;/ Increase width of the row
	LDX.b !RAM_SMW_Misc_ScratchRAM01
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BPL.b CODE_0DB7D6		;/ Go up and add more slope tiles if needed
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Entry2	; Go down
	STY.b !RAM_SMW_Blocks_SubScrPos	;\
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	;/ Preserve pointer/etc
	DEX
	STX.b !RAM_SMW_Misc_ScratchRAM01
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$F7			; | Add lower leftmost tile
	JSR.w SMW_FillInSlopeTileAir_Main	;/
	JMP.w CODE_0DB836

CODE_0DB823:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A3			; | Add the left tile with the diagonal line
	JSR.w AddDiagonalBlackLinesToDirt	;/
	JMP.w CODE_0DB836

CODE_0DB82E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add ground tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DB836:
	DEX				;\
	BNE.b CODE_0DB82E		;/ Check if we need more ground tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A6			; | Add the right tile with the diagonal line
	JSR.w AddDiagonalBlackLinesToDirt	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_GoDownRightAndUpdateLevelDataPointerInObjects_Main	; Move pointer down/right
	LDX.b !RAM_SMW_Misc_ScratchRAM01	;\
	DEC.b !RAM_SMW_Misc_ScratchRAM03	; | Check if we need more ground tiles
	BPL.b CODE_0DB823		;/
	RTS

AddDiagonalBlackLinesToDirt:
	STA.b !RAM_SMW_Misc_ScratchRAM0F	; Preserve tile
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	; Load the tile we're on
	CMP.b #$25			;\
	BEQ.b CODE_0DB85E		;/ Don't change anything if we're on an air tile
	CMP.b #$3F			;\
	BEQ.b CODE_0DB85C		;/ Only go forwards one tile if we're on dirt
	INC.b !RAM_SMW_Misc_ScratchRAM0F
CODE_0DB85C:
	INC.b !RAM_SMW_Misc_ScratchRAM0F
CODE_0DB85E:
	LDA.b !RAM_SMW_Misc_ScratchRAM0F	;\
	JMP.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add the requested tile

; Main creation code for the right-facing diagonal ledge.
RightFacingDiagonalLedgeEntry:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
	LDX.b #$01			;\
	STX.b !RAM_SMW_Misc_ScratchRAM01	;/ Width of first row
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
if ver_is_japanese(!Define_Global_ROMToAssemble)
	LDA.l SMW_SetMap16HighByteForCurrentObject_Page00		;\ Glitch: This should be a JSR.w!
else									;|
	LDA.w SMW_SetMap16HighByteForCurrentObject_Page00		;/
endif
	LDA.b #$AF
	JSR.w AddDiagonalBlackLinesToDirt
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$AF
	JSR.w SMW_FillInSlopeTileAir_Main
	JMP.w CODE_0DB8B7

CODE_0DB88F:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A9			; | Add the left tile with the diagonal line
	JSR.w AddDiagonalBlackLinesToDirt	;/
	JMP.w CODE_0DB8A2

CODE_0DB89A:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add dirt tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DB8A2:
	DEX				;\
	CPX.b #$01			; | Check if we need more dirt tiles
	BNE.b CODE_0DB89A		;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$E4			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; | Add slope + slopeassist tiles
	LDA.b #$AF			; |
	JSR.w SMW_FillInSlopeTileAir_Main	;/
CODE_0DB8B7:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_GoDownLeftAndUpdateLevelDataPointerInObjects_Main	; Move pointer down and left
	INC.b !RAM_SMW_Misc_ScratchRAM01	;\
	INC.b !RAM_SMW_Misc_ScratchRAM01	;/ Increase width of future lines
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Load width
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BPL.b CODE_0DB88F		;/ Check if we need dirt tiles
	DEX				;\
	STX.b !RAM_SMW_Misc_ScratchRAM01	;/ Lower width of the next line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A9			; | Add the left tile with the diagonal line
	JSR.w AddDiagonalBlackLinesToDirt	;/
	JMP.w CODE_0DB8DD

CODE_0DB8D5:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add dirt tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DB8DD:
	DEX				;\
	BNE.b CODE_0DB8D5		;/ Check if we need more dirt tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$F9			; | Add the lower rightmost tile
	JSR.w AddDiagonalBlackLinesToDirt	;/
	JMP.w CODE_0DB909

CODE_0DB8EB:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A9			; | Add the left tile with the diagonal line
	JSR.w AddDiagonalBlackLinesToDirt	;/
	JMP.w CODE_0DB8FE

CODE_0DB8F6:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add dirt tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DB8FE:
	DEX				;\
	BNE.b CODE_0DB8F6		;/ Check if we need more dirt tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$AC			; | Add the right tile with the diagonal line
	JSR.w AddDiagonalBlackLinesToDirt	;/
CODE_0DB909:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_GoDownLeftAndUpdateLevelDataPointerInObjects_Main	; Move pointer down and left
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM03	;\
	BPL.b CODE_0DB8EB		;/ Check for end of the object
	RTS

namespace off
	%SetDuplicateOrNullPointer(SMW_GrasslandObjXX_DiagonalLedge_LeftFacingDiagonalLedgeEntry, SMW_GrasslandObj3A_LeftFacingDiagonalLedge_Main)
	%SetDuplicateOrNullPointer(SMW_GrasslandObjXX_DiagonalLedge_RightFacingDiagonalLedgeEntry, SMW_GrasslandObj3B_RightFacingDiagonalLedge_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj3C_ArchLedge(Address)
namespace SMW_GrasslandObj3C_ArchLedge
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $07,$0A,$0A,$08,$0A,$0A,$09
	db $81,$82,$83,$81,$82,$83,$81
	db $81,$25,$84,$81,$25,$84,$81
	db $81,$25,$84,$81,$25,$84,$81

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b #$03			;\
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/ Height
	LDX.b #$00
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width
	LDA.b #$02			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Number of tiles in left area
CODE_0DB61D:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM01	; | Check for end of the left area
	BPL.b CODE_0DB61D		;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BEQ.b CODE_0DB652		;/ Check if it has a middle area
CODE_0DB630:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.l Tiles+$01,x		; | Add middle tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.l Tiles+$02,x		; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BNE.b CODE_0DB630		;/ Check if we need more middle tiles
CODE_0DB652:
	TXA				;\
	CLC				; |
	ADC.b #$03			; | Update index to table
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DB6B2		; Go to loop to add the lower tiles

CODE_0DB664:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width
	LDA.b #$02			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Number of tiles in left area
CODE_0DB66E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add left tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX				;\
	DEC.b !RAM_SMW_Misc_ScratchRAM01	; | Check if we need more left tiles
	BPL.b CODE_0DB66E		;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BEQ.b CODE_0DB6A3		;/ Check if it has a middle area
CODE_0DB681:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; |
	LDA.l Tiles+$01,x		; | Add middle tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; |
	LDA.l Tiles+$02,x		; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BNE.b CODE_0DB681		;/ Check if we need more middle tiles
CODE_0DB6A3:
	TXA				;\
	CLC				; |
	ADC.b #$03			; | Update index to table
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DB6B2:
	INX
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer down
	DEC.b !RAM_SMW_Misc_ScratchRAM03	;\
	BMI.b Return0DB6C0		; | Check for end of the object
	JMP.w CODE_0DB664		;/

Return0DB6C0:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj3D_TopCloudFridge(Address)
namespace SMW_GrasslandObj3D_TopCloudFridge
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $93		; Top cloud fringe
	db $9C		; Top cloud fringe on white

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Size
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Type
	LSR				; |
	TAX				;/
CODE_0DB6D2:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DB6D2		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj3E_SideCloudFridges(Address)
namespace SMW_GrasslandObj3E_SideCloudFridges
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $94		; Left cloud fridge 1
	db $8F		; Left cloud fridge 2
	db $9D		; Left cloud fridge 1 on white
	db $98		; Left cloud fridge 2 on white
	db $95		; Right cloud fridge 1
	db $90		; Right cloud fridge 2
	db $9E		; Right cloud fridge 1 on white
	db $99		; Right cloud fridge 2 on white

BottomTiles:
	db $8F		; Left cloud fridge 1
	db $8F		; Left cloud fridge 2
	db $98		; Left cloud fridge 1 on white
	db $98		; Left cloud fridge 2 on white
	db $90		; Right cloud fridge 1
	db $90		; Right cloud fridge 2
	db $99		; Right cloud fridge 1 on white
	db $99		; Right cloud fridge 2 on white

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l TopTiles,x		; | Add top tile
	JMP.w ADDR_0DB725		;/

ADDR_0DB71E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.l BottomTiles,x
ADDR_0DB725:
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b ADDR_0DB71E		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GrasslandObj3F_SmallBushes(Address)
namespace SMW_GrasslandObj3F_SmallBushes
%InsertMacroAtXPosition(<Address>)

; Tiles the Bushes 1-5 is made up of, in order of Left-Middle-right (five
; bytes per part)
LeftTiles:
	db $73		; Bush 1
	db $7A		; Bush 2
	db $85		; Bush 3
	db $88		; Bush 4 (not used?)
	db $C3		; Bush 5 (not used?)

MiddleTiles:
	db $74		; Bush 1
	db $7B		; Bush 2
	db $86		; Bush 3
	db $89		; Bush 4 (not used?)
	db $C3		; Bush 5 (not used?)

RightTiles:
	db $79		; Bush 1
	db $80		; Bush 2
	db $87		; Bush 3
	db $8E		; Bush 4 (not used?)
	db $C3		; Bush 5 (not used?)

; 6A-Green Switch Palace Block after you beat its Palace (always Map16 page
; 1)
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	; 6A-Green Switch Palace Block after you beat its Palace (always Map16 page
	; 0)
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Type
	LSR				; |
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l LeftTiles,x		; | Add left tile
	JMP.w CODE_0DB5D7		;/

CODE_0DB5D0:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.l MiddleTiles,x
CODE_0DB5D7:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DB5D0		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l RightTiles,x		; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj34_VerticalDoubleEndedPipe(Address)
namespace SMW_CastleObj34_VerticalDoubleEndedPipe
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Save pointer
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$33			; | Add top left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$34			; | Add top right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JMP.w CODE_0DC606

CODE_0DC5F7:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00				;\ Note: Change this JSR to point to SetMap16HighByteForCurrentObject_Page01 and the #$9D to #$35 to use the standard vertical pipe tiles instead of the castle tileset specific ones that lack solidity.
	LDA.b #$9D								;/
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00				;\ Note: Change this JSR to point to SetMap16HighByteForCurrentObject_Page01 and the #$9E to #$36 to use the standard vertical pipe tiles instead of the castle tileset specific ones that lack solidity.
	LDA.b #$9E								;/
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
CODE_0DC606:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DC5F7		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$33			; | Add bottom left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$34			; | Add bottom right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj35_RockWallBackground(Address)
namespace SMW_CastleObj35_RockWallBackground
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DC59D:
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
CODE_0DC59F:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$94			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; | Add upper row
	LDA.b #$95			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DC59F		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
CODE_0DC5BA:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$96			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; | Add lower row
	LDA.b #$97			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DC5BA		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DC59D		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj36_LargeSpikedPillar(Address)
namespace SMW_CastleObj36_LargeSpikedPillar
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Direction
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	CPX.b #$00			;\
	BEQ.b CODE_0DC51E		;/ Check if it points upwards
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Entry2	; Don't put anything at the first spot
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$87			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; | Add top tiles
	LDA.b #$88			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
CODE_0DC51E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$89			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$66			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; | Add upper row
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$67			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; |
	LDA.b #$8A			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b CODE_0DC572		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$8B			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$68			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; | Add lower row
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	; |
	LDA.b #$69			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; |
	LDA.b #$8C			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DC51E		;/ Check for end of the object
CODE_0DC572:
	CPX.b #$00			;\
	BNE.b Return0DC589		;/ Check if it points downwards
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Entry2	; Don't put anything at the first spot
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$8D			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; | Add bottom tiles
	LDA.b #$8E			; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
Return0DC589:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj37_HorizontalLineGuide(Address)
namespace SMW_CastleObj37_HorizontalLineGuide
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $92,$93

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Type
	LSR				; |
	TAX				;/
CODE_0DCF21:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DCF21		;/ Check for end of the object
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_CastleObj37_HorizontalLineGuide_Main, SMW_RopeObj38_HorizontalLineGuide_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj38_VerticalLineGuide(Address)
namespace SMW_CastleObj38_VerticalLineGuide
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $90			; Vertical left guide line
	db $91			; Vertical right guide line
	db $A2			; Vertical column (Rope Tileset only)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DCF42:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l Tiles,x			; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DCF42		;/ Check for end of the object
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_CastleObj38_VerticalLineGuide_Main, SMW_RopeObj39_VerticalLineGuideAndMushroomStalk_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj3B_GrassLedge(Address)
namespace SMW_CastleObj3B_GrassLedge
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main
endif
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
CODE_0DC4D3:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$09			; | Add top tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DC4D3		;/ Check if we need more top tiles
if ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main
endif
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
CODE_0DC4E3:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$86			; | Add bottom tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DC4E3		;/ Check if we need more bottom tiles
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj3C_StoneBlock(Address)
namespace SMW_CastleObj3C_StoneBlock
%InsertMacroAtXPosition(<Address>)

; The three Map16 tiles that make up the left side of the large stone castle
; block (tileset-specific object 3C in tileset 1). These are low bytes; the
; tiles are on page 1.
LeftTiles:
	db $5D,$60,$63			; Top tiles

; The three Map16 tiles that make up the middle columns of the large stone
; castle block (tileset-specific object 3C in tileset 1). These are low
; bytes; the tiles are on page 1.
MiddleTiles:
	db $5E,$61,$64			; Middle tiles

; The three Map16 tiles that make up the right side of the large stone
; castle block (tileset-specific object 3C in tileset 1). These are low
; bytes; the tiles are on page 1.
RightTiles:
	db $5F,$62,$65			; Bottom tiles

; Main creation code for the large stone castle block (tileset-specific
; object 3C in tileset 1).
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Height
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Width
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b #$00			; Place in table
CODE_0DC48D:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l LeftTiles,x		; | Add left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DC4A8

CODE_0DC49E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l MiddleTiles,x		; | Add middle tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DC4A8:
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BNE.b CODE_0DC49E		;/ Check if we need more middle tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l RightTiles,x		; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b #$01			; Set index to tables
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BMI.b Return0DC4C8		;/ Check for end of the object
	BNE.b CODE_0DC4C5
	LDX.b #$02
CODE_0DC4C5:
	JMP.w CODE_0DC48D

Return0DC4C8:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj3D_Escalator(Address)
namespace SMW_CastleObj3D_Escalator
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$02			; |
	LSR				; | Check which direction the conveyor is facing
	JSL.l SMW_ExecutePtr_Long	;/

EscalatorPtrs:
	dl LeftSlope
	dl RightSlope

ConveyorTiles:
	db $CE			; Left facing up conveyor
	db $D1			; Left facing down conveyor
	db $CF			; Right facing down conveyor
	db $D0			; Right facing up conveyor

ConveyorCornerTiles:
	db $F3			; Left facing up conveyor
	db $F6			; Left facing down conveyor
	db $F4			; Right facing down conveyor
	db $F5			; Right facing up conveyor

LeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Width of the first line
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$03			; | Type
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DC370:
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/ Reload width of line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l ConveyorTiles,x		; | Add conveyor tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DC37E:
	DEC.b !RAM_SMW_Misc_ScratchRAM03	;\
	BMI.b CODE_0DC39B		;/ Check if it's the first line (i.e. if we need slope assist tiles)
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l ConveyorCornerTiles,x	; | Add slope assist tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DC397

CODE_0DC38F:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add dirt tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DC397:
	DEC.b !RAM_SMW_Misc_ScratchRAM03	;\
	BPL.b CODE_0DC38F		;/ Check for end of the line
CODE_0DC39B:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	INC.b !RAM_SMW_Misc_ScratchRAM02	; Increase width of next line
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b CODE_0DC3CD		;/ Check if it's the last line
	BPL.b CODE_0DC3A9		;\
	JMP.w Return0DC3D7		;/ Check for end of the object

CODE_0DC3A9:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; | Update index
	ADC.b #$0F			;/
	TAY				;\
	BCC.b CODE_0DC3B4		; | Move pointer downwards if needed
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
CODE_0DC3B4:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$0F			; | Check if we need to move the pointer leftwards
	BNE.b CODE_0DC3C8		;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; | Move pointer downwards
	BCC.b CODE_0DC3C5		; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
CODE_0DC3C5:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer leftwards
CODE_0DC3C8:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	JMP.w CODE_0DC370

CODE_0DC3CD:
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/ Reload width
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Reload pointer
	JMP.w CODE_0DC37E		; Go to the add-slope-assist-tile area

Return0DC3D7:
	RTS

RightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Width of first line
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$03			; | Type
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
	JMP.w CODE_0DC40D

CODE_0DC3F3:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add dirt tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM03
CODE_0DC3FD:
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	CMP.b #$01
	BNE.b CODE_0DC3F3
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l ConveyorCornerTiles,x	; | Add slope assist tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DC40D:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b Return0DC42B		;/ Check if it's the last line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l ConveyorTiles,x		; | Add actual slope tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	INC.b !RAM_SMW_Misc_ScratchRAM02	; Increase width of next line
	LDA.b !RAM_SMW_Misc_ScratchRAM02	;\
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/ Reload width of line
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DC3FD		;/ Check for end of the object
Return0DC42B:
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_CastleObj3D_Escalator_Main, SMW_RopeObj37_SlopedConveyorRope_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj3E_HorizontalLineOfSpikes(Address)
namespace SMW_CastleObj3E_HorizontalLineOfSpikes
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $5A		; Horizontal down facing spikes
	db $59		; Horizontal up facing spikes

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Type
	LSR				; |
	TAX				;/
CODE_0DC43D:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DC43D		;/ Check for end of the line
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_CastleObj3F_VerticalLineOfSpikes(Address)
namespace SMW_CastleObj3F_VerticalLineOfSpikes
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $5B		; Vertical right facing spikes
	db $5C		; Vertical left facing spikes
	db $53		; Vertical column

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
CODE_0DC45E:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DC45E		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj32_LogBridge(Address)
namespace SMW_RopeObj32_LogBridge
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $A3
	db $0E

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b #$00
CODE_0DD25D:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	CPX.b #$00			; |
	BEQ.b CODE_0DD267		; | Set correct map16 page
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;/
CODE_0DD267:
	LDA.l Tiles,x			;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add tile
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DD25D		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Reload width
	INX				;\
	CPX.b #$02			; | Check for end of the object
	BNE.b CODE_0DD25D		;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj35_ColumnWithPlantOnTop(Address)
namespace SMW_RopeObj35_ColumnWithPlantOnTop
%InsertMacroAtXPosition(<Address>)

LeftPlantTiles:
	db $9A				; Green plant on column
	db $9C				; Orange plant on column
	db $9E				; Yellow plant on column
	db $A0				; Purple plant on column

RightPlantTiles:
	db $9B				; Green plant on column
	db $9D				; Orange plant on column
	db $9F				; Yellow plant on column
	db $A1				; Purple plant on column

ColumnTiles:
	db $61,$62			; Main column tiles
	db $63,$64
	db $65,$66

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l LeftPlantTiles,x		; | Add left plant tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l RightPlantTiles,x		; | Add right plant tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DD205		; | Check if it has a column
	JMP.w Return0DD24B		;/

CODE_0DD205:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$5F			; | Add top left column tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$60			; | Add top right column tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b Return0DD24B		;/ Check if it has more of the column than the top tile
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b #$00
CODE_0DD226:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l ColumnTiles,x		; | Add left column tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	INX
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l ColumnTiles,x		; | Add right column tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	INX
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	CPX.b #$06			;\
	BNE.b CODE_0DD247		; | Check for end of the table
	LDX.b #$00			;/
CODE_0DD247:
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DD226		;/ Check for end of the object
Return0DD24B:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj36_HorizontalConveyorRope(Address)
namespace SMW_RopeObj36_HorizontalConveyorRope
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $0C,$0D

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Type
	LSR				; |
	TAX				;/
ADDR_0DCF01:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b ADDR_0DCF01		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj3A_SlopedLineGuide(Address)
namespace SMW_RopeObj3A_SlopedLineGuide
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	TAX				; | Check type and run the correct code
	JSL.l SMW_ExecutePtr_Long	;/

SlopedLineGuidePtrs:
	dl NormalLeftSlope		; Normal slope left
	dl SteepLeftSlope		; Steep slope left
	dl NormalRightSlope		; Normal slope right
	dl SteepRightSlope		; Steep slope right
	dl ONOFFLeftSlope		; ON/OFF steep left slope
	dl ONOFFRightSlope		; ON/OFF steep right slope

NormalLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DCF7A:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$8C			; | Add left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$8D			; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$0E			; | Update index
	TAY				;/
	BCC.b CODE_0DCF97		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer down if needed
CODE_0DCF97:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$0E			; | Check if pointer needs to move left
	BMI.b CODE_0DCFAB		;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; | Move index down
	TAY				;/
	BCC.b ADDR_0DCFA8		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer down if needed
ADDR_0DCFA8:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer left
CODE_0DCFAB:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	DEX				;\
	BPL.b CODE_0DCF7A		;/ Check for end of the object
	RTS

SteepLeftSlope:
ONOFFLeftSlope:
	LDA.b #$86
	CPX.b #$04
	BNE.b CODE_0DCFB9
	LDA.b #$94
CODE_0DCFB9:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	TAX				;/
CODE_0DCFC4:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$0F			; | Update index
	TAY				;/
	BCC.b CODE_0DCFD6		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer down if needed
CODE_0DCFD6:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$0F			; | Check if pointer needs to move left
	BMI.b CODE_0DCFEA		;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; | Move index down
	TAY				;/
	BCC.b CODE_0DCFE7		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer down if needed
CODE_0DCFE7:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer left
CODE_0DCFEA:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	DEX				;\
	BPL.b CODE_0DCFC4		;/ Check for end of the object
	RTS

NormalRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	TAX				;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
ADDR_0DCFFC:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$8E
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$8F			; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer (waste of time...)
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$10			; | Move index down
	TAY				;/
	BCC.b ADDR_0DD019		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Update pointer if needed
ADDR_0DD019:
	TYA				;\
	CLC				; |
	ADC.b #$02			; | Move index rightwards
	TAY				;/
	AND.b #$0F			;\
	CMP.b #$02			; | Check if we need to move the pointer rightwards
	BPL.b ADDR_0DD02E		;/
	TYA				;\
	SEC				; | Move index back up
	SBC.b #$10			;/
	AND.b #$F1			;\
	TAY				;/ Move index leftwards (smells like a waste of time to me...)
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer rightwards
ADDR_0DD02E:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Save index
	DEX				;\
	BPL.b ADDR_0DCFFC		;/ Check for end of the object
	RTS

SteepRightSlope:
ONOFFRightSlope:
	LDA.b #$87
	CPX.b #$05
	BNE.b CODE_0DD03C
	LDA.b #$95
CODE_0DD03C:
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	TAX				;/
CODE_0DD047:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; | Move pointer downwards
	BCC.b CODE_0DD059		; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
CODE_0DD059:
	TYA
	CLC
	ADC.b #$01
	TAY
	AND.b #$0F
	BNE.b CODE_0DD06A
	DEY
	TYA
	AND.b #$F0
	TAY
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main
CODE_0DD06A:
	STY.b !RAM_SMW_Blocks_SubScrPos
	DEX				;\
	BPL.b CODE_0DD047		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj3B_VerySteepSlopedLineGuide(Address)
namespace SMW_RopeObj3B_VerySteepSlopedLineGuide
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Check type and run the correct code
	LSR				; |
	JSL.l SMW_ExecutePtr_Long	;/

VerySteepSlopedLineGuidePtrs:
	dl VerySteepLeftSlope
	dl VerySteepRightSlope

VerySteepLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Size
	TAX				;/
ADDR_0DD087:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$88			; | Add upper tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; | Move pointer downwards
	BCC.b ADDR_0DD098		; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
ADDR_0DD098:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$8A			; | Add lower tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA
	CLC
	ADC.b #$0F
	TAY
	BCC.b ADDR_0DD0A9
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
ADDR_0DD0A9:
	TYA
	AND.b #$0F
	CMP.b #$0F
	BNE.b ADDR_0DD0BD
	TYA
	CLC
	ADC.b #$10
	TAY
	BCC.b ADDR_0DD0BA
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
ADDR_0DD0BA:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main
ADDR_0DD0BD:
	STY.b !RAM_SMW_Blocks_SubScrPos
	DEX				;\
	BPL.b ADDR_0DD087		;/ Check for end of the object
	RTS

VerySteepRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Size
	TAX				;/
ADDR_0DD0CA:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$89			; | Add upper tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; | Move pointer downwards
	BCC.b ADDR_0DD0DB		; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
ADDR_0DD0DB:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$8B			; | Add lower tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; | Move pointer downwards
	BCC.b ADDR_0DD0EC		; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
ADDR_0DD0EC:
	TYA
	CLC
	ADC.b #$01
	TAY
	AND.b #$0F
	BNE.b ADDR_0DD0FD
	DEY
	TYA
	AND.b #$F0
	TAY
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main
ADDR_0DD0FD:
	STY.b !RAM_SMW_Blocks_SubScrPos
	DEX				;\
	BPL.b ADDR_0DD0CA		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj3C_MushroomTop(Address)
namespace SMW_RopeObj3C_MushroomTop
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDX.b #$07
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	CMP.b #$73
	BMI.b CODE_0DD11C
	CMP.b #$76
	BPL.b CODE_0DD11C
	LDX.b #$0A
CODE_0DD11C:
	TXA
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; and add it
	JMP.w CODE_0DD12B

CODE_0DD123:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$08			; | Add middle tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DD12B:
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DD123		;/ Check if we need more middle tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDX.b #$09
	LDA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	CMP.b #$73
	BMI.b CODE_0DD140
	CMP.b #$76
	BPL.b CODE_0DD140
	LDX.b #$0B
CODE_0DD140:
	TXA
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; and add it
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj3D_MushroomColumn(Address)
namespace SMW_RopeObj3D_MushroomColumn
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DD158:
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$73			; | Add left tile
	JMP.w CODE_0DD167		;/

CODE_0DD162:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$74
CODE_0DD167:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX				;\
	BNE.b CODE_0DD162		;/ Check if we need more middle tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$75			; | Add right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DD158		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj3E_HorizontalLog(Address)
namespace SMW_RopeObj3E_HorizontalLog
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$59			; | Add left tile
	JMP.w ADDR_0DD196		;/

ADDR_0DD191:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$5A
ADDR_0DD196:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX				;\
	BNE.b ADDR_0DD191		;/ Check if we need more middle tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$5B			; | Add right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_RopeObj3F_VerticalLog(Address)
namespace SMW_RopeObj3F_VerticalLog
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Width
	LSR				; |
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$5C			; | Add top tile
	JMP.w ADDR_0DD1BB		;/

ADDR_0DD1B6:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$5D
ADDR_0DD1BB:
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEX				;\
	BNE.b ADDR_0DD1B6		;/ Check if we need more middle tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$5E			; | Add bottom tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj36_4SidedGround(Address)
namespace SMW_UndergroundObj36_4SidedGround
%InsertMacroAtXPosition(<Address>)

; The low bytes of the map16 tiles that make up tileset-specific object 36
; (four-sided ground square). The creation routine for this object at
; $0DE135 puts them on page 01.
LeftTiles:
	db $45				; Left tiles
	db $50
	db $4D

MiddleTiles:
	db $00				; Middle tiles
	db $F0
	db $4E

RightTiles:
	db $48				; Right tiles
	db $51
	db $4F

; Object creation code for tileset-specific object 36 (the four-sided ground
; square).
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b #$00			; Index to table
CODE_0DE14A:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l LeftTiles,x		; | Add left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DE165

CODE_0DE15B:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l MiddleTiles,x		; | Add middle tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DE165:
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BNE.b CODE_0DE15B		;/ Check if we need more middle tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l RightTiles,x		; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b #$01
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BMI.b Return0DE185		;/ Check for end of the object
	BNE.b CODE_0DE182
	LDX.b #$02
CODE_0DE182:
	JMP.w CODE_0DE14A

Return0DE185:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj37_LargeCanvas(Address)
namespace SMW_UndergroundObj37_LargeCanvas
%InsertMacroAtXPosition(<Address>)

CanvasTiles:
	db $5C,$5D,$5E,$60
	db $73,$74,$75			; This line is added twice
	db $62,$63,$64,$5F
	db $76,$76,$76

CanvasPosLo:
	db !RAM_SMW_Blocks_Map16TableLo+$50,!RAM_SMW_Blocks_Map16TableLo+$58	; Low bytes of pointers to where to place the canvasses
	db !RAM_SMW_Blocks_Map16TableLo+$94,!RAM_SMW_Blocks_Map16TableLo+$9C
	db !RAM_SMW_Blocks_Map16TableLo+$D0,!RAM_SMW_Blocks_Map16TableLo+$D8
	db !RAM_SMW_Blocks_Map16TableLo+$14,!RAM_SMW_Blocks_Map16TableLo+$1C

CanvasPosHi:
	db !RAM_SMW_Blocks_Map16TableLo>>8,!RAM_SMW_Blocks_Map16TableLo>>8	; High bytes of pointers to where to place the canvasses
	db !RAM_SMW_Blocks_Map16TableLo>>8,!RAM_SMW_Blocks_Map16TableLo>>8
	db !RAM_SMW_Blocks_Map16TableLo>>8,!RAM_SMW_Blocks_Map16TableLo>>8
	db (!RAM_SMW_Blocks_Map16TableLo+$01B0)>>8,(!RAM_SMW_Blocks_Map16TableLo+$01B0)>>8

ScreenPosLo:
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$00)	; Table of 16-bit pointers to the screens (bank is 7E)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$01)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$02)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$03)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$04)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$05)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$06)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$07)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$08)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$09)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0A)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0B)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0C)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0D)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0E)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0F)

ScreenPosHi:
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$00)	; Table of 16-bit pointers to the screens (bank is 7F)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$01)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$02)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$03)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$04)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$05)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$06)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$07)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$08)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$09)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0A)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0B)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0C)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0D)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0E)
	dw !RAM_SMW_Blocks_Map16TableLo+($01B0*$0F)

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Remove height bits
	STA.b !RAM_SMW_Blocks_SizeOrType	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDY.b #$50			;\
	STY.b !RAM_SMW_Blocks_SubScrPos	;/ Change position
	LDA.b #$0F			;\
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/ Width of a row
	LDA.b #$04			;\
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/ Height
CODE_0DDF4F:
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
CODE_0DDF51:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$61			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DDF51		;/ Check for end of the row
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$40			; |
	STA.b !RAM_SMW_Blocks_SubScrPos	; | Move pointer down
	TAY				; |
	BCC.b CODE_0DDF6C		; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/
CODE_0DDF6C:
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DDF4F		;/ Check for end of this area
	LDA.b #$00
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo
	LDA.b #$00
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #$07
	STA.b !RAM_SMW_Misc_ScratchRAM03
CODE_0DDF80:
	LDA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDX.b !RAM_SMW_Misc_ScratchRAM00	;\
	LDA.l CanvasPosLo,x		; |
	STA.b !RAM_SMW_Blocks_SubScrPos	; |
	TAY				; |
	LDA.l CanvasPosHi,x		; | Set up pointers to where to place the canvasses
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Misc_ScratchRAM05	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
	LDA.b #$03			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Width of top line
	LDX.b #$00
CODE_0DDF9D:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l CanvasTiles,x		; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	INX				; | Add top line
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; |
	BPL.b CODE_0DDF9D		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
CODE_0DDFB2:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l CanvasTiles,x		; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; |
	LDA.l CanvasTiles+$01,x		; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	; | Add middle lines
	LDA.l CanvasTiles+$02,x		; |
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	; |
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; |
	DEC.b !RAM_SMW_Misc_ScratchRAM01	; |
	BPL.b CODE_0DDFB2		;/
	INX				;\
	INX				; | Increase index to table
	INX				;/
	LDA.b #$03			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Width of bottom line
CODE_0DDFDD:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l CanvasTiles,x		; |
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; |
	INX				; | Add bottom line
	DEC.b !RAM_SMW_Misc_ScratchRAM02	; |
	BPL.b CODE_0DDFDD		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b #$02
	STA.b !RAM_SMW_Misc_ScratchRAM02
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
CODE_0DDFF6:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.l CanvasTiles,x
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	; | Add bottom line
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	BPL.b CODE_0DDFF6
	DEC.b !RAM_SMW_Misc_ScratchRAM03	;\
	BMI.b CODE_0DE00E		; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	; | Check for end of the object
	JMP.w CODE_0DDF80		;/

CODE_0DE00E:
	LDA.b #$01			;\
	STA.b !RAM_SMW_Misc_ScratchRAM08	;/ First screen to copy to
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM09	;/ High byte of screen number (always 0)
CODE_0DE016:
	REP.b #$30			; AXY->16
	LDA.b !RAM_SMW_Misc_ScratchRAM08	;\
	ASL				; | Get index to table
	TAX				;/
	LDA.l ScreenPosLo,x		;\
	STA.b !RAM_SMW_Misc_ScratchRAM04	;/ Get pointer to low byte of map16 tiles table
	LDA.l ScreenPosHi,x		;\
	STA.b !RAM_SMW_Misc_ScratchRAM06	;/ Get pointer to high byte of map16 tiles table
	LDA.w #$01B0			;\
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/ Size of a screen
	LDA.w #!RAM_SMW_Blocks_Map16TableLo	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Where to copy from
	PHB				; Preserve DBR (MVN/MVP changes this one)
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; | Load settings
	LDY.b !RAM_SMW_Misc_ScratchRAM04	;/
	MVN !RAM_SMW_Blocks_Map16TableLo>>16,!RAM_SMW_Blocks_Map16TableLo>>16	; And move it
	PLB				; Reload DBR
	LDA.w #$01B0			;\
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/ Size of a screen
	LDA.w #!RAM_SMW_Blocks_Map16TableHi	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Where to copy from
	PHB				; Preserve DBR (MVN/MVP changes this one)
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; | Load settings
	LDY.b !RAM_SMW_Misc_ScratchRAM06	;/
	MVN !RAM_SMW_Blocks_Map16TableHi>>16,!RAM_SMW_Blocks_Map16TableHi>>16	; And move it
	PLB				; Reload DBR
	SEP.b #$30			; AXY->8
	DEC.b !RAM_SMW_Blocks_SizeOrType	;\
	BEQ.b Return0DE05D		; |
	INC.b !RAM_SMW_Misc_ScratchRAM08	; | Check for end of the object
	JMP.w CODE_0DE016		;/

Return0DE05D:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj38_RightLavaEdge(Address)
namespace SMW_UndergroundObj38_RightLavaEdge
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $5A			; Right facing mud/lava with top
	db $5B			; Right facing mud/lava

MiddleTiles:
	db $5B			; Right facing mud/lava with top
	db $5B			; Right facing mud/lava

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopTiles,x		; | Add top tile
	JMP.w CODE_0DDAE8		;/

CODE_0DDAE1:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.l MiddleTiles,x						; Optimization: Save a couple bytes by changing this to LDA.b #$5B and removing this table.
CODE_0DDAE8:
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DDAE1		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj39_SlopedCaveLava(Address)
namespace SMW_UndergroundObj39_SlopedCaveLava
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$03			; | Run the correct code for the type of slope we're trying to add
	JSL.l SMW_ExecutePtr_Long	;/

SlopedCaveLavaPtrs:
	dl NormalLeftSlope		; Normal left mud/lava slope
	dl SteepLeftSlope		; Steep left mud/lava slope
	dl NormalRightSlope		; Normal right mud/lava slope
	dl SteepRightSlope		; Steep right mud/lava slope

NormalLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b #$01			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | Width of the first line
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DDB1B:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Load size
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$D2			; | Add upper left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$D3			; | Add upper right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	DEX				; | Check if we need "slope assist" and plain-color tiles
	BMI.b CODE_0DDB50		;/
CODE_0DDB31:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FB			; | Add bottom left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FF			; | Add bottom right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	JMP.w CODE_0DDB4D		;/ Go to loop

CODE_0DDB45:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FF			; | Add plain-color tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DDB4D:
	DEX				;\
	BPL.b CODE_0DDB45		;/ Check if we need more plain-color tiles
CODE_0DDB50:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	INC.b !RAM_SMW_Misc_ScratchRAM02	;\
	INC.b !RAM_SMW_Misc_ScratchRAM02	;/ Update size of line
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b CODE_0DDB84		;/ Check for the last line
	BPL.b CODE_0DDB60		;\
	JMP.w Return0DDB8E		;/ Check for end of the object

CODE_0DDB60:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$0E			; | Move index left/down or right
	TAY				;/
	BCC.b CODE_0DDB6B		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer downwards if needed
CODE_0DDB6B:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$0E			; | Check which direction it went
	BMI.b CODE_0DDB7F		;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; | Move index downwards
	TAY				;/
	BCC.b CODE_0DDB7C		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer downwards if needed
CODE_0DDB7C:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer leftwards
CODE_0DDB7F:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Update position
	JMP.w CODE_0DDB1B

CODE_0DDB84:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	;\
	DEX				; | Update line size
	DEX				;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	JMP.w CODE_0DDB31

Return0DDB8E:
	RTS

SteepLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b #$00			;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	; | Width of the first line
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DDBA4:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Load size
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$D6			; | Add upper tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DDBAE:
	DEX				;\
	BMI.b CODE_0DDBC7		;/ Check if we need "slope assist" tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FD			; | Add lower tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JMP.w CODE_0DDBC4		; Go to loop

CODE_0DDBBC:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FF			; | Add plain-color tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DDBC4:
	DEX				;\
	BPL.b CODE_0DDBBC		;/ Check if we need more plain-color tiles
CODE_0DDBC7:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	INC.b !RAM_SMW_Misc_ScratchRAM02	; Update size of line
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b CODE_0DDBF9		;/ Check for the last line
	BPL.b CODE_0DDBD5		;\
	JMP.w Return0DDC01		;/ Check for end of the object

CODE_0DDBD5:
	LDA.b !RAM_SMW_Blocks_SubScrPos	;\
	CLC				; |
	ADC.b #$0F			; | Move index left/down or right
	TAY				;/
	BCC.b CODE_0DDBE0		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer downwards if needed
CODE_0DDBE0:
	TYA				;\
	AND.b #$0F			; |
	CMP.b #$0F			; | Check which direction it went
	BNE.b CODE_0DDBF4		;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; | Move index downwards
	TAY				;/
	BCC.b CODE_0DDBF1		;\
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2	;/ Move pointer downwards if needed
CODE_0DDBF1:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main	; Move pointer leftwards
CODE_0DDBF4:
	STY.b !RAM_SMW_Blocks_SubScrPos	; Update position
	JMP.w CODE_0DDBA4

CODE_0DDBF9:
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Reload line size
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	JMP.w CODE_0DDBAE

Return0DDC01:
	RTS

NormalRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$01			;\
	STX.b !RAM_SMW_Misc_ScratchRAM02	; | Width of first line
	STX.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
	JMP.w ADDR_0DDC3D

ADDR_0DDC1A:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FF			; | Add plain-color tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX
ADDR_0DDC23:
	CPX.b #$03
	BNE.b ADDR_0DDC1A
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FF			; | Add bottom left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FC			; | Add bottom right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	DEX				; |
	LDA.b !RAM_SMW_Misc_ScratchRAM00	; | Check if it's the last line
	BEQ.b Return0DDC5D		;/
ADDR_0DDC3D:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$D4			; | Add top left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$D5			; | Add top right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	INC.b !RAM_SMW_Misc_ScratchRAM02	;\
	INC.b !RAM_SMW_Misc_ScratchRAM02	;/ Update size of line
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Reload size of line
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b ADDR_0DDC5E		;/ Check for end of the object
Return0DDC5D:
	RTS

ADDR_0DDC5E:
	JMP.w ADDR_0DDC23

SteepRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDX.b #$00			;\
	STX.b !RAM_SMW_Misc_ScratchRAM02	; | Width of first line
	STX.b !RAM_SMW_Misc_ScratchRAM00	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Size
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; |
	INC.b !RAM_SMW_Misc_ScratchRAM00	;/
	JMP.w CODE_0DDC8E

CODE_0DDC79:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FF			; | Add plain-color tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX
CODE_0DDC82:
	CPX.b #$01
	BNE.b CODE_0DDC79
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FE			; | Add lower tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
CODE_0DDC8E:
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b Return0DDCA8		;/ Check if it's the last line
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$D7			; | Add upper tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	INC.b !RAM_SMW_Misc_ScratchRAM02	; Update size of line
	LDX.b !RAM_SMW_Misc_ScratchRAM02	; Reload size of line
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DDC82		;/ Check for end of the object
Return0DDCA8:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj3A_CaveLavaWithTop(Address)
namespace SMW_UndergroundObj3A_CaveLavaWithTop
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	TXA
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
	SEC				;\
	SBC.b #$39			; | Check if we need top tiles
	BNE.b CODE_0DDCD2		;/
CODE_0DDCC4:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$59			; | Add top tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DDCC4		; | Check if we need more top tiles
	JMP.w CODE_0DDCDD		;/

CODE_0DDCD2:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$FF			; | Add bottom tiles
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DDCD2		;/ Check if we need more bottom tiles
CODE_0DDCDD:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	;\
	DEC.b !RAM_SMW_Misc_ScratchRAM01	; | Check for end of the object
	BPL.b CODE_0DDCD2		;/
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_UndergroundObj3A_CaveLavaWithTop_Main, SMW_UndergroundObj3B_CaveLava_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj3C_VerySteepSlope(Address)
namespace SMW_UndergroundObj3C_VerySteepSlope
%InsertMacroAtXPosition(<Address>)

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Check type and run the correct code
	LSR				; |
	AND.b #$01			; |
	JSL.l SMW_ExecutePtr_Long	;/

VerySteepSlopePtrs:
	dl VerySteepLeftSlope
	dl VerySteepRightSlope

VerySteepLeftSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	ASL				;\
	CLC				; |
	ADC.b #$02			; | Height (this object is added in vertical stripes rather than horizontal)
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
CODE_0DDDA7:
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Load height
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$CA			; | Add top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DDDC2		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DDDC2:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$CB			; | Add middle tile (not counting dirt tiles)
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DDDD8		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DDDD8:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$F1			; | Add bottom tile (not counting dirt tiles)
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DDDEE		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DDDEE:
	DEX				;\
	DEX				; | Update number of remaining tiles in the line and go to loop
	JMP.w CODE_0DDE09		;/

CODE_0DDDF3:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add dirt tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DDE09		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DDE09:
	DEX				;\
	BPL.b CODE_0DDDF3		;/ Check if we need more dirt tiles
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Blocks_SubScrPos
	CLC
	ADC.b #$1F
	TAY
	BCC.b CODE_0DDE1A
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
CODE_0DDE1A:
	TYA
	AND.b #$0F
	CMP.b #$0F
	BNE.b CODE_0DDE2E
	TYA
	CLC
	ADC.b #$10
	TAY
	BCC.b CODE_0DDE2B
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
CODE_0DDE2B:
	JSR.w SMW_GoBackOneScreenAndUpdateLevelDataPointerInObjects_Main
CODE_0DDE2E:
	STY.b !RAM_SMW_Blocks_SubScrPos
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;/ Update height
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b Return0DDE3B		; | Check for end of the object
	JMP.w CODE_0DDDA7		;/

Return0DDE3B:
	RTS

VerySteepRightSlope:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	ASL				;\
	CLC				; |
	ADC.b #$02			; | Height
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
CODE_0DDE4A:
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Load height
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$CC			; | Add top tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DDE65		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DDE65:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$CD			; | Add middle tile (not counting dirt tiles)
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DDE7B		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DDE7B:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$F2			; | Add bottom tile (not counting dirt tiles)
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DDE91		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DDE91:
	DEX				;\
	DEX				; | Update number of remaining tiles in the line and go to loop
	JMP.w CODE_0DDEAC		;/

CODE_0DDE96:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$3F			; | Add dirt tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DDEAC		; | Move pointer downwards
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	ADC.b #$00			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DDEAC:
	DEX				;\
	BPL.b CODE_0DDE96		;/ Check if we need more dirt tiles
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Blocks_SubScrPos
	CLC
	ADC.b #$20
	TAY
	BCC.b CODE_0DDEBD
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
CODE_0DDEBD:
	TYA
	CLC
	ADC.b #$01
	TAY
	AND.b #$0F
	BNE.b CODE_0DDECE
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main
	DEY
	TYA
	AND.b #$F0
	TAY
CODE_0DDECE:
	STY.b !RAM_SMW_Blocks_SubScrPos
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;/ Update height
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b Return0DDEDB		; | Check for end of the object
	JMP.w CODE_0DDE4A		;/

Return0DDEDB:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj3D_CeilingLedge(Address)
namespace SMW_UndergroundObj3D_CeilingLedge
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b CODE_0DDD18		;/ Check if we need dirt tiles
CODE_0DDD01:
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Load width
CODE_0DDD03:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$65			; | Add dirt tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DDD03		;/ Check if we need more dirt tiles
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DDD01		;/ Check for the last row
CODE_0DDD18:
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Load width
CODE_0DDD1A:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$4E			; | Add bottom tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DDD1A		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj3E_CeilingEdges(Address)
namespace SMW_UndergroundObj3E_CeilingEdges 
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $50			; Left facing edge with bottom
	db $50			; Left facing edge
	db $51			; Right facing edge with bottom
	db $51			; Right facing edge

BottomTiles:
	db $4D			; Left facing edge with bottom
	db $50			; Left facing edge
	db $4F			; Right facing edge with bottom
	db $51			; Right facing edge

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	BEQ.b CODE_0DDD51		;/ Check if we need upper tiles
CODE_0DDD41:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l TopTiles,x		; | Add upper tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BNE.b CODE_0DDD41		;/ Check if we need more upper tiles
CODE_0DDD51:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l BottomTiles,x		; | Add bottom tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_UndergroundObj3F_SolidDirt(Address)
namespace SMW_UndergroundObj3F_SolidDirt
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DDD6F:
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Load width
CODE_0DDD71:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$65			; | Add tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DDD71		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DDD6F		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj2E_HorizontalLineOfSpikes(Address)
namespace SMW_GhostHouseObj2E_HorizontalLineOfSpikes
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $59

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos
	LDA.b !RAM_SMW_Blocks_SizeOrType
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Blocks_SizeOrType
	LSR
	LSR
	LSR
	LSR
	TAX
CODE_0DF07B:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.l Tiles,x
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BPL.b CODE_0DF07B
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj30_GrassLedge1(Address)
namespace SMW_GhostHouseObj30_GrassLedge1
%InsertMacroAtXPosition(<Address>)

; Object generation routine for tileset specific object 30 (The ground/ledge
; object used in Yoshi's House) in tileset 04 (Switch Palace 1) $0DF044, 1
; byte: The ledge tile (on page 1) $0DF054, 1 byte: The dirt tile (on page
; 0)
Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos
	LDA.b !RAM_SMW_Blocks_SizeOrType
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Blocks_SizeOrType
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM01
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main
	LDX.b !RAM_SMW_Misc_ScratchRAM00
CODE_0DF040:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$0F
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX
	BPL.b CODE_0DF040
	JMP.w CODE_0DF05B

CODE_0DF04E:
	LDX.b !RAM_SMW_Misc_ScratchRAM00
CODE_0DF050:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$EA
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX
	BPL.b CODE_0DF050
CODE_0DF05B:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel
	DEC.b !RAM_SMW_Misc_ScratchRAM01
	BPL.b CODE_0DF04E
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj31_WoodCrate(Address)
namespace SMW_GhostHouseObj31_WoodCrate
%InsertMacroAtXPosition(<Address>)

LeftEdgeTiles:
	db $63				; Left tiles
	db $65

MiddleTiles:
	db $C7				; Middle tiles (the top and bottom lines aren't here)
	db $C8

RightEdgeTiles:
	db $64,$6A			; Right tiles

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$61			;/ Add top left tile
	BNE.b CODE_0DEFCB		; This looks like some random instruction that should be BRA!
CODE_0DEFC6:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$0D
CODE_0DEFCB:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BNE.b CODE_0DEFC6		;/ Check if we need more middle tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$62			; | Add upper right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	LDX.b #$01			; Set which line we're on
	JMP.w CODE_0DEFFE

CODE_0DEFDE:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l LeftEdgeTiles,x		; | Add left tile
	BNE.b CODE_0DEFEE		;/
CODE_0DEFE7:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.l MiddleTiles,x
CODE_0DEFEE:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	BNE.b CODE_0DEFE7		;/ Check if we need more middle tiles
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l RightEdgeTiles,x		; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
CODE_0DEFFE:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	TXA
	EOR.b #$01
	TAX
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel
	DEC.b !RAM_SMW_Misc_ScratchRAM01
	BNE.b CODE_0DEFDE
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$6B
	BNE.b CODE_0DF01C
CODE_0DF017:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$6C
CODE_0DF01C:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_0DF017
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$6D
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj32_GrassLedge2(Address)
namespace SMW_GhostHouseObj32_GrassLedge2
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DEF7C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$0E			; | Add top tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DEF7C		;/ Check for end of the line
CODE_0DEF87:
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BMI.b Return0DEFA1		;/ Check if we need any lower tiles
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
CODE_0DEF93:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A3			; | Add lower tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DEF93		; | Check for end of the object
	JMP.w CODE_0DEF87		;/

Return0DEFA1:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj33_Cloud(Address)
namespace SMW_GhostHouseObj33_Cloud
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A0			; | Add left tile
	JMP.w CODE_0DEF59		;/

CODE_0DEF54:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$A1
CODE_0DEF59:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX				;\
	BNE.b CODE_0DEF54		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$A2			; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj34_WoodLedgeOnColumn(Address)
namespace SMW_GhostHouseObj34_WoodLedgeOnColumn
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Number of columns
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	ASL				;\
	ASL				; |
	CLC				; | "Real" width
	ADC.b #$02			; |
	TAX				;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	JSR.w SMW_GhostHouseObj38_WoodenLedge_WoodLedgeOnColumnEntry	; Add the ledge by "stealing" the column-less one's code
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Blocks_SubScrPos
	CLC
	ADC.b #$01
	TAY
	AND.b #$0F
	BNE.b CODE_0DEEF1
	LDA.b !RAM_SMW_Blocks_SubScrPos
	AND.b #$F0
	TAY
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main
CODE_0DEEF1:
	TYA
	CLC
	ADC.b #$10
	STA.b !RAM_SMW_Blocks_SubScrPos
	TAY
	BCC.b CODE_0DEEFD
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel_Entry2
CODE_0DEEFD:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM01	; Load height (looks like this object is added in vertical stripes)
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.b #$78			; | Add top tile
	JMP.w CODE_0DEF0F		;/

CODE_0DEF0A:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.b #$79
CODE_0DEF0F:
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	TYA				;\
	CLC				; |
	ADC.b #$10			; |
	TAY				; |
	BCC.b CODE_0DEF21		; |
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; | Move pointer downwards
	CLC				; |
	ADC.b #$01			; |
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	; |
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
CODE_0DEF21:
	DEX				;\
	BNE.b CODE_0DEF0A		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	LDA.b !RAM_SMW_Blocks_SubScrPos
	CLC
	ADC.b #$04
	TAY
	AND.b #$0F
	CMP.b #$04
	BPL.b CODE_0DEF3B
	TYA
	SEC
	SBC.b #$10
	TAY
	JSR.w SMW_GoForwardOneScreenAndUpdateLevelDataPointerInObjects_Main
CODE_0DEF3B:
	STY.b !RAM_SMW_Blocks_SubScrPos
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BMI.b Return0DEF44		; | Check for end of the object
	JMP.w CODE_0DEEFD		;/

Return0DEF44:
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_RT00_SMW_GhostHouseObj35_BrickBackground(Address)
namespace SMW_GhostHouseObj35_BrickBackground
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $92			; Grey bricks background
	db $5E			; Wooden blocks
	db $82			; Log background

Main:
	TXA				;\
	SEC				; |
	SBC.b #$34			; | Check which type of object it is
	TAX				;/
CODE_0DECCE:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DECE3:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	CPX.b #$01			; |
	BNE.b CODE_0DECED		; | Set map16 page
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;/
CODE_0DECED:
	LDA.l Tiles,x			;\
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/ Add tile
	DEC.b !RAM_SMW_Misc_ScratchRAM02	;\
	LDA.b !RAM_SMW_Misc_ScratchRAM02	; | Check for end of the line
	BPL.b CODE_0DECE3		;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDA.b !RAM_SMW_Misc_ScratchRAM00	;\
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/ Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DECE3		;/ Check for end of the object
	RTS
namespace off
	%SetDuplicateOrNullPointer(SMW_GhostHouseObj35_BrickBackground_Main, SMW_GhostHouseObj36_WoodenBlocks_Main)
endmacro

macro ROUTINE_RT01_SMW_GhostHouseObj35_BrickBackground(Address)
namespace SMW_GhostHouseObj35_BrickBackground
%InsertMacroAtXPosition(<Address>)

LogBackgroundEntry:
	LDX.b #$02
	JMP.w CODE_0DECCE
namespace off
	%SetDuplicateOrNullPointer(SMW_GhostHouseObj35_BrickBackground_LogBackgroundEntry, SMW_GhostHouseObj2F_LogBackground_Main)
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj37_HorizontalBackgroundLogAndRailing(Address)
namespace SMW_GhostHouseObj37_HorizontalBackgroundLogAndRailing
%InsertMacroAtXPosition(<Address>)

LeftTiles:
	db $82			; Horizontal log background
	db $89			; Top of hand rail
	db $88			; Bottom of hand rail

MiddleTiles:
	db $82			; Horizontal log background
	db $8A			; Top of hand rail
	db $88			; Bottom of hand rail

RightTiles:
	db $82			; Horizontal log background
	db $8B			; Top of hand rail
	db $88			; Bottom of hand rail

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Type
	LSR				; |
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l LeftTiles,x		; | Add left tile
	JMP.w CODE_0DED32		;/

CODE_0DED2B:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.l MiddleTiles,x
CODE_0DED32:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEC.b !RAM_SMW_Misc_ScratchRAM00
	BNE.b CODE_0DED2B
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l RightTiles,x		; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj38_WoodenLedge(Address)
namespace SMW_GhostHouseObj38_WoodenLedge
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Height
	TAX				;/
WoodLedgeOnColumnEntry:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$0A			; | Add left tile
	JMP.w CODE_0DED57		;/

CODE_0DED52:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$0B
CODE_0DED57:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX				;\
	BNE.b CODE_0DED52		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$0C			; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj39_VerticalBackgroundLog(Address)
namespace SMW_GhostHouseObj39_VerticalBackgroundLog
%InsertMacroAtXPosition(<Address>)

TopTiles:
	db $83			; Vertical log background 1
	db $78			; Vertical log background 2
	db $79			; Vertical log background 3

BottomTiles:
	db $83			; Vertical log background 1
	db $79			; Vertical log background 2
	db $79			; Vertical log background 3

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00	;\
	LDA.l TopTiles,x		; | Add top tile
	JMP.w CODE_0DED8B		;/

CODE_0DED84:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page00
	LDA.l BottomTiles,x
CODE_0DED8B:
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DED84		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj3A_SolidBrickWallAndVerticalLineOfSpikes(Address)
namespace SMW_GhostHouseObj3A_SolidBrickWallAndVerticalLineOfSpikes
%InsertMacroAtXPosition(<Address>)

Tiles:
	db $5F			; Solid brick left edge
	db $60			; Solid brick right edge
	db $5A			; Vertical right facing thin spikes
	db $5B			; Vertical left facing thin spikes

Main:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Type
	TAX				;/
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
CODE_0DEDA8:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.l Tiles,x			; | Add tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	DEC.b !RAM_SMW_Misc_ScratchRAM00	;\
	BPL.b CODE_0DEDA8		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj3B_BonusGameLedge(Address)
namespace SMW_GhostHouseObj3B_BonusGameLedge
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Size
	TAX				;/
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$07			; | Add left tile
	JMP.w CODE_0DEDCD		;/

CODE_0DEDC8:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01
	LDA.b #$08
CODE_0DEDCD:
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main
	DEX				;\
	BNE.b CODE_0DEDC8		;/ Check for end of the object
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$09			; | Add right tile
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;/
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj3C_SwitchPalaceCeiling(Address)
namespace SMW_GhostHouseObj3C_SwitchPalaceCeiling
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
	LDA.b !RAM_SMW_Misc_ScratchRAM01	;\
	BEQ.b CODE_0DEE0B		;/ Check if we need any middle tiles
CODE_0DEDF4:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$53			; | Add middle tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DEDF4		;/ Check for end of the line
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BNE.b CODE_0DEDF4		;/ Check for end of the object (except bottom line)
CODE_0DEE0B:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$54			; | Add bottom tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DEE0B		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj3D_SwitchPalaceLedge(Address)
namespace SMW_GhostHouseObj3D_SwitchPalaceLedge
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
CODE_0DEE2C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$5D			; | Add top tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DEE2C		; | Check for end of the line
	JMP.w CODE_0DEE45		;/

CODE_0DEE3A:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$53			; | Add middle tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DEE3A		;/ Check for end of the line
CODE_0DEE45:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DEE3A		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj3E_SwitchPalaceRightFacingWall(Address)
namespace SMW_GhostHouseObj3E_SwitchPalaceRightFacingWall
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DEE65:
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
	BEQ.b CODE_0DEE74		; Check if we need any middle tiles
CODE_0DEE69:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$53			; | Add middle tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BNE.b CODE_0DEE69		;/ Check for end of the line
CODE_0DEE74:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$55			; | Add right tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DEE65		;/ Check for end of the object
	RTS
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_GhostHouseObj3F_SwitchPalaceLeftFacingWall(Address)
namespace SMW_GhostHouseObj3F_SwitchPalaceLeftFacingWall
%InsertMacroAtXPosition(<Address>)

Main:
	LDY.b !RAM_SMW_Blocks_SubScrPos	; Position
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	AND.b #$0F			; | Width
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\
	LSR				; |
	LSR				; |
	LSR				; | Height
	LSR				; |
	STA.b !RAM_SMW_Misc_ScratchRAM01	;/
	JSR.w SMW_PreserveLevelDataPointerInObjects_Main	; Preserve pointer
CODE_0DEE9C:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$5C			; | Add left tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Load width
	BEQ.b CODE_0DEEB3		; Check if we need any middle tiles
CODE_0DEEA8:
	JSR.w SMW_SetMap16HighByteForCurrentObject_Page01	;\
	LDA.b #$53			; | Add middle tile
	JSR.w SMW_HandleHorizontalSubScreenCrossingForCurrentObject_Main	;/
	DEX				;\
	BPL.b CODE_0DEEA8		;/ Check for end of the line
CODE_0DEEB3:
	JSR.w SMW_RestoreLevelDataPointerInObjects_Main	; Reload pointer
	JSR.w SMW_HandleVerticalSubScreenCrossingForCurrentObject_HorizontalLevel	; Move pointer downwards
	LDX.b !RAM_SMW_Misc_ScratchRAM00	; Reload width
	DEC.b !RAM_SMW_Misc_ScratchRAM01	;\
	BPL.b CODE_0DEE9C		;/ Check for end of the object
	RTS
namespace off
endmacro

macro INLINEDATATABLE_RT39_SMW_EmptySpace(Address)
!SMW_UBytes = $98 : !SMW_JBytes = $97 : !SMW_E1Bytes = $98 : !SMW_E2Bytes = $98 : !SMASW_UBytes = $98 : !SMASW_EBytes = $98 : !SMW_ARCADEBytes = $98
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 39)
endmacro

macro INLINEDATATABLE_RT40_SMW_EmptySpace(Address)
!SMW_UBytes = $01E0 : !SMW_JBytes = $01E0 : !SMW_E1Bytes = $01E0 : !SMW_E2Bytes = $01DA : !SMASW_UBytes = $01E0 : !SMASW_EBytes = $01DA : !SMW_ARCADEBytes = $01E0
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 40)
endmacro

macro INLINEDATATABLE_RT41_SMW_EmptySpace(Address)
!SMW_UBytes = $017E : !SMW_JBytes = $017E : !SMW_E1Bytes = $017E : !SMW_E2Bytes = $017E : !SMASW_UBytes = $017E : !SMASW_EBytes = $017E : !SMW_ARCADEBytes = $017E
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 41)
endmacro

macro INLINEDATATABLE_RT42_SMW_EmptySpace(Address)

; LM: Lunar Magic inserts some stuff here:
; $0DE190 - Routine to allow for using long addressing for secondary entrance table SecondaryEntrance1.
; $0DE197 - Routine to allow for using long addressing for secondary entrance table SecondaryEntrance2.
; $0DE19E - Routine to allow for using long addressing for secondary entrance table SecondaryEntrance3.
; $0DE1B0 - Extended Object 02 (Custom Screen Exit)
; $0DE1D0 - Extended Object 01 (Modified Screen Jump)
; $0DE1E0 - Extended Object 03 (Horizontal level mode 1C screen jump)
; $0DE1F0 - Routine that initializes $8A and $8B during level load.
!SMW_UBytes = $017A : !SMW_JBytes = $017A : !SMW_E1Bytes = $017A : !SMW_E2Bytes = $017A : !SMASW_UBytes = $017A : !SMASW_EBytes = $017A : !SMW_ARCADEBytes = $017A
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 42)
endmacro

macro INLINEDATATABLE_RT43_SMW_EmptySpace(Address)

; LM: Lunar Magic inserts some routines here:
; $0DF08A - Standard Object 22/23 (Page 00/01 Direct Map16 object)
; $0DF0E0 - Standard Object 24 (Old GFX Bypass, FG/BG/Sprite)
; $0DF0F0 - Standard Object 25 (Old GFX Bypass, AN2)
; $0DF130 - Standard Object 26 (Music Bypass)
; $0DF150 - Standard Object 27 (Page 2-3F Direct Map16 Object)
; $0DF160 - Standard Object 28 (Time Limit Bypass)
; $0DF1C0 - Routine that handles the direct map16 objects
; $0DF290 - Routine that handles conditional map16
!SMW_UBytes = $0276 : !SMW_JBytes = $0277 : !SMW_E1Bytes = $0276 : !SMW_E2Bytes = $0276 : !SMASW_UBytes = $0276 : !SMASW_EBytes = $0276 : !SMW_ARCADEBytes = $0276
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 43)
endmacro

macro INLINEDATATABLE_RT44_SMW_EmptySpace(Address)

; LM: Lunar Magic inserts some routines here:
; $0DFEA0 - Routine that preserves the level data pointer and screen
; $0DFEB2 - Routine that restores the level data pointer and screen
; $0DFED0 - Routine that handles horizontal subscreen crossing in LM objects
; $0DFF10 - Routine that handles vertical subscreen crossing in LM objects
; $0DFF50 - Standard Object 29 (Page 40-7F Direct Map16 Object)
!SMW_UBytes = $0161 : !SMW_JBytes = $0315 : !SMW_E1Bytes = $0161 : !SMW_E2Bytes = $0161 : !SMASW_UBytes = $0161 : !SMASW_EBytes = $0161 : !SMW_ARCADEBytes = $0161
	
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 44)
endmacro
