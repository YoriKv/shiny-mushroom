;--- Overworld state - $7E1B78-$7E1FFE
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; This is used on the overworld to determine if a hard coded path should be
; processed. This flag is set and read in 16-bit mode, it can have the
; values #$0000 or #$0001. #$0001 means that a hard coded path/event is
; processed. Lunar Magic also uses it in levels when the "Fix Layer 3 scroll
; sync" option is enabled, as the next frame's Layer 3 X position (as
; opposed to the current frame's one in $22).
!RAM_SMW_Overworld_ProcessHardcodedPathFlagLo #= !Define_SMW_LowRAMLocation+$1B78
!RAM_SMW_Overworld_ProcessHardcodedPathFlagHi #= !RAM_SMW_Overworld_ProcessHardcodedPathFlagLo+$01
; This address serves as an index to $049086 and $0490CA, which are used to
; get what hard coded tile to use for the current tile the player is walking
; on. Lunar Magic also uses it in levels when the "Fix Layer 3 scroll sync"
; option is enabled, as the next frame's Layer 3 X position (as opposed to
; the current frame's one in $24).
!RAM_SMW_Overworld_HardcodedPathIndexLo #= !Define_SMW_LowRAMLocation+$1B7A
!RAM_SMW_Overworld_HardcodedPathIndexHi #= !RAM_SMW_Overworld_HardcodedPathIndexLo+$01
; Accumulating fraction bits for the Layer 1 X speed on the overworld, used
; when the camera returns to the player after having been in free scrolling
; mode. This address handles incrementing the Layer 1 X position when it
; overflows.
!RAM_SMW_Overworld_Layer1SubXPos #= !Define_SMW_LowRAMLocation+$1B7C
; Accumulating fraction bits for the Layer 1 Y speed on the overworld, used
; when the camera returns to the player after having been in free scrolling
; mode. This address handles incrementing the Layer 1 Y position when it
; overflows.
!RAM_SMW_Overworld_Layer1SubYPos #= !RAM_SMW_Overworld_Layer1SubXPos+$01
; This address is a mirror of $7E:13C1 (tile the player is on in the
; overworld) and it's used to check whether the player is walking on a
; complementive corner tile (those small corners used with the paths, a list
; of all tile numbers can be found at $04:A03C) while settling on a level
; tile. Appears to be designed to allow for (very) curvy paths leading to
; level tiles, found in for example Star World and the path to the warp pipe
; from Chocolate Island 2. Depending on the complementive corner tile in
; question, the player image and position are altered when settling on a
; level tile.
!RAM_SMW_CopyOfTilePlayerIsStandingdOnLo #= !Define_SMW_LowRAMLocation+$1B7E
; Empty. Cleared on reset, titlescreen load, overworld load and level load.
; This address could be regarded as the "high byte" of $7E:1B7E, however it
; is never used (AND #$00FF is applied) and only stored to on the overworld.
; Thus, it is safe to use this address as free RAM outside of the overworld.
!RAM_SMW_CopyOfTilePlayerIsStandingdOnHi #= !RAM_SMW_CopyOfTilePlayerIsStandingdOnLo+$01
; Flag used on the overworld to indicate the player is moving across a
; ladder or vine path tile (tiles 3F-41).
!RAM_SMW_Overworld_PlayerOnClimbingTileLo #= !Define_SMW_LowRAMLocation+$1B80
; Uses in 16-bit loads to $7E:1B80, and otherwise #$00 is always stored
; here. Using this outside of the overworld is fine, however. Cleared on
; reset, titlescreen load and overworld load.
!RAM_SMW_Overworld_PlayerOnClimbingTileHi #= !RAM_SMW_Overworld_PlayerOnClimbingTileLo+$01
; X position on-screen of the current castle/fortress destruction explosion.
; Also denotes X position on-screen of the appearing event sprite tiles.
!RAM_SMW_Overworld_OnScreenXPosOfCurrentEventTile #= !Define_SMW_LowRAMLocation+$1B82
; Y position on-screen of the current castle/fortress destruction explosion.
; Also denotes Y position on-screen of the appearing event sprite tiles.
!RAM_SMW_Overworld_OnScreenYPosOfCurrentEventTile #= !Define_SMW_LowRAMLocation+$1B83
; The 16-bit address is used to determine whether the large event tiles
; (6x6) are uploaded or the small event tiles (2x2). It's #$0900 or higher
; if it's the latter. It gets its values from the table at $04:DD8D. Solely
; $7E:1B84 is a timer used for handling castle/fortress destruction on the
; overworld, as well as the timer used for a level tile being revealed (the
; flash sprite).
!RAM_SMW_Timer_DestroyTileEvent_Unknown #= !Define_SMW_LowRAMLocation+$1B84
	!RAM_SMW_Timer_FadeInLevelTile #= !Define_SMW_LowRAMLocation+$1B84
	!RAM_SMW_Overworld_EventTileSizeAddressLo #= !Define_SMW_LowRAMLocation+$1B84
!RAM_SMW_Overworld_EventTileSizeAddressHi #= !RAM_SMW_Overworld_EventTileSizeAddressLo+$01
; Pointer to the various routines that handle overworld events being
; activated. The pointers are located at $04E577.
!RAM_SMW_Pointer_OverworldEventProcess #= !Define_SMW_LowRAMLocation+$1B86
; Used to indicate the current stage of the save and 2-player life exchange
; prompts on the overworld.
!RAM_SMW_Pointer_DisplayOverworldPrompt #= !Define_SMW_LowRAMLocation+$1B87
; Message box expanding (#$00) or shrinking (#$01) flag. Also used in
; various other instances such as the save prompt on the overworld.
!RAM_SMW_Flag_MessageWindowSizeChangeDirection #= !Define_SMW_LowRAMLocation+$1B88
; Message box expansion and shrinking timer/size. Note: Setting expanding
; timer above #$04 will cause the message to be blank. Also used in various
; other instances, such as the save prompt on the overworld, and the
; opening/closing window effects during the credits.
!RAM_SMW_Timer_WaitBeforeMessageWindowSizeChange #= !Define_SMW_LowRAMLocation+$1B89
; Which direction to point the arrow on the give lives menu. #$00 = Point to
; Luigi's direction, give him lives. #$01 = Point to Mario's direction, give
; him lives.
!RAM_SMW_Flag_WhoGetsLivesInExchangeMenu #= !Define_SMW_LowRAMLocation+$1B8A
; A timer that increments every frame, used for the blinking arrow on the
; give lives (between players) screen. If $7E:1B8B & #$18 gives a non-zero
; value, the arrow is shown. If the result of that is zero instead, a blank
; is shown.
!RAM_SMW_Timer_LifeExchangeBlinkingArrowFrames #= !Define_SMW_LowRAMLocation+$1B8B
; Used as a flag to determine whether you are at the first or second
; iteration of the pointer to $04:DB18 ($7E:1DE8 is #$00 or #$06). #$02 is
; fully cleared, #$00 is fully blacked out. Needed to make the windowing
; HDMA fade out at first, then fade back in when the submap switching
; process is done.
!RAM_SMW_Overworld_HDMATransitionEffectFlag #= !Define_SMW_LowRAMLocation+$1B8C
; Used in the calculation of the X positions for the overworld fade in/out
; windowing HDMA transitions. Removing stores to this address will make it
; only active in the Y direction. Starts at #$0000 (completely black) and
; ends at #$7000 (cleared, except for the sides which are hidden under the
; overworld border).
!RAM_SMW_Overworld_HDMATransitionEffectXPosLo #= !Define_SMW_LowRAMLocation+$1B8D
!RAM_SMW_Overworld_HDMATransitionEffectXPosHi #= !RAM_SMW_Overworld_HDMATransitionEffectXPosLo+$01
; Used in the calculation of the Y positions for the overworld fade in/out
; windowing HDMA transitions. Removing stores to this address will make it
; only active in the X direction. Starts at #$0000 (completely black) and
; ends at #$5400 (cleared).
!RAM_SMW_Overworld_HDMATransitionEffectYPosLo #= !Define_SMW_LowRAMLocation+$1B8F
!RAM_SMW_Overworld_HDMATransitionEffectYPosHi #= !RAM_SMW_Overworld_HDMATransitionEffectYPosLo+$01
; Blinking cursor frame counter (file select, save prompt, etc.)
!RAM_SMW_Counter_BlinkingCursorFrame #= !Define_SMW_LowRAMLocation+$1B91
; Position of the cursor on the title screen menus, as well as the overworld
; "continue with/without save" and "continue/end" menus.
!RAM_SMW_Misc_BlinkingCursorPos #= !Define_SMW_LowRAMLocation+$1B92
; Secondary exit flag. When a screen exit is taken, this controls whether
; the exit goes to the primary entrance of a level or a secondary entrance.
; In the original game, this is controlled by the last screen exit present
; in the level's object data, and affects every screen exit in the level (so
; you can not have a mixture of primary and secondary exits in a single
; level). Lunar Magic modifies the system so that this flag instead comes
; from the screen exit's data at $19D8.
!RAM_SMW_Flag_UseSecondaryEntrance #= !Define_SMW_LowRAMLocation+$1B93
; Disable bonus game sprite from being loaded flag. If not zero, the bonus
; game sprite will terminate itself in the init routine.
!RAM_SMW_Flag_DisableBonusGameSprite #= !Define_SMW_LowRAMLocation+$1B94
; This flag is set to #$02 as soon as the Yoshi wings animation (#$08 of
; $7E:0071) brings you above the screen ($7E:0080 = #$FFC0), which means you
; will be heading for level C8 or 1C8. As a byproduct, Yoshi will have wings
; in that level, and you can't die from falling into the depths. Moreover,
; as you enter the level, Yoshi will always be blue. It's also the only way
; you can "die" with Yoshi without losing him on the overworld.
!RAM_SMW_InYoshiWingsBonusArea #= !Define_SMW_LowRAMLocation+$1B95
; Side exit enabled flag. #$00 = Disabled; #$01 = enabled.
!RAM_SMW_Flag_SideExits #= !Define_SMW_LowRAMLocation+$1B96
; This address is only stored to once in all of SMW, and that's in code that
; was originally never used (the fifth scrolling command, sprite #$EC). It
; was going to have some unknown use when you reached the last screen of the
; level. Because SMW never executes the code that writes to it (unless that
; command is used), this is a safe address to use. Cleared on reset,
; titlescreen load, overworld load and cutscene load.
!RAM_SMW_UnusedRAM_UnknownScrollFunctionFlagLo #= !Define_SMW_LowRAMLocation+$1B97
!RAM_SMW_UnusedRAM_UnknownScrollFunctionFlagHi #= !RAM_SMW_UnusedRAM_UnknownScrollFunctionFlagLo+$01
; Used in goal point marching: flag to show peace image flag and handling
; the fade-out ellipse. #$00 = Don't show peace image yet, don't handle
; fade-out ellipse. #$01 = Show peace image and handle fade-out ellipse.
!RAM_SMW_Flag_ShowVictoryPoseDuringLevelEnd #= !Define_SMW_LowRAMLocation+$1B99
; Background Scroll Activated flag. The unused orange platform (sprite 5E)
; sets it to #$01, and the flying turn blocks (sprite C1) set it to #$08. If
; set, triggers the fast BG scroll sprite, as well as making the flying turn
; blocks move.
!RAM_SMW_Flag_ActiveFastBackgroundScrollGenerator #= !Define_SMW_LowRAMLocation+$1B9A
; Used to check if Yoshi should not reappear for the next room (castle intro
; cutscene and the likes). These cutscenes set the flag to #$01, which makes
; Yoshi not reappear for the next room, but it does keep Yoshi on the
; overworld. Automatically set to #$00 when the overworld is loaded again.
; One could use this RAM address to disable Yoshi for one room, but
; re-enable him in the next again.
!RAM_SMW_Flag_PreventYoshiCarryOver #= !Define_SMW_LowRAMLocation+$1B9B
; Player is entering a warp pipe/star flag. #$00 = No; #$01 = Yes.
!RAM_SMW_Overworld_WarpingOnPipeOrStarFlag #= !Define_SMW_LowRAMLocation+$1B9C
; Time to wait until the rising/sinking tide starts rising/sinking again
; (after the "no movement" interval).
!RAM_SMW_Timer_WaitBeforeLayer3TideMovesVertically #= !Define_SMW_LowRAMLocation+$1B9D
; Music has to be altered on the overworld during a 2-player game flag. #$00
; = Do not alter music. #$01 = Do alter music. It's set when the players are
; switching, but also when you go from submap to submap, the latter even
; when it's a 1-player game. But this flag is never read if it's a 1-player
; game.
!RAM_SMW_Flag_ChangeSubmapMusicOnPlayerSwitch #= !Define_SMW_LowRAMLocation+$1B9E
; Number of broken tile pairs in the Reznor battle.
!RAM_SMW_Counter_NumberOfBrokenReznorBridgeTiles #= !Define_SMW_LowRAMLocation+$1B9F
; The overworld uses this address to shake the ground as the Valley of
; Bowser entrance rises from the depths, by setting this address to #$FF. It
; also changes the music and adds some sound effects. It's a timer, but it
; only decrements as long as $7E:13D9 is #$02.
!RAM_SMW_Overworld_ActiveEarthquakeEvent #= !Define_SMW_LowRAMLocation+$1BA0
; One of two screen numbers used in the level loading routine. This one
; points to where the next tile will be placed and is often changed inside
; an object loading code. The other screen number is $7E:1928. Although
; referenced at $03:DF58 (Bowser's code), its value isn't actually used
; there.
!RAM_SMW_Blocks_ScreenToPlaceNextObject #= !Define_SMW_LowRAMLocation+$1BA1
	!RAM_SMW_UnusedRAM_7E1BA1 #= !Define_SMW_LowRAMLocation+$1BA1
; Used to index the tilemap for the Mode 7 bosses, with bits 0-6 used to
; index the table at $03D9DE (16 bytes per image). Bit 7 is used to control
; the X-flip of the tiles; when set, all of the tiles in the tilemap get +1
; added to them, since the Mode 7 graphics get decompressed into consecutive
; pairs of a regular and X-flipped tile (e.g. tile 01 is an X-flipped
; version of tile 00).
!RAM_SMW_Misc_Mode7TilemapIndex #= !Define_SMW_LowRAMLocation+$1BA2
; A buffer that is used for uploading Mode 7 tile data to VRAM in
; non-platform Mode 7 bosses. The buffer is enough to fill in an entire 8x8
; tile, as each 8x8 tile requires 64 bytes in Mode 7 8bpp. The original game
; also uses $1BB2-$1BB9 as a temporary buffer in the graphics upload routine
; for converting 3bpp graphics to 4bpp. This no longer occurs with Lunar
; Magic. $1BBC is additionally used as a 16-bit flag in the graphics upload
; routine to alter the 3bpp conversion depending on the graphics file that
; is being uploaded (specifically for moving berries to the right half of
; the palette). Set to FFFF for GFX 01 and 17, and 0000 for all others. The
; result of this doesn't actually get used with LM's 4bpp hack, but does
; still get set.
!RAM_SMW_Graphics_Mode7TileBuffer #= !Define_SMW_LowRAMLocation+$1BA3
	!RAM_SMW_Graphics_3BPPTo4BPPBuffer #= !Define_SMW_LowRAMLocation+$1BB2
	!RAM_SMW_Flag_Alter3BPPTo4BPPConversion #= !Define_SMW_LowRAMLocation+$1BBC
; Layer 3 settings. #$00 = No Layer 3; #$01 = Low and high tide; #$02 = Low
; tide only; #$03 = Tileset specific image.
!RAM_SMW_Misc_LevelLayer3Settings #= !Define_SMW_LowRAMLocation+$1BE3
; VRAM address to start uploading data from the table at $1BE6. Used for
; Layer 1.
!RAM_SMW_Blocks_Layer1VRAMUploadAddressLo #= !Define_SMW_LowRAMLocation+$1BE4
!RAM_SMW_Blocks_Layer1VRAMUploadAddressHi #= !RAM_SMW_Blocks_Layer1VRAMUploadAddressLo+$01
; Which tiles should be used for each row of 16x16 tiles, 2 bytes per 8x8
; tile, used while scrolling layer 1 (loading new tiles). In horizontal
; levels, $7E:1BE6-$7E:1C65 form the left column of 8x8 tiles while
; $7E:1C66-$7E:1CE5 form the right column of 8x8 tiles. On the overworld and
; in vertical levels, $7E:1BE6-$7E:1C65 form the upper row of 8x8 tiles,
; while $7E:1C66-$7E:1CE5 form the bottom row of 8x8 tiles.
!RAM_SMW_Blocks_Layer1TilesToUploadBuffer #= !Define_SMW_LowRAMLocation+$1BE6
; VRAM address to start uploading data from the table at $7E:1CE8. It's used
; for layer 2. Big endian.
!RAM_SMW_Blocks_Layer2VRAMUploadAddressLo #= !Define_SMW_LowRAMLocation+$1CE6
!RAM_SMW_Blocks_Layer2VRAMUploadAddressHi #= !RAM_SMW_Blocks_Layer2VRAMUploadAddressLo+$01
; Which tiles should be used for each row of 16x16 tiles, 2 bytes per 8x8
; tile, used while scrolling interactive layer 2 (loading new tiles). In
; horizontal levels, $7E:1CE8-$7E:1D77 form the left column of 8x8 tiles
; while $7E:1D78-$7E:1DE7 form the right column of 8x8 tiles. On the
; overworld and in vertical levels, $7E:1CE8-$7E:1D77 form the upper row of
; 8x8 tiles, while $7E:1D78-$7E:1DE7 form the bottom row of 8x8 tiles.
!RAM_SMW_Blocks_Layer2TilesToUploadBuffer #= !Define_SMW_LowRAMLocation+$1CE8
; This is a pointer index used for various tasks during the submap switching
; scene ($7E:13D9 is #$0A).
!RAM_SMW_Overworld_SubmapSwitchProcess #= !Define_SMW_LowRAMLocation+$1DE8
; If non-zero, indicates an event should be activated on overworld load
; (otherwise, event handling is skipped). The 'Course Clear!' and Switch
; Palace message box routines set this just before loading the overworld,
; and it's set to zero again when the event finishes executing.
; Additionally, the enemy credits use this as the current screen number.
; Counts up to #$0C, which has the last set of enemies (the Koopa Kids and
; Bowser).
!RAM_SMW_Counter_EnemyRollcallScreen #= !Define_SMW_LowRAMLocation+$1DE9
	!RAM_SMW_Overworld_CheckIfEventPassedFlag #= !Define_SMW_LowRAMLocation+$1DE9
; Overworld event to run at level end. #$FF means that no event will be run.
!RAM_SMW_Overworld_CurrentEventNumber #= !Define_SMW_LowRAMLocation+$1DEA
; Event tile to load to the overworld. A starting value is set to this at
; level end, and it increments until it reaches the value of $7E:1DED.
!RAM_SMW_Overworld_StartingEventTileLo #= !Define_SMW_LowRAMLocation+$1DEB
!RAM_SMW_Overworld_StartingEventTileHi #= !RAM_SMW_Overworld_StartingEventTileLo+$01
; Last event tile to load to the overworld during a given event, set at
; level end.
!RAM_SMW_Overworld_FinalEventTileLo #= !Define_SMW_LowRAMLocation+$1DED
!RAM_SMW_Overworld_FinalEventTileHi #= !RAM_SMW_Overworld_FinalEventTileLo+$01
;Empty $001DEF
; 16-bit X position of the camera when using the overworld scroll function.
; Only used to determine which way the camera should move to get back to the
; player.
!RAM_SMW_Overworld_ScrollCameraXPosLo #= !Define_SMW_LowRAMLocation+$1DF0
!RAM_SMW_Overworld_ScrollCameraXPosHi #= !RAM_SMW_Overworld_ScrollCameraXPosLo+$01
; $7E:1DF2 - Y position of the camera when using the overworld scroll
; function, low byte. $7E:1DF3 - Y position of the camera when using the
; overworld scroll function, high byte. These values are only used to
; determine which way the camera should go to get back to the player.
!RAM_SMW_Overworld_ScrollCameraYPosLo #= !Define_SMW_LowRAMLocation+$1DF2
!RAM_SMW_Overworld_ScrollCameraYPosHi #= !RAM_SMW_Overworld_ScrollCameraYPosLo+$01
; Index to intro control sequence data table.
!RAM_SMW_Misc_TitleScreenMovementDataIndex #= !Define_SMW_LowRAMLocation+$1DF4
; Timer to used for multiple purposes: - How long a particular input during
; the intro sequence will remain pressed. - How long the Nintendo Presents
; screen will remain active. - How long a Switch Palace message will remain
; active. - How long the player has to wait before they can dismiss the
; intro message.
!RAM_SMW_Timer_TitleScreenInputTimer #= !Define_SMW_LowRAMLocation+$1DF5
	!RAM_SMW_Timer_DisplayNintendoPresents #= !Define_SMW_LowRAMLocation+$1DF5
	!RAM_SMW_Timer_DisplaySpecialMessage #= !Define_SMW_LowRAMLocation+$1DF5
; Star and Warp pipe handler. It's an index of the current star/warp pipe
; tile you're standing on, multiplied by two. With this index, the
; destination coordinates are determined.
!RAM_SMW_Overworld_StarPipeIndex #= !Define_SMW_LowRAMLocation+$1DF6
; Used by the Star Road warp star on the overworld. Determines the speed
; with which the player is launched in the air during warping. The higher
; the value, the faster they gets launched in the air. By default the
; maximum is #$04, though this cap can be altered by editing
; $04:9E70/0x22070.
!RAM_SMW_Overworld_StarLaunchSpeed #= !Define_SMW_LowRAMLocation+$1DF7
; Used by the Star Road warp star tile on the overworld. It controls how
; long the player has to stay on the ground during the warp, before they
; actually gets launched in the air. The player gets airborne as soon as the
; timer hits #$31 (as it increments).
!RAM_SMW_Timer_WaitBeforeStarLaunch #= !Define_SMW_LowRAMLocation+$1DF8
; SPC700 I/O ports. Write values to play music/SFX; see details lists for
; valid values in each port. The original game reserves $1DFB for music,
; while $1DF9 and $1DFC are used for sound effects. $1DFA meanwhile handles
; a couple of additional high-priority sounds and special effects (e.g.
; toggling Yoshi drums). Note that the valid values lists are based on a
; clean rom. If using a tool for custom music, songs and sound effects may
; be remapped for their original layout. For example, with AddmusicK you can
; find them in "Addmusic_sound effects.txt" ($1DF9/$1DFC) and
; "Addmusic_list.txt" ($1DFB).
!RAM_SMW_IO_SoundCh1 #= !Define_SMW_LowRAMLocation+$1DF9
!RAM_SMW_IO_SoundCh2 #= !RAM_SMW_IO_SoundCh1+$01
!RAM_SMW_IO_MusicCh1 #= !RAM_SMW_IO_SoundCh1+$02
!RAM_SMW_IO_SoundCh3 #= !RAM_SMW_IO_SoundCh1+$03
; Empty. Cleared on reset, titlescreen, overworld and level load (the latter
; two due to new music banks being uploaded). Note that $7E:1DFD is cleared
; twice, due to a 16-bit store to $7E:1DFC - at $04:969F/0x2189F (LDA #$0023
; : STA $1DFC) and $05:C75D/0x2C95D (LDA #$0009 : STA $1DFC).
!RAM_SMW_UnusedRAM_7E1DFD #= !Define_SMW_LowRAMLocation+$1DFD
!RAM_SMW_UnusedRAM_7E1DFE #= !RAM_SMW_UnusedRAM_7E1DFD+$01
; A copy of $7E:1DFB, the music register. It contains the last value written
; to SNES register $2142. Probably used to keep the music playing between
; areas.
!RAM_SMW_IO_CopyOfMusicCh1 #= !RAM_SMW_UnusedRAM_7E1DFD+$02
; Empty. Cleared on reset, titlescreen, overworld and level load (the latter
; two due to new music banks being uploaded).
!RAM_SMW_UnusedRAM_7E1E00 #= !RAM_SMW_UnusedRAM_7E1DFD+$03
; During levels, holding A and pressing L will cycle this address through
; the values 00, 01, 02. The value, however, is only actually read by the
; unused free-roam debug code found at $00CC86 (enabled via the edit
; described at $00CC84). When enabled, the values correspond to: 00 = off,
; 01 = enable max P-speed, 02 = enable no-clip free roam. Use this tweak to
; disable the cycling, rendering the address truly empty to use as free RAM
; (cleared at reset and title screen load).
!RAM_SMW_Debug_FreeMovement #= !Define_SMW_LowRAMLocation+$1E01
; Cluster sprite Y position, low byte.
!RAM_SMW_ClusterSpr_YPosLo #= !Define_SMW_LowRAMLocation+$1E02
; Cluster sprite X position, low byte.
!RAM_SMW_ClusterSpr_XPosLo #= !Define_SMW_LowRAMLocation+$1E16
; Cluster sprite Y position, high byte.
!RAM_SMW_ClusterSpr_YPosHi #= !Define_SMW_LowRAMLocation+$1E2A
; Cluster sprite X position, high byte.
!RAM_SMW_ClusterSpr_XPosHi #= !Define_SMW_LowRAMLocation+$1E3E
; Miscellaneous cluster sprite table, mainly used as its Y speed
; (particularly for the position update routine at $02FF98).
!RAM_SMW_ClusterSpr_Table7E1E52 #= !Define_SMW_LowRAMLocation+$1E52
; Miscellaneous cluster sprite table, mainly used as its X speed
; (particularly for the position update routine at $02FF98).
!RAM_SMW_ClusterSpr_Table7E1E66 #= !Define_SMW_LowRAMLocation+$1E66
; Miscellaneous cluster sprite table, mainly used as the accumulating
; fraction bits of its Y position (particularly for the position update
; routine at $02FF98).
!RAM_SMW_ClusterSpr_Table7E1E7A #= !Define_SMW_LowRAMLocation+$1E7A
; Miscellaneous cluster sprite table, mainly used as the accumulating
; fraction bits of its X position (particularly for the position update
; routine at $02FF98).
!RAM_SMW_ClusterSpr_Table7E1E8E #= !Define_SMW_LowRAMLocation+$1E8E
; Overworld level setting flags, location within the table corresponds to
; $7E13BF. Format: bmesudlr. b = level is beaten. m = midway point has been
; passed. e = unused in SMW, Lunar Magic turns it into the "no entry if
; level already passed" flag. s = unused in SMW, Lunar Magic turns it into
; the "open Save Prompt when level is beaten" flag. u = enable walking
; upwards. d = enable walking downwards. l = enable walking leftwards. r =
; enable walking rightwards. Setting the high bit of $7E1EEB will enable the
; special stage features (autumn overworld palettes, etc.) in the ORIGINAL
; game. The bit is set when you beat level 125 (FUNKY).
!RAM_SMW_Overworld_LevelTileSettings #= !Define_SMW_LowRAMLocation+$1EA2			; 96 bytes
; Overworld event flags. The table works bitwise - if a bit corresponding to
; an event is set, that event has been run. If it's clear, it hasn't been
; run yet. To find the bit for a particular event, use event >> 3 to get the
; byte, and then 1 << (7 - (event & 7)) to get a bitmask for the bit
; (ordered high to low).
!RAM_SMW_Overworld_EventFlags #= !Define_SMW_LowRAMLocation+$1F02
; Current submap for Mario. #$00 = Main map; #$01 = Yoshi's Island; #$02 =
; Vanilla Dome; #$03 = Forest of Illusion; #$04 = Valley of Bowser; #$05 =
; Special World; #$06 = Star World.
!RAM_SMW_Overworld_MarioMap #= !Define_SMW_LowRAMLocation+$1F11
; Current submap for Luigi. #$00 = Main map; #$01 = Yoshi's Island; #$02 =
; Vanilla Dome; #$03 = Forest of Illusion; #$04 = Valley of Bowser; #$05 =
; Special World; #$06 = Star World.
!RAM_SMW_Overworld_LuigiMap #= !RAM_SMW_Overworld_MarioMap+$01
; Player animation on the overworld. $7E:1F13/4 form Mario's image and
; $7E:1F15/6 form Luigi's image. Note that the high bytes of the two (bytes
; 2 and 4, $7E:1F14 and $7E:1F16) are actually unused.
!RAM_SMW_Overworld_MarioAnimationLo #= !Define_SMW_LowRAMLocation+$1F13
!RAM_SMW_Overworld_MarioAnimationHi #= !RAM_SMW_Overworld_MarioAnimationLo+$01
!RAM_SMW_Overworld_LuigiAnimationLo #= !RAM_SMW_Overworld_MarioAnimationLo+$02
!RAM_SMW_Overworld_LuigiAnimationHi #= !RAM_SMW_Overworld_MarioAnimationLo+$03
; Overworld X position of Mario.
!RAM_SMW_Overworld_MarioXPosLo #= !Define_SMW_LowRAMLocation+$1F17
!RAM_SMW_Overworld_MarioXPosHi #= !RAM_SMW_Overworld_MarioXPosLo+$01
; Overworld Y position of Mario.
!RAM_SMW_Overworld_MarioYPosLo #= !RAM_SMW_Overworld_MarioXPosLo+$02
!RAM_SMW_Overworld_MarioYPosHi #= !RAM_SMW_Overworld_MarioXPosLo+$03
; Overworld X position of Luigi.
!RAM_SMW_Overworld_LuigiXPosLo #= !RAM_SMW_Overworld_MarioXPosLo+$04
!RAM_SMW_Overworld_LuigiXPosHi #= !RAM_SMW_Overworld_MarioXPosLo+$05
; Overworld Y position of Luigi.
!RAM_SMW_Overworld_LuigiYPosLo #= !RAM_SMW_Overworld_MarioXPosLo+$06
!RAM_SMW_Overworld_LuigiYPosHi #= !RAM_SMW_Overworld_MarioXPosLo+$07
; Mario's overworld X position divided by #$10 (#16). Used to determine
; which layer 1 tile the player is standing on when drawing the level name,
; deciding which level the player is entering, and used during the overworld
; movement code.
!RAM_SMW_Overworld_MarioGridAlignedXPosLo #= !Define_SMW_LowRAMLocation+$1F1F
!RAM_SMW_Overworld_MarioGridAlignedXPosHi #= !RAM_SMW_Overworld_MarioGridAlignedXPosLo+$01
; Mario's overworld Y position divided by #$10 (#16). Used to determine
; which layer 1 tile the player is standing on when drawing the level name,
; deciding which level the player is entering, and used during the overworld
; movement code.
!RAM_SMW_Overworld_MarioGridAlignedYPosLo #= !RAM_SMW_Overworld_MarioGridAlignedXPosLo+$02
!RAM_SMW_Overworld_MarioGridAlignedYPosHi #= !RAM_SMW_Overworld_MarioGridAlignedXPosLo+$03
; Luigi's overworld X position divided by #$10 (#16). Used to determine
; which layer 1 tile the player is standing on when drawing the level name,
; deciding which level the player is entering, and used during the overworld
; movement code.
!RAM_SMW_Overworld_LuigiGridAlignedXPosLo #= !RAM_SMW_Overworld_MarioGridAlignedXPosLo+$04
!RAM_SMW_Overworld_LuigiGridAlignedXPosHi #= !RAM_SMW_Overworld_MarioGridAlignedXPosLo+$05
; Luigi's overworld Y position divided by #$10 (#16). Used to determine
; which layer 1 tile the player is standing on when drawing the level name,
; deciding which level the player is entering, and used during the overworld
; movement code.
!RAM_SMW_Overworld_LuigiGridAlignedYPosLo #= !RAM_SMW_Overworld_MarioGridAlignedXPosLo+$06
!RAM_SMW_Overworld_LuigiGridAlignedYPosHi #= !RAM_SMW_Overworld_MarioGridAlignedXPosLo+$07
; Switch palace activation flags. $00 = off (outline passable switch palace
; blocks), $01 = on (solid switch palace blocks): $7E1F27: Green $7E1F28:
; Yellow $7E1F29: Blue $7E1F2A: Red Note: effects to the blocks will only
; apply during level loading when these flags are changed.
!RAM_SMW_Flag_ActivatedGreenSwitch #= !Define_SMW_LowRAMLocation+$1F27
!RAM_SMW_Flag_ActivatedYellowSwitch #= !RAM_SMW_Flag_ActivatedGreenSwitch+$01
!RAM_SMW_Flag_ActivatedBlueSwitch #= !RAM_SMW_Flag_ActivatedGreenSwitch+$02
!RAM_SMW_Flag_ActivatedRedSwitch #= !RAM_SMW_Flag_ActivatedGreenSwitch+$03
;Empty $001F2B-$001F2D
; Number of events triggered. Can be used as a levels beaten counter.
!RAM_SMW_Counter_EventsTriggered #= !Define_SMW_LowRAMLocation+$1F2E
; Collected five or more Yoshi Coins flags for each level. Each of the 8
; bits of each byte represents a different level, based on the level's
; translevel ID from $7E13BF. If a level's corresponding bit is set, Yoshi
; Coin objects will be skipped when the level is reloaded. Notably, the
; levels within each byte are ordered from most-significant bit to
; least-significant (e.g. level 0 uses bit 7 of $1F2F, while level 7 uses
; bit 0). To find a specific level's flag, start with the level's translevel
; ID; use id >> 3 to find its byte, and 1 << (7 - (id & 7)) to get a bitmask
; for its bit.
!RAM_SMW_Flag_Collected5YoshiCoins #= !Define_SMW_LowRAMLocation+$1F2F
;Empty $001F3B
; Collected invisible 1-Up flags flags for each level. Each of the 8 bits of
; each byte represents a different level, based on the level's translevel ID
; from $7E13BF. If a level's corresponding bit is set, the invisible 1-Up
; checkpoint objects will be skipped when the level is reloaded. Notably,
; the levels within each byte are ordered from most-significant bit to
; least-significant (e.g. level 0 uses bit 7 of $1F3C, while level 7 uses
; bit 0). To find a specific level's flag, start with the level's translevel
; ID; use id >> 3 to find its byte, and 1 << (7 - (id & 7)) to get a bitmask
; for its bit.
!RAM_SMW_Flag_Collected1upCheckpoints #= !Define_SMW_LowRAMLocation+$1F3C
;Empty $001F48
; Buffer for $7E:1EA2-$7E:1F2E. SRAM transfer of those bytes goes via this
; buffer.
!RAM_SMW_Overworld_SaveBuffer #= !Define_SMW_LowRAMLocation+$1F49
; Unused sprite table, cleared at individual sprite load. (1 slot each.)
!RAM_SMW_NorSpr_UnusedTable7E1FD6 #= !Define_SMW_SprTable_1FD6
; Sprite table that decrements once per frame, and is used for multiple
; purposes. All standard sprites have it briefly set after spawning.
; Primarily, it disables water splashes from showing when the sprite enter
; or exits water, and disables interaction for the sprite with capespins,
; quake sprites, cape smashes, and net punches. Some sprites use it for
; miscellaneous purposes, as well.
!RAM_SMW_NorSpr_DecrementingTable7E1FE2 #= !Define_SMW_SprTable_1FE2
; Collected 3-Up moon flags for each level. Each of the 8 bits of each byte
; represents a different level, based on the level's translevel ID from
; $7E13BF. If a level's corresponding bit is set, 3-Up moon objects will be
; skipped when the level is reloaded. Notably, the levels within each byte
; are ordered from most-significant bit to least-significant (e.g. level 0
; uses bit 7 of $1FEE, while level 7 uses bit 0). To find a specific level's
; flag, start with the level's translevel ID; use id >> 3 to find its byte,
; and 1 << (7 - (id & 7)) to get a bitmask for its bit.
!RAM_SMW_Flag_CollectedMoons #= !Define_SMW_LowRAMLocation+$1FEE
;Empty $001FFA
; Lightning flash color index. Only #$00-#$07 are actually used. #$07 is the
; brightest shade of white, the lower the value, the closer to black it
; gets. This address gets its value from the table at $04:F700.
!RAM_SMW_Palettes_LightningFlashColorIndex #= !Define_SMW_LowRAMLocation+$1FFB
; How long to wait until the next lightning flash is generated. Gets its
; value from a table at $04:F6F8, which in turn gets its index from a
; "random" value in the routine of $04:F708 & #$07. This address decrements
; after the previous lightning flash has ended.
!RAM_SMW_Timer_WaitBeforeNextLightningFlash #= !Define_SMW_LowRAMLocation+$1FFC
; How long a lightning flash should last, per color change. Is set to #$08
; frames for the first color flash (the most bright one), then it's set to
; #$04 frames for the following color flashes which are becoming less and
; less bright. Decrements every frame.
!RAM_SMW_Timer_LightningFrameDuration #= !Define_SMW_LowRAMLocation+$1FFD
; Whether to update the background in the first part of the credits, or not.
; #$00 = Don't update the background. #$01 = Do update the background.
!RAM_SMW_Flag_UpdateCreditsBackground #= !Define_SMW_LowRAMLocation+$1FFE
;Empty $001FFF

;Non Mirrored RAM
