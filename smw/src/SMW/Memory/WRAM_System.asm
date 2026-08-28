;--- System state - $7E0D76-$7E0E04
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; Used during the GFX33 DMA routine. It holds the first of three possible
; source addresses for the animated graphics.
!RAM_SMW_Graphics_TileAnimationSourceAddress1Lo #= !Define_SMW_LowRAMLocation+$0D76
!RAM_SMW_Graphics_TileAnimationSourceAddress1Hi #= !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo+$01
; Used during the GFX33 DMA routine. It holds the second of three possible
; source addresses for the animated graphics.
!RAM_SMW_Graphics_TileAnimationSourceAddress2Lo #= !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo+$02
!RAM_SMW_Graphics_TileAnimationSourceAddress2Hi #= !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo+$03
; Used during the GFX33 DMA routine. It holds the third of three possible
; source addresses for the animated graphics.
!RAM_SMW_Graphics_TileAnimationSourceAddress3Lo #= !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo+$04
!RAM_SMW_Graphics_TileAnimationSourceAddress3Hi #= !RAM_SMW_Graphics_TileAnimationSourceAddress1Lo+$05
; Used during the GFX33 DMA routine. It holds the first of three possible
; VRAM addresses for the animated graphics.
!RAM_SMW_Graphics_TileAnimationVRAMAddress1Lo #= !Define_SMW_LowRAMLocation+$0D7C
!RAM_SMW_Graphics_TileAnimationVRAMAddress1Hi #= !RAM_SMW_Graphics_TileAnimationVRAMAddress1Lo+$01
; Used during the GFX33 DMA routine. It holds the second of three possible
; VRAM addresses for the animated graphics.
!RAM_SMW_Graphics_TileAnimationVRAMAddress2Lo #= !Define_SMW_LowRAMLocation+$0D7E
!RAM_SMW_Graphics_TileAnimationVRAMAddress2Hi #= !RAM_SMW_Graphics_TileAnimationVRAMAddress2Lo+$01
; Used during the GFX33 DMA routine. It holds the third of three possible
; VRAM addresses for the animated graphics.
!RAM_SMW_Graphics_TileAnimationVRAMAddress3Lo #= !Define_SMW_LowRAMLocation+$0D80
!RAM_SMW_Graphics_TileAnimationVRAMAddress3Hi #= !RAM_SMW_Graphics_TileAnimationVRAMAddress3Lo+$01
; 16-bit pointer to the player palette. #$B2C8 = regular Mario; #$B2DC =
; regular Luigi; #$B2F0 = fire Mario; #$B304 = fire Luigi. Always uses #$00
; for bank byte (the first bank).
!RAM_SMW_Pointer_PlayerPaletteLo #= !Define_SMW_LowRAMLocation+$0D82
!RAM_SMW_Pointer_PlayerPaletteHi #= !RAM_SMW_Pointer_PlayerPaletteLo+$01
; Used in Player Graphics DMA routine. This holds the amount of tiles to
; load. Is #$0A in levels (because of Yoshi) and #$06 on the overworld. If
; it's set to zero, the player palette isn't reloaded. The presents screen
; makes use of that.
!RAM_SMW_Player_NumberOfTilesToUpdate #= !Define_SMW_LowRAMLocation+$0D84
; 16-bit pointers in bank $7E for uploading the player's, Yoshi's and
; Podoboo's on-screen tiles. They're divided in two sets of 10 bytes, each
; two bytes being used for two 8x8 tiles. The first 10 bytes are for the top
; half of each 16x16 tile (player's head, player's bottom, cape, Yoshi's
; head/Podoboo, Yoshi's bottom), while the latter 10 bytes are for the
; bottom half of each 16x16 tile (same order). The format to calculate the
; tile used is as follows: ([8x8 tile number] - $900 * $20) + $2000. NOTE:
; The tile number is only applicable to page 9 onwards.
!RAM_SMW_Graphics_DynamicSpritePointersTopLo #= !Define_SMW_LowRAMLocation+$0D85
!RAM_SMW_Graphics_DynamicSpritePointersBottomLo #= !RAM_SMW_Graphics_DynamicSpritePointersTopLo+$0A
; Holds the lower two bytes of the 24-bit RAM address (bank byte is $7E) of
; tile 7F's graphics; used during the player graphics DMA routine.
!RAM_SMW_Graphics_DynamicSpriteTile7FLo #= !Define_SMW_LowRAMLocation+$0D99
!RAM_SMW_Graphics_DynamicSpriteTile7FHi #= !RAM_SMW_Graphics_DynamicSpriteTile7FLo+$01
; Activates different IRQ/NMI behavior for various game modes, depending on
; the following values: #$00 = Regular level. #$01 = Mario Start, Time Up,
; etc. + Title Screen + Castle destruction scene. #$02 = Overworld. #$80 =
; Iggy's and Larry's battle mode. #$C0 = Reznor's, Morton's, Roy's, and
; Ludwig's battle mode. #$C1 = Bowser's battle mode.
!RAM_SMW_Misc_NMIToUseFlag #= !Define_SMW_LowRAMLocation+$0D9B
;Empty $000D9C
; Main Screen and Window logic mask setting of current level mode (000abcde
; - a = Object layer; b = Layer 4; c = Layer 3; d = Layer 2; e = Layer 1).
; Appears as TM in Lunar Magic. Mirror of SNES registers $212C and $212E;
; transfer only occurs on level load.
!RAM_SMW_Mirror_MainScreenLayers #= !Define_SMW_LowRAMLocation+$0D9D
; Sub Screen and Window logic mask setting of current level mode (000abcde -
; a = Object layer; b = Layer 4; c = Layer 3; d = Layer 2; e = Layer 1).
; Appears as TD in Lunar Magic. Mirror of SNES registers $212D and $212F;
; transfer only occurs on level load.
!RAM_SMW_Mirror_SubScreenLayers #= !Define_SMW_LowRAMLocation+$0D9E
; HDMA flags, ordered bitwise %76543210. Set the corresponding bit to enable
; HDMA on that channel. Mirror of SNES register $420C.
!RAM_SMW_Mirror_HDMAEnable #= !Define_SMW_LowRAMLocation+$0D9F
; Which controllers are plugged in (00 = port 1, 01 = port 2). Used to
; determine which port to accept data from when only one controller is
; plugged in. If the high bit is set, then both controller ports are plugged
; in and $0DB3 will be used instead to determine the active controller.
!RAM_SMW_IO_ControllersPluggedIn #= !Define_SMW_LowRAMLocation+$0DA0
;Empty $000DA1
; Copy of controller data 1 ($7E:0015). Format: byetUDLR. b = B, y = Y, e =
; Select, t = Start, UDLR = Up/Down/Left/Right. Used by player 1 (Mario).
!RAM_SMW_IO_ControllerHold1CopyP1 #= !Define_SMW_LowRAMLocation+$0DA2
; Copy of controller data 1 ($7E:0015). Format: byetUDLR. b = B, y = Y, e =
; Select, t = Start, UDLR = Up/Down/Left/Right. Used by player 2 (Luigi).
!RAM_SMW_IO_ControllerHold1CopyP2 #= !RAM_SMW_IO_ControllerHold1CopyP1+$01
; Copy of controller data 2 ($7E:0017). Format: axlr----. a = A; x = X; l =
; L; r = R, 0 = null/unused. Note that the upper two bits are also used by
; controller data 1 at $7E:0015, so that A/B and X/Y are combined. Used by
; player 1 (Mario).
!RAM_SMW_IO_ControllerHold2CopyP1 #= !RAM_SMW_IO_ControllerHold1CopyP1+$02
; Copy of controller data 2 ($7E:0017). Format: axlr----. a = A; x = X; l =
; L; r = R, 0 = null/unused. Note that the upper two bits are also used by
; controller data 1 at $7E:0015, so that A/B and X/Y are combined. Used by
; player 2 (Luigi).
!RAM_SMW_IO_ControllerHold2CopyP2 #= !RAM_SMW_IO_ControllerHold1CopyP1+$03
; Copy of controller data 1, one frame ($7E:0016). Format: byetUDLR. b = B,
; y = Y, e = Select, t = Start, UDLR = Up/Down/Left/Right. Used by player 1
; (Mario).
!RAM_SMW_IO_ControllerPress1CopyP1 #= !RAM_SMW_IO_ControllerHold1CopyP1+$04
; Copy of controller data 1, one frame ($7E:0016). Format: byetUDLR. b = B,
; y = Y, e = Select, t = Start, UDLR = Up/Down/Left/Right. Used by player 2
; (Luigi).
!RAM_SMW_IO_ControllerPress1CopyP2 #= !RAM_SMW_IO_ControllerHold1CopyP1+$05
; Copy of controller data 2, one frame ($7E:0018). Format: axlr----. a = A;
; x = X; l = L; r = R, 0 = null/unused. Note that the sixth bit is also used
; by controller data 1 at $7E:0016, so that X/Y are combined. Used by player
; 1 (Mario).
!RAM_SMW_IO_ControllerPress2CopyP1 #= !RAM_SMW_IO_ControllerHold1CopyP1+$06
; Copy of controller data 2, one frame ($7E:0018). Format: axlr----. a = A;
; x = X; l = L; r = R, 0 = null/unused. Note that the sixth bit is also used
; by controller data 1 at $7E:0016, so that X/Y are combined. Used by player
; 2 (Luigi).
!RAM_SMW_IO_ControllerPress2CopyP2 #= !RAM_SMW_IO_ControllerHold1CopyP1+$07
; Controller 1 button disable flags ($4219), one frame. If a bit is set
; here, that bit will be disabled in $16/$0DA6 (but not $15). Format:
; byetUDLR. b = B, y = Y, e = Select, t = Start, UDLR = Up/Down/Left/Right.
!RAM_SMW_IO_P1CtrlDisableLo #= !Define_SMW_LowRAMLocation+$0DAA
; Controller 2 button disable flags ($421B), one frame. If a bit is set
; here, that bit will be disabled in $16/$0DA7 (but not $15). Format:
; byetUDLR. b = B, y = Y, e = Select, t = Start, UDLR = Up/Down/Left/Right.
!RAM_SMW_IO_P2CtrlDisableLo #= !RAM_SMW_IO_P1CtrlDisableLo+$01
; Controller 1 button disable flags ($4218), one frame. If a bit is set
; here, that bit will be disabled in $18/$0DA8 (but not $17). Format:
; axlr----. a = A, x = X, l = L, r = R, 0 = null/unused.
!RAM_SMW_IO_P1CtrlDisableHi #= !RAM_SMW_IO_P1CtrlDisableLo+$02
; Controller 2 button disable flags ($421A), one frame. If a bit is set
; here, that bit will be disabled in $18/$0DA9 (but not $17). Format:
; axlr----. a = A, x = X, l = L, r = R, 0 = null/unused.
!RAM_SMW_IO_P2CtrlDisableHi #= !RAM_SMW_IO_P1CtrlDisableLo+$03
; Handles brightness and force blank. Format: f---bbbb. f = force blank
; flag, --- = unused bits, bbbb = brightness setting. Mirror of SNES
; register $2100.
!RAM_SMW_Mirror_ScreenDisplayRegister #= !Define_SMW_LowRAMLocation+$0DAE
; Mosaic direction. #$00 = shrinking mosaic; #$01 = growing mosaic.
!RAM_SMW_Misc_MosaicDirection #= !Define_SMW_LowRAMLocation+$0DAF
; Current mosaic pixel size on level load. Mirror of SNES register $2106,
; though bits 0 and 1 are always set ($2106 = $7E:0DB0 | #$03).
!RAM_SMW_Mirror_MosaicSizeAndBGEnable #= !Define_SMW_LowRAMLocation+$0DB0
; Is used to keep a mode active. If the respective value is positive, the
; game mode doesn't change. This is primarily used in the fading routines
; (example: from overworld to level and vice versa).
!RAM_SMW_Timer_KeepGameModeActive #= !Define_SMW_LowRAMLocation+$0DB1
; Two player game flag. #$00 = No; #$01 = Yes.
!RAM_SMW_Flag_TwoPlayerGame #= !Define_SMW_LowRAMLocation+$0DB2
; Which character is in play. #$00 = Mario; #$01 = Luigi. If you prefer
; Luigi to be #$04, use $7E:0DD6.
!RAM_SMW_Player_CurrentCharacter #= !Define_SMW_LowRAMLocation+$0DB3
; Mario's lives. Note that this is only used in two player games, you'll
; want $7E:0DBE in 99% of the cases.
!RAM_SMW_Player_MariosLives #= !Define_SMW_LowRAMLocation+$0DB4
; Luigi's lives. Note that this is only used in two player games, you'll
; want $7E:0DBE in 99% of the cases.
!RAM_SMW_Player_LuigisLives #= !RAM_SMW_Player_MariosLives+$01
; Mario's coins. Note that this is only used in two player games, you'll
; want $7E:0DBF in 99% of the cases.
!RAM_SMW_Player_MariosCoins #= !Define_SMW_LowRAMLocation+$0DB6
; Luigi's coins. Note that this is only used in two player games, you'll
; want $7E:0DBF in 99% of the cases.
!RAM_SMW_Player_LuigisCoins #= !RAM_SMW_Player_MariosCoins+$01
; Mario's powerup/status. Note that this is only used in two player games,
; you'll want $7E:0019 in 99% of the cases.
!RAM_SMW_Player_MariosPowerUp #= !Define_SMW_LowRAMLocation+$0DB8
; Luigi's powerup/status. Note that this is only used in two player games,
; you'll want $7E:0019 in 99% of the cases.
!RAM_SMW_Player_LuigisPowerUp #= !RAM_SMW_Player_MariosPowerUp+$01
; Mario's Yoshi color. #$04=yellow; #$06=blue; #$08=red; #$0A=green
!RAM_SMW_Player_MariosYoshi #= !Define_SMW_LowRAMLocation+$0DBA
; Luigi's Yoshi color. #$04=yellow; #$06=blue; #$08=red; #$0A=green
!RAM_SMW_Player_LuigisYoshi #= !RAM_SMW_Player_MariosYoshi+$01
; Item in Mario's item box. #$00 = None; #$01 = Mushroom; #$02 = Fire
; Flower; #$03 = Star; #$04 = Feather. Note that you'll want $7E:0DC2 in
; most cases.
!RAM_SMW_Player_MariosItemBox #= !Define_SMW_LowRAMLocation+$0DBC
; Item in Luigi's item box. #$00 = None; #$01 = Mushroom; #$02 = Fire
; Flower; #$03 = Star; #$04 = Feather. Note that you'll want $7E:0DC2 in
; most cases.
!RAM_SMW_Player_LuigisItemBox #= !RAM_SMW_Player_MariosItemBox+$01
; Current player lives, minus one (#$04 here means that the player has 5
; lives).
!RAM_SMW_Player_CurrentLifeCount #= !Define_SMW_LowRAMLocation+$0DBE
; Current player coin count.
!RAM_SMW_Player_CurrentCoinCount #= !Define_SMW_LowRAMLocation+$0DBF
; Green star block coin counter. Starts at 30 (#$1E) at the beginning of a
; level, and decrements for each coin that is collected. Adjusts content of
; green star block when it hits zero. (A 1-Up mushroom comes out, instead of
; a spinning coin.) It is also used in Chocolate Island 2 to count how many
; coins have been collected since the start of the level, and determine what
; sublevel data should be loaded.
!RAM_SMW_Counter_GreenStarBlock #= !Define_SMW_LowRAMLocation+$0DC0
; Player can carry Yoshi over levels flag. #$00 = can't carry over levels;
; #$01 = can carry over levels.
!RAM_SMW_Yoshi_CarryOverLevelsFlag #= !Define_SMW_LowRAMLocation+$0DC1
; Item in current player's item box. #$00 = None; #$01 = Mushroom; #$02 =
; Fire Flower; #$03 = Star; #$04 = Feather.
!RAM_SMW_Player_CurrentItemBox #= !Define_SMW_LowRAMLocation+$0DC2
; Empty. Cleared on reset and titlescreen load. $7E:0DC3 is also cleared
; when selecting how many players to use, but this can be disabled with no
; known side effects by setting $00:9E48 to [80 01 EA].
!RAM_SMW_UnusedRAM_7E0DC3 #= !Define_SMW_LowRAMLocation+$0DC3
;Empty $000DC4-$000DC6
; Overworld X position where Mario should be going to. Is used by overworld
; path tiles to indicate Mario's direction. Updated as soon as Mario starts
; moving - zero otherwise.
!RAM_SMW_Player_OverworldXPosMarioIsGoingToLo #= !Define_SMW_LowRAMLocation+$0DC7
!RAM_SMW_Player_OverworldXPosMarioIsGoingToHi #= !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo+$01
; Overworld Y position where Mario should be going to. Is used by overworld
; path tiles to indicate Mario's direction. Updated as soon as Mario starts
; moving - zero otherwise.
!RAM_SMW_Player_OverworldYPosMarioIsGoingToLo #= !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo+$02
!RAM_SMW_Player_OverworldYPosMarioIsGoingToHi #= !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo+$03
; Overworld X position where Luigi should be going to. Is used by overworld
; path tiles to indicate Luigi's direction. Updated as soon as Luigi starts
; moving - zero otherwise.
!RAM_SMW_Player_OverworldXPosLuigiIsGoingToLo #= !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo+$04
!RAM_SMW_Player_OverworldXPosLuigiIsGoingToHi #= !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo+$05
; Overworld Y position where Luigi should be going to. Is used by overworld
; path tiles to indicate Luigi's direction. Updated as soon as Luigi starts
; moving - zero otherwise.
!RAM_SMW_Player_OverworldYPosLuigiIsGoingToLo #= !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo+$06
!RAM_SMW_Player_OverworldYPosLuigiIsGoingToHi #= !RAM_SMW_Player_OverworldXPosMarioIsGoingToLo+$07
; Player X speed on the overworld. Added with $7E:13D5, which does happen to
; be zero all the time.
!RAM_SMW_Player_OverworldXSpeedLo #= !Define_SMW_LowRAMLocation+$0DCF
!RAM_SMW_Player_OverworldXSpeedHi #= !RAM_SMW_Player_OverworldXSpeedLo+$01
; Player Y speed on the overworld. Added with $7E:13D7, which is zero most
; of the time.
!RAM_SMW_Player_OverworldYSpeedLo #= !RAM_SMW_Player_OverworldXSpeedLo+$02
!RAM_SMW_Player_OverworldYSpeedHi #= !RAM_SMW_Player_OverworldXSpeedLo+$03
; Player direction. #$00 = up; #$02 = down; #$04 = left; #$06 = right.
!RAM_SMW_Overworld_PlayerDirection #= !Define_SMW_LowRAMLocation+$0DD3
; This address is effectively the high byte of $0DD3 on the overworld and
; should not be touched there, though in levels it is unused. It is also
; referenced once as the low byte of $0DD5, though its value isn't used
; there. Cleared on reset and titlescreen load, and when Mario starts
; walking on an overworld path.
!RAM_SMW_UnusedRAM_7E0DD4 #= !Define_SMW_LowRAMLocation+$0DD4
; Used to indicate how a level has been exited, and hence what events to
; activate on the overworld.
!RAM_SMW_Misc_ExitLevelAction #= !Define_SMW_LowRAMLocation+$0DD5
; Which character is in play. Used on the overworld. The value of this
; address is actually $7E:0DB3 * 4. #$00 = Mario; #$04 = Luigi.
!RAM_SMW_Player_CurrentCharacterX4Lo #= !Define_SMW_LowRAMLocation+$0DD6
; An address that is expected to be #$00 throughout the entire game.
; $7E:0DD6 (current player) is sometimes used in 16bit mode, so using this
; address for different purposes is a bad idea.
!RAM_SMW_Player_CurrentCharacterX4Hi #= !RAM_SMW_Player_CurrentCharacterX4Lo+$01
; Used to tell if the game is currently switching between Mario and Luigi or
; not. #$00 = Not switching between Mario and Luigi. #$01 = Switching
; between Mario and Luigi, during the fade-out.
!RAM_SMW_Flag_SwitchPlayers #= !Define_SMW_LowRAMLocation+$0DD8
;Empty $000DD9
; Back-up of the music register. Gets its value from the level music table
; at $05:84DB. Bit 7 of this address is set when the player has a star
; powerup or presses a P-switch; when this is cleared again, the music ends.
; This address is also set to #$FF when the level ends, either by beating it
; or by dying. Bit 6 is similar but is used to not reupload all music. This
; is used when changing from the Mario start screen to the level game mode.
!RAM_SMW_Misc_MusicRegisterBackup #= !Define_SMW_LowRAMLocation+$0DDA
;Empty $000DDB-$000DDD
; Which files to delete on the erase file screen. Format: xxxxx123. It is
; also used as an overworld sprite index.
!RAM_SMW_Misc_WhichFileToErase #= !Define_SMW_LowRAMLocation+$0DDE
	!RAM_SMW_Sprites_CurrentlyProcessedOverworldSprite #= !Define_SMW_LowRAMLocation+$0DDE
; Where the next cloud tile writes, as a byte offset from OAM object $10. A
; cursor rather than a fixed index: every tile drawn through
; SMW_OWSpr05_Cloud's entry points takes it and stores it back four lower, so
; the clouds on screen share one downward-walking run. It is reset to $30 once
; a frame, immediately ahead of the slot loop that spends it, which leaves 13
; objects before the run reaches the players' own.
;
; Not only the clouds: SMW_OWSpr01_Lakitu and SMW_OWSpr02_BlueBird draw their
; bodies through the same two entry points and so come out of this run too.
; Their shadows, and every other overworld sprite, take a fixed per-slot index
; from SMW_OverworldSpriteOAMIndexes instead.
!RAM_SMW_Sprites_StartingOAMIndexForOverworldSprites #= !Define_SMW_LowRAMLocation+$0DDF
; Used for the overworld cloud sprites. This table is used in such a way
; that clouds check each other's 16-bit Y positions. By doing this, they can
; maintain their speed, making it the same for all clouds on-screen.
!RAM_SMW_Sprites_OverworldCloudSyncTable #= !Define_SMW_LowRAMLocation+$0DE0
; Overworld sprite number.
!RAM_SMW_OWSpr_SpriteID #= !Define_SMW_LowRAMLocation+$0DE5
; Miscellaneous overworld sprite table.
!RAM_SMW_OWSpr_Table7E0DF5 #= !Define_SMW_LowRAMLocation+$0DF5
!RAM_SMW_OWSpr_Table7E0E05 #= !RAM_SMW_OWSpr_Table7E0DF5+((!Define_SMW_MaxOverworldSpriteSlot+$01)*$01)
