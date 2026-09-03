;--- Sprite slot tables - $7E14C8-$7E18FF
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; Sprite status table. State 0 indicates a sprite slot is empty and
; available to use. State 1 indicates a slot has been taken, but has not run
; its initialization routine. States 8+ are generally used to indicate the
; sprite is alive, while states 2-7 indicate the sprite has been killed and
; should not run its usual code.
!RAM_SMW_NorSpr_CurrentStatus #= !Define_SMW_SprTable_14C8
; Sprite Y position, high byte.
!RAM_SMW_NorSpr_YPosHi #= !Define_SMW_SprTable_14D4
!RAM_SMW_NorSpr_XPosHi #= !RAM_SMW_NorSpr_YPosHi+(!Define_SMW_MaxNormalSpriteSlot+$01)
; Accumulating fraction bits for fixed point sprite Y position (in fractions
; of 16 with only the high nybble being used, i.e. %YYYY0000). Modified via
; routine at $01ABCC.
!RAM_SMW_NorSpr_SubYPos #= !Define_SMW_SprTable_14EC
!RAM_SMW_NorSpr_SubXPos #= !RAM_SMW_NorSpr_SubYPos+(!Define_SMW_MaxNormalSpriteSlot+$01)
; Miscellaneous sprite table. In the original game, it's only used in the
; revolving brown platform and nowhere else.
!RAM_SMW_NorSpr_Table7E1504 #= !Define_SMW_SprTable_1504
; Miscellaneous sprite table. In the original game, it's only used in the
; revolving brown platform and nowhere else. Unlike $1504 (and every other
; sprite table), it is also not cleared by the sprite table initialization
; routine.
!RAM_SMW_NorSpr_Table7E1510 #= !Define_SMW_SprTable_1504+(!Define_SMW_MaxNormalSpriteSlot+$01)
; Miscellaneous sprite table, often used by the game for controlling the
; direction of vertical movement for a sprite. If a Reznor is spawned in
; sprite slot 7 and these four addresses add up to exactly 4, then the
; Reznor will be treated as defeated and the level will end.
!RAM_SMW_NorSpr_Table7E151C #= !Define_SMW_SprTable_151C
; Miscellaneous sprite table. In SMW, it's used for Chargin' Chuck HP (see
; $190F), Thwomp's face expression, etc.
!RAM_SMW_NorSpr_Table7E1528 #= !Define_SMW_SprTable_1528
	!RAM_SMW_NorSpr_PlayerXSpeedOffset #= !RAM_SMW_NorSpr_Table7E1528
	!RAM_SMW_NorSpr_FireballHPCounter #= !RAM_SMW_NorSpr_Table7E1528
; Miscellaneous sprite table. Certain powerups use this table as a
; blink-fall flag. #$00 = Off; #$01 = On, powerup will blink and fall
; straight down. The game stores #$01 here when it drops the reserved item
; from the item box. The blink-fall flag affects the Super Mushroom and the
; Fire Flower, but not the Cape Feather. The blink-fall flag also affects
; some other sprites, at least the Starman, the 1-Up mushroom and the coin
; sprite, but these sprites might glitch if you set the flag. One glitch is
; that the blinking sprite-coin permanently occupies a sprite slot if it
; falls off the level, so that it might prevent the spawning of other common
; sprites. Other than that, this address has many different purposes.
!RAM_SMW_NorSpr_Table7E1534 #= !Define_SMW_SprTable_1534
; Miscellaneous sprite table. Table decrements itself once per frame, except
; for carryable sprites, where it decrements every second frame (the code at
; $0196D7 "slows" the timer by 1/2 by incrementing it every even frames
; ($13), which results in a decrement every odd frames). Various sprites use
; this table as a stun timer. For example, this timer controls when flipped
; Goombas and squashed Mecha-Koopas decide to rise and walk. This table is
; also the sprite spinjump death frame counter - that is, how long to show
; the "spinjumped" image when the sprite is killed by a jump of such sorts.
!RAM_SMW_NorSpr_DecrementingTable7E1540 #= !Define_SMW_SprTable_1540
	!RAM_SMW_NorSpr_SpinJumpKillTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
	!RAM_SMW_NorSpr_SmushedSpriteDespawnTimer #= !RAM_SMW_NorSpr_DecrementingTable7E1540
	!RAM_SMW_NorSprStatus06_GoalCoins_WaitBeforeTurningIntoCoin #= !RAM_SMW_NorSpr_DecrementingTable7E1540
; Miscellaneous sprite table. Used as a timer to disable sprite contact with
; the player. Table decrements itself once per frame.
!RAM_SMW_NorSpr_DecrementingTable7E154C #= !Define_SMW_SprTable_154C
; Miscellaneous sprite table. Used as a timer for how long a sprite is
; sinking in lava/mud. Table decrements itself once per frame.
!RAM_SMW_NorSpr_DecrementingTable7E1558 #= !Define_SMW_SprTable_1558
; Miscellaneous sprite table. Used as a timer to disable sprite contact with
; other sprites. Table decrements itself once per frame.
!RAM_SMW_NorSpr_DecrementingTable7E1564 #= !Define_SMW_SprTable_1564
; Miscellaneous sprite table. In SMW's original sprites, it's most commonly
; used as a local frame counter (as opposed to the global frame counter at
; $14).
!RAM_SMW_NorSpr_Table7E1570 #= !Define_SMW_SprTable_1570
	!RAM_SMW_NorSpr_AnimationFrameCounter #= !RAM_SMW_NorSpr_Table7E1570
	!RAM_SMW_NorSprStatus06_GoalCoins_UnknownRAM #= !RAM_SMW_NorSpr_Table7E1570
; Miscellaneous sprite table. It's most often used as a horizontal sprite
; direction table. #$00 = Right; #$01 = Left.
!RAM_SMW_NorSpr_Table7E157C #= !Define_SMW_SprTable_157C
	!RAM_SMW_NorSpr_FacingDirection #= !RAM_SMW_NorSpr_Table7E157C
; Sprite blocked status table. Format: asb-udlr a - blocked by Layer 2 above
; s - blocked by Layer 2 on the side b - blocked by Layer 2 below u -
; blocked above (ceiling) d - blocked below (floor) l - blocked to the left
; r - blocked to the right The goal tape in particular also uses this as a
; miscellaneous sprite table, for tracking its direction of movement.
!RAM_SMW_NorSpr_Table7E1588 #= !Define_SMW_SprTable_157C+(!Define_SMW_MaxNormalSpriteSlot+$01)
	!RAM_SMW_NorSpr_LevelCollisionFlags #= !RAM_SMW_NorSpr_Table7E1588
; Miscellaneous sprite table. In classic Piranha Plants, it is used to check
; if the sprite should be made visible and have interaction with the player.
; If it's any non-zero value, that Piranha Plant will become invisible.
!RAM_SMW_NorSpr_Table7E1594 #= !Define_SMW_SprTable_1594
; Sprite off screen flag table, horizontal.
!RAM_SMW_NorSpr_XOffscreenFlag #= !Define_SMW_SprTable_15A0
; Miscellaneous sprite table. It's often used as a timer to determine how
; long it takes to turn around. Table decrements itself once per frame.
!RAM_SMW_NorSpr_DecrementingTable7E15AC #= !Define_SMW_SprTable_15AC
	!RAM_SMW_NorSpr_TurnAroundTimer #= !RAM_SMW_NorSpr_DecrementingTable7E15AC
; Determines what kind of slope a sprite is on.
!RAM_SMW_NorSpr_SlopeSurfaceItsOn #= !Define_SMW_SprTable_15B8
; Flag set if a sprite is more than 4 tiles horizontally offscreen. Used by
; a few large sprites (e.g. turnblock bridges and chained platforms) to
; determine whether to draw any of the sprite at all.
!RAM_SMW_NorSpr_Table7E15C4 #= !Define_SMW_SprTable_15C4
; Flag for whether the sprite is on Yoshi's tongue. #$00 = No; #$01 = Yes.
!RAM_SMW_NorSpr_Table7E15D0 #= !Define_SMW_SprTable_15C4+(!Define_SMW_MaxNormalSpriteSlot+$01)
	!RAM_SMW_NorSpr_OnYoshisTongue #= !RAM_SMW_NorSpr_Table7E15D0
; Flag to disable sprite interaction with objects. Ghost house ledge holes
; store their sprite index (plus one) to this to make sprites fall through
; the ground, but any non-zero value will work.
!RAM_SMW_NorSpr_NoLevelCollisionFlag #= !Define_SMW_SprTable_15DC
;Empty $0015E8
; Sprite index for the current sprite that is being processed. It can be
; used in a sprite to reload the current index in X after having used X for
; something else. Make sure you don't change it in a sprite's code, or
; unintended effects may happen (game crash, infinite loops, ...). Most
; sprite types use this: normal sprites, spinning coin sprites, extended
; sprites, score sprites, cluster sprites, and shooters. Other sprite types
; use $1698.
!RAM_SMW_NorSpr_CurrentSlotID #= !Define_SMW_LowRAMLocation+$15E9
; Sprite index to the OAM table, handled by $0180D2 to quickly obtain an
; empty OAM slot. Note: meant to be used as an index to the second half of
; the OAM table (use it for $0300 and $0460, not $0200 and $0420).
!RAM_SMW_NorSpr_OAMIndex #= !Define_SMW_SprTable_15EA
; Sprite YXPPCCCT table. Many sprites use it in their graphics routines.
!RAM_SMW_NorSpr_Table7E15F6 #= !Define_SMW_SprTable_15F6
	!RAM_SMW_NorSpr_YXPPCCCT #= !RAM_SMW_NorSpr_Table7E15F6
; Miscellaneous sprite table. Often used as graphics pointer.
!RAM_SMW_NorSpr_Table7E1602 #= !Define_SMW_SprTable_1602
	!RAM_SMW_NorSpr_AnimationFrame #= !RAM_SMW_NorSpr_Table7E1602
; Miscellaneous sprite table. In SMW, it is used to keep track of things
; such as the green bouncing Koopa's Y speed and the sprite number of
; certain spawned, kicked, etc. sprites.
!RAM_SMW_NorSpr_Table7E160E #= !Define_SMW_SprTable_160E
; Sprite index to the load status table (see $7E1938). $FF means the sprite
; won't be reloaded.
!RAM_SMW_NorSpr_LoadStatusTableIndex #= !Define_SMW_SprTable_161A
; Miscellaneous sprite table. Consecutive enemies killed by a sprite table.
; Each byte is how many sprites that particular sprite has killed. In SMW,
; this applies to sprites that can be thrown, such as Koopa shells.
!RAM_SMW_NorSpr_Table7E1626 #= !Define_SMW_SprTable_1626
; Sprite is behind scenery flag. Sprites will only interact with each other
; if they share the same value in this address; this includes interaction
; with Mario using his equivalent flag at $13F9, and with fireballs using
; their flags at $1779. Mainly used for handling the climbing net Koopas,
; but does also get used for e.g. sprites sinking in lava or being eaten by
; Baby Yoshi.
!RAM_SMW_NorSpr_Table7E1632 #= !Define_SMW_SprTable_1626+(!Define_SMW_MaxNormalSpriteSlot+$01)
	!RAM_SMW_NorSpr_CurrentLayerPriority #= !RAM_SMW_NorSpr_Table7E1632
; Miscellaneous sprite table. Table decrements once per frame. In SMW, it's
; used as e.g. a timer that, when it's zero, makes Ludwig face the player,
; while he's spitting fireballs.
!RAM_SMW_NorSpr_DecrementingTable7E163E #= !Define_SMW_SprTable_163E
; Sprite is in liquid indicator table. #$00 = Sprite not in liquid; #$01 =
; Sprite in water; #$80 = Sprite in lava. Also used in the Morton/Roy battle
; as an indicator that the walls have to close in, and in Bowser's fight to
; indicate the music after Bowser is defeated has already started.
!RAM_SMW_NorSpr_Table7E164A #= !Define_SMW_SprTable_164A
	!RAM_SMW_NorSpr_InLiquidFlag #= !RAM_SMW_NorSpr_Table7E164A
; Sprite properties, first Tweaker/MWR byte. Format: sSjJcccc s=Disappear in
; cloud of smoke. S=Hop in/kick shells. j=Dies when jumped on. J=Can be
; jumped on (false = player gets hurt if they jump on the sprite, but can
; bounce off with a spin jump). cccc=Object clipping.
!RAM_SMW_NorSpr_PropertyBits1656 #= !Define_SMW_SprTable_1656
; Sprite properties, second Tweaker/MWR byte. Format: dscccccc d=Falls
; straight down when killed s=Use shell as death frame cccccc=Sprite
; clipping
!RAM_SMW_NorSpr_PropertyBits1662 #= !Define_SMW_SprTable_1662
; Sprite properties, third Tweaker/MWR byte. Format: lwcfpppg l=Don't
; interact with layer 2 (or layer 3 tides) w=Disable water splash c=Disable
; cape killing f=Disable fireball killing ppp=Palette g=Use second graphics
; page
!RAM_SMW_NorSpr_PropertyBits166E #= !Define_SMW_SprTable_166E
; Sprite properties, fourth Tweaker/MWR byte. Bitwise format: dpmksPiS: d =
; Don't use default interaction with player p = Gives power-up when eaten by
; Yoshi m = Process interaction with player every frame k = Can't be kicked
; like a shell s = Don't change into a shell when stunned P = Process while
; off screen i = Invincible to star/cape/fire/bouncing bricks (fireballs
; passes through rather than disappear in a puff of smoke) S = Don't disable
; clipping when killed with star
!RAM_SMW_NorSpr_PropertyBits167A #= !Define_SMW_SprTable_167A
; Sprite properties, fifth Tweaker/MWR byte. Format: dnctswye d=Don't
; interact with objects n=Spawns a new sprite c=Don't turn into a coin when
; goal passed t=Don't change direction if touched s=Don't interact with
; other sprites w=Weird ground behavior y=Stay in Yoshi's mouth e=Inedible
!RAM_SMW_NorSpr_PropertyBits1686 #= !Define_SMW_SprTable_1686
; Sprite memory setting from header.
!RAM_SMW_Sprites_SpriteMemorySetting #= !Define_SMW_LowRAMLocation+$1692
; During block interaction, this contains the low byte of the "acts like"
; setting of the tile being interacted with (with the high byte being in Y).
; Writing to it (and Y) will change how things interact with the block. In
; custom blocks, if you want to get the block's actual 16-bit Map16 number,
; that can instead be found in $03/$04.
!RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo #= !Define_SMW_LowRAMLocation+$1693
; How many pixels the sprite should move down from the nearest 16x16 tile.
; Originally, its data comes from the table at $00:E632.
!RAM_SMW_Sprites_DistanceToSnapDownToNearestTile #= !Define_SMW_LowRAMLocation+$1694
; Used most often in tracking the second sprite currently being checked in
; various interaction routines, for example the second sprite's index in the
; sprite contact routine (used similarly to $7E15E9). It also serves a use
; during checking when a sprite is entering/exiting water.
!RAM_SMW_Sprites_SecondTrackedSpriteIndex #= !Define_SMW_LowRAMLocation+$1695
	!RAM_SMW_Sprites_SpriteEnterOrExitingWater #= !Define_SMW_LowRAMLocation+$1695
;Empty $001696
; Consecutive enemies stomped.
!RAM_SMW_Counter_ConsecutiveEnemiesStomped #= !Define_SMW_LowRAMLocation+$1697
; Current index being processed for a variety of sprite types, specifically
; minor extended sprites, bounce sprites, quake sprites, and smoke sprites.
!RAM_SMW_Sprites_CurrentlyProcessedMiscSprite #= !Define_SMW_LowRAMLocation+$1698
; Bounce sprite type number.
!RAM_SMW_BounceSpr_SpriteID #= !Define_SMW_LowRAMLocation+$1699
; Bounce sprite initialization flag table. #$00 = bounce sprite in init
; routine; #$01 = bounce sprite in main routine. Used for several things,
; such as generating tile 152 (invisible solid) once only.
!RAM_SMW_BounceSpr_CurrentStatus #= !Define_SMW_LowRAMLocation+$169D
; Bounce sprite Y position, low byte.
!RAM_SMW_BounceSpr_YPosLo #= !Define_SMW_LowRAMLocation+$16A1
; Bounce sprite X position, low byte.
!RAM_SMW_BounceSpr_XPosLo #= !Define_SMW_LowRAMLocation+$16A5
; Bounce sprite Y position, high byte.
!RAM_SMW_BounceSpr_YPosHi #= !Define_SMW_LowRAMLocation+$16A9
; Bounce sprite X position, high byte.
!RAM_SMW_BounceSpr_XPosHi #= !Define_SMW_LowRAMLocation+$16AD
; Bounce sprite Y speed.
!RAM_SMW_BounceSpr_YSpeed #= !Define_SMW_LowRAMLocation+$16B1
; Bounce sprite X speed.
!RAM_SMW_BounceSpr_XSpeed #= !Define_SMW_LowRAMLocation+$16B5
; Accumulating fraction bits for bounce sprite X speed.
!RAM_SMW_BounceSpr_SubYPos #= !Define_SMW_LowRAMLocation+$16B9
; Accumulating fraction bits for bounce sprite Y speed.
!RAM_SMW_BounceSpr_SubXPos #= !Define_SMW_LowRAMLocation+$16BD
; Bounce sprite turns into Map16 tile. This uses the same values as $9C.
!RAM_SMW_BounceSpr_Map16TileToSpawn #= !Define_SMW_LowRAMLocation+$16C1
; Bounce sprite timer - amount of frames until bounce sprite disappears.
; Turn blocks are set to spinning mode when this timer runs out.
!RAM_SMW_BounceSpr_Timer #= !Define_SMW_LowRAMLocation+$16C5
; Block bounce sprite table. Format: L-----DD L is which layer it is on.
; Clear means it's on layer 1, set means it's on layer 2 (or layer 3 if
; applicable). DD is the direction it is moving in. 00 = up; 01 = right; 10
; = left; 11 = down.
!RAM_SMW_BounceSpr_Properties #= !Define_SMW_LowRAMLocation+$16C9
; Quake/interaction sprite type. 0 = empty, 1 = hitting/breaking a block, 2
; = Yoshi's stomp.
!RAM_SMW_BounceSpr_Type #= !Define_SMW_LowRAMLocation+$16CD
; Quake/interaction sprite X position, low byte.
!RAM_SMW_BounceSpr_HitboxXLo #= !Define_SMW_LowRAMLocation+$16D1
; Quake/interaction sprite X position, high byte.
!RAM_SMW_BounceSpr_HitboxXHi #= !Define_SMW_LowRAMLocation+$16D5
; Quake/interaction sprite Y position, low byte.
!RAM_SMW_BounceSpr_HitboxYLo #= !Define_SMW_LowRAMLocation+$16D9
; Quake/interaction sprite Y position, high byte.
!RAM_SMW_BounceSpr_HitboxYHi #= !Define_SMW_LowRAMLocation+$16DD
; Score/1-Up sprite number.
!RAM_SMW_ScoreSpr_SpriteID #= !Define_SMW_LowRAMLocation+$16E1
; Score/1-up sprite Y position, low byte.
!RAM_SMW_ScoreSpr_YPosLo #= !Define_SMW_LowRAMLocation+$16E7
; Score/1-up sprite X position, low byte.
!RAM_SMW_ScoreSpr_XPosLo #= !Define_SMW_LowRAMLocation+$16ED
; Score/1-up sprite X position, high byte.
!RAM_SMW_ScoreSpr_XPosHi #= !Define_SMW_LowRAMLocation+$16F3
; Score/1-up sprite Y position, high byte.
!RAM_SMW_ScoreSpr_YPosHi #= !Define_SMW_LowRAMLocation+$16F9
; Score/1-up sprite Y movement - how long the score sprite should move
; upwards. It is not possible to go down, and the maximum amount of frames
; is #$30. Additionally, the sprite is twice as slow with #$10-#$1F as with
; #$20-#$2F, and four times as slow with #$00-#$0F. The sprite terminates
; itself when this hits zero.
!RAM_SMW_ScoreSpr_YSpeed #= !Define_SMW_LowRAMLocation+$16FF
; Layer the score/1-up sprite is on. Used to control its position.
!RAM_SMW_ScoreSpr_LayerIndex #= !Define_SMW_LowRAMLocation+$1705
; Extended sprite number. Last two bytes reserved for fireballs.
!RAM_SMW_ExtSpr_SpriteID #= !Define_SMW_LowRAMLocation+$170B
; Extended sprite Y position, low byte. Last two bytes reserved for
; fireballs.
!RAM_SMW_ExtSpr_YPosLo #= !Define_SMW_LowRAMLocation+$1715
; Extended sprite X position, low byte. Last two bytes reserved for
; fireballs.
!RAM_SMW_ExtSpr_XPosLo #= !Define_SMW_LowRAMLocation+$171F
; Extended sprite Y position, high byte. Last two bytes reserved for
; fireballs.
!RAM_SMW_ExtSpr_YPosHi #= !Define_SMW_LowRAMLocation+$1729
; Extended sprite X position, high byte. Last two bytes reserved for
; fireballs.
!RAM_SMW_ExtSpr_XPosHi #= !Define_SMW_LowRAMLocation+$1733
; Extended sprite Y speed. Last two bytes reserved for fireballs.
!RAM_SMW_ExtSpr_YSpeed #= !Define_SMW_LowRAMLocation+$173D
; Extended sprite X speed. Last two bytes reserved for fireballs.
!RAM_SMW_ExtSpr_XSpeed #= !Define_SMW_LowRAMLocation+$1747
; Accumulating fraction bits for extended sprite Y position (fractions of
; 16: %YYYY0000). The last two bytes are for the player's fireballs. Handled
; via $02B560.
!RAM_SMW_ExtSpr_SubYPos #= !Define_SMW_LowRAMLocation+$1751
; Accumulating fraction bits for extended sprite X position (fractions of
; 16: %XXXX0000). The last two bytes are for the player's fireballs. Handled
; via $02B560. The fireballs also use this table for a hit flag table.
!RAM_SMW_ExtSpr_SubXPos #= !Define_SMW_LowRAMLocation+$175B
	!RAM_SMW_ExtSpr05_MarioFireball_HitFlag #= !Define_SMW_LowRAMLocation+$175B
; Miscellaneous extended sprite table.
!RAM_SMW_ExtSpr_Table7E1765 #= !Define_SMW_LowRAMLocation+$1765
; Miscellaneous extended sprite table, decrements by 1 each frame until
; zero. Often used for animation management or as a "lifespan" timer that
; erases the sprite when it reaches zero.
!RAM_SMW_ExtSpr_DecrementingTable7E176F #= !Define_SMW_LowRAMLocation+$176F
; Extended sprite is behind scenery flag. Extended sprites will only
; interact with sprites who share the same value in their equivalent table
; at $1632, or with Mario only if he has the same value in his equivalent
; address at $13F9. Mainly intended for fireballs shot by Mario while behind
; a net.
!RAM_SMW_ExtSpr_Table7E1779 #= !Define_SMW_LowRAMLocation+$1779
; Shooter number. #$00 = None, #$01 = Bullet Bill shooter, #$02 = Torpedo
; Launcher. Pixi uses the most significant bits of this table to hold the
; extra bits of the shooter.
!RAM_SMW_ShooterSpr_SpriteID #= !Define_SMW_LowRAMLocation+$1783
; Shooter Y position, low byte.
!RAM_SMW_ShooterSpr_YPosLo #= !Define_SMW_LowRAMLocation+$178B
; Shooter Y position, high byte.
!RAM_SMW_ShooterSpr_YPosHi #= !Define_SMW_LowRAMLocation+$1793
; Shooter X position, low byte.
!RAM_SMW_ShooterSpr_XPosLo #= !Define_SMW_LowRAMLocation+$179B
; Shooter X position, high byte.
!RAM_SMW_ShooterSpr_XPosHi #= !Define_SMW_LowRAMLocation+$17A3
; Amount of time it takes for a shooter to shoot the next sprite. Decrements
; every 2 frames via $13.
!RAM_SMW_ShooterSpr_ShootTimer #= !Define_SMW_LowRAMLocation+$17AB
; Index to the sprite load status table ($1938) for each shooter. However,
; the original game's shooters never actually do anything with this address,
; so they'll always respawn no matter what.
!RAM_SMW_ShooterSpr_UnusedLevelListIndex #= !Define_SMW_LowRAMLocation+$17B3				; Optimization: Useless, as nothing can cause a shooter to stop spawning
; Contains the low byte of the level number when loading the levels. It's
; cleared when the loading is done. Can be used as freeram, as the value
; from this is never actually used anywhere.
!RAM_SMW_UnusedRAM_7E17BB #= !Define_SMW_LowRAMLocation+$17BB
; How much the Y position of Layer 1 changed in the current frame. Only used
; by the originally unused winged cage sprite.
!RAM_SMW_Misc_Layer1YDisp #= !Define_SMW_LowRAMLocation+$17BC
; How much the X position of Layer 1 changed in the current frame. Used in
; various instances, for example to check how fast the spinning coins should
; move horizontally when a goal tape is touched when there are sprites on
; screen.
!RAM_SMW_Misc_Layer1XDisp #= !Define_SMW_LowRAMLocation+$17BD
; How much the Y position of Layer 2 changed in the current frame. Used when
; the player should be still compared to a moving layer 2. For example, it's
; used by the Layer 2 horizontal scroll sprite, F4.
!RAM_SMW_Misc_Layer2YDisp #= !Define_SMW_LowRAMLocation+$17BE
; How much the X position of Layer 2 changed in the current frame. Used for
; moving Mario horizontally with Layer 2 when it has interaction. When using
; the Layer 3 tides with one of the horizontal autoscroll settings of LM's
; advanced Layer 3 bypass, this tracks the same information but for Layer 3
; instead.
!RAM_SMW_Misc_Layer2XDisp #= !Define_SMW_LowRAMLocation+$17BF
; Smoke sprite number.
!RAM_SMW_SmokeSpr_SpriteID #= !Define_SMW_LowRAMLocation+$17C0
; Smoke sprite Y position, low byte.
!RAM_SMW_SmokeSpr_YPosLo #= !Define_SMW_LowRAMLocation+$17C4
; Smoke sprite X position, low byte.
!RAM_SMW_SmokeSpr_XPosLo #= !Define_SMW_LowRAMLocation+$17C8
; Smoke sprite timer - amount of frames until smoke sprite disappears.
!RAM_SMW_SmokeSpr_Timer #= !Define_SMW_LowRAMLocation+$17CC
; Spinning coin from block. If zero, the slot is free, otherwise it's
; occupied by such a spinning coin.
!RAM_SMW_BlockCoinSpr_SlotID #= !Define_SMW_LowRAMLocation+$17D0
; Spinning coin from block Y position, low byte.
!RAM_SMW_BlockCoinSpr_YPosLo #= !Define_SMW_LowRAMLocation+$17D4
; Spinning coin from block Y speed. $20-$9F will terminate the sprite and
; cause a score sprite to appear.
!RAM_SMW_BlockCoinSpr_YSpeed #= !Define_SMW_LowRAMLocation+$17D8
; Accumulating fraction bits for fixed point spinning coin from block Y
; speed.
!RAM_SMW_BlockCoinSpr_SubYPos #= !Define_SMW_LowRAMLocation+$17DC
; Spinning coin from block X position, low byte.
!RAM_SMW_BlockCoinSpr_XPosLo #= !Define_SMW_LowRAMLocation+$17E0
; Spinning coin from block table. Indicates whether the spinning coin is
; generated from a block on Layer 1, or Layer 2/3. Depending on the layer,
; it updates its position based on the layer's movements.
!RAM_SMW_BlockCoinSpr_LayerIndex #= !Define_SMW_LowRAMLocation+$17E4
; Spinning coin from block Y position, high byte.
!RAM_SMW_BlockCoinSpr_YPosHi #= !Define_SMW_LowRAMLocation+$17E8
; Spinning coin from block X position, high byte.
!RAM_SMW_BlockCoinSpr_XPosHi #= !Define_SMW_LowRAMLocation+$17EC
; Minor extended sprite number.
!RAM_SMW_MExtSpr_SpriteID #= !Define_SMW_LowRAMLocation+$17F0
; Minor extended sprite Y position, low byte.
!RAM_SMW_MExtSpr_YPosLo #= !Define_SMW_LowRAMLocation+$17FC
; Minor extended sprite X position, low byte.
!RAM_SMW_MExtSpr_XPosLo #= !Define_SMW_LowRAMLocation+$1808
; Minor extended sprite Y position, high byte.
!RAM_SMW_MExtSpr_YPosHi #= !Define_SMW_LowRAMLocation+$1814
; Minor extended sprite Y speed.
!RAM_SMW_MExtSpr_YSpeed #= !Define_SMW_LowRAMLocation+$1820
; Minor extended sprite X speed.
!RAM_SMW_MExtSpr_XSpeed #= !Define_SMW_LowRAMLocation+$182C
; Accumulating fraction bits for fixed point minor extended sprite Y speed.
!RAM_SMW_MExtSpr_SubYPos #= !Define_SMW_LowRAMLocation+$1838
; Accumulating fraction bits for fixed point minor extended sprite X speed.
!RAM_SMW_MExtSpr_SubXPos #= !Define_SMW_LowRAMLocation+$1844
; Minor extended sprite table. Often used as a lifespan timer to indicate
; when the sprite should despawn.
!RAM_SMW_MExtSpr_Timer #= !Define_SMW_LowRAMLocation+$1850
; Flag to disable player interaction with objects. Ghost house ledge holes
; store their sprite index (plus one) to this to make Mario fall through the
; ground, but any non-zero value will work.
!RAM_SMW_Player_DisableObjectInteractionFlag #= !Define_SMW_LowRAMLocation+$185C
; Related to the spawning of extended sprites. Used to index $7E:17F0 (minor
; extended sprite type table) if there are no empty slots when an extended
; sprite needs to be spawned. This is so that the oldest extended sprite can
; be removed when a new one needs to be made.
!RAM_SMW_MExtSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$185D
; Sometimes used to keep track of a tile to generate at $00:BEB0 (before
; storing to $7E:009C); may be used in conjunction with $7E:18B6. Also used
; to determine the player Y position when they're on the line guided rope
; and used to determine positions and such of Yoshi's tiles. In the
; sprite/object interaction routine, it's also used to indicate which layer
; the sprite is touching. 00 = layer 1; 01 = layer 2.
!RAM_SMW_Misc_ScratchRAM7E185E #= !Define_SMW_LowRAMLocation+$185E
	!RAM_SMW_Sprites_CopyOfDisappearingBooFrameCounter #= !RAM_SMW_Misc_ScratchRAM7E185E
	!RAM_SMW_Sprites_SumoBroFlameScratchRAM7E185E #= !RAM_SMW_Misc_ScratchRAM7E185E
	!RAM_SMW_Sprites_PowerUpFromBlockSpriteSlot #= !RAM_SMW_Misc_ScratchRAM7E185E
; This is the low byte of the Map16 tile (actual tile number, not "acts
; like" setting) that a sprite is touching vertically. The high byte is at
; $18D7. This address is set after calling the standard object-sprite
; interaction routine at $019138 (or $01802A).
!RAM_SMW_Sprites_Map16TileBeingTouchedVerticallyLo #= !Define_SMW_LowRAMLocation+$185F
; This is the low byte of the Map16 tile (actual tile number, not "acts
; like" setting) that a sprite is touching horizontally. The high byte is at
; $1862. This address is set after calling the standard object-sprite
; interaction routine at $019138 (or $01802A).
!RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyLo #= !Define_SMW_LowRAMLocation+$1860
; Which sprite to overwrite if all slots are full. Used for blocks
; containing sprites and the item box. Note that only the last two slots can
; be overwritten using this method.
!RAM_SMW_NorSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$1861
; This is the high byte of the Map16 tile (actual tile number, not "acts
; like" setting) that a sprite is touching horizontally. The low byte is at
; $1860. This address is set after calling the standard object-sprite
; interaction routine at $019138 (or $01802A).
!RAM_SMW_Sprites_Map16TileBeingTouchedHorizontallyHi #= !Define_SMW_LowRAMLocation+$1862
; Smoke sprite index. Holds the first available smoke image index and resets
; to #$03 if all of them have been filled and another smoke image is
; spawned.
!RAM_SMW_SmokeSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$1863
;Empty $001864
; Spinning coin from block index. Holds the first available index and resets
; to #$03 if all of them have been filled and another coin is spawned.
!RAM_SMW_BlockCoinSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$1865
; Two seperate, 8-bit addresses used by the brown chained platform rotation
; routine. Used to tell if an angle is negative or not. Refer to $7E:0036
; also.
!RAM_SMW_Sprites_BrownRoatingPlatformAngleSign1 #= !Define_SMW_LowRAMLocation+$1866
!RAM_SMW_Sprites_BrownRoatingPlatformAngleSign2 #= !Define_SMW_LowRAMLocation+$1867
; Used as a mirror of $1693 (the low byte of a Map16 tile being interacted
; with) for solid Map16 tiles when touched from below by a sprite. Carryable
; sprites in particular then use this value to handle actually hitting the
; block.
!RAM_SMW_Blocks_CopyOfCurrentlyProcessedMap16TileLo1 #= !Define_SMW_LowRAMLocation+$1868
;Empty $001869-$00186A
; Multiple coin block timer - amount of time until the multiple coin block
; turns into a used block. Keeps decrementing until it's #$01, after that it
; stays that value until the block is hit again, at which it's turned into a
; used block. Then, this address gets set to zero.
!RAM_SMW_Blocks_MultiCoinBlockTimer #= !Define_SMW_LowRAMLocation+$186B
; Sprite off screen flag table, vertical. For sprites in bank 1, if the
; sprite is set to be two tiles high (with $190F), then bits 0 and 1
; correspond to the top and bottom tiles respectively. The routine that sets
; this address in bank 2 and 3 has an error, however; this address instead
; does the 2-bit functionality if bit 5 of $1662 (which is one of the bits
; in the sprite clipping value). As a result, some sprites will register as
; vertically offscreen when they're actually just at the top of the screen.
!RAM_SMW_NorSpr_YOffscreenFlag #= !Define_SMW_SprTable_186C
; Indicates where the player is on the X axis in relation to the
; currently-active revolving net door sprite. If this is #$00, the player is
; perfectly centered on the sprite horizontally. It will be positive if the
; player is toward the left side of the sprite (the farther left, the bigger
; the positive number) and negative if the player is toward the right side
; of the sprite (the farther right, the bigger the negative number). Is used
; to calculate the player X speed as the net is turning around sideways.
!RAM_SMW_Sprites_PlayerXSpeedOnSwingingNetDoor #= !Define_SMW_LowRAMLocation+$1878
;Empty $001879
; Riding Yoshi Flag. #$00 = No, #$01 = Yes, #$02 = Yes, and turning around.
!RAM_SMW_Player_RidingYoshiFlag #= !Define_SMW_LowRAMLocation+$187A
; Miscellaneous sprite table. Has the following purposes: Sprite stomp
; immunity flag table - enables stomp immunity for sprites if the flag is
; set, meaning the sprite will act as a Chuck/Disco Shell when jumped on
; (when using default interaction). Additionally, any kicked sprite will
; move towards Mario like Disco Shells do. Additionally, the changing item
; sprite uses it to determine which sprite it is (#$00 = mushroom, #$40 =
; fire flower, #$80 = feather, #$C0 = star), the goal tape determines by
; this address whether it activates the normal or secret exit, the radius of
; rotating chain sprites is held by this address, certain Yoshi abilities
; are handled, etc. There is also a bug with the background flames during
; the Ludwig battle, as they seem to change color upon this address not
; being #$01. This is responsible for a palette glitch in the original SMW,
; where the fire turns into a greyish blue very briefly. Change $02:8380 to
; #$80 to fix the bug.
!RAM_SMW_NorSpr_Table7E187B #= !Define_SMW_SprTable_187B
	!RAM_SMW_Sprites_BackgroundToUseInKoopaKidBattle #= !Define_SMW_SprTable_1884
; Time to shake Layer 1.
!RAM_SMW_Timer_ShakeLayer1 #= !Define_SMW_LowRAMLocation+$1887
; Layer 1 image relative Y position, used by $7E:1887 (shaking ground). Does
; not affect Layer 1 interaction. #$0000 = default value, Layer 1's image
; unchanged. The higher the value (positive, #$0001 and beyond), the more
; Layer 1 goes up. The lower the value (negative, wraps around to #$FFFF and
; below) the more Layer 1 goes down.
!RAM_SMW_ShakingLayer1DispYLo #= !Define_SMW_LowRAMLocation+$1888
!RAM_SMW_ShakingLayer1DispYHi #= !RAM_SMW_ShakingLayer1DispYLo+$01
; Empty. Cleared on reset, titlescreen load, overworld load and level load,
; hurt, death, and taking hit while cape flying ($00:F625 for the last
; three) and in the Peach Rescued scene ($03:AE39).
!RAM_SMW_UnusedRAM_7E188A #= !Define_SMW_LowRAMLocation+$188A
; Player image-relative Y position, used by $7E:1887 (shaking ground). Does
; not affect player interaction. Unlike $7E:1888, this is an 8-bit address.
!RAM_SMW_Player_RelativeYPositionDuringScreenShake #= !Define_SMW_LowRAMLocation+$188B
; Flag that determines if the game should keep updating the tile and
; YXPPCCCT data for the sprite background tiles in the Morton/Roy/Ludwig
; room. #$00 = Keep updating; #$01 = Stop updating.
!RAM_SMW_Flag_UpdateBackgroundSpritesInKoopaKidRooms #= !Define_SMW_LowRAMLocation+$188C
; Used as scratch RAM during calculation of the X offset of the background
; in the Morton/Roy/Ludwig room. The result of that calculation instead gets
; stored into $06.
!RAM_SMW_Misc_MortonRoyLudwigBackgroundXOffset #= !Define_SMW_LowRAMLocation+$188D
;Empty $00188E
; Used to indicate whether the bonus game is over. It will disable the
; interaction and movement.
!RAM_SMW_Sprites_BonusGameIsOverFlag #= !Define_SMW_LowRAMLocation+$188F
; How many 1-Ups to spawn. (Used for bonus game.)
!RAM_SMW_Counter_NumberOfBonusGame1upsToSpawn #= !Define_SMW_LowRAMLocation+$1890
; P-balloon timer. Ticks down once every four frames, controlled by $14.
; Note that: This does not serve as a flag for actually having a P-ballon;
; instead, that is controlled by $13F3. Due to an oversight, the timer does
; not check whether the game-frozen flag at $9D is set, which means the
; timer may decrement every frame during a freeze if frozen on certain
; values of $14.
!RAM_SMW_Timer_PlayerHasPBalloon #= !Define_SMW_LowRAMLocation+$1891
; Cluster sprite number. The pointer to each cluster sprite's MAIN code can
; be found at $02F825.
!RAM_SMW_ClusterSpr_SpriteID #= !Define_SMW_LowRAMLocation+$1892
; Empty, unused RAM. Referenced at $01CF9E (Morton's code) but never
; actually used. Cleared on reset, titlescreen load, overworld load and
; level load.
!RAM_SMW_UnusedRAM_7E18A6 #= !Define_SMW_LowRAMLocation+$18A6
; This address is a mirror of $7E:1693, which holds the Map16 number of the
; current block that is being checked. Primarily used in the Chargin' Chuck
; turn/throw block detection code.
!RAM_SMW_Blocks_CopyOfCurrentlyProcessedMap16TileLo2 #= !Define_SMW_LowRAMLocation+$18A7
; Morton and Roy left and right pillar status. $7E:18A8 controls the left
; pillar, whereas $7E:18A9 is used for the right pillar. #$00 = Pillar is
; not falling yet. #$01 = Pillar is falling. #$81 = Pillar has fallen.
!RAM_SMW_Sprites_MortonAndRoyLeftPillarStatus #= !Define_SMW_LowRAMLocation+$18A8
!RAM_SMW_Sprites_MortonAndRoyRightPillarStatus #= !RAM_SMW_Sprites_MortonAndRoyLeftPillarStatus+$01
; Morton and Roy left and right pillar Y positions. $7E:18AA is the left
; pillar, $7E:18AB is the right pillar. The pillar status ($7E:18A8 and
; $7E:18A9) is set to #$81 (pillar has fallen) as soon as this Y position
; becomes #$B0. The Y speed here accelerates slightly - see $02:83F8 for
; reference.
!RAM_SMW_Sprites_MortonAndRoyLeftPillarYPosition #= !Define_SMW_LowRAMLocation+$18AA
!RAM_SMW_Sprites_MortonAndRoyRightPillarYPosition #= !RAM_SMW_Sprites_MortonAndRoyLeftPillarYPosition+$01
; Timer on when Yoshi will swallow the sprite in his mouth. Decrements every
; fourth frame (based on $14), and Yoshi's swallowing animation starts when
; this is #$26 or lower. Note that the original game has a minor issue with
; this timer where if the game freezes via $9D on a frame when $14 is zero,
; the timer will decrement every frame during that freeze, which can cause
; Yoshi to swallow a sprite much faster than he should.
!RAM_SMW_Yoshi_SwallowTimer #= !Define_SMW_LowRAMLocation+$18AC
; Frame counter for Yoshi's walking frames. It goes from #$00-#$02, forms an
; index for the image table at $01:EDEE, and becomes #$02 when it gets lower
; than #$00 (frame counter decrements). This address is comparable with the
; player's version, at $7E:13DB.
!RAM_SMW_Yoshi_WalkingFrames #= !Define_SMW_LowRAMLocation+$18AD
; How long it takes for Yoshi's tongue to come out after the player "hits"
; Yoshi (after $7E:14A3 becomes #$10). Starts at #$06 and decrements each
; frame.
!RAM_SMW_Timer_YoshiTongueInit #= !Define_SMW_LowRAMLocation+$18AE
; Yoshi squatting timer. It's set to #$0C once the player hops onto Yoshi,
; decrements once every frame, and takes care of the ducking frame.
!RAM_SMW_Timer_YoshiSquatting #= !Define_SMW_LowRAMLocation+$18AF
; Yoshi's X position. Used only to determine where Yoshi is when eating a
; berry (by means of walking into one, not sticking his tongue out).
!RAM_SMW_Yoshi_XPosLo #= !Define_SMW_LowRAMLocation+$18B0
!RAM_SMW_Yoshi_XPosHi #= !RAM_SMW_Yoshi_XPosLo+$1
; Yoshi's Y position. Used only to determine where Yoshi is when eating a
; berry (by means of walking into one, not sticking his tongue out).
!RAM_SMW_Yoshi_YPosLo #= !Define_SMW_LowRAMLocation+$18B2
!RAM_SMW_Yoshi_YPosHi #= !RAM_SMW_Yoshi_YPosLo+$1
;Empty $0018B4
; Cleared when standing on the ground, set when standing on the floor of the
; unused winged cage. It tells whether the player should be following the
; cage or layer 1.
!RAM_SMW_Flag_StandingOnBetaCage #= !Define_SMW_LowRAMLocation+$18B5
; Sometimes used to keep track of a tile to generate at $00:BEB0 (before
; storing to $7E:009C); may be in conjunction with $7E:185E. Also used to
; determine the player X position when they're on the line guided rope, used
; when the player is on top of Boo Block, etc.
!RAM_SMW_Misc_ScratchRAM7E18B6 #= !Define_SMW_LowRAMLocation+$18B6
;Empty $0018B7
; Flag for whether cluster sprite routines should be run. Initially set to 0
; at the start of a level, then set to 1 whenever any cluster sprite is
; spawned.
!RAM_SMW_Flag_RunClusterSprites #= !Define_SMW_LowRAMLocation+$18B8
; Generator type that is currently active. #$00 = None, #$01-#$0F =
; generators CB-D9. The pointers for this address are located at $02:B00C.
; Pixi uses the most significant bits of this address to hold the extra bits
; of the generator.
!RAM_SMW_GenSpr_SpriteID #= !Define_SMW_LowRAMLocation+$18B9
; Index to the Boo rings that are on screen (maximum is two). Additionally,
; depending on bit 0 of this byte, the reappearing ghosts use position
; combination 1 or 2.
!RAM_SMW_ClusterSpr04_BooRing_RingIndex #= !Define_SMW_LowRAMLocation+$18BA
;Empty $0018BB
; Floating skull speed. It's set to #$00 in the sprite initial routine, and
; set to #$0C when the player touches the sprite.
!RAM_SMW_Sprites_FloatingSkullSpeed #= !Define_SMW_LowRAMLocation+$18BC
; Time to stun the player. It will make the player face the screen and make
; him unable to move.
!RAM_SMW_Timer_StunPlayer #= !Define_SMW_LowRAMLocation+$18BD
; Flag used to tell if the player can climb on air. The line guided ropes
; use this to let the player get onto them.
!RAM_SMW_Flag_PlayerClimbOnAir #= !Define_SMW_LowRAMLocation+$18BE
; Timer used by a bunch of appearing/disappearing sprites (examples: Lakitu,
; Magikoopa, and Layer 3 smasher). Sprite D2 freezes it by incrementing the
; timer - effectively getting rid of the decrements applied by said sprites.
!RAM_SMW_Timer_DisappearingSprite #= !Define_SMW_LowRAMLocation+$18BF
; Timer for respawning certain sprites, such as the Boo Buddies or sprite E5
; (and Lakitu). Sprite D2, Turn Off Generator 2, sets this to zero when it
; is active.
!RAM_SMW_Timer_RespawnSprite #= !Define_SMW_LowRAMLocation+$18C0
; Used by Magikoopa and Lakitu to determine which sprite number should
; respawn when $7E:18BF is zero.
!RAM_SMW_Sprites_SpriteToRespawn #= !Define_SMW_LowRAMLocation+$18C1
; Player is inside Lakitu cloud flag. #$00 = Not inside Lakitu cloud. #$01 =
; Inside Lakitu cloud. If the latter, the player does not animate as if they
; were walking or floating.
!RAM_SMW_Flag_PlayerInLakitusCloud #= !Define_SMW_LowRAMLocation+$18C2
; Y position of the respawning sprite, used with $7E:18C0 (respawn timer)
; and $7E:18C1 (respawn sprite number).
!RAM_SMW_Sprites_YPosOfRespawningSpriteLo #= !Define_SMW_LowRAMLocation+$18C3
!RAM_SMW_Sprites_YPosOfRespawningSpriteHi #= !RAM_SMW_Sprites_YPosOfRespawningSpriteLo+$01
;Empty $0018C5-$0018CC
; Bounce sprite (alternative) index. Also used as which bounce sprite to
; overwrite if all slots are full when resetting a turn block (similar to
; $7E1861).
!RAM_SMW_BounceSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$18CD
; Spinning turn block timer - amount of frames a spinning turn block lasts.
; When it hits zero, it reverts to a regular turn block.
!RAM_SMW_BounceSpr07_SpinningTurnBlock_DespawnTimer #= !Define_SMW_LowRAMLocation+$18CE
; This address is incremented every time the player kills a sprite with a
; star while the star is active and will reset when the star runs out. #$01
; = 200; #$02 = 400; #$03 = 800; #$04 = 1000; #$05 = 2000; #$06 = 4000; #$07
; = 8000; #$08 and above = 1-Up
!RAM_SMW_Player_StarKillCount #= !Define_SMW_LowRAMLocation+$18D2
; Write a value to here, and sparkles (like the ones from the stars) will
; fly around the player for that amount of frames. However, it is never used
; in the original game, and it can be turned into free RAM by applying this
; tweak. Note that if the player has an invincibility star, this timer will
; wait until the star runs out.
!RAM_SMW_Timer_UnusedPlayerSparkle #= !Define_SMW_LowRAMLocation+$18D3
; Red berries eaten by Yoshi. After 10 berries, the counter resets and Yoshi
; lays an egg, containing a mushroom.
!RAM_SMW_Counter_EatenRedBerries #= !Define_SMW_LowRAMLocation+$18D4
; Pink berries eaten by Yoshi. After 2 berries, the counter resets and Yoshi
; lays an egg, containing a coin game cloud.
!RAM_SMW_Counter_EatenPinkBerries #= !Define_SMW_LowRAMLocation+$18D5
; Type of the current berry being eaten. #$00 = Coin (no effect except
; getting a coin), #$01 = Red, #$02 = Pink, #$03 = Green. Controls both
; color and what happens when Yoshi eats the berry.
!RAM_SMW_Yoshi_BerryBeingEaten #= !Define_SMW_LowRAMLocation+$18D6
; This is the high byte of the Map16 tile (actual tile number, not "acts
; like" setting) that a sprite is touching vertically. The low byte is at
; $185F. This address is set after calling the standard object-sprite
; interaction routine at $019138 (or $01802A).
!RAM_SMW_Sprites_Map16TileBeingTouchedVerticallyHi #= !Define_SMW_LowRAMLocation+$18D7
;Empty $0018D8
; Timer for the castle/ghost house door in the intro sequence. The castle
; door starts at #$FF, the ghost house door starts at #$7F. For the castle
; door: start rising and generate first sound at #$B0, rise until #$81, stay
; still until #$30, then sink and generate second sound at #$01. For the
; ghost house door: open and generate first sound at #$76, then close and
; generate second sound at #$08.
!RAM_SMW_Timer_NoYoshiIntroDoorTimer #= !Define_SMW_LowRAMLocation+$18D9
; Sprite number that spawns when Yoshi lays an egg. Valid values are #$74
; (mushroom) and #$6A (coin game cloud).
!RAM_SMW_Yoshi_LaidEggContents #= !Define_SMW_LowRAMLocation+$18DA
; Set to #$08 at $00:CDD4 (unreachable by default) and never touched again.
; Might have been intended as a starting index for the player's fireballs.
; Cleared on reset, titlescreen load, overworld load and level load.
!RAM_SMW_UnusedRAM_7E18DB #= !Define_SMW_LowRAMLocation+$18DB
; Flag that is set when the player is ducking with Yoshi. They cannot turn
; around in this state. If you were to use the debug codes at
; $00:D085-$00:D089, this also makes the fireballs that the player fires
; when on Yoshi appear at a different position.
!RAM_SMW_Yoshi_DuckingFlag #= !Define_SMW_LowRAMLocation+$18DC
; Number of silver coins collected.
!RAM_SMW_Counter_CurrentSilverCoins #= !Define_SMW_LowRAMLocation+$18DD
	!RAM_SMW_Counter_GoalCoinPointsIndex #= !RAM_SMW_Counter_CurrentSilverCoins
; Timer that determines how long it takes before an egg is laid by Yoshi,
; when 10 red Berries have been eaten. Is set to #$20 by default. Also, as
; long as this timer is above #$01, the player is frozen ($7E:13FB is set).
!RAM_SMW_Yoshi_EggLayTimer #= !Define_SMW_LowRAMLocation+$18DE
; Sprite slot plus 1 of the currently active Yoshi, current frame. If no
; Yoshi is active, will be set to 00. In reality, this address is set to
; #$00 every frame, and Yoshi's sprite routines later set it. Because of
; this, sprites running prior to Yoshi's code won't be able to actually get
; the slot from here. Instead, it is preferable to use $18E2, which contains
; the previous frame's value for this address.
!RAM_SMW_Sprites_YoshiSlotIndex #= !Define_SMW_LowRAMLocation+$18DF
; Timer for how long stolen Lakitu clouds should remain before evaporating.
; Decrements once every four frames.
!RAM_SMW_Timer_DespawnLakituCloud #= !Define_SMW_LowRAMLocation+$18E0
; Slot of the Lakitu cloud (index to the sprite table that corresponds to
; the Lakitu cloud sprite). Contains a valid value even if the Lakitu itself
; is still alive.
!RAM_SMW_Sprites_LakituCloudSlotIndex #= !Define_SMW_LowRAMLocation+$18E1
; Sprite slot plus 1 of the currently active Yoshi, previous frame. If no
; Yoshi is active, will be set to 00. Copied from $18DF, though it is
; generally preferable to use this address instead. If set, Yoshis spawned
; from an egg will become a 1-up instead.
!RAM_SMW_Yoshi_StrayYoshiFlag #= !Define_SMW_LowRAMLocation+$18E2
; How many of the coins from the coin game cloud (the one that appears if
; Yoshi eats two pink berries) the player has collected. Oddly enough, it's
; cleared if you get hurt.
!RAM_SMW_Counter_PinkBerryCloudCoins #= !Define_SMW_LowRAMLocation+$18E3
; Lives incrementer (increments lives over multiple frames instead of
; instantly), mainly handled by $028AB4-$028ACC. $18E4: How many lives left
; to increase the current player's life count. $18E5: How many frames left
; before each life is given to the player (this ignores $9D).
!RAM_SMW_Misc_1upHandler #= !Define_SMW_LowRAMLocation+$18E4
!RAM_SMW_Timer_Give1up #= !Define_SMW_LowRAMLocation+$18E5
;Empty $0018E6
; Yoshi ground stomp flag. #$00 = Yoshi does not stomp the ground when
; landing on it; #$01 = Yoshi does stomp the ground when landing on it. This
; is set to #$01 when a Yellow Yoshi has a shell in its mouth, or when any
; Yoshi has a yellow shell in its mouth.
!RAM_SMW_Yoshi_StompGroundFlag #= !Define_SMW_LowRAMLocation+$18E7
; Yoshi growing animation timer. Starts at #$40 and then decrements.
; Additionally, it freezes everything on the screen except Yoshi.
!RAM_SMW_GrowingYoshiTimer #= !Define_SMW_LowRAMLocation+$18E8
; Occasionally used to index $7E:17C0 (smoke image table). If there are no
; empty slots left when a smoke image should be spawned, the oldest one is
; removed and the index is reset.
!RAM_SMW_SmokeSpr_CopyOfSlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$18E9			; Todo: Duplicate of $001863?
; Minor extended sprite X position, high byte.
!RAM_SMW_MExtSpr_XPosHi #= !Define_SMW_LowRAMLocation+$18EA
;Empty $0018F6
; Score sprite index.
!RAM_SMW_ScoreSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$18F7
; Timer for quake/interaction sprites. This is set to #$06 and decrements by
; 1 each frame. If the timer is less than #$03, the quake sprite is allowed
; to interact with normal sprites (if $7E:16CD is not 0). When it reaches 0,
; the quake sprite is erased.
!RAM_SMW_BounceSpr_InteractTimer #= !Define_SMW_LowRAMLocation+$18F8
; Alternative extended sprite index, used when the extended sprite tables
; are full. Holds the first available extended sprite index and resets to
; #$07 if all of them have been filled and another extended sprite is
; spawned.
!RAM_SMW_ExtSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$18FC
; Flag set when Whistlin' Chuck whistles, even when it's the Super
; Koopa-generating kind. Setting this makes Rip van Fish chase the player.
!RAM_SMW_Flag_WakeUpRipVanFish #= !Define_SMW_LowRAMLocation+$18FD
; The diagonal and surrounded bullet bills timer. It increments every second
; frame, and when it reaches #$A0, it sends out some more Bullet Bills and
; resets itself.
!RAM_SMW_Sprites_SpecialBulletGeneratorTimer #= !Define_SMW_LowRAMLocation+$18FE
; Shooter index for the current shooter that is being processed.
!RAM_SMW_ShooterSpr_SlotToOverwriteWhenSlotsFull #= !Define_SMW_LowRAMLocation+$18FF
