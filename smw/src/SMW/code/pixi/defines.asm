includeonce

; What PIXI's own sa1def.asm adds over the shared dialect
; (code/uberasm/defines.asm, read in front of this file): the base pair
; that makes one file assemble on both a console cartridge and a
; coprocessor one, and that tool's names for the sprite-engine tables the
; UberASM library does not carry -- the shooter's, the cluster's, the
; extended, minor extended, bounce, smoke and score sprites'. Every line
; is the memory map's own entry under the tool's name, so each resolves
; to the address the table has on the cartridge being assembled -- the
; pack's moves included -- and nothing here is a number. Nothing in this
; source may read them: the disassembly would then have two names for one
; address. Regenerated from the tool's file; the generator is not part of
; the build.
;
; = rather than #= so a file that defines its own wins, which is what a
; sprite carrying a newer copy of them expects.

!Base1 = !Define_SMW_DirectPageLocation
!Base2 = !Define_SMW_LowRAMLocation

; The miscellaneous defines sa1def.asm sets beside the tables, spelled
; from the shared dialect's facts where one exists. !EXLEVEL is Lunar
; Magic's expanded level format, which this cartridge's own containers
; never use; !Disable255SpritesPerLevel is 1 because the load-status
; relocation is not made (see the foot of this file); !fullsa1 is the
; pack's above-4MB mapping, which no build here asks for.
!SA1 = !sa1
!SA_1 = !sa1
!SprSize = !sprite_slots
!EXLEVEL = 0
!Disable255SpritesPerLevel = 1
!fullsa1 = 0
!PerLevel = 0
!More_ExSprite = 0

; The constants sa1def.asm sets beside the tables. The custom bit, the
; generators' first record byte, and each kind's dispatch offset -- the
; count of the game's own entries, spelled from the dialect's own fact
; where the feature declares one; the spinning coin's and the score
; sprite's are the tool's numbers, as this cartridge dispatches nothing
; custom there. The sizes are the slot counts of each kind's tables,
; which sprites read as loop bounds. !ExSprSize is the plain cartridge's
; $07 on either base: the More Extended Sprites patch that raises it is
; never applied here, so !ExtendedSize and !FireballSprSize carry the
; values PIXI computes from it.
!CustomBit = $08
!GenStart = $D0
!ClusterOffset = !Define_SMW_CustomSprites_ClusterCount
!ExtendedOffset = !Define_SMW_CustomSprites_ExtendedCount
!MinorExtendedOffset = !Define_SMW_CustomSprites_MinorExtendedCount
!SmokeOffset = !Define_SMW_CustomSprites_SmokeCount
!BounceOffset = !Define_SMW_CustomSprites_BounceCount
!SpinningCoinOffset = $02
!ScoreOffset = $16
!ClusterSize = $14
!ExSprSize = $07
!ExtendedSize = $08
!FireballSprSize = $09
!MinorExtendedSize = $0C
!SmokeSize = $04
!SpinningCoinSize = $04
!BounceSize = $04
!ScoreSize = $06
if defined("Define_SMW_SA1")
!BankA = $400000
!BankB = $000000
!Bank8 = $00
else
!BankA = $7E0000
!BankB = $800000
!Bank8 = $80
endif

!7FAB64 = !RAM_SMW_CustomSprites_ExtraByte4
!shoot_num = !RAM_SMW_ShooterSpr_SpriteID
!shoot_y_low = !RAM_SMW_ShooterSpr_YPosLo
!shoot_y_high = !RAM_SMW_ShooterSpr_YPosHi
!shoot_x_low = !RAM_SMW_ShooterSpr_XPosLo
!shoot_x_high = !RAM_SMW_ShooterSpr_XPosHi
!shoot_timer = !RAM_SMW_ShooterSpr_ShootTimer
!cluster_num = !RAM_SMW_ClusterSpr_SpriteID
!cluster_y_low = !RAM_SMW_ClusterSpr_YPosLo
!cluster_y_high = !RAM_SMW_ClusterSpr_YPosHi
!cluster_x_low = !RAM_SMW_ClusterSpr_XPosLo
!cluster_x_high = !RAM_SMW_ClusterSpr_XPosHi
!cluster_misc_0f4a = !RAM_SMW_ClusterSpr_Table7E0F4A
!cluster_misc_0f72 = !RAM_SMW_ClusterSpr_Table7E0F72
!cluster_misc_0f86 = !RAM_SMW_ClusterSpr_Table7E0F86
!cluster_misc_0f9a = !RAM_SMW_ClusterSpr_Table7E0F9A
!cluster_misc_1e52 = !RAM_SMW_ClusterSpr_Table7E1E52
!cluster_misc_1e66 = !RAM_SMW_ClusterSpr_Table7E1E66
!cluster_misc_1e7a = !RAM_SMW_ClusterSpr_Table7E1E7A
!cluster_misc_1e8e = !RAM_SMW_ClusterSpr_Table7E1E8E
!extended_num = !RAM_SMW_ExtSpr_SpriteID
!extended_y_low = !RAM_SMW_ExtSpr_YPosLo
!extended_y_high = !RAM_SMW_ExtSpr_YPosHi
!extended_x_low = !RAM_SMW_ExtSpr_XPosLo
!extended_x_high = !RAM_SMW_ExtSpr_XPosHi
!extended_x_speed = !RAM_SMW_ExtSpr_XSpeed
!extended_y_speed = !RAM_SMW_ExtSpr_YSpeed
!extended_x_fraction = !RAM_SMW_ExtSpr_SubXPos
!extended_y_fraction = !RAM_SMW_ExtSpr_SubYPos
!extended_table = !RAM_SMW_ExtSpr_Table7E1765
!extended_timer = !RAM_SMW_ExtSpr_DecrementingTable7E176F
!extended_behind = !RAM_SMW_ExtSpr_Table7E1779
!extended_table_1 = !RAM_SMW_ExtSpr_Table7E1765
!minor_extended_num = !RAM_SMW_MExtSpr_SpriteID
!minor_extended_y_low = !RAM_SMW_MExtSpr_YPosLo
!minor_extended_y_high = !RAM_SMW_MExtSpr_YPosHi
!minor_extended_x_low = !RAM_SMW_MExtSpr_XPosLo
!minor_extended_x_high = !RAM_SMW_MExtSpr_XPosHi
!minor_extended_x_speed = !RAM_SMW_MExtSpr_XSpeed
!minor_extended_y_speed = !RAM_SMW_MExtSpr_YSpeed
!minor_extended_x_fraction = !RAM_SMW_MExtSpr_SubXPos
!minor_extended_y_fraction = !RAM_SMW_MExtSpr_SubYPos
!minor_extended_timer = !RAM_SMW_MExtSpr_Timer
!smoke_num = !RAM_SMW_SmokeSpr_SpriteID
!smoke_y_low = !RAM_SMW_SmokeSpr_YPosLo
!smoke_x_low = !RAM_SMW_SmokeSpr_XPosLo
!smoke_timer = !RAM_SMW_SmokeSpr_Timer
!spinning_coin_num = !RAM_SMW_BlockCoinSpr_SlotID
!spinning_coin_y_low = !RAM_SMW_BlockCoinSpr_YPosLo
!spinning_coin_y_speed = !RAM_SMW_BlockCoinSpr_YSpeed
!spinning_coin_y_bits = !RAM_SMW_BlockCoinSpr_SubYPos
!spinning_coin_x_low = !RAM_SMW_BlockCoinSpr_XPosLo
!spinning_coin_layer = !RAM_SMW_BlockCoinSpr_LayerIndex
!spinning_coin_y_high = !RAM_SMW_BlockCoinSpr_YPosHi
!spinning_coin_x_high = !RAM_SMW_BlockCoinSpr_XPosHi
!score_num = !RAM_SMW_ScoreSpr_SpriteID
!score_y_low = !RAM_SMW_ScoreSpr_YPosLo
!score_x_low = !RAM_SMW_ScoreSpr_XPosLo
!score_x_high = !RAM_SMW_ScoreSpr_XPosHi
!score_y_high = !RAM_SMW_ScoreSpr_YPosHi
!score_y_speed = !RAM_SMW_ScoreSpr_YSpeed
!score_layer = !RAM_SMW_ScoreSpr_LayerIndex
!bounce_num = !RAM_SMW_BounceSpr_SpriteID
!bounce_init = !RAM_SMW_BounceSpr_CurrentStatus
!bounce_y_low = !RAM_SMW_BounceSpr_YPosLo
!bounce_x_low = !RAM_SMW_BounceSpr_XPosLo
!bounce_y_high = !RAM_SMW_BounceSpr_YPosHi
!bounce_x_high = !RAM_SMW_BounceSpr_XPosHi
!bounce_y_speed = !RAM_SMW_BounceSpr_YSpeed
!bounce_x_speed = !RAM_SMW_BounceSpr_XSpeed
!bounce_x_bits = !RAM_SMW_BounceSpr_SubYPos
!bounce_y_bits = !RAM_SMW_BounceSpr_SubXPos
!bounce_map16_tile = !RAM_SMW_BounceSpr_Map16TileToSpawn
!bounce_timer = !RAM_SMW_BounceSpr_Timer
!bounce_table = !RAM_SMW_BounceSpr_Properties
!bounce_table_1 = !RAM_SMW_BounceSpr_Properties
!bounce_properties = !RAM_SMW_BounceSpr_YXPPCCCT
!bounce_map16_low = !RAM_SMW_BounceSpr_Map16TileToSpawn

; What sa1def.asm names and this file deliberately does not:
;
; - The defines inside $1938, the sprite load-status table (!smoke_y_high,
;   !bounce_map16_high, the minor extended, spinning coin and score
;   tables, the extended tables past the first): PIXI relocates that
;   table to $7FAF00 and repurposes the space it freed, and those names
;   only exist on a cartridge that made the same relocation. This one has
;   not; a sprite reaching for one fails at the build rather than
;   corrupting the load-status table.
; - !sprite_load_table and its spellings: the shared dialect maps them to
;   the table's stock home, for the same reason.
; - The three shooter extra-byte tables ($7FAC00, $7FAC08, $7FAC10):
;   extra bytes are not read out of the level stream yet, so declaring
;   RAM for the shooter's would promise what the loader does not do.
; - !cluster_misc_0f5e: between two named cluster tables, and unnamed by
;   this tree's RAM map. Wants reading before it is either named or
;   dismissed.
