;--- Cutscene sprite tables - $7E0AF5-$7E0D75
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; Cleared on reset and titlescreen load. Also cleared after a boss had been
; beaten - this can be disabled by changing [9C 5C 0A] at $00B08D to [80 01
; EA]. Lunar Magic may also expand $0905 to include this address, in which
; case it contains one of the bytes for color F8 (with $0AF6 holding the
; other).
!RAM_SMW_UnusedRAM_7E0AF5 #= !Define_SMW_LowRAMLocation+$0AF5
; Used for multiple purposes: Decompressed overworld graphics for animated
; tiles. Continues into $0BF6-$0C55. Iggy's/Larry's platform interaction.
; (16x16 tiles in a 16x16 square.) Various sprite tables for the credits and
; castle destruction scenes; see details. Note that the white flag sprite
; used in the castle destruction scenes has its X/Y designation reversed for
; whatever reason. Lunar Magic may extend $0905 to include the first 15
; bytes of this region (up to and including $0B05), corresponding to palette
; data for colors F8-FF. Lunar Magic v3.00+ uses part of this region at
; $0BE6-$0BF5 to support the expanded horizontal level system. See details
; for more information.
!RAM_SMW_Misc_ScratchRAM7E0AF6 #= !Define_SMW_LowRAMLocation+$0AF6
	!RAM_SMW_Graphics_DecompressedOverworldGFX #= !RAM_SMW_Misc_ScratchRAM7E0AF6
	!RAM_SMW_Misc_IggyLarryPlatformInteraction #= !RAM_SMW_Misc_ScratchRAM7E0AF6
	!RAM_SMW_Sprites_CutsceneSpriteTable7E0AF6 #= !RAM_SMW_Misc_ScratchRAM7E0AF6
	!RAM_SMW_CutsceneSprites_CreditsEgg_YAcceleration #= !RAM_SMW_Misc_ScratchRAM7E0AF6
	!RAM_SMW_Sprites_CutsceneSpriteYSpeed #= !RAM_SMW_Misc_ScratchRAM7E0AF6+$0F
		!RAM_SMW_Sprites_SmallCastleDoorYSpeed #= !RAM_SMW_Sprites_CutsceneSpriteYSpeed
		!RAM_SMW_Sprites_CastleDustYSpeed #= !RAM_SMW_Sprites_CutsceneSpriteYSpeed+$01
		!RAM_SMW_Sprites_FarawayCastleRocketYSpeed #= !RAM_SMW_Sprites_CutsceneSpriteYSpeed+$02
		!RAM_SMW_Sprites_EndingYoshisYSpeed #= !RAM_SMW_Sprites_CutsceneSpriteYSpeed+$01
	!RAM_SMW_Sprites_CutsceneSpriteXSpeed #= !Define_SMW_LowRAMLocation+$0B14
		!RAM_SMW_Sprites_WhiteFlagYSpeed #= !RAM_SMW_Sprites_CutsceneSpriteXSpeed+$01
		!RAM_SMW_Sprites_SmallCastleDoorXSpeed #= !RAM_SMW_Sprites_CutsceneSpriteXSpeed
		!RAM_SMW_Sprites_FarawayCastleRocketXSpeed #= !RAM_SMW_Sprites_CutsceneSpriteXSpeed+$02
		!RAM_SMW_Sprites_EndingPlayerXSpeed #= !RAM_SMW_Sprites_CutsceneSpriteXSpeed
	!RAM_SMW_Sprites_CutsceneSpriteSubYPos #= !Define_SMW_LowRAMLocation+$0B23
	!RAM_SMW_Sprites_CutsceneSpriteSubXPos #= !Define_SMW_LowRAMLocation+$0B32
		!RAM_SMW_Sprites_EndingPlayerSubXPos #= !RAM_SMW_Sprites_CutsceneSpriteSubXPos
		!RAM_SMW_Sprites_EndingYoshisSubXPos #= !RAM_SMW_Sprites_CutsceneSpriteSubXPos+$01
	!RAM_SMW_Sprites_CutsceneSpriteYPosLo #= !Define_SMW_LowRAMLocation+$0B41
		!RAM_SMW_Sprites_SmallCastleDoorYPosLo #= !RAM_SMW_Sprites_CutsceneSpriteYPosLo
		!RAM_SMW_Sprites_CastleDustYPos #= !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$01
		!RAM_SMW_Sprites_CastleRocketFlameYPos #= !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$02
		!RAM_SMW_Sprites_FarawayCastleRocketYPosLo #= !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$02
		!RAM_SMW_Sprites_RoyCutscenePlayerCoughYPosLo #= !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$02
		!RAM_SMW_Sprites_MortonCutscenePlayerCoughYPosLo #= !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$03
		!RAM_SMW_Sprites_EndingYoshisYPosLo #= !RAM_SMW_Sprites_CutsceneSpriteYPosLo+$01
	!RAM_SMW_Sprites_CutsceneSpriteXPosLo #= !Define_SMW_LowRAMLocation+$0B50
		!RAM_SMW_Sprites_SmallCastleDoorXPosLo #= !RAM_SMW_Sprites_CutsceneSpriteXPosLo
		!RAM_SMW_Sprites_TNTFuseAndLineXPos #= !RAM_SMW_Sprites_CutsceneSpriteXPosLo
		!RAM_SMW_Sprites_CastleDustXPos #= !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$01
		!RAM_SMW_Sprites_WhiteFlagYPosLo #= !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$01
		!RAM_SMW_Sprites_FarawayCastleRocketXPosLo #= !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$02
		!RAM_SMW_Sprites_MortonCutscenePlayerCoughXPosLo #= !RAM_SMW_Sprites_CutsceneSpriteXPosLo+$03
		!RAM_SMW_Sprites_EndingPlayerXPosLo #= !RAM_SMW_Sprites_CutsceneSpriteXPosLo
	!RAM_SMW_Sprites_CutsceneSpriteYPosHi #= !Define_SMW_LowRAMLocation+$0B5F
		!RAM_SMW_Sprites_SmallCastleDoorYPosHi #= !RAM_SMW_Sprites_CutsceneSpriteYPosHi
		!RAM_SMW_Sprites_WhiteFlagYPosHi = !RAM_SMW_Sprites_CutsceneSpriteXPosHi+$01
		!RAM_SMW_Sprites_FarawayCastleRocketYPosHi #= !RAM_SMW_Sprites_CutsceneSpriteYPosHi+$02
		!RAM_SMW_Sprites_EndingYoshisYPosHi #= !RAM_SMW_Sprites_CutsceneSpriteYPosHi+$01
	!RAM_SMW_Sprites_CutsceneSpriteXPosHi #= !Define_SMW_LowRAMLocation+$0B6E
		!RAM_SMW_Sprites_SmallCastleDoorXPosHi #= !RAM_SMW_Sprites_CutsceneSpriteXPosHi
		!RAM_SMW_Sprites_FarawayCastleRocketXPosHi #= !RAM_SMW_Sprites_CutsceneSpriteXPosHi+$02
		!RAM_SMW_Sprites_EndingPlayerXPosHi #= !RAM_SMW_Sprites_CutsceneSpriteXPosHi
	!RAM_SMW_CutsceneSpr_HammerDebris_YAcceleration #= !Define_SMW_LowRAMLocation+$0B7D
	!RAM_SMW_CutsceneSpr_HammerDebris_CurrentStatus #= !Define_SMW_LowRAMLocation+$0B8C
