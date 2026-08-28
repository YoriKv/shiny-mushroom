;--- Global game state - $7E0F30-$7E13FF
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; Timer frame counter. Starts at $28 and decreases by 1 every frame. When
; this value becomes negative (by reaching $FF), one second is subtracted
; from SMW's game timer, and the counter is reset to $28. This means that an
; SMW second is 41 frames. At the NTSC refresh rate of about 60Hz, one SMW
; second is just over 2/3 of a real second (about 0.684s).
!RAM_SMW_Counter_TimerFrames #= !Define_SMW_LowRAMLocation+$0F30
; In-level timer. Each of its three digits are stored separately: $0F31 =
; Hundreds (X--) $0F32 = Tens (-X-) $0F33 = Ones (--X)
!RAM_SMW_Counter_TimerHundreds #= !Define_SMW_LowRAMLocation+$0F31
!RAM_SMW_Counter_TimerTens #= !RAM_SMW_Counter_TimerHundreds+$01
!RAM_SMW_Counter_TimerOnes #= !RAM_SMW_Counter_TimerHundreds+$02
; 24-bit scores for each player. $0F34 = Mario's score. $0F37 = Luigi's
; score. Note: This value is in hexadecimal and not decimal, so it needs to
; be converted before it can be displayed in-game. Additionally, this value
; is actually the score seen in the status bar divided by 10, as the "ones
; digit" SMW displays is actually just a static 0 tile.
!RAM_SMW_Player_MarioScoreLo #= !Define_SMW_LowRAMLocation+$0F34
!RAM_SMW_Player_MarioScoreMid #= !RAM_SMW_Player_MarioScoreLo+$01
!RAM_SMW_Player_MarioScoreHi #= !RAM_SMW_Player_MarioScoreLo+$02
!RAM_SMW_Player_LuigiScoreLo #= !RAM_SMW_Player_MarioScoreLo+$03
!RAM_SMW_Player_LuigiScoreMid #= !RAM_SMW_Player_MarioScoreLo+$04
!RAM_SMW_Player_LuigiScoreHi #= !RAM_SMW_Player_MarioScoreLo+$05
;Empty $000F3A-$000F3F
; Amount of score to add up to the score total, at level end. Decrements as
; total score increments.
!RAM_SMW_Counter_LevelEndScoreTallyLo #= !Define_SMW_LowRAMLocation+$0F40
!RAM_SMW_Counter_LevelEndScoreTallyHi #= !RAM_SMW_Counter_LevelEndScoreTallyLo+$01
;Empty $000F42-$000F47
; Mario Bonus stars.
!RAM_SMW_Player_MarioBonusStars #= !Define_SMW_LowRAMLocation+$0F48
; Luigi Bonus stars.
!RAM_SMW_Player_LuigiBonusStars #= !RAM_SMW_Player_MarioBonusStars+$01
; Miscellaneous cluster sprite table.
!RAM_SMW_ClusterSpr_Table7E0F4A #= !Define_SMW_LowRAMLocation+$0F4A
;Empty $000F5E-$000F71
; Miscellaneous cluster sprite table.
!RAM_SMW_ClusterSpr_Table7E0F72 #= !Define_SMW_LowRAMLocation+$0F72
; Miscellaneous cluster sprite table.
!RAM_SMW_ClusterSpr_Table7E0F86 #= !Define_SMW_LowRAMLocation+$0F86
; Miscellaneous cluster sprite table. Used specifically by the Boo and
; Swooper ceilings.
!RAM_SMW_ClusterSpr_Table7E0F9A #= !Define_SMW_LowRAMLocation+$0F9A
; Low byte of the angle of the Boo rings. $7E:0FAE is for the first Boo ring
; active; $7E:0FAF is for the second Boo ring active. Note that this is not
; reset on level or overworld load.
!RAM_SMW_ClusterSpr04_BooRing_Ring1AngleLo #= !Define_SMW_LowRAMLocation+$0FAE
!RAM_SMW_ClusterSpr04_BooRing_Ring2AngleLo #= !RAM_SMW_ClusterSpr04_BooRing_Ring1AngleLo+$01
; High byte of the angle of the Boo rings. $7E:0FB0 is for the first Boo
; ring active; $7E:0FB1 is for the second Boo ring active. Note that this
; does not reset on level or overworld load.
!RAM_SMW_ClusterSpr04_BooRing_Ring1AngleHi #= !Define_SMW_LowRAMLocation+$0FB0
!RAM_SMW_ClusterSpr04_BooRing_Ring2AngleHi #= !RAM_SMW_ClusterSpr04_BooRing_Ring1AngleHi+$01
; Boo ring center X position, low byte. $7E:0FB2 is for the first active Boo
; ring; $7E:0FB3 is for the second active Boo ring.
!RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosLo #= !Define_SMW_LowRAMLocation+$0FB2
!RAM_SMW_ClusterSpr04_BooRing_Ring2CenterXPosLo #= !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosLo+$01
; Boo ring center X position, high byte. $7E:0FB4 is for the first active
; Boo ring; $7E:0FB5 is for the second active Boo ring.
!RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosHi #= !Define_SMW_LowRAMLocation+$0FB4
!RAM_SMW_ClusterSpr04_BooRing_Ring2CenterXPosHi #= !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterXPosHi+$01
; Boo ring center Y position, low byte. $7E:0FB6 is for the first active Boo
; ring; $7E:0FB7 is for the second active Boo ring.
!RAM_SMW_ClusterSpr04_BooRing_Ring1CenterYPosLo #= !Define_SMW_LowRAMLocation+$0FB6
!RAM_SMW_ClusterSpr04_BooRing_Ring2CenterYPosLo #= !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterYPosLo+$01
; Boo ring center Y position, high byte. $7E:0FB8 is for the first active
; Boo ring; $7E:0FB9 is for the second active Boo ring.
!RAM_SMW_ClusterSpr04_BooRing_Ring1CenterYPosHi #= !Define_SMW_LowRAMLocation+$0FB8
!RAM_SMW_ClusterSpr04_BooRing_Ring2CenterYPosHi #= !RAM_SMW_ClusterSpr04_BooRing_Ring1CenterYPosHi+$01
; Offscreen flag for the Boo ring. If a byte is set to 01, the ring is
; offscreen and doesn't show up. $7E:0FBA is for the first Boo ring active;
; $7E:0FBB is for the second.
!RAM_SMW_ClusterSpr04_BooRing_Ring1OffscreenFlag #= !Define_SMW_LowRAMLocation+$0FBA
!RAM_SMW_ClusterSpr04_BooRing_Ring2OffscreenFlag #= !RAM_SMW_ClusterSpr04_BooRing_Ring1OffscreenFlag+$01
; Boo ring index to level table (see $7E:1938). They are never erased,
; though, so they will always be reloaded.
!RAM_SMW_ClusterSpr04_BooRing_UnusedRing1LevelListIndex #= !Define_SMW_LowRAMLocation+$0FBC
!RAM_SMW_ClusterSpr04_BooRing_UnusedRing2LevelListIndex #= !RAM_SMW_ClusterSpr04_BooRing_UnusedRing1LevelListIndex+$01
; Used as a table of 16-bit pointers to the VRAM data for each of the
; original game's Map16 tiles (tiles 000-1FF), indexed by tile * 2.
; Generally references the tables at around $0D8000 (levels, FG), $0D9100
; (levels, BG), or $05D000 (overworld). Only the lower two bytes of each are
; included, though, with the bank byte just assumed based on whether the
; player is in a level or the overworld.
!RAM_SMW_Pointer_Map16Tiles #= !Define_SMW_LowRAMLocation+$0FBE			; 1024 bytes
; Item memory settings from header.
!RAM_SMW_Misc_ItemMemorySetting #= !Define_SMW_LowRAMLocation+$13BE
; Translevel number, set during transfer from world map to level. This
; identifies the first room of the current level. To convert this to a room
; number (the "level number" in Lunar Magic), if > #$24, then add #$DC. In
; the clean ROM, the actual formula is more complex. If translevel number >
; #$24, then subtract #$24. Then check RAM $1F11/$1F12. If the player is in
; a submap (not the big world map), then add #$100. Since the submaps of SMW
; use translevel numbers > #$24 and the big map uses numbers <= #$24, the
; simplication is that #$100 - #$24 is #$DC; Lunar Magic forces this
; simplification to remain.
!RAM_SMW_Overworld_LevelNumberLo #= !Define_SMW_LowRAMLocation+$13BF
!RAM_SMW_UnusedRAM_LevelNumberHi #= !RAM_SMW_Overworld_LevelNumberLo+$01
; Current Layer 1 overworld tile the player is standing on.
!RAM_SMW_Overworld_TilePlayerIsStandingdOnLo #= !Define_SMW_LowRAMLocation+$13C1
; Used occasionally on the overworld as the high byte of $13C1, and thus
; should be kept as #$00 there. It is safe to use in levels, however.
; Cleared on reset, title screen load, and when walking onto a new overworld
; tile.
!RAM_SMW_Overworld_TilePlayerIsStandingdOnHi #= !RAM_SMW_Overworld_TilePlayerIsStandingdOnLo+$01
; Current player submap. #$00 = Main map; #$01 = Yoshi's Island; #$02 =
; Vanilla Dome; #$03 = Forest of Illusion; #$04 = Valley of Bowser; #$05 =
; Special World; #$06 = Star World. Note that it is sometimes inaccurate. It
; is wiser to use $7E:0DB3 and $7E:1F11.
!RAM_SMW_Overworld_CurrentlyLoadedSubmapLo #= !Define_SMW_LowRAMLocation+$13C3
; An address that is expected to be #$00 throughout the entire game.
; $7E:13C3 (current player submap) is often used in 16-bit mode, so using
; this address for different purposes is a bad idea, unless you make sure
; it's cleared on overworld load. Is also cleared during the switch between
; Mario and Luigi. Furthermore, cleared on reset and titlescreen load.
!RAM_SMW_Overworld_CurrentlyLoadedSubmapHi #= !RAM_SMW_Overworld_CurrentlyLoadedSubmapLo+$01
; Increments each time a 3-Up moon is collected, serves no other purpose.
; (Its value is never loaded.)
!RAM_SMW_UnusedRAM_3upMoonsCounter #= !Define_SMW_LowRAMLocation+$13C5
; Used by SMW's cutscenes. Goes from #$01 to #$08 and these values are in
; the order of the boss battles, e.g. #$01 = Iggy's castle, #$02 = Morton's
; castle. #$08 is the value used for the credits. Set to #$FF (in
; conjunction with $7E1493) to end the level as a boss fight: Mario won't
; walk during the fanfare, and it will trigger the boss cutscene set in
; Lunar Magic for the current level (if any). This also works for triggering
; the credit sequence.
!RAM_SMW_Misc_CurrentlyActiveBossEndCutscene #= !Define_SMW_LowRAMLocation+$13C6
; Yoshi color. #$04=yellow; #$06=blue; #$08=red; #$0A=green. Refreshes on
; level change
!RAM_SMW_Yoshi_CurrentYoshiColor #= !Define_SMW_LowRAMLocation+$13C7
;Empty $0013C8
; Show "Continue/End" menu flag. #$00 = Don't show it; #$01 = freeze player,
; but don't load the text yet; #$02 = freeze player, load "Continue/End"
; menu.
!RAM_SMW_Flag_ShowContinueAndEnd #= !Define_SMW_LowRAMLocation+$13C9
; Show save prompt flag. It actually triggers when you get on a new level
; tile. #$00 = Don't show save prompt; #$01 = show save prompt.
!RAM_SMW_Flag_ShowSavePrompt #= !Define_SMW_LowRAMLocation+$13CA
; This has been left out in the current SMW version. When you hit a goal
; tape, and spawn a starman (which never happens), this is set to #$01. Now
; each time you switch an area in a level, this gets multiplied by 2. When
; this reaches #$80 (changed area seven times), you will start the area with
; the star power. The instruction which sets this address to #$01 is located
; at $00:FB5C.
!RAM_SMW_UnusedRAM_GotInvincibleStarFromGoal #= !Define_SMW_LowRAMLocation+$13CB
; The value you store here is the amount of coins that are being added up,
; once per frame, to the total (done by incrementing the coin count and
; decrementing $13CC until 0). This is originally to allow the coin
; incrementing animation instead of instantly showing the total. This is
; handled by a code at $008F1D-$008F27. In the vanilla game, $13CC is
; written to via the routines at $05B329 - used by sprite 7E, the flying red
; coin, to give the player 5 coins - $05B330 - used by the Yoshi coin, to
; give the player 1 coin without overwriting the Yoshi coin sound effect -
; and $05B34A - used by various things which give the player a coin. These
; routines accumulate the value, in such a manner that the player can
; collect more than one coin in the same frame.
!RAM_SMW_Counter_CoinHandler #= !Define_SMW_LowRAMLocation+$13CC
; The entered level's midway entrance screen: the high nibble of
; SecondaryHeader3, stored here by SMW_SpecifySublevelToLoad and only for a
; level entered from the overworld, so a sublevel runs on the value its main
; level loaded. Its one reader is the midway point tile, which sets the
; midway flag only while this is non-zero -- a level whose nibble is zero
; grabs a midpoint that still makes you big but records nothing. The same
; nibble is read again out of scratch RAM by the routine that stores it, to
; place the player when the level tile's midway bit is set. Lunar Magic
; hijacks the midway point's check and reuses the byte for its own purposes.
!RAM_SMW_Misc_MidwayEntranceScreen #= !Define_SMW_LowRAMLocation+$13CD
; Midway Point flag. #$00 = Midway Point not crossed; #$01 = Midway Point
; crossed. Also used on the overworld as a flag to to indicate the level
; should activate an event.
!RAM_SMW_Flag_GotMidpoint #= !Define_SMW_LowRAMLocation+$13CE
	!RAM_SMW_Flag_ActivateOverworldEvent #= !RAM_SMW_Flag_GotMidpoint
; Used to override the castle/ghost house entrance cutscene after you
; collect the midway point. #$00 = Show castle/ghost house entrance cutscene
; after collecting midway point. #$40 = Don't show castle/ghost house
; entrance cutscene after collecting midway point. Note that any non-zero
; value will work, this is just what SMW uses. Change $05:D9DE to #$9C to
; make the cutscene play regardless.
!RAM_SMW_Flag_OverrideNoYoshiIntroForMidwayEntrance #= !Define_SMW_LowRAMLocation+$13CF
; Index to what tile should be stored to VRAM during the castle/switch
; palace/fortress destruction sequence. #$00 = Pressed green switch. #$01 =
; Pressed yellow/red/blue switch. #$02 = Destroyed fortress. #$03 =
; Destroyed castle with exit. #$04 = Destroyed castle without exit. The tile
; data is then read from $04:EE7A through a 24-bit pointer at $7E:000A
; (scratch RAM).
!RAM_SMW_Overworld_DestroyTileEventTileIndex #= !Define_SMW_LowRAMLocation+$13D0
; Holds the value of the listed castle/fortress/switch tile that must be
; destroyed, by checking which event it uses (table at $04E5D6). For
; example, event #$06 (Iggy's Castle destroyed) makes this address hold
; value #$00 (it's the first slot in the table). This address is then used
; as index to the address where the destroyed tile is uploaded to VRAM.
!RAM_SMW_Overworld_DestroyTileEventVRAMIndex #= !Define_SMW_LowRAMLocation+$13D1
; Color of the currently pressed switch palace, or #$00 for None. It's set
; to #$01 when the player hits a switch palace, and then set to the correct
; color (#$01 for Yellow, #$02 for Blue, #$03 for Red and #$04 for Green,
; others are oddly colored and/or flipped) by the message box routine. It
; creates both the ! blocks in the message boxes and on the overworld.
!RAM_SMW_Misc_ColorOfPalaceSwitchPressed1 #= !Define_SMW_LowRAMLocation+$13D2
; Timer that disables Start from flipping the Pause flag when its value is
; not #$00 (thus, #$01-#$FF). If it is #$00, being able to press Start to
; get into the Pause mode is possible.
!RAM_SMW_Timer_PreventPause #= !Define_SMW_LowRAMLocation+$13D3
; The pause flag for levels, and the "look around the map" flag on the
; overworld. In a level: 00 = off, 01 = paused On the overworld: 00 = off,
; 01 = looking around, 02 = returning to player Note that this does not
; cover instances of temporary pauses during gameplay (e.g. L/R scrolling,
; powerup animations, pipes, etc.), which can instead by checked via $9D.
!RAM_SMW_Flag_Pause #= !Define_SMW_LowRAMLocation+$13D4
	!RAM_SMW_Flag_MainMapFreeScrolling #= !Define_SMW_LowRAMLocation+$13D4
; A flag that determines whether or not Layer 3 should scroll with the
; screen. If this is zero, Layer 3 will scroll depending on the tileset and
; tide setting; if it is any other value, Layer 3 will always be at the same
; position relative to Layer 1. Also used on the overworld as accumulating
; fraction bits for player X speed (see $04:9801).
!RAM_SMW_Flag_DisableLayer3Scroll #= !Define_SMW_LowRAMLocation+$13D5
	!RAM_SMW_Player_OverworldSubXPosLo #= !Define_SMW_LowRAMLocation+$13D5
; Amount of time to wait until the score-incrementing drumroll begins when
; you beat a level. Any time you enter a level, this address is set to #$50.
; Once you beat the level and the number of bonus stars you won and the
; score is displayed (or just the score if you didn't cut the goal tape),
; this timer will decrement itself once per frame. Once it reaches a
; negative value or zero, the drumroll will commence. Once the drumroll
; ends, this is set to #$30, and then set to zero upon going to the
; overworld. It serves the same purpose after you beat a boss as well.
!RAM_SMW_Timer_WaitBeforeScoreTally #= !Define_SMW_LowRAMLocation+$13D6
	!RAM_SMW_Player_OverworldSubXPosHi #= !RAM_SMW_Player_OverworldSubXPosLo+$01
; Y position fraction bits for the intro march (walking to Yoshi's House).
; Treated as 16-bit, but the high byte is effectively unused outside of
; being written to. With Lunar Magic v3.00, this address gains a new purpose
; in horizontal levels, being used to hold the height of the level data (in
; units of pixels). For example, in the original level sizes, this value is
; set to 0x01B0 (for 0x1B blocks tall). Because the level screen is always
; 16 blocks wide, this is also the number of blocks per screen column.
!RAM_SMW_Player_OverworldSubYPosLo #= !RAM_SMW_Player_OverworldSubXPosLo+$02
!RAM_SMW_Player_OverworldSubYPosHi #= !RAM_SMW_Player_OverworldSubXPosLo+$03
; A pointer to various processes running on the overworld. Also used in the
; level end march.
!RAM_SMW_Pointer_CurrentOverworldProcess #= !Define_SMW_LowRAMLocation+$13D9
	!RAM_SMW_Pointer_CurrentLevelEndProcess #= !Define_SMW_LowRAMLocation+$13D9
; Accumulating fraction bits for the player's X position. Generally, only
; the upper four bits are used (i.e. %xxxx0000), with the player's X speed
; ($7B) being added to it after shifting 4 bits to the left. This value can
; be thought of as "subpixels", or fractions of a pixel. The game shifts
; Mario's X position an extra pixel any time the value overflows after
; adding his X speed in the routine at $00DC4F. Note that the lower 4 bits
; may still end up non-zero if the player is pushed by the sides of the
; screen in an autoscrolling level.
!RAM_SMW_Player_SubXPos #= !Define_SMW_LowRAMLocation+$13DA
; Player walking/running frame. As the player runs, this will cycle between
; 0 and the maximum defined by the table at $00DC78 (indexed by the player's
; powerup). By default, small Mario cycles between 0 and 1, while other
; powerups cycle 0-2-1-0. The speed at which it cycles is managed by $1496,
; which obtains its rate from the table at $00DC7C.
!RAM_SMW_Player_WalkingFrame #= !Define_SMW_LowRAMLocation+$13DB
; Accumulating fraction bits for the player's Y position, though the game
; only ever uses the the upper four bits (i.e. %yyyy0000), with the player's
; Y speed ($7D) being added to it after shifting 4 bits to the left. This
; value can be thought of as "subpixels", i.e. fractions of a pixel. The
; game shifts Mario's Y position an extra pixel any time the value overflows
; after adding his Y speed in the routine at $00DC4F.
!RAM_SMW_Player_SubYPos #= !RAM_SMW_Player_SubXPos+$02
; Pose used while the player is on the ground and turning around with a
; non-zero X speed. Uses same format as $13E0. This address can be used as a
; flag for when the player is turning, but note that it only gets set if the
; player is moving horizontally already; if the player turns from a
; stand-still, it will not be set. $1499 can be used to check this instead
; if the player is also holding an item.
!RAM_SMW_Player_TurningAroundFlag #= !Define_SMW_LowRAMLocation+$13DD
; Poses used on overworld map and during credits by the player. The
; animation uses three frames, namely: this value, this value + 1, and this
; value + 2. Can also be used as a "Player is looking up" flag. That's
; cleared every frame, and it's set to #$03 when holding the Up arrow and
; standing still. The graphics routine is the only code that actually reads
; it.
!RAM_SMW_Player_OverrideWalkingFrames #= !Define_SMW_LowRAMLocation+$13DE
; This address controls which image must be shown of the cape. This
; obviously only has effect when the player has a cape at all. While walking
; and sprint-jumping, frames 3 through 6 are cycled through, while 7 through
; A are used when falling downward. Pose zero is used for both standing
; still and jumping straight upwards, but is never shown without being
; preceded by frames 2 and 1. Note that when the player is swooping/flying
; with his cape, $7E:13E0 will override the cape image. See also the diagram
; shown under $7E:13E0, poses #$2A through #$2F. Whatever value $7E:13DF has
; will be irrelevant during this phase. Cape images beyond #$0A are not
; recommended for usage, as they are glitched.
!RAM_SMW_Player_CapeImage #= !Define_SMW_LowRAMLocation+$13DF
; This address controls the pose of Mario and Luigi. Writing to it will draw
; the player with the corresponding image. Notably: Poses 40 and 41 are
; blank; the player is "invisible". These are indicated with a large red
; cross in the diagram. Poses 2A-2F (flying) require the player to have a
; cape powerup, or they won't display properly. Pose 42 (inflated, small)
; can be shown regardless of powerup. It is obviously not recommended to be
; used as such. The same can be said about pose 43 (inflated, big). Poses
; 00, 3D and 46 are all used in the powerup animation. Poses 14, 20, 21, 27,
; 28 and 29 are all used when riding Yoshi. Poses 00-3C may differ in
; appearance between small, big/fire, and cape powerups. Poses 3D onwards do
; not. Poses beyond 45 are not properly defined and are generally not
; recommended to use.
!RAM_SMW_Player_CurrentPose #= !Define_SMW_LowRAMLocation+$13E0
; What kind of slope the player is on (also set when flying with a cape).
!RAM_SMW_Player_SlopePlayerIsOn1 #= !Define_SMW_LowRAMLocation+$13E1
; Spinjump fireball timer. It increments every frame when the player
; spinjumps, if they have fire power. If the lowest four bits are clear, the
; player will throw out a fireball. The fourth bit (#$10) is the direction
; in which that fireball will move.
!RAM_SMW_Player_SpinjumpFireballTimer #= !Define_SMW_LowRAMLocation+$13E2
; Player is wall-running flag.
!RAM_SMW_Player_WallWalkStatus #= !Define_SMW_LowRAMLocation+$13E3
; Player dash timer/P-meter. Increments with #$02 every frame the player is
; walking on the ground with the dash button held, otherwise decrements
; until it is zero. #$70 indicates that the player is at its maximum running
; speed, and also means that the player is able to fly with a cape.
!RAM_SMW_Player_PMeter #= !Define_SMW_LowRAMLocation+$13E4
; This is the index used to index the table at $00DC7C, to determine how
; many frames to store to the player animation timer, at $7E:1496. It
; changes depending on the surface the player is standing/walking/running
; on.
!RAM_SMW_Player_AnimationSpeedIndex #= !Define_SMW_LowRAMLocation+$13E5
;Empty $0013E6-$0013E7
; Cape spin interacts with sprites flag. #$00 = don't interact; #$01 = do
; interact.
!RAM_SMW_Flag_CapeToSpriteInteraction #= !Define_SMW_LowRAMLocation+$13E8
; Cape interaction X position within the level. It's adjusted when the cape
; attack is used.
!RAM_SMW_Player_CapeHitboxXLo #= !Define_SMW_LowRAMLocation+$13E9
!RAM_SMW_Player_CapeHitboxXHi #= !RAM_SMW_Player_CapeHitboxXLo+$01
; Cape interaction Y position within the level. It's adjusted when the cape
; attack is used.
!RAM_SMW_Player_CapeHitboxYLo #= !Define_SMW_LowRAMLocation+$13EB
!RAM_SMW_Player_CapeHitboxYHi #= !RAM_SMW_Player_CapeHitboxYLo+$01
; Player pose on a slope when sliding, is set to #$1C. This value is also
; negative (bit 7 set) when landing from flying, which allows the player to
; slide.
!RAM_SMW_Player_SlidingOnGround #= !Define_SMW_LowRAMLocation+$13ED
; What kind of slope the player is on.
!RAM_SMW_Player_SlopePlayerIsOn2 #= !Define_SMW_LowRAMLocation+$13EE
; Player is on ground flag. Set to #$01 on Layer 1, #$02 on Layer 2, and
; #$03 when on both. If they're running fast enough up a slope, that value
; is doubled. Is only set when touching an actual floor, and not when
; running up walls. Does not work correctly in blocks, as the value still
; has to be calculated at that point. Instead, the value is copied over to
; $7E008D during that time. If Layer 1 interaction is enabled, that address
; is also doubled.
!RAM_SMW_Player_OnGroundFlag #= !Define_SMW_LowRAMLocation+$13EF
; Used to calculate the index to the direction the player faces while using
; a climbing net door. The formula is $7E149D << 1 & #$0E | $7E13F0. This
; address gets its value from $7E13F9.
!RAM_SMW_Player_FacingDirectionOnNetDoor #= !Define_SMW_LowRAMLocation+$13F0
; Vertical scrolling unlocked flag. When in a level that has its vertical
; scroll setting set to "No Vertical Scroll at Bottom unless Flying/Etc",
; this flag controls if the camera is currently locked at the bottom of the
; level (zero) or unlocked (non-zero). For managing if vertical scrolling is
; enabled in general, see $1412 instead.
!RAM_SMW_Flag_EnableVerticalScroll #= !Define_SMW_LowRAMLocation+$13F1
; Cleared on reset, titlescreen, overworld, and cutscene load, as well as at
; $00F8A7 (the routine that handles vertical scrolling).
!RAM_SMW_UnusedRAM_7E13F2 #= !Define_SMW_LowRAMLocation+$13F2
; P-balloon flag. It also serves as a timer for the inflation/deflation
; animation when set to a value greater than 1, which decrements each frame
; down to 1.
!RAM_SMW_Timer_InflateFromPBalloon #= !Define_SMW_LowRAMLocation+$13F3
; A byte assigned to each row of blocks in the coin bonus game. Updated as
; blocks are chosen by the player to decide whether a life is given or not.
; If the value is #$FF, a life will be handed out. $7E:13F4 is for the
; uppermost row, $7E:13F5 for the one below that, etc.
!RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1 #= !Define_SMW_LowRAMLocation+$13F4
!RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow2 #= !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1+$01
!RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow3 #= !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1+$02
!RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow4 #= !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1+$03
!RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow5 #= !RAM_SMW_Blocks_GiveLifeInCoinBonusGameFlagsRow1+$04
; Used to control the graphical layer priority of the player. 01 will send
; him behind objects, 02 will send him behind objects and sprites, and 03
; will only send him behind sprites. #$01 is also used to indicate Mario as
; being behind a net, meaning he'll only interact with sprites also behind
; nets (indicated by $1632). #$02 is used when entering pipes and #$03 is
; used on the overworld and after killing Bowser. Both of these disable
; sprite interaction entirely.
!RAM_SMW_Player_CurrentLayerPriority #= !Define_SMW_LowRAMLocation+$13F9
; Whether the player is capable of jumping out of the water immediately or
; not (so just below the surface). #$00 = No; #$01 = Yes.
!RAM_SMW_Player_CanJumpOutOfWater #= !Define_SMW_LowRAMLocation+$13FA
; Player is frozen flag. This includes controls and animation. Other sprites
; still move and can interact with the player, but contact with them should
; be avoided, as it would freeze the game. This may be useful for cutscenes
; to eliminate the jumping sound. Mainly used for the Yoshi growing
; animation from a baby to an adult, as well as while Yoshi is laying an egg
; or eating a berry. It's also used during the keyhole animation and at the
; start of Morton/Roy's fight.
!RAM_SMW_Player_FreezePlayerFlag #= !Define_SMW_LowRAMLocation+$13FB
; Currently active Mode 7 boss. Used for determining which graphics to load,
; as well as checking for various other purposes (like when the player
; should have priority over certain sprite backgrounds that can be found in
; the boss rooms). Note that Iggy and Lemmy don't make use of this despite
; having a Mode 7 room. Cleared on level->overworld transitions, and
; possibly at other times too.
!RAM_SMW_Misc_CurrentlyActiveBoss #= !Define_SMW_LowRAMLocation+$13FC
; When the L/R button is pressed, this address gets set to #$01 which
; briefly freezes the screen while the screen scrolls in whatever direction
; you pressed. It's cleared again when scrolling is done.
!RAM_SMW_Flag_LRScrollFlag #= !Define_SMW_LowRAMLocation+$13FD
; Indicates whether L/R scrolling is active, and in which direction. 00 =
; not L/R scrolling, 02 = scrolling right, 04 = scrolling left.
!RAM_SMW_Misc_LRScrollDirection #= !Define_SMW_LowRAMLocation+$13FE
; Player direction ($76) times 2. Used when scrolling the screen
; horizontally.
!RAM_SMW_Player_FacingDirectionX2 #= !Define_SMW_LowRAMLocation+$13FF
