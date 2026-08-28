;--- Level header settings - $7E1900-$7E1B77
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; Bonus stars gained at level end - decrements to zero.
!RAM_SMW_Counter_BonusStarsEarned #= !Define_SMW_LowRAMLocation+$1900
; YXPPCCCT data of bounce sprite that is being shown.
!RAM_SMW_BounceSpr_YXPPCCCT #= !Define_SMW_LowRAMLocation+$1901
; Iggy's/Larry's platform total number of tilts made counter. It will
; increment everytime the platform will be at a maximum tilt. Only the
; lowest bit is ever used, and it controls which direction it should move.
!RAM_SMW_Counter_DirectionToTiltPlatform #= !Define_SMW_LowRAMLocation+$1905
; Iggy/Larry's platform stationary phase timer. Is set to #$40 and
; decrements every frame. As long as it's not zero, the platform won't
; rotate.
!RAM_SMW_Timer_WaitBeforeNextTiltingPlatformPhase #= !Define_SMW_LowRAMLocation+$1906
; Iggy's platform rotation phase counter. After the third phase ends, the
; counter resets.
!RAM_SMW_Counter_TiltingPlatformPhase #= !Define_SMW_LowRAMLocation+$1907
;Empty $001908
; Flag that makes the creating/eating block run or not run. #$FF = don't
; run, any other value = run. Set to #$00 when a brown block is touched.
!RAM_SMW_Flag_ActiveCreateEatBlock #= !Define_SMW_LowRAMLocation+$1909
; Reappearing Boo frame counter. They start appearing at #$FF, become fully
; opaque at #$DF, start disappearing at #$3F, and become fully invisible at
; #$1F. The counter decrements every frame and doesn't stop when it hits
; #$00 unless sprite D2 is active, which causes it to freeze at #$FF.
!RAM_SMW_Sprites_DisappearingBooFrameCounter #= !Define_SMW_LowRAMLocation+$190A
; Big Boo Boss palette index, used for the transparency effect. The
; reappearing Boos (cluster sprites) also use this. They set this address to
; #$08.
!RAM_SMW_Sprites_BigBooBossPaletteIndex #= !Define_SMW_LowRAMLocation+$190B
; Directional coin timer. Decrements every fourth frame.
!RAM_SMW_NorSpr045_DirectionalCoins_DespawnTimer #= !Define_SMW_LowRAMLocation+$190C
; Used as a flag in the Bowser battle for whether or not the final cutscene
; is playing. Used to remove the item box, as well as several palette
; updates and using a different OAM index for the roof tiles. Any non-zero
; value activates the flag.
!RAM_SMW_NorSpr0A0_ActivateBowserBattle_EndOfBattleFlag #= !Define_SMW_LowRAMLocation+$190D
; Sprite buoyancy settings from level header. Format: XY-- ---- (bits) X =
; Enable sprite buoyancy. This reduces the number of sprites that can be on
; the screen at once without slowing down. Y = Enable sprite buoyancy and
; disable all other sprite interaction with layer 2. This reduces the
; processing cost and slowdown.
!RAM_SMW_Sprites_SpriteBuoyancySettings #= !Define_SMW_LowRAMLocation+$190E
; Sprite properties, sixth Tweaker/MWR byte. Format: wcdj5sDp w=Don't get
; stuck in walls (carryable sprites) c=Don't turn into a coin with silver
; POW d=Death frame 2 tiles high j=Can be jumped on with upward Y speed
; 5=Takes 5 fireballs to kill. If not set, the sprite is killed with a
; single fireball. The counter for hits is controlled by $1528. s=Can't be
; killed by sliding D=Don't erase when goal passed p=Make platform passable
; from below
!RAM_SMW_NorSpr_PropertyBits190F #= !Define_SMW_SprTable_190F
; Empty. Cleared on reset, titlescreen load, overworld load, and every frame
; when Yoshi is on screen. The latter can be disabled by changing $01:EBD9
; from [9C 1B 19] to [80 01 EA].
!RAM_SMW_UnusedRAM_7E191B #= !Define_SMW_LowRAMLocation+$191B
; Indicates whether or not Yoshi has a key in his mouth. #$00 = no, #$01 =
; yes.
!RAM_SMW_Yoshi_KeyInMouthFlag #= !Define_SMW_LowRAMLocation+$191C
; Which cluster sprite to overwrite for the Sumo Bros. lightning's flames if
; all usable slots are full. Only cycles through sprites 0 to 9.
!RAM_SMW_ClusterSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$191D
; Is set to a value #$00-#$03 when pressing a big switch. Depending on the
; value, either a green, yellow, blue or red flat switch sprite will be left
; behind in the room.
!RAM_SMW_Sprites_ColorOfFlatPalaceSwitchToSpawn #= !Define_SMW_LowRAMLocation+$191E
;Empty $00191F
; How many 1-Ups from the bonus game are still not collected. Decrements
; every time a 1-Up is collected. The bonus game ends when this address hits
; zero.
!RAM_SMW_Counter_RemainingBonusGame1ups #= !Define_SMW_LowRAMLocation+$1920
; During the cutscene after defeating Bowser, indicates which letter the
; "Mario's adventure is over..." message is currently at. Ends at #$54.
!RAM_SMW_NorSpr07C_PrincessPeach_CurrentLetterLo #= !Define_SMW_LowRAMLocation+$1921
; High byte of $7E:1921. This is never any value other than #$00 in the
; original SMW, but since $7E:1921 is sometimes loaded in 16-bit mode, it's
; not a good idea to use it if you're using the original Bowser battle.
; Cleared on reset, title screen load, and overworld load.
!RAM_SMW_NorSpr07C_PrincessPeach_CurrentLetterHi #= !RAM_SMW_NorSpr07C_PrincessPeach_CurrentLetterLo+$01
;Empty $001923-$001924
; Level mode settings from level header.
!RAM_SMW_Misc_LevelModeSetting #= !Define_SMW_LowRAMLocation+$1925
;Empty $001926-$001927
; One of two screen numbers used in the level loading routine. This one
; points to where the current object is placed and is never changed inside
; an object loading code. The other screen number is $1BA1. It is also used
; in the credits as a pointer to which background should be used for which
; part of the credits roll.
!RAM_SMW_Blocks_ScreenToPlaceCurrentObject #= !Define_SMW_LowRAMLocation+$1928
	!RAM_SMW_Pointer_CreditsBackgroundIndex #= !Define_SMW_LowRAMLocation+$1928
	!RAM_SMW_Unknown_7E1928 #= !Define_SMW_LowRAMLocation+$1928
;Empty $001929
; RAM address used to hold some information while loading a level. Format:
; swaaaaaa. s = slippery level, w = water level, a = player action. In the
; original game, if one of bits 3-5 is set, the player action will be
; "vertical pipe exit downwards, water level", though with Lunar Magic,
; these extra bits are just ignored. Lunar Magic also uses the w bit during
; a screen exit for temporarily holding the water/midway flag from $19D8 as
; well. Note that the s and w bits are cleared after being transferred to
; $85/$86, so they'll both be 0 when read mid-level.
!RAM_SMW_Misc_LevelHeaderEntranceSettings #= !Define_SMW_LowRAMLocation+$192A
; Sprite GFX setting from the level header. Also used on the overworld and
; in cutscenes to determine the graphics files that should be uploaded.
!RAM_SMW_Graphics_LevelSpriteGraphicsSetting #= !Define_SMW_LowRAMLocation+$192B
;Empty $00192C
; FG palette settings from the level header.
!RAM_SMW_Misc_FGPaletteSetting #= !Define_SMW_LowRAMLocation+$192D
; Sprite palette settings from the level header.
!RAM_SMW_Misc_SpritePaletteSetting #= !Define_SMW_LowRAMLocation+$192E
; Background color settings from the level header.
!RAM_SMW_Misc_BackgroundColorSetting #= !Define_SMW_LowRAMLocation+$192F
; Background palette settings from the level header.
!RAM_SMW_Misc_BGPaletteSetting #= !Define_SMW_LowRAMLocation+$1930
; FG/BG GFX setting from the level header. Also used on the overworld and in
; cutscenes to determine the graphics files that should be uploaded. FE and
; FF are special values used by Mode 7 levels in order to upload GFX27
; instead.
!RAM_SMW_Misc_LevelTilesetSetting #= !Define_SMW_LowRAMLocation+$1931
	!RAM_SMW_Misc_OverworldAndCutsceneGFXToLoad #= !RAM_SMW_Misc_LevelTilesetSetting
; Copy of the tileset setting from the level header. Never read by anything,
; as $1931 is used instead.
!RAM_SMW_UnusedRAM_CopyOfLevelTilesetSetting #= !Define_SMW_LowRAMLocation+$1932
; Layer being processed. #$00 = Layer 1; #$01 = Layer 2/3 (depending on
; which is interactive). Used in both level loading routine and processing
; interactions.
!RAM_SMW_Misc_CurrentLayerBeingProcessedLo #= !Define_SMW_LowRAMLocation+$1933
; While this is never non-zero in the original SMW, $7E:1933 (current layer)
; is sometimes used in 16bit mode, so using this address for different
; purposes is a bad idea.
!RAM_SMW_Misc_CurrentLayerBeingProcessedHi #= !RAM_SMW_Misc_CurrentLayerBeingProcessedLo+$01
; In the original game, this is used as a flag to restore tiles 4A-4F and
; 5A-5F with the graphics from $0BF6. Set at the start of any loading screen
; message (i.e. MARIO START, TIME UP, GAME OVER, BONUS GAME) and cleared
; immediately after the tiles are restored. Mainly intended for the BONUS
; GAME text. Lunar Magic deprecates this address by disabling the relevant
; routine at $00A436, making it essentially free RAM (cleared on reset,
; titlescreen load, and overworld load), though it still sets the flag to 01
; when preparing a loading screen message. This can be disabled by changing
; $00A8BF to [$60].
!RAM_SMW_Flag_RestoreSP1TilesAfterMarioStart #= !Define_SMW_LowRAMLocation+$1935
;Empty $001936-$001937
; Sprite load status within the level, used as a flag to determine whether
; to respawn a sprite when its spawn position is scrolled onscreen. A sprite
; will only respawn if its value in the table is 00. Currently-loaded
; sprites can retrieve their index to the table via $161A. Shooters
; similarly have a table for this at $17B3. The table is initialized to
; zeros on level load, indicating that all sprites should be able to spawn.
; When a sprite is spawned, it sets its entry to 01, and when it despawns
; offscreen without dying, it's set back to 00. However, if the sprite is
; instead erased by being killed, its entry will remain 01 to prevent it
; from respawning. The original game has an issue where only the first 64
; bytes of actually get reset when entering a new subroom, which meant that
; if there were enough sprites in a level, sprites in sublevels could be
; blocked from spawning at all. Lunar Magic fixes this to reset the full
; 128-byte table. PIXI expands the table even further to 256 bytes by
; relocating it to $7FAF00, though as a safeguard whichever one is in use
; can be accessed via the !1938 define. Prior to v1.41, the relocation could
; be disabled via the !Disable255SpritesPerLevel define, but this is now no
; longer supported. Instead, this space is repurposed as a series of
; miscellaneous tables for various sprite types; see details for a
; breakdown.
!RAM_SMW_Sprites_LoadStatus #= !Define_SMW_LowRAMLocation+$1938
; Screen exit table, low bytes. Combined with the table at $19D8, this
; connects doors and exit-enabled pipes to their correct entrances. This
; table specifically contains the lower 8 bits of the destination
; level/secondary exit. This table is indexed by the screen number Mario is
; on. In regular horizontal levels, this is the high byte of his X position,
; and in vertical levels, the high byte of his Y position. With the expanded
; horizontal level mode setting added by LM v3.00+, the current screen
; number the player is on can be obtained by calling the routine at $03BCDC.
!RAM_SMW_Misc_SubscreenExitEntranceNumberLo #= !Define_SMW_LowRAMLocation+$19B8
; Screen exit table, high bytes. Combined with the table at $19B8, this
; connects doors and exit-enabled pipes to their correct entrances. This
; table specifically contains the upper 5 bits of the destination
; level/secondary exit, as well as some additional information about the
; exit, in the format HHHHwush: h: High bit of destination level HHHHh: High
; byte of destination secondary exit s: Secondary exit flag u: LM-modified
; flag (if unset, the entire byte is ignored and SMW's original exit system
; is used instead) w: Water level flag (secondary exits) or midway flag*
; (primary exits) * Only used if the destination level has "use seperate
; settings for midway entrance" set This table is indexed by the screen
; number Mario is on. In regular horizontal levels, this is the high byte of
; his X position, and in vertical levels, the high byte of his Y position.
; With the expanded horizontal level mode setting added by LM v3.00+, the
; current screen number the player is on can be obtained by calling the
; routine at $03BCDC. This table goes unused in the original game, although
; the h bit for each screen is still written. Instead, the original game
; just calculates high bit of the destination level/secondary exit based on
; whether the level is on the main map (0) or submap (1), and the s bit is
; controlled globally for the entire level by $1B93.
!RAM_SMW_Misc_SubscreenExitProperties #= !Define_SMW_LowRAMLocation+$19D8
; Three tables of 128 bytes each for remembering which items have been
; collected (item memory settings). If the corresponding bits are set (items
; are collected), those objects will not be reloaded. The tables are split
; up like this: every screen number has 4 bytes designated to it. The first
; byte is for the left half of the top subscreen, the second byte for the
; right half, and the third and fourth are for the bottom subscreen. Each
; vertical column within these regions uses one bit. Item memory setting 3
; doesn't actually exist in the original game, but LM still allows you to
; select it. As of LM 1.8, it is apparently possible to use item memory
; setting 3 as well, but it only means "make everything respawn" and doesn't
; remember anything.
!RAM_SMW_Misc_ItemMemoryBits #= !Define_SMW_LowRAMLocation+$19F8
	!RAM_SMW_Misc_ItemMemory0Bits #= !RAM_SMW_Misc_ItemMemoryBits
	!RAM_SMW_Misc_ItemMemory1Bits #= !RAM_SMW_Misc_ItemMemoryBits+$0080
	!RAM_SMW_Misc_ItemMemory2Bits #= !RAM_SMW_Misc_ItemMemoryBits+$0100
