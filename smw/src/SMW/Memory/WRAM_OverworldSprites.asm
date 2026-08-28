;--- Overworld sprite slots - $7E0E05-$7E0F2F
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; Miscellaneous overworld sprite table.
!RAM_SMW_OWSpr_Table7E0E15 #= !Define_SMW_LowRAMLocation+$0E15
; Miscellaneous overworld sprite table.
!RAM_SMW_OWSpr_Table7E0E25 #= !Define_SMW_LowRAMLocation+$0E25
; Overworld sprite X position, low byte.
!RAM_SMW_OWSpr_XPosLo #= !Define_SMW_LowRAMLocation+$0E35
!RAM_SMW_OWSpr_YPosLo #= !RAM_SMW_OWSpr_XPosLo+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$01)
!RAM_SMW_OWSpr_ZPosLo #= !RAM_SMW_OWSpr_XPosLo+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$02)
; Overworld sprite X position, high byte.
!RAM_SMW_OWSpr_XPosHi #= !Define_SMW_LowRAMLocation+$0E65
!RAM_SMW_OWSpr_YPosHi #= !RAM_SMW_OWSpr_XPosHi+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$01)
!RAM_SMW_OWSpr_ZPosHi #= !RAM_SMW_OWSpr_XPosHi+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$02)
; Overworld sprite X speed.
!RAM_SMW_OWSpr_XSpeed #= !Define_SMW_LowRAMLocation+$0E95
!RAM_SMW_OWSpr_YSpeed #= !RAM_SMW_OWSpr_XSpeed+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$01)
!RAM_SMW_OWSpr_ZSpeed #= !RAM_SMW_OWSpr_XSpeed+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$02)
; Accumulating fraction bits for overworld sprite X speed.
!RAM_SMW_OWSpr_SubXPos #= !Define_SMW_LowRAMLocation+$0EC5
!RAM_SMW_OWSpr_SubYPos #= !RAM_SMW_OWSpr_SubXPos+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$01)
!RAM_SMW_OWSpr_SubZPos #= !RAM_SMW_OWSpr_SubXPos+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$02)
; Bits 5 through 7 of this address are used to keep track of which overworld
; Koopa Kids have been defeated (i.e. they pulled Mario into a level and the
; level was beaten). If set, the corresponding sprite will not respawn.
!RAM_SMW_OWSpr06_KoopaKid_ActivateFlag #= !Define_SMW_LowRAMLocation+$0EF5
; Indicates which of the koopa kid triggers you are standing on. By default
; the tiles are: #$49, #$4A and #$4B. These correspond to index #$00, #$01
; and #$02 respectively. This address is unused in the original SMW and can
; be used as empty free RAM, it is cleared on reset and titlescreen load.
!RAM_SMW_OWSpr06_KoopaKid_TileIndex #= !Define_SMW_LowRAMLocation+$0EF6
; If bit 7 is set (#$80-#$FF) and the player is located on a level tile,
; they will enter it directly without user input. The Koopa Kid and Piranha
; Plant overworld sprites also write their sprite index to this address
; while the player is in contact with them. The Piranha Plant in particular
; uses this to erase itself if Mario beats the level the sprite is on top
; of.
!RAM_SMW_Overworld_EnterLevelFlag #= !Define_SMW_LowRAMLocation+$0EF7
; Yoshi has been saved for the first time flag - used for Yoshi's thank
; message.
!RAM_SMW_Flag_YoshiSaved #= !Define_SMW_LowRAMLocation+$0EF8
; Status bar tilemap (tiles numbers only, no YXPCCCTT). The tile numbers in
; this table are automatically uploaded every frame to the middle two rows.
; The base for this table, as well as the remaining tiles for the item box,
; can be found at $008C81.
!RAM_SMW_Misc_StatusBarTilemap #= !Define_SMW_LowRAMLocation+$0EF9

!RAM_SMW_Misc_StatusBar_Player = !RAM_SMW_Misc_StatusBarTilemap+((SMW_StatusBarTilemap_SecondRow_Mario-SMW_StatusBarTilemap_SecondRow)/2)
!RAM_SMW_Misc_StatusBar_YoshiCoin1 = !RAM_SMW_Misc_StatusBarTilemap+((SMW_StatusBarTilemap_SecondRow_YoshiCoins-SMW_StatusBarTilemap_SecondRow)/2)
!RAM_SMW_Misc_StatusBar_YoshiCoin2 = !RAM_SMW_Misc_StatusBar_YoshiCoin1+$01
!RAM_SMW_Misc_StatusBar_YoshiCoin3 = !RAM_SMW_Misc_StatusBar_YoshiCoin1+$02
!RAM_SMW_Misc_StatusBar_YoshiCoin4 = !RAM_SMW_Misc_StatusBar_YoshiCoin1+$03
!RAM_SMW_Misc_StatusBar_TopBonusStarsHi = !RAM_SMW_Misc_StatusBarTilemap+((SMW_StatusBarTilemap_SecondRow_BonusStarNumbers-SMW_StatusBarTilemap_SecondRow)/2)
!RAM_SMW_Misc_StatusBar_TopBonusStarsLo = !RAM_SMW_Misc_StatusBar_TopBonusStarsHi+$01
!RAM_SMW_Misc_StatusBar_ItemBox = !RAM_SMW_Misc_StatusBarTilemap+((SMW_StatusBarTilemap_SecondRow_ItemBox-SMW_StatusBarTilemap_SecondRow)/2)
!RAM_SMW_Misc_StatusBar_CoinsHi = !RAM_SMW_Misc_StatusBarTilemap+((SMW_StatusBarTilemap_SecondRow_Coins-SMW_StatusBarTilemap_SecondRow)/2)+$03
!RAM_SMW_Misc_StatusBar_CoinsLo = !RAM_SMW_Misc_StatusBar_CoinsHi+$01
!RAM_SMW_Misc_StatusBar_LivesHi = !RAM_SMW_Misc_StatusBarTilemap+((SMW_StatusBarTilemap_ThirdRow_Lives-SMW_StatusBarTilemap_SecondRow)/2)+$01
!RAM_SMW_Misc_StatusBar_LivesLo = !RAM_SMW_Misc_StatusBar_LivesHi+$01
!RAM_SMW_Misc_StatusBar_BottomBonusStarsHi = !RAM_SMW_Misc_StatusBar_TopBonusStarsHi+((SMW_StatusBarTilemap_ThirdRow_BonusStarNumbers-SMW_StatusBarTilemap_SecondRow_BonusStarNumbers)/2)
!RAM_SMW_Misc_StatusBar_BottomBonusStarsLo = !RAM_SMW_Misc_StatusBar_BottomBonusStarsHi+$01
!RAM_SMW_Misc_StatusBar_TimerHundreds = !RAM_SMW_Misc_StatusBarTilemap+((SMW_StatusBarTilemap_ThirdRow_Time-SMW_StatusBarTilemap_SecondRow)/2)
!RAM_SMW_Misc_StatusBar_TimerTens = !RAM_SMW_Misc_StatusBar_TimerHundreds+$01
!RAM_SMW_Misc_StatusBar_TimerOnes = !RAM_SMW_Misc_StatusBar_TimerHundreds+$02
!RAM_SMW_Misc_StatusBar_ScoreMillions = !RAM_SMW_Misc_StatusBarTilemap+((SMW_StatusBarTilemap_ThirdRow_Score-SMW_StatusBarTilemap_SecondRow)/2)
!RAM_SMW_Misc_StatusBar_ScoreHundredThousands = !RAM_SMW_Misc_StatusBar_ScoreMillions+$01
!RAM_SMW_Misc_StatusBar_ScoreTenThousands = !RAM_SMW_Misc_StatusBar_ScoreMillions+$02
!RAM_SMW_Misc_StatusBar_ScoreThousands = !RAM_SMW_Misc_StatusBar_ScoreMillions+$03
!RAM_SMW_Misc_StatusBar_ScoreHundreds = !RAM_SMW_Misc_StatusBar_ScoreMillions+$04
!RAM_SMW_Misc_StatusBar_ScoreTens = !RAM_SMW_Misc_StatusBar_ScoreMillions+$05

