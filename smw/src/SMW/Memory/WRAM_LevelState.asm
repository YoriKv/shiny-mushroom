;--- Level runtime state - $7E1400-$7E14C7
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; Controls if the camera should move to be at the proper place compared to
; the player. If this is set, L and R are ignored. #$00 = normal case, don't
; move camera automatically, keep it in place (assuming L/R aren't used).
; #$08 = move camera right. #$0A = move camera left.
!RAM_SMW_Camera_LRScrollMoveFlag #= !Define_SMW_LowRAMLocation+$1400
; Increments with one each time one of the L/R buttons is pressed, until the
; timer hits #$10 (at which the L/R screen scroll is activated) or if the
; buttons are released.
!RAM_SMW_Timer_TimeBeforeLRScroll #= !Define_SMW_LowRAMLocation+$1401
; A flag that is set when the player is on a note block that is currently
; going down, i.e. the bounce sprite is moving downwards. If this wouldn't
; be set, the player would be pushed away from tile 152 (the tile that
; temporarily comes into place of the note block).
!RAM_SMW_Blocks_NoteBlockBounceFlag #= !Define_SMW_LowRAMLocation+$1402
; Settings for current layer 3 tide. #$00 - Not a tide image #$01 - Water
; level changes #$02 - Water level doesn't change
!RAM_SMW_Flag_Layer3TideLevel #= !Define_SMW_LowRAMLocation+$1403
; If vertical scrolling is enabled and the screen is not currently locked to
; the bottom of the level, setting this flag tells the screen it needs to
; scroll upwards to "catch up" to Mario. This is only necessary when other
; conditions that cause the screen to scroll vertically are not met (such as
; flying, swimming, climbing, or running with a full P-meter). The original
; game sets it when the screen is unlocked and Mario is on the ground above
; the Y position defined at $00F806, and clears it once he passes below that
; line.
!RAM_SMW_Flag_ScrollUpToPlayer #= !Define_SMW_LowRAMLocation+$1404
; Indicates that the player is just about to warp to another level via a
; pipe, and whether or not Yoshi should be drawn at that point. It is set as
; soon as $7E:0088 reaches zero, and if Yoshi is inside the warp pipe too,
; his graphics will be hidden.
!RAM_SMW_Flag_AboutToWarpInPipe #= !Define_SMW_LowRAMLocation+$1405
; This is set to #$80 if you bounce off of a springboard or a purple
; triangle (while on Yoshi, that is), and is cleared when touching the
; ground. The game uses this, along with some other RAM addresses, to
; determine if the screen should scroll up with the player or not.
!RAM_SMW_Camera_BounceOffSpringFlag #= !Define_SMW_LowRAMLocation+$1406
; Player flying with cape phase. Controls player pose as well (table at
; $00:CE79).
!RAM_SMW_Player_CapeFlyingPhase #= !Define_SMW_LowRAMLocation+$1407
; Used to index the cape gliding table at $00:D7D4 to see what the next step
; should be in the cape gliding phase. That value is (eventually) stored in
; $7E:1407. #$00 = Make player rise. #$01 = Make player sink (eventually
; swoop down). #$02 = Holding off left/right button, make player sink, but
; not swoop down. #$03 = Holding off left/right button, swooping down, make
; player sink less. #$04 = Holding off left/right and X/Y buttons, terminate
; cape gliding.
!RAM_SMW_Player_CapeGlideIndex #= !Define_SMW_LowRAMLocation+$1408
; Keeps track of the furthest stage the player has been diving during
; flight. Possible values are: #$F8: the stage when not holding the right or
; left button #$F4: Partially aiming towards floor #$F0: Almost completely
; diving #$C8: Diving completely, the stage where you cause an earthquake
; where you land. When set to #$C8, the player will gain the large upwards
; boost (instead of the little normal boost) when cathing air.
!RAM_SMW_Player_FurthestCapeDiveStage #= !Define_SMW_LowRAMLocation+$1409
; Empty. Cleared on reset, titlescreen load, overworld load and during part
; of the cape flight routine.
!RAM_SMW_UnusedRAM_7E140A #= !Define_SMW_LowRAMLocation+$140A
;Empty $00140B-$00140C
; Spin Jump flag. #$00 = normal jump (or on ground); any other value =
; spinjumping.
!RAM_SMW_Player_SpinJumpFlag #= !Define_SMW_LowRAMLocation+$140D
; Layer 2 is touched flag, which is used in the Layer 2 sinking/rising upon
; touch scroll sprite. #$00 = Layer 2 not touched; #$01 = Layer 2 touched.
!RAM_SMW_Sprites_Layer2IsTouchedFlag #= !Define_SMW_LowRAMLocation+$140E
; Keeps incrementing in the Reznor battle room. It is used as a flag to
; determine that a different OAM index needs to be used for a smoke sprite
; or a puff of smoke, to make sure there's no conflict with the platform
; tiles. However, since this keeps incrementing and thus sometimes hits #$00
; again, it can occur that a platform tile disappears for one frame when a
; smoke sprite is shown.
!RAM_SMW_Flag_ReznorRoomOAMIndexTimer #= !Define_SMW_LowRAMLocation+$140F
; Yoshi has wings flag #1 (the other is $7E:141E). #$01 would mean that the
; player with a fire flower powerup can shoot fireballs while on Yoshi
; (never occurs in the game), whereas #$02 indicates Yoshi has wings. Note
; that this one only handles graphics of the wings (value #$02), and that it
; disables the Yoshi tongue action (value #$01). The value from $7E:141E is
; stored here each frame.
!RAM_SMW_Flag_DisplayYoshisWings #= !Define_SMW_LowRAMLocation+$1410
; Vertical and horizontal scroll settings from header: $1411: Horizontal
; scroll settings from header flag. #$00 = Disable; #$01 = Enable. $1412:
; Vertical scroll settings from header. #$00 = Disable; #$01 = Enable; #$02
; = Enable if flying/climbing/etc. Note that setting these to zero will
; merely disable the screen from scrolling within the player, as well
; checking the scroll limits to prevent it from escaping the level
; boundaries. It is disabled by auto-scroll sprite generators to prevent the
; code at $00F713 and $00F7F4 from interfering with the generator from
; moving the screen.
!RAM_SMW_Flag_Layer1HorizontalScrollLevelSetting #= !Define_SMW_LowRAMLocation+$1411
!RAM_SMW_Flag_Layer1VerticalScrollLevelSetting #= !Define_SMW_LowRAMLocation+$1412
; Horizontal scroll setting for Layer 2. The original game only uses 00
; (none), 01 (constant), and 02 (medium), while Lunar Magic expands on the
; system with additional values up to 1F. Notably, the actual order of these
; values is different from the order Lunar Magic lists them; see the details
; table for a full list.
!RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting #= !Define_SMW_LowRAMLocation+$1413
; Vertical scroll setting for Layer 2. The original game only uses 00
; (none), 01 (constant), 02 (medium), and 03 (slow), while Lunar Magic
; expands on the system with additional values up to 1F. Notably, the actual
; order of these values is different from the order Lunar Magic lists them;
; see the details table for a full list.
!RAM_SMW_Flag_Layer2VerticalScrollLevelSetting #= !Define_SMW_LowRAMLocation+$1414
;Empty $001415-$001416
; The base vertical offset of Layer 2 from Layer 1, when vertical scrolling
; is enabled for it. This is calculated based on the type of vertical
; scrolling set in $1414 and the initial FG/BG positions stored to $1C and
; $20 as $20 - ($1C * scroll rate) .
!RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo #= !Define_SMW_LowRAMLocation+$1417
!RAM_SMW_Camera_Layer2YPosRelativeToLayer1Hi #= !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo+$01
; How sprites enter pipes with the player. This handles carried sprites and
; riding yoshi, and is always set regardless whether or not the player is
; carrying a sprite and whether or not is riding yoshi. When this RAM is set
; to any non-zero and the sprite is being carried and/or yoshi is being
; ridden on, they're placed behind layer 1 and yoshi's tongue is not shown
; (when licking). $01 = Horizontal pipes (duck a little on yoshi and
; carrying sprites facing left or right). $02 = Vertical pipes (face the
; screen). $FF = Don't change image, only go behind layer (shooting out of
; slanted pipe). Note that this will probably work with all values
; #$03-#$FF.
!RAM_SMW_Yoshi_InPipe #= !Define_SMW_LowRAMLocation+$1419
; Counter that increments every time a new level is entered (with a door or
; pipe). This enables you to distinguish when the level has just been
; entered from the overworld (at which point the value is 00) rather than
; from a sublevel. Warning: Because this value increments each time a room
; is entered rather than simply getting set to 1, after transitioning 256
; times, it will overflow and cause problems.
!RAM_SMW_Counter_SublevelsEntered #= !Define_SMW_LowRAMLocation+$141A
; Determines if you have played the bonus game before in the same level
; before. If it is non-zero (meaning you've played the game before), all
; blocks in the coin game will always be incorrect. Note that if you don't
; hit a single block the first time playing the game, then this will be
; zero, and you can play the game again.
!RAM_SMW_Flag_PreventCoinBonusGameReplay #= !Define_SMW_LowRAMLocation+$141B
; What type of goal tape has just been hit, for deciding which event to
; activate after the goal walk is finished. Although this value will still
; be written in vertical levels, it has no effect due to the goal walk not
; occurring.
!RAM_SMW_Flag_SecretGoalSprite #= !Define_SMW_LowRAMLocation+$141C
; Whether "Mario/Luigi Start!" should be shown or not. Used after a
; "No-Yoshi" entrance to prevent the actual starting level from showing the
; text. #$00 = enable; #$01 = disable.
!RAM_SMW_Flag_ShowPlayerStart #= !Define_SMW_LowRAMLocation+$141D
; Yoshi has wings flag. The only possible value for this address in the
; original is #$02, but setting to #$01 will allow the player to throw
; fireballs if on Yoshi, even if they don't have fire power. This will,
; however, disable flight as well as Yoshi's tongue attack. It's
; recalculated each frame.
!RAM_SMW_Yoshi_YoshiHasWings #= !Define_SMW_LowRAMLocation+$141E
; Disable No Yoshi Intro flag. #$00 = regular behavior (depending on the
; tileset, the No Yoshi Intro is either shown or not). #$80 = the No Yoshi
; Intro is disabled, regardless of tileset.
!RAM_SMW_Flag_DisableNoYoshiIntro #= !Define_SMW_LowRAMLocation+$141F
; Yoshi Coins collected. Does not affect amount of Yoshi Coins on status
; bar, and is instead exclusively used to control the number of points each
; coin gives.
!RAM_SMW_Counter_YoshiCoinsCollected #= !Define_SMW_LowRAMLocation+$1420
; Counter used by the invisible 1-Up checkpoints. Starts at zero, and
; increments with one every time the next checkpoint has been touched.
; Resets to zero when a checkpoint has been touched that can't be checked
; yet, for example checkpoint #2 when #1 hasn't been touched yet.
!RAM_SMW_Counter_1upCheckPointsCollected #= !Define_SMW_LowRAMLocation+$1421
; Amount of Yoshi Coins to display on the status bar. Values #$01 through
; #$04 are the values where it will display that number of Yoshi Coins,
; otherwise none are displayed.
!RAM_SMW_Counter_YoshiCoinsToDisplay #= !Define_SMW_LowRAMLocation+$1422				; Todo: See if this can be merged with $001420
; Indicates which switch palace switch is being pressed. Its value also
; varies depending on which side of the switch was pressed. (Left side -> it
; uses the first value, right side -> it uses the second.) 01/02 = green,
; 05/06 = yellow, 09/0A = blue, 0D/0E = red. The bottom halves also set
; this, but this doesn't trigger anything.
!RAM_SMW_Misc_ColorOfPalaceSwitchPressed2 #= !Define_SMW_LowRAMLocation+$1423
; Used to determine whether or not the victory walk should display the
; number of collected bonus stars. If it is zero (see also $7E:1900), the
; amount of collected bonus stars is not displayed. Otherwise, it is.
; $7E:1900 is stored to it, causing this address to decrement as well. Also
; note that this value does NOT have any effect on the rest of the bonus
; text.
!RAM_SMW_Timer_DisplayBonusStars #= !Define_SMW_LowRAMLocation+$1424
; Bonus game flag. If anything non-zero, the bonus game will commence after
; the level has been cleared.
!RAM_SMW_Flag_ActiveBonusGame #= !Define_SMW_LowRAMLocation+$1425
; Message box trigger. #$00 = none; #$01 = message 1; #$02 = message 2; #$03
; = Yoshi thanks message.
!RAM_SMW_Misc_DisplayMessage #= !Define_SMW_LowRAMLocation+$1426
; Bowser clown car image. #$00 = Regular. #$01 = Blinking. #$02 = Hurt. #$03
; = Angry face. Higher values makes it cycle through the above ones.
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_ClownCarFaceAnimationFrame #= !Define_SMW_LowRAMLocation+$1427
; Used as an index for the frames of the Bowser propeller. Valid frames
; range from #$00-#$03.
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_PropellerAnimationFrameCounter #= !Define_SMW_LowRAMLocation+$1428
; Used to calculate which palette to use for Bowser. Valid values range from
; #$00-#$07. This value is calculated based on the Mode 7 scale factor, with
; the table at $03:A265.
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_PaletteIndex #= !Define_SMW_LowRAMLocation+$1429
; A set of RAM addresses used to determine the horizontal static camera
; region, which defines the size and position of the area in which Mario's
; movement should not cause the screen to scroll horizontally. There are
; three different 16-bit values involved in this: - $142A: The origin
; position of the region. - $142C: The left edge of the region (calculated
; as $142A - #$000C). - $142E: The right edge of the region (calculated as
; $142A + #$000C). It is worth noting that writing to $142C/$142E will not
; actually do anything, as those values are automatically recalculated every
; frame (at $00F6E0).
!RAM_SMW_Player_RelativePositionNeededToScrollScreenLo #= !Define_SMW_LowRAMLocation+$142A
!RAM_SMW_Player_RelativePositionNeededToScrollScreenHi #= !RAM_SMW_Player_RelativePositionNeededToScrollScreenLo+$01
!RAM_SMW_Camera_RelativePositionNeededToScrollScreenRightLo #= !Define_SMW_LowRAMLocation+$142C
!RAM_SMW_Camera_RelativePositionNeededToScrollScreenRightHi #= !RAM_SMW_Camera_RelativePositionNeededToScrollScreenRightLo+$01
!RAM_SMW_Camera_RelativePositionNeededToScrollScreenLeftLo #= !RAM_SMW_Camera_RelativePositionNeededToScrollScreenRightLo+$02
!RAM_SMW_Camera_RelativePositionNeededToScrollScreenLeftHi #= !RAM_SMW_Camera_RelativePositionNeededToScrollScreenRightLo+$03
; Lowest tile that's solid for sprites from below (in addition to 111
; through 16D). It's on page 1.
!RAM_SMW_Blocks_LowestNumberSolidMap16TileForSprites #= !Define_SMW_LowRAMLocation+$1430
; Highest tile that's solid for sprites from below (in addition to 111
; through 16D) plus 1. It's on page 1.
!RAM_SMW_Blocks_HighestNumberSolidMap16TileForSprites #= !Define_SMW_LowRAMLocation+$1431
; Directional coin activation flag. This is set to #$01 when the sprite
; changes the music, and it is used to prevent the player being able to
; spawn any more than one instance of the sprite in an entire level, as it
; carries across sublevels.
!RAM_SMW_NorSpr045_DirectionalCoins_NoRespawnFlag #= !Define_SMW_LowRAMLocation+$1432
; Scaling factor of the circle for the windowing HDMA effects used with the
; titlescreen, level ending and keyhole. The closer to zero, the smaller the
; circle. Loads titlescreen when value becomes #$F0 or higher.
!RAM_SMW_Timer_HDMAWindowScalingFactor #= !Define_SMW_LowRAMLocation+$1433
; Set to #$30 to end level via keyhole. Works as a timer of some sorts, to
; indicate how long the keyhole sequence should last - but in SMW, this
; value is never set to anything other than #$00 or #$30. Also, this address
; freezes player and sprites by storing its value to $7E:13FB, resp.
; $7E:009D.
!RAM_SMW_Timer_EndLevelViaKeyhole #= !Define_SMW_LowRAMLocation+$1434
; Keyhole growing/shrinking flag. #$00 = growing; #$01 = shrinking.
!RAM_SMW_Flag_KeyholeAnimationPhase #= !Define_SMW_LowRAMLocation+$1435
; Used for multiple purposes. Keyholes use it as the X position of the
; keyhole animation. The Iggy/Larry boss fight uses it to control the
; player's X position when on the ground. The overworld also uses it when
; spawning switch palace blocks. $1436 is used as the current base index to
; the tables at $7EB900; it increments by 0x08 with each set of blocks up to
; 0x28, at which point it resets to 0x00. $1437 is used as a timer for
; waiting between spawning each set of switch blocks.
!RAM_SMW_Misc_ScratchRAM7E1436 #= !Define_SMW_LowRAMLocation+$1436
	!RAM_SMW_Player_OnTiltingPlatformXPosLo #= !RAM_SMW_Misc_ScratchRAM7E1436
	!RAM_SMW_Player_OnTiltingPlatformXPosHi #= !RAM_SMW_Player_OnTiltingPlatformXPosLo+$01
	!RAM_SMW_Overworld_SwitchBlockEventBlocksThrownCounter #= !RAM_SMW_Misc_ScratchRAM7E1436
!RAM_SMW_Misc_ScratchRAM7E1437 #= !Define_SMW_LowRAMLocation+$1437
	!RAM_SMW_Overworld_SwitchBlockEventWaitBeforeNextEjection #= !RAM_SMW_Misc_ScratchRAM7E1437
; Used for multiple purposes. Keyholes use it as the Y position of the
; keyhole animation. The Iggy/Larry boss fight uses it to control the
; player's Y position when on the ground. The overworld also uses it when
; spawning switch palace blocks. $1438 is the base OAM index of the current
; block set. Increments by 0x20 with each set of blocks, then resets to 0x00
; once it reaches 0xA0. $1439 is a counter for how many sets of blocks have
; been spawned. It stops spawning at 0x08, but keeps counting up to 0x0C, at
; which point the spawn routine ends.
!RAM_SMW_Misc_ScratchRAM7E1438 #= !Define_SMW_LowRAMLocation+$1438
	!RAM_SMW_Player_OnTiltingPlatformYPosLo #= !RAM_SMW_Misc_ScratchRAM7E1438
	!RAM_SMW_Player_OnTiltingPlatformYPosHi #= !RAM_SMW_Player_OnTiltingPlatformYPosLo+$01
	!RAM_SMW_Overworld_SwitchBlockEventOAMOffset #= !RAM_SMW_Misc_ScratchRAM7E1438
!RAM_SMW_Misc_ScratchRAM7E1439 #= !Define_SMW_LowRAMLocation+$1439
	!RAM_SMW_Overworld_SwitchBlockEventEjectionCounter #= !RAM_SMW_Misc_ScratchRAM7E1439
; When set to a value that is not zero, this will make the game overwrite
; tiles 00-05, 10-15, 4A-4F, and 5A-5F with data decompressed at $7F977B.
; These are uploaded during NMI. Used to write the graphics for "MARIO
; START!", "LUIGI START!", "TIME UP!", "GAME OVER" and "BONUS GAME".
!RAM_SMW_Flag_UploadLoadScreenLettersToVRAM #= !Define_SMW_LowRAMLocation+$143A
; Which death message must be displayed. #$14 = "GAME OVER"; #$1D = "TIME
; UP!".
!RAM_SMW_Misc_DeathMessageToDisplay #= !Define_SMW_LowRAMLocation+$143B
; Death message animation timer. Amount of time until the two segments come
; together, such as with "GAME OVER", where the animation goes like this:
; GAME --> <-- OVER. Is set to #$C0, decrements by four at a time.
!RAM_SMW_Timer_DisplayDeathMessageAnimation #= !Define_SMW_LowRAMLocation+$143C
; Timer for the "TIME UP!"/"GAME OVER" death message - how long it should
; stay active after the two words have come together. Is set to #$FF,
; decrements by one at a time.
!RAM_SMW_Timer_TimeToDisplayDeathMessage #= !Define_SMW_LowRAMLocation+$143D
; Scroll command number. Also used during castle cutscenes. Iggy/Ludwig/Roy
; use it to indicate the switch was hit, Wendy uses it to indicate when the
; castle is fully erased, and Morton/Lemmy/Larry use it for deciding how to
; move the castle.
!RAM_SMW_L1ScrollSpr_SpriteID #= !Define_SMW_LowRAMLocation+$143E
	!RAM_SMW_Flag_CastleMovementInCutscene #= !RAM_SMW_L1ScrollSpr_SpriteID
		!RAM_SMW_Flag_DropkickCounter #= !RAM_SMW_Flag_CastleMovementInCutscene
		!RAM_SMW_Flag_TNTPlungerWasPressed #= !RAM_SMW_Flag_CastleMovementInCutscene
		!RAM_SMW_Flag_HammeredCastleShouldCrumble #= !RAM_SMW_Flag_CastleMovementInCutscene
		!RAM_SMW_Flag_PickedUpCastle #= !RAM_SMW_Flag_CastleMovementInCutscene
		!RAM_SMW_Flag_KickedCastle #= !RAM_SMW_Flag_CastleMovementInCutscene
		!RAM_SMW_Flag_FullyMoppedCastle #= !RAM_SMW_Flag_CastleMovementInCutscene
		!RAM_SMW_Flag_ShowVictoryPoseInLarryCutscene #= !RAM_SMW_Flag_CastleMovementInCutscene
; Scroll command number used on layer 2. This address serves as a complement
; to $7E:143E. This address is set by the init routine of the layer one of
; each scroll address. Also used during castle destruction cutscenes as a
; timer for animations, as well as a few miscellaneous wait timers.
!RAM_SMW_L2ScrollSpr_SpriteID #= !RAM_SMW_L1ScrollSpr_SpriteID+$01
	!RAM_SMW_Sprites_WaitBeforeCastleRocketAppearsInSky #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_CastleDustAnimationTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_DropkickContactAnimationTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_WaitBeforeCastleCrumblesFromStompTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_DudTNTSmokeAnimationTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_TNTFuseAnimationTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_TNTExplosionAnimationTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_DestroyedCastleRocketAnimationTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_DelayedTNTExplosionTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
	!RAM_SMW_Sprites_KickedCastleQuakeTimer #= !RAM_SMW_L2ScrollSpr_SpriteID
; The starting Y position of the current scroll sprite, left-shifted twice
; and with the extra bits still added. (Format: --YYYYEE, where Y = Y
; position and EE = extra bits). Regularly adjusted inside the scroll
; sprites. It can be particularly useful for determining what type of
; scrolling should be applied with this scroll sprite. This address is used
; for Layer 1 scrolling. Also used during the castle destruction cutscenes
; as a frame number for various animations.
!RAM_SMW_L1ScrollSpr_ScrollTypeIndex #= !Define_SMW_LowRAMLocation+$1440
	!RAM_SMW_Sprites_CastleDustFacingDirection #= !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	!RAM_SMW_Sprites_DudTNTSmokeAnimationIndex #= !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	!RAM_SMW_Sprites_TNTFuseAnimationIndex #= !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	!RAM_SMW_Sprites_TNTExplosionAnimationIndex #= !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
	!RAM_SMW_Sprites_FarawayCastleRocketAnimationIndex #= !RAM_SMW_L1ScrollSpr_ScrollTypeIndex
; The starting Y position of the current scroll sprite, left-shifted twice
; and with the extra bits still added. (Format: --YYYYEE, where Y = Y
; position and EE = extra bits). Regularly adjusted inside the scroll
; sprites. It can be particularly useful for determining what type of
; scrolling should be applied with this scroll sprite. This address is used
; for Layer 2 scrolling. Also used during Iggy, Ludwig, and Roy's castle
; destruction scenes as a timer for the explosion.
!RAM_SMW_L2ScrollSpr_ScrollTypeIndex #= !Define_SMW_LowRAMLocation+$1441
	!RAM_SMW_Sprites_TNTExplosionTimer #= !RAM_SMW_L2ScrollSpr_ScrollTypeIndex
; Used in scroll sprites for tracking what type of scrolling Layer 1 it is
; currently doing, usually depending on $1440. Also used during the Yoshi's
; House portion of the credits to keep track of the current phase (24-bit
; pointers to which can be found at $0CA1DE): 00 = Player and companion
; walks in 01 = Various Yoshis duck and watch in excitement. 02 = Eggs are
; shattering, one by one. 03 = Yoshis get up and "THANK YOU" appears on
; Yoshi's house. 04 = Yoshis jump in excitement, then screen fades out.
; Similarly used during the castle destruction sequences to keep track of
; the current phase for those as well. Each castle destruction has its own
; pointer table for this address, which can be found by starting from the
; pointer table at $0CC9A5.
!RAM_SMW_L1ScrollSpr_CurrentState #= !Define_SMW_LowRAMLocation+$1442
	!RAM_SMW_Pointer_CurrentYoshiHouseSceneProcess #= !RAM_SMW_L1ScrollSpr_CurrentState
	!RAM_SMW_Pointer_CurrentCutsceneProcess #= !RAM_SMW_L1ScrollSpr_CurrentState
; Used in scroll sprites for tracking what type of scrolling Layer 2 it is
; currently doing, usually depending on $1441. It's also a castle
; destruction sequence text timer. Starts at #$FF when the 'Welcome' music
; starts, and a new line of text appears every #$20 frames after that.
; (#$DF, #$BF, #$9F, etc.)
!RAM_SMW_L2ScrollSpr_CurrentState #= !Define_SMW_LowRAMLocation+$1443
	!RAM_SMW_Timer_DisplayCastleDestructionText #= !RAM_SMW_L2ScrollSpr_CurrentState
	!RAM_SMW_Misc_ZoneSelectionCursorPos #= !Define_SMW_LowRAMLocation+$1443						; Note: Exclusive to the arcade version
; Layer 1 scroll command pointer/timer. This timer serves no defined purpose
; on itself, but is generally used for waiting a specific number of frames
; before updating scroll properties such as speed. For example, with the
; Layer 1 auto-scroll, this value being #$00 indicates the auto-scroll has
; finished. Also used during the castle destruction scenes as an indicator
; to show the white surrender flag. Also used as a flag on the overworld to
; indicate if the player is on a level tile. Value is #$00 when on a path
; tile, and #$01 when on a level tile.
!RAM_SMW_L1ScrollSpr_Timer #= !Define_SMW_LowRAMLocation+$1444
	!RAM_SMW_Flag_ShowWhiteFlag #= !RAM_SMW_L1ScrollSpr_Timer
	!RAM_SMW_Overworld_PlayerIsSteppingOnLevelTileFlagLo #= !RAM_SMW_L1ScrollSpr_Timer
; Layer 2 scroll command pointer/timer. This timer serves no defined purpose
; on itself, but is generally used for waiting a specific number of frames
; before updating scroll properties such as speed. Also used during the
; castle destruction cutscenes for various purposes. Lemmy uses it as a
; timer for the hammer animation, Ludwig and Roy uses it as a counter for
; the ? marks (0-3 for Roy and 4-7 for Ludwig), and Wendy uses it to decide
; how the broom should move.
!RAM_SMW_L2ScrollSpr_Timer #= !Define_SMW_LowRAMLocation+$1445
	!RAM_SMW_Overworld_PlayerIsSteppingOnLevelTileFlagHi #= !RAM_SMW_Overworld_PlayerIsSteppingOnLevelTileFlagLo+$01
	!RAM_SMW_Sprites_SwingHammerTimer #= !RAM_SMW_L2ScrollSpr_Timer
	!RAM_SMW_Sprites_QuestionMarkAnimationIndex #= !RAM_SMW_L2ScrollSpr_Timer
	!RAM_SMW_Sprites_MoppingMovementDirection #= !RAM_SMW_L2ScrollSpr_Timer
; Layer 1 X speed used in the scrolling codes. #$0001-#$7FFF = move left;
; #$8000-#$FFFF = move right. #$0000 means there is no movement.
; Effectively, it's the X speed to give the player when they're touching the
; side of a screen, during a level which does not have regular Layer 1
; scrolling. Values are different depending on the type of (auto-)scroll.
; This value divided by #$10/#16 is stored into $7E:007B. Additionally used
; during the castle destruction cutscenes for various purposes. $1446 is
; used in Morton/Roy's scenes to show the huff cloud at the end and as the Y
; position of the broom in Wendy's scene. $1447 is used in Ludwig's scene as
; the vertical speed of the castle as well as a counter for the dust
; animation when it hits the hill, and in Larry's as the vertical speed of
; the castle as well as a timer for when it crashes.
!RAM_SMW_L1ScrollSpr_XSpeedLo #= !Define_SMW_LowRAMLocation+$1446
	!RAM_SMW_Sprites_MopYPosLo #= !RAM_SMW_L1ScrollSpr_XSpeedLo
	!RAM_SMW_Misc_CreditsTempLayer2XSpeedLo #= !RAM_SMW_L1ScrollSpr_XSpeedLo
	!RAM_SMW_Misc_ShowPlayerCough #= !RAM_SMW_L1ScrollSpr_XSpeedLo
!RAM_SMW_L1ScrollSpr_XSpeedHi #= !RAM_SMW_L1ScrollSpr_XSpeedLo+$01
	!RAM_SMW_Sprites_CastleLiftoffYSpeed #= !RAM_SMW_L1ScrollSpr_XSpeedHi
	!RAM_SMW_Sprites_DestroyedCastleRocketSmokeIndex #= !RAM_SMW_L1ScrollSpr_XSpeedHi
	!RAM_SMW_Sprites_KickedCastleYSpeed #= !RAM_SMW_L1ScrollSpr_XSpeedHi
	!RAM_SMW_Sprites_MopYPosHi #= !RAM_SMW_Sprites_MopYPosLo+$01
	!RAM_SMW_Misc_CreditsTempLayer2XSpeedHi #= !RAM_SMW_Misc_CreditsTempLayer2XSpeedLo+$01
; Layer 1 Y speed used in the scrolling codes. #$0001-#$7FFF = move upwards;
; #$8000-#$FFFF = move downwards. #$0000 means there is no movement. $1449
; specifically is also used as a timer in Wendy's castle destruction scene
; for pausing between shifting broom directions or moving Mario to the side.
!RAM_SMW_L1ScrollSpr_YSpeedLo #= !Define_SMW_LowRAMLocation+$1448
		!RAM_SMW_Misc_CreditsTempLayer3YSpeedLo #= !RAM_SMW_L1ScrollSpr_XSpeedLo+$02
!RAM_SMW_L1ScrollSpr_YSpeedHi #= !RAM_SMW_L1ScrollSpr_XSpeedLo+$01
	!RAM_SMW_Sprites_MopTimer #= !Define_SMW_LowRAMLocation+$1449
	!RAM_SMW_Misc_CreditsTempLayer3YSpeedHi #= !RAM_SMW_Misc_CreditsTempLayer3YSpeedLo+$01
; Layer 2 X speed used in the scrolling codes. #$0001-#$7FFF = move left;
; #$8000-#$FFFF = move right. #$0000 means there is no movement. $144A
; specifically is also used in the castle destruction cutscenes to indicate
; what sprite Mario is holding, if any, 00 indicates the egg, 01 indicates
; nothing, and anything greater indicates something else (e.g. the hammer or
; broom).
!RAM_SMW_L2ScrollSpr_XSpeedLo #= !Define_SMW_LowRAMLocation+$144A
	!RAM_SMW_Flag_DisplayThankYouBubble #= !Define_SMW_LowRAMLocation+$144A
!RAM_SMW_L2ScrollSpr_XSpeedHi #= !RAM_SMW_L2ScrollSpr_XSpeedLo+$01
	!RAM_SMW_Sprites_CarriedEggBounceFrameCounter #= !RAM_SMW_L2ScrollSpr_XSpeedHi
; Layer 2 Y speed used in the scrolling codes, particularly in the Layer 2
; scroll command (sprite EA). #$0001-#$7FFF = move upwards; #$8000-#$FFFF =
; move downwards. #$0000 means there is no movement. $7E:144D also controls
; the time until you can press a button to end the castle destruction
; sequence (after all text has been generated on-screen).
!RAM_SMW_L2ScrollSpr_YSpeedLo #= !Define_SMW_LowRAMLocation+$144C
	!RAM_SMW_Sprites_CarriedEggXPosLo #= !RAM_SMW_L2ScrollSpr_YSpeedLo
!RAM_SMW_L2ScrollSpr_YSpeedHi #= !RAM_SMW_L2ScrollSpr_YSpeedLo+$01
	!RAM_SMW_Timer_WaitBeforeAllowingEndOfCastleDestructionCutscene #= !RAM_SMW_L2ScrollSpr_YSpeedHi
; Used internally by scroll sprites, often as accumulating fraction bits for
; Layer 1's X position (specifically with the routine at $05C4F9). On the
; overworld, $144E specifically is used to determine after how many frames
; the player should face the screen again after settling on a level tile.
; During the credits, $144E is used as a timer for Peach's walking
; animation, while $144F indicates which frame of that animation she is in.
!RAM_SMW_L1ScrollSpr_SubXPosLo #= !Define_SMW_LowRAMLocation+$144E
	!RAM_SMW_Misc_CreditsTempLayer2XPosLo #= !RAM_SMW_L1ScrollSpr_SubXPosLo
	!RAM_SMW_Sprites_EndingPeachWalkBobbingTimer #= !RAM_SMW_L1ScrollSpr_SubXPosLo
	!RAM_SMW_Overworld_MakeStandingPlayerFaceDownTimerLo #= !RAM_SMW_L1ScrollSpr_SubXPosLo
!RAM_SMW_L1ScrollSpr_SubXPosHi #= !RAM_SMW_L1ScrollSpr_SubXPosLo+$01
	!RAM_SMW_Misc_CreditsTempLayer2SXPosHi #= !RAM_SMW_L1ScrollSpr_SubXPosLo+$01
	!RAM_SMW_Sprites_EndingPeachWalkBobbingFlag #= !RAM_SMW_L1ScrollSpr_SubXPosLo+$01
	!RAM_SMW_Overworld_MakeStandingPlayerFaceDownTimerHi #= !RAM_SMW_L1ScrollSpr_SubXPosLo+$01
; Used internally by scroll sprites as accumulating fraction bits for Layer
; 1's Y position, specifically with the routine at $05C4F9.
!RAM_SMW_L1ScrollSpr_SubYPosLo #= !Define_SMW_LowRAMLocation+$1450
	!RAM_SMW_Misc_CreditsTempLayer3YPosLo #= !RAM_SMW_L1ScrollSpr_SubXPosLo+$02
!RAM_SMW_L1ScrollSpr_SubYPosHi #= !RAM_SMW_L1ScrollSpr_SubYPosLo+$01
	!RAM_SMW_Misc_CreditsTempLayer3YPosHi #= !RAM_SMW_Misc_CreditsTempLayer3YPosLo+$01
; Used internally by scroll sprites, usually as accumulating fraction bits
; for Layer 2's X position (specifically with the routine at $05C4F9).
!RAM_SMW_L2ScrollSpr_SubXPosLo #= !Define_SMW_LowRAMLocation+$1452
!RAM_SMW_L2ScrollSpr_SubXPosHi #= !RAM_SMW_L2ScrollSpr_SubXPosLo+$01
; Used internally by scroll sprites as accumulating fraction bits for Layer
; 2's Y position, specifically with the routine at $05C4F9.
!RAM_SMW_L2ScrollSpr_SubYPosLo #= !Define_SMW_LowRAMLocation+$1454
!RAM_SMW_L2ScrollSpr_SubYPosHi #= !RAM_SMW_L2ScrollSpr_SubYPosLo+$01
; Used internally by scroll sprites for indexing the layer position RAM
; addresses based on which layer is being moved (00 = Layer 1, 04 = Layer
; 2).
!RAM_SMW_ScrollSpr_LayerIndex #= !Define_SMW_LowRAMLocation+$1456
; This flag is set and used to determine whether to upload the multicolor
; Yoshis in the ending cutscene. The surprised Yoshi image (when the eggs
; are hatching) will appear regardless of this address, but the jumping
; Yoshi images require this flag to be #$01. If anything else, they will not
; be drawn on-screen.
!RAM_SMW_Sprites_DrawEndingYoshis #= !Define_SMW_LowRAMLocation+$1457
; Layer 3 X speed, used by the non-tide autoscrolling Layer 3 settings (e.g.
; the fish or ghost house fog). Lunar Magic expands on the usage of this
; address when the advanced Layer 3 bypass is enabled, using the full 16-bit
; value as the Layer 3 autoscroll X speed. Also used during the Yoshi's
; House portion of the credits, with $1458 being used as the animation frame
; for the jumping Yoshis and $1459 being used as a timer for their crouching
; animation.
!RAM_SMW_Misc_Layer3XSpeedLo #= !Define_SMW_LowRAMLocation+$1458
	!RAM_SMW_Sprites_CheeringYoshiAnimationFrame #= !RAM_SMW_Misc_Layer3XSpeedLo
!RAM_SMW_Misc_Layer3XSpeedHi #= !RAM_SMW_Misc_Layer3XSpeedLo+$01
	!RAM_SMW_Sprites_WaitBeforeNextEndingYoshiDuckFrame #= !RAM_SMW_Misc_Layer3XSpeedHi
; Layer 3 Y speed, used by the original game for the rising/falling Layer 3
; tides. The tides only actually ever use the low byte, although the high
; byte does get cleared when initializing Layer 3. Lunar Magic expands on
; the usage of this address when the advanced Layer 3 bypass is enabled,
; using the full 16-bit value as the Layer 3 autoscroll Y speed. $145B is
; also used during the credits for various purposes. During the Yoshi House
; portion, it's used as a counter for the number of Yoshi eggs hatched. It's
; also used as for a timer to transition from the Yoshi House cutscene to
; the enemy roll, and subsequently as a timer for each screen of the enemy
; credits.
!RAM_SMW_Misc_Layer3YSpeedLo #= !Define_SMW_LowRAMLocation+$145A
	!RAM_SMW_Sprites_WhichEndingEggsHatched #= !RAM_SMW_Misc_Layer3YSpeedLo
!RAM_SMW_Misc_Layer3YSpeedHi #= !RAM_SMW_Misc_Layer3YSpeedLo+$01
	!RAM_SMW_Counter_NumberOfEndingEggsHatched #= !RAM_SMW_Misc_Layer3YSpeedHi
	!RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo #= !RAM_SMW_Misc_Layer3YSpeedHi
; Used as accumulating fraction bits for Layer 3's position. When using the
; rising/sinking tides, it's used for its Y position. Only the low byte is
; used in this case. When using an autoscrolling Layer 3 that isn't the
; tides (e.g. the fish and ghost house fog), it's instead used for the X
; position. The high byte does get written to in this case, although only
; the low byte actually gets read. Lunar Magic expands on the usage of this
; address when using the Layer 3 autoscroll settings of the advanced Layer 3
; bypass, by implementing separate accumulating fraction bits for both the X
; and Y position. $145C is used for the X position, while $145D is used for
; the Y. $145D is also used during the Yoshi's House portion of the credits
; as a timer to determine when to move to the next game mode. Gets set to
; #$F0 the moment all eggs hatched.
!RAM_SMW_Misc_Layer3TideSubYPosLo #= !Define_SMW_LowRAMLocation+$145C
	!RAM_SMW_Flag_EndingEggIsHatching #= !RAM_SMW_Misc_Layer3TideSubYPosLo
	!RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenHi #= !RAM_SMW_Timer_WaitBeforeNextEnemyRollcallScreenLo+$01
!RAM_SMW_Misc_Layer3TideSubYPosHi #= !RAM_SMW_Misc_Layer3TideSubYPosLo+$01
	!RAM_SMW_Timer_WaitBeforeFadingOutYoshisHouseScene #= !RAM_SMW_Misc_Layer3TideSubYPosLo+$01
;Empty $00145E-$00145F
; Direction of movement for the Layer 3 tides. 00 = downwards, 01 = upwards.
; When the advanced Layer 3 bypass is enabled, Lunar Magic also uses this
; for the Layer 3 vertical scroll setting, multiplied by 2. Notably, the
; actual order of these values is different from the order Lunar Magic lists
; them; see the details table for a full list.
!RAM_SMW_Flag_Layer3VerticalScrollDirection #= !Define_SMW_LowRAMLocation+$1460
; Empty. Cleared on reset, titlescreen load, overworld load and cutscene
; load. This byte functions as the "high byte" of $7E:1460. SMW does not
; actually use this byte, however it is overwritten during level load (see
; $05:BE92). Cleared on reset, titlescreen, overworld, level (with the
; exception of boss rooms) and cutscene load.
!RAM_SMW_UnusedRAM_7E1461 #= !Define_SMW_LowRAMLocation+$1461
; Layer 1 X position, next frame, as opposed to the current frame's position
; at $1A. Mainly used for autoscrolling Layer 1. Also used during the
; credits scene for the second layer 1 X position, where the output is
; separated in two halves, each with their own scrolling.
!RAM_SMW_Misc_Layer1XPosLo #= !Define_SMW_LowRAMLocation+$1462
!RAM_SMW_Misc_Layer1XPosHi #= !RAM_SMW_Misc_Layer1XPosLo+$01
; Layer 1 Y position, next frame, as opposed to the current frame's position
; at $1C. Mainly used for autoscrolling Layer 1.
!RAM_SMW_Misc_Layer1YPosLo #= !RAM_SMW_Misc_Layer1XPosLo+$02
!RAM_SMW_Misc_Layer1YPosHi #= !RAM_SMW_Misc_Layer1YPosLo+$01
; Layer 2 X position, next frame, as opposed to the current frame's position
; at $1E. Mainly used for autoscrolling Layer 2.
!RAM_SMW_Misc_Layer2XPosLo #= !RAM_SMW_Misc_Layer1XPosLo+$04
!RAM_SMW_Misc_Layer2XPosHi #= !RAM_SMW_Misc_Layer2XPosLo+$01
; Layer 2 Y position, next frame, as opposed to the current frame's position
; at $20. Mainly used for autoscrolling Layer 2.
!RAM_SMW_Misc_Layer2YPosLo #= !RAM_SMW_Misc_Layer1XPosLo+$06
!RAM_SMW_Misc_Layer2YPosHi #= !RAM_SMW_Misc_Layer2YPosLo+$01
; Used to determine how much layer 3 has moved horizontally in the current
; frame. This address is only used during the credits while displaying the
; enemies for the windowing HDMA. Also used by Lunar Magic to hold the Layer
; 3 Initial X position/offset.
!RAM_SMW_Misc_Layer3XDispLo #= !RAM_SMW_Misc_Layer1XPosLo+$08
!RAM_SMW_Misc_Layer3XDispHi #= !RAM_SMW_Misc_Layer3XDispLo+$01
;Empty $00146C-$00146F
; Carrying something flag. Very similar to the flag at $148F, and most of
; the time this address is just a copy of $148F's value from the previous
; frame. The one exception is that on the frame Mario picks up a carryable
; item, only $1470 will get set. Generally, it is safest to use both $1470
; and $148F whenever reading or writing to this flag.
!RAM_SMW_Player_CarryingSomethingFlag1 #= !Define_SMW_LowRAMLocation+$1470
; Whether the player is on top of a solid sprite, and what kind of sprite
; that is. #$01 = Standing on top of a floating rock, floating grass
; platform, floating skull, Mega Mole, carrot top lift, etc. This one
; calculates the player's position based on the next frame. #$02 = Standing
; on top of a springboard, pea bouncer. This one calculates the player's
; position based on the next frame. There's a check at $00:D60B so that the
; player can hold the jump button pressed for a longer while to jump higher.
; #$03 = Standing on top of a brown chained platform, gray falling platform.
; This one calculates the player's position based on the current frame.
!RAM_SMW_Misc_PlayerOnSolidSprite #= !Define_SMW_LowRAMLocation+$1471
; Left window X position of the top of the spotlight. It's always #$78. This
; is the value stored that is stored to $7E:147A every four frames.
!RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosTop #= !Define_SMW_LowRAMLocation+$1472
;Empty $001473
; Right window X position of the top of the spotlight. It's always #$87.
; This is the value that is stored to $7E:147C every four frames.
!RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosTop #= !Define_SMW_LowRAMLocation+$1474
;Empty $001475
; Left window X position of the extreme bottom of the spotlight. Please note
; that this position is for the imaginary scanline #$FF, whereas there are
; normally only #$E0 scanlines on a screen. That means that the value here
; is never equal to the left window X position on the very bottom of the
; screen, unless $7E:1476 is equal to $7E:1472, forming a straight vertical
; line.
!RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom #= !Define_SMW_LowRAMLocation+$1476
;Empty $001477
; Right window X position of the extreme bottom of the spotlight. Please
; note that this position is for the imaginary scanline #$FF, whereas there
; are normally only #$E0 scanlines on a screen. That means that the value
; here is never equal to the right window X position on the very bottom of
; the screen, unless $7E:1478 is equal to $7E:1474, forming a straight
; vertical line.
!RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom #= !Define_SMW_LowRAMLocation+$1478
;Empty $001479
; In the spotlight code, the left window X position of each scanline is
; calculated and temporarily stored here, after which this address stores
; its value to an even byte of $7E:04A0. What is left at the end of every
; frame is the left window X position on the very bottom scanline. This is
; used once in every four frames, probably to reduce lag.
!RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos #= !Define_SMW_LowRAMLocation+$147A
;Empty $00147B
; In the spotlight code, the right window X position of each scanline is
; calculated and temporarily stored here, after which this address stores
; its value to an odd byte of $7E:04A0. What is left at the end of every
; frame is the right window X position on the very bottom scanline. This
; address used once in every four frames, probably to reduce lag.
!RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos #= !Define_SMW_LowRAMLocation+$147C
;Empty $00147D
; Used by the spotlight to calculate whether or not to move the left window
; on a particular scan line into the direction of the resulting X position
; on the bottom left. It works by adding the width from $7E:1480 to itself
; (starting at #$00 initially), and if the resulting value is higher than
; #$CF (or even overflows, setting the carry bit), the left window moves a
; pixel into the direction of the resulting X position on the bottom left.
!RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow #= !Define_SMW_LowRAMLocation+$147E
; Used by the spotlight to calculate whether or not to move the right window
; on a particular scan line into the direction of the resulting X position
; on the bottom right. It works by adding the width from $7E:1481 to itself
; (starting at #$00 initially), and if the resulting value is higher than
; #$CF (or even overflows, setting the carry bit), the right window moves a
; pixel into the direction of the resulting X position on the bottom right.
!RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow #= !Define_SMW_LowRAMLocation+$147F
; Width between the top left window ($7E:1472) and the bottom left window
; ($7E:1476) of the spotlight. This value is always positive, and its sign
; flag is saved at $7E:1484.
!RAM_SMW_NorSpr0C6_Spotlight_WidthOfLeftSideOfWindow #= !Define_SMW_LowRAMLocation+$1480
; Width between the top right window ($7E:1474) and the bottom right window
; ($7E:1478) of the spotlight. This value is always positive, and its sign
; flag is saved at $7E:1485.
!RAM_SMW_NorSpr0C6_Spotlight_WidthOfRightSideOfWindow #= !Define_SMW_LowRAMLocation+$1481
; Used as a flag in the spotlight code to skip initialization of the top
; left, top right, bottom left, and bottom right RAM addresses. #$00 = Run
; initialization; #$01 = Do not run initialization.
!RAM_SMW_Flag_SkipSpotlightWindowInitialization #= !Define_SMW_LowRAMLocation+$1482
; Used as a flag for the current direction the spotlight is moving. #$00 =
; spotlight is moving right; #$01 = spotlight is moving left.
!RAM_SMW_NorSpr0C6_Spotlight_Direction #= !Define_SMW_LowRAMLocation+$1483
; A flag used in the spotlight code to determine which side of the top left
; window border the bottom left window border is on. #$00 = bottom left is
; more to the left; #$01 = bottom left is on the same position, or more to
; the right.
!RAM_SMW_NorSpr0C6_Spotlight_BottomLeftWindowPosRelativeToTop #= !Define_SMW_LowRAMLocation+$1484
; A flag used in the spotlight code to determine which side of the top right
; window border the bottom right window border is on. #$00 = bottom right is
; more to the left; #$01 = bottom right is on the same position, or more to
; the right.
!RAM_SMW_NorSpr0C6_Spotlight_BottomRightWindowPosRelativeToTop #= !Define_SMW_LowRAMLocation+$1485
; Unused, set to #$01 in the dark room spotlight sprite. Change $03:C544 to
; EA EA EA (NOP #3) to change this into free RAM. If that patch is
; performed, this address is safe for other uses. Cleared on reset,
; titlescreen load, overworld load and cutscene load.
!RAM_SMW_UnusedRAM_7E1486 #= !Define_SMW_LowRAMLocation+$1486
;Empty $001487-$00148A
; Seed used by random number generation subroutine to determine the next
; output. Do not use these if you want a random number. Use $148D instead.
!RAM_SMW_Misc_RNGRoutineScratchRAM148B #= !Define_SMW_LowRAMLocation+$148B
!RAM_SMW_Misc_RNGRoutineScratchRAM148C #= !RAM_SMW_Misc_RNGRoutineScratchRAM148B+$01
; Output of random number generation routine, located at $01ACF9.
!RAM_SMW_Misc_RandomByte1 #= !Define_SMW_LowRAMLocation+$148D
!RAM_SMW_Misc_RandomByte2 #= !RAM_SMW_Misc_RandomByte1+$01
; Carrying something flag. Very similar to the flag at $1470, except this
; one generally tracks the flag for the current frame. Cleared just before
; sprites get processed, then set by any carryable sprites the player is
; currently holding. Generally, it is safest to use both $1470 and $148F
; whenever reading or writing to this flag.
!RAM_SMW_Player_CarryingSomethingFlag2 #= !Define_SMW_LowRAMLocation+$148F
; Star power timer. Decrements every fourth frame ($14 divisible by 4). The
; music will revert when this timer reaches #$1E.
!RAM_SMW_Timer_StarPower #= !Define_SMW_LowRAMLocation+$1490
; Amount of pixels on the X/Y axis a sprite has moved in the current frame.
; It is set after every call to update sprite position based on speed (see
; $01801A, $018022, and $01802A), and the routine that updates both X/Y
; position based on speed will leave $7E1491 with the movement on the X axis
; in this address. Very often used for rideable sprites as this address can
; be added to the player position to move the player in tandem with the
; sprite. Note: If using $01802A (both X and Y movement), this contains the
; X-movement because it handles the Y movement first, then the X movement
; with the latter being the last write to $1491.
!RAM_SMW_Sprites_PositionDisp #= !Define_SMW_LowRAMLocation+$1491
; Player peace image timer.
!RAM_SMW_Timer_ShowVictoryPose #= !Define_SMW_LowRAMLocation+$1492
; End level timer. Setting to #$FF will end the level as a goal sphere /
; boss fight (use in conjunction with $7E13C6). Peace sign is shown here
; when the timer hits #$28. The switches (yellow, green, red and blue) set
; it to #$08.
!RAM_SMW_Timer_EndLevel #= !Define_SMW_LowRAMLocation+$1493
; Direction of the color fading at level end. Only the highest bit is ever
; read. #$00 = getting darker; #$80 = getting brighter.
!RAM_SMW_Palettes_LevelEndColorFadeDirection #= !Define_SMW_LowRAMLocation+$1494
; Timer that controls fading and the level end scorecard. Increments and
; stops when it hits #$40. While it's ticking, the colors will fade; when
; it's done, $7E:003A through $7E:003D won't be read and the Layer 3
; scrolling will be locked.
!RAM_SMW_Timer_LevelEndFade #= !Define_SMW_LowRAMLocation+$1495
; Player animation timer. This controls a lot of things such as the
; walking/running animation rate, how long the death animation should last,
; how long to stay invisible for after getting the cape, the alternating
; player images when the player is walking over slippery surfaces, etc.
!RAM_SMW_Player_AnimationTimer #= !Define_SMW_LowRAMLocation+$1496
; Flashing invulnerability timer - not to be confused with the star timer.
; This is activated when the player gets hurt. Controls both interaction
; (player should not interact with sprites again) as well as the blinking
; graphics.
!RAM_SMW_Timer_PlayerHurt #= !Define_SMW_LowRAMLocation+$1497
; Time to show player picking an item/object up pose.
!RAM_SMW_Timer_DisplayPlayerPickUpPose #= !Define_SMW_LowRAMLocation+$1498
; Time for player to face the screen. Normally, only set while Mario is
; Mario is turning with an item or entering a vertical pipe.
!RAM_SMW_Timer_DisplayPlayerFaceScreenPose #= !Define_SMW_LowRAMLocation+$1499
; Time to show player kicking something pose.
!RAM_SMW_Timer_DisplayPlayerKickingPose #= !Define_SMW_LowRAMLocation+$149A
; Time for the player to change through palettes, as if they got a fire
; flower. Only ticks when the "get flower" animation is active, and is just
; a flag otherwise.
!RAM_SMW_Timer_PlayerPaletteCycle #= !Define_SMW_LowRAMLocation+$149B
; Time to show player shooting a fireball pose.
!RAM_SMW_Timer_DisplayPlayerShootFireballPose #= !Define_SMW_LowRAMLocation+$149C
; Side flipping climbing net sprite flag and timer. Whenever you punch the
; flipping net, this gets set to #$1E and decrements every frame till it's
; zero. That's how many frames the spinning animation lasts. It also
; determines the X speed the player has while they're on the climbing net
; sprite - this means that it should be decremented every frame in order to
; avoid issues.
!RAM_SMW_Timer_OnSwingingClimbingNetDoor #= !Define_SMW_LowRAMLocation+$149D
; Player punches while climbing on a net flag and timer. Every time you
; punch a net this is set to #$08 and decremented till it's zero again.
; During the time it's not zero, the frame is displayed that shows the
; player punching the net. If you store #$08 or greater to it every frame
; you'll be hold onto the net without being able to move or get off. When
; this RAM address is non-zero, the player can also not move.
!RAM_SMW_Timer_DisplayPlayerNetPunchPose #= !Define_SMW_LowRAMLocation+$149E
; Cape flight takeoff timer. When the player has a feather and a max P-meter
; and they jump, this timer gets set to #$50. While this timer is set, the
; player can receive additional upwards boosts during the jump. If the
; player starts to descend and meets the additional conditions for flight
; (i.e. not spinjumping, riding Yoshi, carrying something, or sliding from a
; slope), then the player will start flying. This timer has two quirks.
; First is that it will not actually decrease to 0 while the player is in
; the air (stopping at 2). They won't be able to receive the vertical boosts
; anymore, but they'll still be able to gain flight so long as they do not
; touch the ground. The second quirk is that it does not reset when going
; into another sublevel, allowing the player to "carry over" flying if the
; timer is sufficient enough that they can get back into the air before the
; timer runs out.
!RAM_SMW_Timer_WaitBeforeCapeFlightBegins #= !Define_SMW_LowRAMLocation+$149F
; How long the running frames should be shown after the player launches off
; with the cape. Is #$10 by default and decrements each frame.
!RAM_SMW_Timer_ShowRunningFramesBeforeTakeOff #= !Define_SMW_LowRAMLocation+$14A0
; Player slides a bit when turning around timer. Most notably used with very
; steep slopes. If this is non-zero, $7E:13DD's image (#$0D) won't be shown.
!RAM_SMW_Timer_PlayerSlidesWhenTuring #= !Define_SMW_LowRAMLocation+$14A1
; Used as a timer for the cape animation. This is what makes the cape wave
; when the player walks and what makes the cape fall when they stop.
!RAM_SMW_Timer_CapeFlapAnimation #= !Define_SMW_LowRAMLocation+$14A2
; A timer for Yoshi's tongue stretching out. #$12 = Yoshi about to stretch
; out tongue (timer starts here), player pose #$27. #$10 = $7E:18AE is set
; to #$06. #$0C = Player now gets a different pose, #$28. #$00 = Player now
; gets a different pose, #$20 (or #$21 if turning around, $7E:187A is used
; to determine that).
!RAM_SMW_Timer_YoshiTongueIsOut #= !Define_SMW_LowRAMLocation+$14A3
; Time until the player advances a diving stage, while flying and holding
; forward, and time until the player pulls back up a stage, while flying and
; holding backward.
!RAM_SMW_Timer_ChangeDivingState #= !Define_SMW_LowRAMLocation+$14A4
; Timer for how long you keep floating after releasing B when floating with
; the cape. It also affects how long Yoshi flaps his wings for when rising
; up while flying.
!RAM_SMW_Timer_TimeToFloatAfterCapeFlight #= !Define_SMW_LowRAMLocation+$14A5
; Cape spin timer.
!RAM_SMW_Timer_ActiveCapeSpin #= !Define_SMW_LowRAMLocation+$14A6
; Timer for breaking the bridge in Reznor battles. It is set to #$40 and
; decrements each frame. When it reaches #$3C, a tile on each side breaks.
; When it drops to #$00, a sound is played and it's reset to #$40 again.
!RAM_SMW_Timer_ReznorBridgeBreaking #= !Define_SMW_LowRAMLocation+$14A7
; Unused. $7E:14A8 decrements every frame automatically until it reaches
; zero, while $7E:14A9 and $7E:14AA decrement every fourth frame. $7E:14A9
; is cleared when the player ground pounds with the cape (this can be
; prevented by setting $02:94C6 to NOP #3 or [EA EA EA]), and $7E:14AA is
; set to #$40 when Yoshi grabs the wings (this can be stopped by setting
; $01:F6CF to NOP #3 or [EA EA EA]).
!RAM_SMW_UnusedRAM_7E14A8 #= !Define_SMW_LowRAMLocation+$14A8
!RAM_SMW_UnusedRAM_7E14A9 #= !Define_SMW_LowRAMLocation+$14A9
!RAM_SMW_UnusedRAM_7E14AA #= !Define_SMW_LowRAMLocation+$14AA
; Bonus game ending timer. Does nothing in a normal level, but during a
; bonus game, setting it will end the bonus game and return to the
; overworld. At #$44 it starts the "end bonus game" music, and at #$01 it
; actually fades to the overworld.
!RAM_SMW_Timer_BonusGameEnd #= !Define_SMW_LowRAMLocation+$14AB
; Empty. However, due to the code at $00:C563 and $00:C513, it decrements
; every fourth frame until it hits zero.
!RAM_SMW_UnusedRAM_7E14AC #= !Define_SMW_LowRAMLocation+$14AC
; Blue P-Switch timer. Decrements every fourth frame (you can convert
; seconds to this timer value via PSwitchTimerLength = Seconds * 15). The
; P-switch running out sound is played when this hits #$1E.
!RAM_SMW_Timer_BluePSwitch #= !Define_SMW_LowRAMLocation+$14AD
; Silver P-Switch timer. Decrements every fourth frame (you can convert
; seconds to this timer value via PSwitchTimerLength = Seconds * 15). The
; P-switch running out sound is played when this hits #$1E.
!RAM_SMW_Timer_SilverPSwitch #= !RAM_SMW_Timer_BluePSwitch+$01
; On/Off Switch value. #$00 is ON and all others (non-zero, i.e. #$01-#$FF)
; are OFF.
!RAM_SMW_Flag_OnOffSwitch #= !RAM_SMW_Timer_BluePSwitch+$02
; Used for multiple purposes. The 16-bit address forms the center X position
; of the brown chained platform that is currently processed. The formula for
; this address = $7E:14B4 - $7E:14BC. Additionally, the Lakitu cloud
; graphics routine uses $7E:14B0 as scratch RAM for the X position of a
; tile. $7E:14B0 is furthermore used in the Bowser battle as a timer between
; his various attacks. Set to #$78 at the beginning, and between attacks
; afterwards it is set to #$54 each time. Note that, whether he throws the
; Mechakoopas or not, does not only depend on this address! And finally,
; $7E:14B1 is a timer that is set to #$FF when Bowser begins with the
; Mechakoopa attack. Note that the Mechakoopas are thrown when this timer is
; at #$80.
!RAM_SMW_Misc_ScratchRAM7E14B0 #= !Define_SMW_LowRAMLocation+$14B0
	!RAM_SMW_Misc_RotatingObjectCenterXPosLo #= !RAM_SMW_Misc_ScratchRAM7E14B0
!RAM_SMW_Misc_ScratchRAM7E14B1 #= !Define_SMW_LowRAMLocation+$14B1
	!RAM_SMW_Misc_RotatingObjectCenterXPosHi #= !RAM_SMW_Misc_RotatingObjectCenterXPosLo+$01
; Used for multiple purposes. The 16-bit address forms the center Y position
; of the brown chained platform that is currently processed. Note that,
; since the radius based on the sprite Y position is always zero, this holds
; the same value as $7E:14B6. The formula for this address = $7E:14B6 -
; $7E:14BF. Additionally, the Lakitu cloud graphics routine uses $7E:14B2 as
; scratch RAM for the Y position of a tile. $7E:14B2 is also a flag for
; scaling when Bowser is flying away. #$00 = shrinking; #$01 = growing; #$02
; = disappear. And finally, $7E:14B3 is an incrementing index to the Y
; position for the teardrop tile that appears on the Clown Car when Bowser
; is hurt.
!RAM_SMW_Misc_ScratchRAM7E14B2 #= !Define_SMW_LowRAMLocation+$14B2
	!RAM_SMW_Misc_RotatingObjectCenterYPosLo #= !RAM_SMW_Misc_ScratchRAM7E14B2
!RAM_SMW_Misc_ScratchRAM7E14B3 #= !Define_SMW_LowRAMLocation+$14B3
	!RAM_SMW_Misc_RotatingObjectCenterYPosHi #= !RAM_SMW_Misc_RotatingObjectCenterYPosLo+$01
; Used for multiple purposes. Both addresses are used by brown chained
; platforms as a 16-bit X position of the platform's right-most point, when
; the cosine of the platform's angle is 1. This is a mirror of the sprite's
; X position around the sprite's center of rotation, so the center of the
; platform can also be found by subtracting the sprite's radius ($14BC) from
; here. Both are also used to determine the interactive X position of
; Iggy/Larry, as well as the X position of the player's fireballs during
; their boss battle. $14B4 specifically is used in the Bowser battle as an
; index to what music should be played in phases 2 and 3. It only appears to
; use values 07 and 08, which correspond to tracks 19 and 1A; both tracks
; are identical, so it may be a remnant of an unused music variant. $14B5
; specifically is also used a timer for Bowser's hurt state. If non-zero,
; Bowser will show his hurt pose.
!RAM_SMW_Misc_ScratchRAM7E14B4 #= !Define_SMW_LowRAMLocation+$14B4
	!RAM_SMW_Sprites_OnTiltingPlatformXOffsetLo #= !RAM_SMW_Misc_ScratchRAM7E14B4
!RAM_SMW_Misc_ScratchRAM7E14B5 #= !Define_SMW_LowRAMLocation+$14B5
	!RAM_SMW_Sprites_OnTiltingPlatformXOffsetHi #= !RAM_SMW_Misc_ScratchRAM7E14B5
; Used for multiple purposes. The 16-bit address is the Y position of the
; brown chained platform sprite at sin a = 0. It is in fact a mirror of the
; sprite Y position, which always stays the same. By subtracting the
; horizontal radius ($7E:14BF) from this address, the center position to
; revolve around is calculated. Since $7E:14BF is always zero, the center
; position and this address always have the same identical value. The 16-bit
; address is also used to determine Iggy/Larry interactive Y position, as
; well as the player's fireball Y position during this boss battle. $7E:14B6
; is also a timer that is set to #$FF when Bowser begins with the Big
; Steelie attack. Note that the Big Steelie is thrown when this timer is at
; #$80. And finally, $7E:14B7 holds the X position of each new fireball that
; falls from the sky in the Bowser battle, as well as the index to the sound
; effects that are generated with them (table at $03:A841).
!RAM_SMW_Misc_ScratchRAM7E14B6 #= !Define_SMW_LowRAMLocation+$14B6
	!RAM_SMW_Sprites_OnTiltingPlatformYOffsetLo #= !RAM_SMW_Misc_ScratchRAM7E14B6
!RAM_SMW_Misc_ScratchRAM7E14B7 #= !Define_SMW_LowRAMLocation+$14B7
	!RAM_SMW_Sprites_OnTiltingPlatformYOffsetHi #= !RAM_SMW_Misc_ScratchRAM7E14B7
; Used for multiple purposes. Both addresses are used by brown chained
; platforms as a 16-bit X position of the first (outermost) chain tile. This
; value is responsible for the actual movement of the platform and
; interaction with the player. $14B8 specifically seems to form a buffer for
; the X position of Iggy/Larry during their boss battle, similar to $14B4.
; $14B8 is also used as an attack counter used in the second phase of the
; Bowser battle to determine if Bowser should throw Mechakoopas or Big
; Steelies. It increments on every throw, on #$02 Mechakoopas are thrown,
; and on #$03 it resets to #$00.
!RAM_SMW_Misc_ScratchRAM7E14B8 #= !Define_SMW_LowRAMLocation+$14B8
	!RAM_SMW_Sprites_BrownRotatingPlatformFirstTileXPosLo #= !RAM_SMW_Misc_ScratchRAM7E14B8
!RAM_SMW_Misc_ScratchRAM7E14B9 #= !Define_SMW_LowRAMLocation+$14B9
	!RAM_SMW_Sprites_BrownRotatingPlatformFirstTileXPosHi #= !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileXPosLo+$01
; Used for multiple purposes. The 16-bit address is the Y position of the
; first (outermost) chain tile of the brown chained platform currently being
; processed. This address is responsible for the actual movement of the
; platform and interaction with the player. $7E:14BA itself seems to form a
; buffer for the Y position of Iggy/Larry during that boss battle, much
; similar to $7E:14B6.
!RAM_SMW_Misc_ScratchRAM7E14BA #= !Define_SMW_LowRAMLocation+$14BA
	!RAM_SMW_Sprites_BrownRotatingPlatformFirstTileYPosLo #= !RAM_SMW_Misc_ScratchRAM7E14BA
!RAM_SMW_Misc_ScratchRAM7E14BB #= !Define_SMW_LowRAMLocation+$14BB
	!RAM_SMW_Sprites_BrownRotatingPlatformFirstTileYPosHi #= !RAM_SMW_Sprites_BrownRotatingPlatformFirstTileYPosLo+$01
; Radius of the rotating brown platform, by default this value is #$50
; (found at $01:CACC). This value is subtracted from $7E:14B4 and stored
; into $7E:14B0. In SMW however, the value is always #$50. Additionally, the
; high byte is always #$00. Note that this radius depends on sprite X
; position (which stays the same). It calculates the center position of the
; imaginary circle you rotate around from that position. The further you
; increment the radius, the further you will have to move the sprite to the
; right in order for the center position to be the same. See also $7E:14BF.
!RAM_SMW_Misc_ScratchRAM7E14BC #= !Define_SMW_LowRAMLocation+$14BC
	!RAM_SMW_Misc_RotatingObjectXRadiusLo #= !RAM_SMW_Misc_ScratchRAM7E14BC
!RAM_SMW_Misc_ScratchRAM7E14BD #= !RAM_SMW_Misc_ScratchRAM7E14BC+$01
	!RAM_SMW_Misc_RotatingObjectXRadiusHi #= !RAM_SMW_Misc_RotatingObjectXRadiusLo+$01
;Empty $0014BE
; Another type of radius that would rely on the brown chained platform's Y
; position, except that it's always #$0000, and thus effectively it does
; nothing. Subtracted from $7E:14B6 and stored into $7E:14B2. See also
; $7E:14BC.
!RAM_SMW_Misc_ScratchRAM7E14BF #= !Define_SMW_LowRAMLocation+$14BF
	!RAM_SMW_Misc_RotatingObjectYRadiusLo #= !RAM_SMW_Misc_ScratchRAM7E14BF
!RAM_SMW_Misc_ScratchRAM7E14C0 #= !Define_SMW_LowRAMLocation+$14C0
	!RAM_SMW_Misc_RotatingObjectYRadiusHi #= !RAM_SMW_Misc_RotatingObjectYRadiusLo+$01
;Empty $0014C1
; Used to hold the sine value of the brown rotating platform. Note that the
; range of this is always #$0000-#$0100. XOR isn't applied to this value
; when it is negative.
!RAM_SMW_Sprites_BrownRotatingPlatformSineLo #= !Define_SMW_LowRAMLocation+$14C2
!RAM_SMW_Sprites_BrownRotatingPlatformSineHi #= !RAM_SMW_Sprites_BrownRotatingPlatformSineLo+$01 
;Empty $0014C4
; Used to hold the cosine value of the brown rotating platform. Note that
; the range of this is always #$0000-#$0100. XOR isn't applied to this value
; when it is negative.
!RAM_SMW_Sprites_BrownRotatingPlatformCosineLo #= !Define_SMW_LowRAMLocation+$14C5
!RAM_SMW_Sprites_BrownRotatingPlatformCosineHi #= !RAM_SMW_Sprites_BrownRotatingPlatformCosineLo+$01
;Empty $0014C7
