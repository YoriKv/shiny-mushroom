includeonce

;#############################################################################################################
;# Lunar Magic level compatibility: the four bytes Lunar Magic adds to a
;# level's secondary header, and the Layer 2 scroll settings they carry.
;#
;# Lunar Magic extends the secondary header by four bytes per level, kept in
;# four $200-byte tables of its own and carried in a level container's
;# level-information slot. Setting !Define_SMW_LunarMagicLevels to !TRUE
;# gives this cartridge the same four tables, one fragment per byte under
;# levels/properties/, emitted in sequence in the level bank behind the
;# per-level code and ahead of the custom palettes (Config/LevelBank.asm):
;#
;# - lunar-magic-entrance.asm, IWPXXtTT: the level is slippery, the level
;#   is water, the main entrance is placed by the second method with XX its
;#   high X bits, and the sprite spawn settings -- which are read by nothing
;#   here yet.
;# - lunar-magic-scroll.asm, SHCvvvvv: S says the level scrolls Layer 2 by
;#   two settings rather than the header's pair, vvvvv the vertical one;
;#   C is the tool's own auto-set-screens flag.
;# - lunar-magic-entrance-y.asm, OFYYYYYY: O places the background relative
;#   to Layer 1 rather than to its own height, F is the relative offset's
;#   high bit, YYYYYY the second method's high Y bits.
;# - lunar-magic-background.asm, RL-ooooo: R places the camera relative to
;#   the player, L faces the player left, ooooo the background's height in
;#   rows less one -- or its offset from Layer 1, where O is set.
;#
;# The entrance bits are the main entrance's. A level entered through a
;# secondary entrance takes that entrance's own -- Lunar Magic keeps two
;# tables per secondary entrance for them -- which this cartridge does not
;# hold yet, so on that path the stock placement stands untouched.
;#
;# Every row ships as Lunar Magic writes a level it has not touched --
;# $00, $20, $00, $1A -- so the tables with nothing edited change nothing.
;#
;# **Layer 2 scrolls as it does under Lunar Magic.** The stock game picks a
;# horizontal and a vertical setting together, out of eight pairs the
;# header's nibble indexes, and knows four values of each: none, constant,
;# half and slow. Lunar Magic keeps the pair for a level whose S bit is
;# clear -- with four more pairs in the nibble's upper half, which the two
;# tables in SMW_SpecifySublevelToLoad gain under this define -- and for a
;# level whose S bit is set takes the nibble whole as the horizontal setting
;# and vvvvv as the vertical one. Either way a setting is one of thirty-two:
;#
;#   $00  none: the layer stays where the load put it
;#   $01  constant, 1:1               $05  1:8, Lunar Magic's medium 3
;#   $02  1:2, medium                 $06  1:16, medium 4
;#   $03  1:32, slow                  $07  1:64, slow 2
;#   $04  1:4, medium 2               $08  6:5, fast
;#   $09-$0F  none
;#   $10-$15  the layer scrolls by itself, $40, $80, $100, $200, $300, $400
;#            256ths of a pixel a frame, rightwards or downwards
;#   $16-$1B  the same six, leftwards or upwards
;#   $1C-$1F  the layer scrolls by itself at no speed
;#
;# **The main entrance places as it does under Lunar Magic.** The second
;# position method (P) puts the player at a tile rather than at one of the
;# stock table's positions: the column is XXxxx, the header's three X bits
;# under the two high ones, times sixteen; the row YYYYYYyyyy the same way,
;# the header's four under the six high ones. The entrance screen the stock
;# code wrote into the high byte stays: on a horizontal level the column's
;# high bit is lost past the screen's sixteen and the row keeps YYYYYY, on
;# a vertical level the reverse -- Lunar Magic hooks ahead of that store,
;# and its tile-precise axis is the one the screen does not count along.
;# Relative placement (R) starts
;# the camera at the player's Y plus Fffbb, a signed offset in rows the
;# header's FG/BG nibble and the F bit spell, rather than at the header's
;# fixed height; and it starts Layer 2 either so that the bottom of a
;# background ooooo+1 rows tall meets the bottom of the level when the
;# camera is there, or, with O set, ooooo rows from Layer 1: $00-$0F that
;# many rows down, $11-$1F counting back from $20, and $10 at the level's
;# top outright, the wiki's "absolute 0". The two flags are the level's
;# slippery (I) and water
;# (W) flags, and L faces the player left and shoots them leftwards out of
;# a pipe entrance.
;#
;# Six hooks give those their meaning, each exactly one JSL or JML over
;# instructions of the same size, at the spots Lunar Magic hooks for its own:
;#
;# - SMW_SpecifySublevelToLoad (Banks/Bank05.asm, CODE_05DA17), after the
;#   stock load has taken the header's pair and placed the entrance: a level
;#   with S set has its two settings written over the pair, one with P its
;#   position rewritten, one with R its camera and Layer 2 placed.
;# - SMW_InitializeLevelRAM (Banks/Bank00.asm, LM000Hijack_JSLTo05DD00):
;#   the slippery and water flags, where the stock init decides the same
;#   from the entrance action.
;# - SMW_GameMode11_LoadSublevel (Banks/Bank00.asm, CODE_00A796), the
;#   routine that fixes Layer 2's vertical offset from Layer 1 once per
;#   load: taken over whole, so the self-scrolling settings start their
;#   accumulators, a relative entrance keeps the offset the load already
;#   placed, and the player faces the way the entrance says. The offset
;#   itself is the stock routine's arithmetic, which Lunar Magic leaves
;#   alone: the distance for constant, half of Layer 1's start for medium,
;#   an eighth for every other setting -- the slow pair's included, so the
;#   background starts a little higher than it scrolls, as it always has.
;# - SMW_PlayerState07_ShootOutOfPipe (Banks/Bank00.asm,
;#   LM300Hijack_ShootingDirectionOnLevelLoad): the X speed the shoot-out
;#   loads is read from !RAM_SMW_LM_Misc_PipeShootDirection, which the load
;#   sets, in place of the rightward constant.
;# - SMW_HandleStandardLevelCameraScroll (Banks/Bank00.asm, CODE_00F79D),
;#   the once-a-frame placement of Layer 2 against Layer 1: taken over up to
;#   the point the displacements are measured.
;# - SMW_ProcessScrollSprites (Banks/Bank05.asm, Layer2), the once-a-frame
;#   pass that moves an interactive Layer 2: a self-scrolling setting in a
;#   level whose Layer 2 is interactive steps here, the way a scroll sprite
;#   would, so the layer's committed position moves with it.
;#
;# A self-scrolling setting keeps its state where the Layer 2 scroll sprites
;# keep theirs -- the speed in !RAM_SMW_L2ScrollSpr_XSpeedLo and
;# !RAM_SMW_L2ScrollSpr_YSpeedLo, a byte of fraction in
;# !RAM_SMW_L2ScrollSpr_CurrentState and !RAM_SMW_L2ScrollSpr_Timer, the
;# pixels scrolled so far in !RAM_SMW_L2ScrollSpr_SubXPosLo and, for the
;# vertical axis, in the offset itself -- which is what Lunar Magic does,
;# and is free while no such sprite is active: a level that has one keeps
;# the sprite and the setting is not stepped.
;#
;# Every rule here was measured against a Lunar Magic 3.63 save running
;# the same level: the tables edited, the level entered, the placement
;# read back off work RAM, on both cartridges.
;#
;# The define needs a cartridge assembled at 1 MB or larger, which the
;# bank's reservation says rather than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_LunarMagicLevels=1 turns the tables on.
if defined("Define_SMW_LunarMagicLevels") == 0
	!Define_SMW_LunarMagicLevels = !FALSE
endif

; The four tables, one byte per level each. What the whole block comes to
; -- these and the stubs behind them -- is !Define_SMW_Block_LunarMagicLevels,
; declared with every other block in Config/PackedRuns.asm because the
; palettes behind it are read past the same figure and the editor prices
; the bank against it. The placement asserts what it emitted against it.
!Define_SMW_LunarMagicLevelsTableBytes	#= $0200
!Define_SMW_LunarMagicLevelsTablesBytes	#= $0004*!Define_SMW_LunarMagicLevelsTableBytes

; The scroll byte's bits.
!Define_SMW_LunarMagicLevels_SeparateScroll	= $80	;> S: the two settings below, not the header's pair
!Define_SMW_LunarMagicLevels_VerticalScroll	= $1F	;> vvvvv: the vertical setting

; The entrance byte's bits.
!Define_SMW_LunarMagicLevels_Slippery		= $80	;> I
!Define_SMW_LunarMagicLevels_Water		= $40	;> W
!Define_SMW_LunarMagicLevels_SecondMethod	= $20	;> P: the entrance at a tile
!Define_SMW_LunarMagicLevels_HighX		= $18	;> XX: the tile column's high two bits

; The entrance Y byte's bits.
!Define_SMW_LunarMagicLevels_BackgroundRelative	= $80	;> O: Layer 2 from Layer 1, not from its height
!Define_SMW_LunarMagicLevels_OffsetHigh		= $40	;> F: the camera offset's sign
!Define_SMW_LunarMagicLevels_HighY		= $3F	;> YYYYYY: the tile row's high six bits

; The background byte's bits.
!Define_SMW_LunarMagicLevels_Relative		= $80	;> R: the camera from the player
!Define_SMW_LunarMagicLevels_FaceLeft		= $40	;> L
!Define_SMW_LunarMagicLevels_BackgroundRows	= $1F	;> ooooo: the background's rows less one, or its offset

; The stock horizontal level: how far the camera may scroll down, and how
; many rows of a background the bottom of the screen leaves above the
; level's bottom when the camera is there -- the terms Lunar Magic's
; relative placement works in, fixed here because this cartridge's levels
; are the stock height.
!Define_SMW_LunarMagicLevels_MaxCameraY		= $00C0
!Define_SMW_LunarMagicLevels_RowsAboveBottom	= $0E

; The pipe shoot direction the load writes: rightwards, or leftwards for L.
!Define_SMW_LunarMagicLevels_ShootRight		= $40
!Define_SMW_LunarMagicLevels_ShootLeft		= $C0

; The settings' bands.
!Define_SMW_LunarMagicLevels_FastScroll		= $08	;> 6:5, the one ratio that is not a shift
!Define_SMW_LunarMagicLevels_FirstUnusedScroll	= $09	;> $09-$0F scroll not at all
!Define_SMW_LunarMagicLevels_FirstSelfScroll	= $10	;> $10 up scroll by themselves
!Define_SMW_LunarMagicLevels_SelfScrollSpeeds	= $0C	;> six speeds each way

;#############################################################################################################
;# Where they go: behind the per-level code's block, or the level graphics',
;# or at the packed head -- Config/LevelBank.asm works the address out --
;# and ahead of the custom palettes, whose blobs are the packed head's
;# growing end.
;#############################################################################################################

; Place the four tables and the stubs. Called from %SMW_PlaceLevelBank
; behind the per-level code's block.
macro SMW_PlaceLunarMagicLevels()
if !Define_SMW_LunarMagicLevels == !TRUE
	assert pc() == !Loc_SMW_LevelBank_LunarMagic, "The Lunar Magic tables must follow the per-level code, the level graphics, or lead the level bank: they have to sit at one address per cartridge."

; The four tables, each a fragment the editor writes rows into, in the
; order Lunar Magic keeps them.
namespace SMW_LunarMagicLevels
	incsrc "levels/properties/lunar-magic-entrance.asm"
	assert pc() == SMW_LunarMagicLevels_Entrance+!Define_SMW_LunarMagicLevelsTableBytes, "The Lunar Magic entrance table is not $200 rows. Check levels/properties/lunar-magic-entrance.asm."
	incsrc "levels/properties/lunar-magic-scroll.asm"
	assert pc() == SMW_LunarMagicLevels_Scroll+!Define_SMW_LunarMagicLevelsTableBytes, "The Lunar Magic scroll table is not $200 rows. Check levels/properties/lunar-magic-scroll.asm."
	incsrc "levels/properties/lunar-magic-entrance-y.asm"
	assert pc() == SMW_LunarMagicLevels_EntranceY+!Define_SMW_LunarMagicLevelsTableBytes, "The Lunar Magic entrance Y table is not $200 rows. Check levels/properties/lunar-magic-entrance-y.asm."
	incsrc "levels/properties/lunar-magic-background.asm"
	assert pc() == SMW_LunarMagicLevels_Background+!Define_SMW_LunarMagicLevelsTableBytes, "The Lunar Magic background table is not $200 rows. Check levels/properties/lunar-magic-background.asm."
namespace off

; The load hook in bank $05 lands here, in place of the SEP and the read
; that follow the stock load's last store of the pair, once
; !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting and its vertical twin
; hold the header's pair. Entered with whatever widths the paths into
; CODE_05DA17 left, which the displaced SEP normalised and this does too;
; the data bank is $05, whose low addresses mirror work RAM. The level
; number is the word the shared stash keeps (Config/LevelNumberStash.asm),
; stored earlier in the same routine.
SMW_LunarMagicLevels_ScrollSettings:
	REP.b #$30				; AXY->16
	LDA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	AND.w #$01FF
	TAX					;> The level, as the tables' index
	SEP.b #$20				; A->8
	LDA.l SMW_LunarMagicLevels_Scroll,x
	BPL.b .Paired				;> S clear: the header's pair stands
	AND.b #!Define_SMW_LunarMagicLevels_VerticalScroll
	STA.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	LDA.l SMW_SpecifySublevelToLoad_SecondaryHeader1,x
	LSR					;\ The nibble whole, as the
	LSR					;| horizontal setting: the same
	LSR					;| bits the stock load indexed
	LSR					;/ its pair with
	STA.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting
.Paired:
	LDA.w !RAM_SMW_Flag_UseSecondaryEntrance
	BNE.b .Done				;> A secondary entrance's own bytes: not held yet
	LDA.l SMW_LunarMagicLevels_Entrance,x
	BIT.b #!Define_SMW_LunarMagicLevels_SecondMethod
	BEQ.b .Placed
	AND.b #!Define_SMW_LunarMagicLevels_HighX
	ASL					;\ XX to bits 7 and 8: the column
	ASL					;| times sixteen, high bits first
	ASL					;|
	ASL					;/
	STA.b !RAM_SMW_Player_XPosLo
	ROL					;> Bit 8 on its own
	PHA
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	LSR					;> Carry: the level is vertical
	PLA
	BCC.b .Column				;> Horizontal: the high byte keeps the screen
	STA.b !RAM_SMW_Player_XPosHi
.Column:
	LDA.l SMW_SpecifySublevelToLoad_SecondaryHeader2,x
	ASL					;\ xxx under them
	ASL					;|
	ASL					;|
	ASL					;|
	AND.b #$70				;/
	TSB.b !RAM_SMW_Player_XPosLo
	LDA.l SMW_SpecifySublevelToLoad_SecondaryHeader1,x
	ASL					;\ The row: yyyy times sixteen
	ASL					;|
	ASL					;|
	ASL					;/
	STA.b !RAM_SMW_Player_YPosLo
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	LSR
	BCS.b .Placed				;> Vertical: the high byte keeps the screen
	LDA.l SMW_LunarMagicLevels_EntranceY,x
	AND.b #!Define_SMW_LunarMagicLevels_HighY
	STA.b !RAM_SMW_Player_YPosHi		;> YYYYYY over it
.Placed:
	LDA.l SMW_LunarMagicLevels_Background,x
	BPL.b .Done				;> R clear: the header's fixed camera stands
	JSR.w SMW_LunarMagicLevels_Relative
.Done:
	SEP.b #$30				; AXY->8, the displaced SEP
	LDA.w !RAM_SMW_Overworld_LevelNumberLo	;> The displaced read
	RTL

; The relative placement: the camera from the player, Layer 2 from its
; height or from Layer 1. Entered from the load stub with A 8-bit, XY
; 16-bit and X the level; the scroll settings are final, the player's
; position is, and $02 still holds SecondaryHeader3 -- the main entrance's
; FG/BG nibble in its low four bits. Leaves the widths as it found them
; and X gone: the stub sets its own after.
;
; The camera: the player's Y plus Fffbb times sixteen -- ffbb the nibble,
; F the sign, so a row from -16 to +15 -- and never above the level's top.
; Riding Yoshi the camera sits eight pixels higher again in one case only:
; an offset of exactly seven rows up (F with ffbb = 9) in a level whose
; header vertical scroll is its second or third setting, and for the third
; not when the camera is already as far down as it goes. Lunar Magic's own
; rule, measured against its 3.63 save with every setting and offset.
;
; Layer 2, with O clear: a background of ooooo+1 rows starts fourteen rows
; above its own height -- that is, so that its bottom row meets the level's
; bottom when the camera is as far down as it goes -- and where the
; vertical setting moves the layer at all, the offset is what puts it there
; at that camera, and the layer's start follows from the camera's. With O
; set: ooooo as a signed row offset from the camera, $11-$1F counting back
; from $20 -- and $10 puts the layer at the level's top, not at the camera
; -- and the offset what keeps that.
SMW_LunarMagicLevels_Relative:
	LDA.l SMW_LunarMagicLevels_EntranceY,x
	STA.b !RAM_SMW_Misc_ScratchRAM0A		;> OFYYYYYY
	LDA.l SMW_LunarMagicLevels_Background,x
	STA.b !RAM_SMW_Misc_ScratchRAM0B		;> RL-ooooo
	SEP.b #$10				; XY->8
	REP.b #$20				; A->16
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags	;\ A vertical level's furthest
	LSR					;| camera is the screen before
	BCS.b .Vertical				;| its last, in pixels -- the
	LDA.w #!Define_SMW_LunarMagicLevels_MaxCameraY	;| count the load just placed
	BRA.b .Bounded				;| in the byte above the
.Vertical:					;| horizontal one, so the word
	LDA.b !RAM_SMW_Camera_LastScreenHoriz	;| read there is the count times
	AND.w #$FF00				;| $100
	SEC					;|
	SBC.w #$0100				;/
.Bounded:
	STA.b !RAM_SMW_Misc_ScratchRAM04		;> As far down as the camera goes
	SEP.b #$20				; A->8
	STZ.b !RAM_SMW_Misc_ScratchRAM08		;> The Yoshi exception, if any
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b .NoYoshi
	LDY.b #$04
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	;> The header's vertical scroll
	AND.b #$30
	CMP.b #$30
	BEQ.b .NoYoshi
	STA.b !RAM_SMW_Misc_ScratchRAM08
.NoYoshi:
	LDA.b !RAM_SMW_Misc_ScratchRAM02		;\ ffbb, times sixteen
	ASL					;|
	ASL					;|
	ASL					;|
	ASL					;/
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	STZ.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	BIT.b #!Define_SMW_LunarMagicLevels_OffsetHigh
	BEQ.b .Upward
	LDA.b #$FF				;> F: rows up
	STA.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	CMP.b #$90				;> Seven rows up keeps the exception
	BEQ.b .Kept
.Upward:
	STZ.b !RAM_SMW_Misc_ScratchRAM08
.Kept:
	REP.b #$20				; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	CLC
	ADC.b !RAM_SMW_Player_YPosLo
	BMI.b .Top
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	AND.w #$00FF
	BEQ.b .Camera
	CMP.w #$0020
	BNE.b .Higher
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	CMP.b !RAM_SMW_Misc_ScratchRAM04
	BEQ.b .Camera
.Higher:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	SEC
	SBC.w #$0008
	BPL.b .Placed
.Top:
	LDA.w #$0000
	BRA.b .Placed
.Camera:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
.Placed:
	STA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	SEP.b #$20				; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	BMI.b .FromLayer1
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	AND.b #!Define_SMW_LunarMagicLevels_BackgroundRows
	REP.b #$20				; A->16
	AND.w #$00FF
	SEC
	SBC.w #!Define_SMW_LunarMagicLevels_RowsAboveBottom
	ASL					;\ Rows to pixels
	ASL					;|
	ASL					;|
	ASL					;/
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	LDY.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	BEQ.b .Return				;> None: the layer stays there
	LDA.b !RAM_SMW_Misc_ScratchRAM04		;> At the camera's furthest
	JSR.w SMW_LunarMagicLevels_ScaleAny
	EOR.w #$FFFF
	SEC
	ADC.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STA.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	JSR.w SMW_LunarMagicLevels_ScaleAny
	CLC
	ADC.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	BRA.b .Return
.FromLayer1:
	LDA.b !RAM_SMW_Misc_ScratchRAM0B
	REP.b #$20				; A->16
	AND.w #$00FF
	ASL					;\ ooooo to pixels, with the
	ASL					;| flags above shifting up out
	ASL					;| of the way
	ASL					;/
	BIT.w #$0100
	BEQ.b .Forward
	ORA.w #$FF00				;> The values above $10 count back
	CMP.w #$FF00
	BNE.b .Offset
	LDA.w #$0000				;> and $10 puts the layer at the level's top
	BRA.b .Absolute
.Forward:
	AND.w #$00F0
.Offset:
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
.Absolute:
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	LDY.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	JSR.w SMW_LunarMagicLevels_ScaleAny
	EOR.w #$FFFF
	SEC
	ADC.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	STA.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo
.Return:
	SEP.b #$20				; A->8
	REP.b #$10				; XY->16, as found
	RTS

; A position in A scaled by any setting in Y: the eight ratios through
; the scaler below, and every other value as one to one -- which is what
; the tool's own table answers for them at this seam. A 16-bit, XY 8-bit.
SMW_LunarMagicLevels_ScaleAny:
	CPY.b #$00
	BEQ.b .Whole
	CPY.b #!Define_SMW_LunarMagicLevels_FirstUnusedScroll
	BCS.b .Whole
	JMP.w SMW_LunarMagicLevels_Scale
.Whole:
	RTS

; The RAM-initialisation hook in bank $00 lands here, in place of the read
; and compare that decide whether vertical scrolling opens: entered with
; AXY 8-bit and the data bank $00. The main entrance's slippery and water
; flags go into the two the stock init would set from an entrance action;
; a secondary entrance's are its own, not held yet. Then the displaced
; pair, whose flags the hook's branch reads. Y is the caller's -- the
; facing direction it stores after the hook -- so the flags go in through
; X, which the table read has already spent.
SMW_LunarMagicLevels_EntranceFlags:
	LDA.w !RAM_SMW_Flag_UseSecondaryEntrance
	BNE.b .Displaced
	REP.b #$30				; AXY->16
	LDA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	AND.w #$01FF
	TAX
	SEP.b #$20				; A->8
	LDA.l SMW_LunarMagicLevels_Entrance,x
	SEP.b #$10				; XY->8
	BPL.b .NotSlippery
	LDX.b #$80
	STX.b !RAM_SMW_Flag_IceLevel
.NotSlippery:
	BIT.b #!Define_SMW_LunarMagicLevels_Water
	BEQ.b .Displaced
	LDX.b #$01
	STX.b !RAM_SMW_Flag_UnderwaterLevel
.Displaced:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo	;\ The displaced pair, for the
	CMP.b #$C0				;/ branch under the hook
	RTL

; The load-time offset the bank $00 hook lands on, in place of the whole of
; the stock routine: entered by JML over its first two instructions, with
; A 8-bit and XY 8-bit as game mode $11 runs, the data bank $00. Layer 1's
; and Layer 2's starting positions are in their mirrors by now, the two
; settings are final, and the RAM initialisation has faced the player
; right. Three things are settled: which way the player faces and is shot
; out of a pipe, from the main entrance's L; the self-scrolling settings'
; speed and accumulators, for both axes; and the vertical offset -- Layer
; 2's start less Layer 1's start scaled as the stock routine scales it,
; the whole distance for constant, half for medium and an eighth for every
; other setting, which the frame stub adds back to the camera scaled by
; the setting's own ratio every frame. That is the stock game's arithmetic
; and Lunar Magic's, which leaves this routine alone: the slow pair starts
; its background a little higher than it scrolls on every cartridge. A
; setting that never moves the layer leaves the offset alone, since
; nothing reads it; a self-scrolling one starts at the unscaled distance
; and moves it from there; and a relative entrance keeps the offset the
; load placed with the layer. What follows the stock routine's offset --
; the static camera region's start -- is handed back to it.
SMW_LunarMagicLevels_InitialOffset:
	LDA.b #!Define_SMW_LunarMagicLevels_ShootRight
	STA.b !RAM_SMW_LM_Misc_PipeShootDirection
	STZ.b !RAM_SMW_Misc_ScratchRAM0C		;> The main entrance's byte, or none
	LDA.w !RAM_SMW_Flag_UseSecondaryEntrance
	BNE.b .Facing
	REP.b #$30				; AXY->16
	LDA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	AND.w #$01FF
	TAX
	SEP.b #$20				; A->8
	LDA.l SMW_LunarMagicLevels_Background,x
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	SEP.b #$10				; XY->8
	BIT.b #!Define_SMW_LunarMagicLevels_FaceLeft
	BEQ.b .Facing
	STZ.b !RAM_SMW_Player_FacingDirection
	LDA.b #!Define_SMW_LunarMagicLevels_ShootLeft
	STA.b !RAM_SMW_LM_Misc_PipeShootDirection
.Facing:
	REP.b #$20				; A->16, the displaced REP
	LDX.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting
	JSR.w SMW_LunarMagicLevels_Speed
	STA.w !RAM_SMW_L2ScrollSpr_XSpeedLo
	STY.w !RAM_SMW_L2ScrollSpr_CurrentState
	STZ.w !RAM_SMW_L2ScrollSpr_SubXPosLo
	LDX.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	JSR.w SMW_LunarMagicLevels_Speed
	STA.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	STY.w !RAM_SMW_L2ScrollSpr_Timer
	LDY.b !RAM_SMW_Misc_ScratchRAM0C
	BMI.b .Done				;> R: the load placed the offset with the layer
	LDY.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	BEQ.b .Done				;> None: nothing reads the offset
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	CPY.b #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	BCS.b .Scaled				;> Self-scrolling: the whole distance
	CPY.b #$02
	BCC.b .Scaled				;> Constant: the whole distance
	LSR					;> Medium: half
	CPY.b #$03
	BCC.b .Scaled
	LSR					;\ Every other setting an eighth, as
	LSR					;/ the stock routine has it
.Scaled:
	EOR.w #$FFFF				;\ Layer 2's start less that
	INC					;|
	CLC					;|
	ADC.b !RAM_SMW_Mirror_CurrentLayer2YPosLo	;/
	STA.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo
.Done:
	JML.l SMW_GameMode11_LoadSublevel_CODE_00A7B9

; A self-scrolling setting's speed, and the fraction it starts from: X is
; the setting, A 16-bit and XY 8-bit. Returns A the speed in 256ths of a
; pixel a frame -- zero for a setting that does not scroll by itself -- and
; Y the fraction byte the accumulator starts at: zero, or for a speed that
; scrolls back the speed's own low byte, so that the first whole pixel
; comes as many frames in either direction.
SMW_LunarMagicLevels_Speed:
	LDA.w #$0000
	TAY
	CPX.b #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	BCC.b .Return
	CPX.b #!Define_SMW_LunarMagicLevels_FirstSelfScroll+!Define_SMW_LunarMagicLevels_SelfScrollSpeeds
	BCS.b .Return
	TXA
	SEC
	SBC.w #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	ASL					;> Two bytes a speed
	TAX
	LDA.l .Speeds,x
	BPL.b .Return
	TAY					;> The low byte: Y is 8-bit
.Return:
	RTS

.Speeds:
	dw $0040,$0080,$0100,$0200,$0300,$0400
	dw $FFC0,$FF80,$FF00,$FE00,$FD00,$FC00

; The frame placement the bank $00 hook lands on, in place of the stock
; routine's Layer 2 half: entered by JML with A 16-bit and XY 8-bit, the
; data bank $00, Layer 1's new position in its mirror. Each axis in turn:
; a scaled setting places Layer 2 at Layer 1's position scaled, the
; vertical one plus the load's offset; a self-scrolling one steps its
; accumulator -- unless an interactive Layer 2 has the scroll-sprite pass
; do that, or the sprites are frozen, or a scroll sprite of the level's
; own holds the state -- and places the layer at Layer 1 plus what has
; accumulated. Then the stock routine measures the displacements.
SMW_LunarMagicLevels_ScrollLayer2:
	LDY.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting
	BEQ.b .Vertical				;> None: the layer stays put
	CPY.b #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	BCS.b .SelfX
	CPY.b #!Define_SMW_LunarMagicLevels_FirstUnusedScroll
	BCS.b .Vertical
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	JSR.w SMW_LunarMagicLevels_Scale
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
	BRA.b .Vertical
.SelfX:
	JSR.w SMW_LunarMagicLevels_StepsHere
	BCC.b .PlaceX
	JSR.w SMW_LunarMagicLevels_StepX
.PlaceX:
	LDA.w !RAM_SMW_L2ScrollSpr_SubXPosLo
	CLC
	ADC.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2XPosLo
.Vertical:
	LDY.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	BEQ.b .Done
	CPY.b #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	BCS.b .SelfY
	CPY.b #!Define_SMW_LunarMagicLevels_FirstUnusedScroll
	BCS.b .Done
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	JSR.w SMW_LunarMagicLevels_Scale
	BRA.b .PlaceY
.SelfY:
	JSR.w SMW_LunarMagicLevels_StepsHere
	BCC.b .Unscaled
	JSR.w SMW_LunarMagicLevels_StepY
.Unscaled:
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
.PlaceY:
	CLC
	ADC.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
.Done:
	JML.l SMW_HandleStandardLevelCameraScroll_CODE_00F7C2

; Whether the frame placement steps a self-scrolling setting itself:
; carry set to step, clear to leave the accumulator as it is. Not while a
; scroll sprite of the level's own holds the state, not while the sprites
; are frozen, and not in a level whose Layer 2 is interactive and has no
; tide -- there the scroll-sprite pass steps it, so the layer's committed
; position moves too. XY 8-bit; A is not kept.
SMW_LunarMagicLevels_StepsHere:
	CLC
	LDX.w !RAM_SMW_L2ScrollSpr_SpriteID
	BNE.b .Return
	LDX.w !RAM_SMW_Flag_SpritesLocked
	BNE.b .Return
	LDX.b !RAM_SMW_Misc_LevelLayoutFlags
	BPL.b .Steps				;> Layer 2 is a background: step here
	LDX.w !RAM_SMW_Flag_Layer3TideLevel
	BEQ.b .Return
.Steps:
	SEC
.Return:
	RTS

; The scroll-sprite pass the bank $05 hook lands on, in place of the two
; instructions that mark the pass as Layer 2's: entered by JML with AXY
; 8-bit and the data bank $05. A scroll sprite of the level's own takes
; the stock pass. Otherwise a self-scrolling setting in a level whose
; Layer 2 is interactive -- and has no tide, whose pass is Layer 3's --
; steps here while the sprites run and the level is not ending, moving the
; layer's committed position by the same pixels, as a scroll sprite moves
; it; and Layer 2 takes Layer 1's shake for the frame, as the stock scroll
; sprites give it. A level with neither axis self-scrolling has nothing to
; do, which is what the stock pass would have found.
SMW_LunarMagicLevels_AutoScroll:
	LDA.b #$04				;\ The displaced pair: this
	STA.w !RAM_SMW_ScrollSpr_LayerIndex	;/ pass is Layer 2's
	LDA.w !RAM_SMW_L2ScrollSpr_SpriteID
	BNE.b .Sprite
	LDA.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting
	CMP.b #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	BCS.b .Self
	LDA.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	CMP.b #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	BCC.b .Return
.Self:
	LDA.b !RAM_SMW_Misc_LevelLayoutFlags
	BPL.b .Return				;> A background: the frame placement steps it
	LDA.w !RAM_SMW_Flag_Layer3TideLevel
	ORA.w !RAM_SMW_Flag_SpritesLocked
	ORA.w !RAM_SMW_Timer_EndLevel
	BNE.b .Return
	REP.b #$20				; A->16
	LDA.w !RAM_SMW_Flag_Layer2HorizontalScrollLevelSetting
	AND.w #$00FF
	CMP.w #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	BCC.b .Y
	JSR.w SMW_LunarMagicLevels_StepX
	CLC
	ADC.w !RAM_SMW_Misc_Layer2XPosLo
	STA.w !RAM_SMW_Misc_Layer2XPosLo
.Y:
	LDA.w !RAM_SMW_Flag_Layer2VerticalScrollLevelSetting
	AND.w #$00FF
	CMP.w #!Define_SMW_LunarMagicLevels_FirstSelfScroll
	BCC.b .Shake
	JSR.w SMW_LunarMagicLevels_StepY
	CLC
	ADC.w !RAM_SMW_Misc_Layer2YPosLo
	STA.w !RAM_SMW_Misc_Layer2YPosLo
.Shake:
	LDA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	CLC
	ADC.w !RAM_SMW_ShakingLayer1DispYLo
	STA.b !RAM_SMW_Mirror_CurrentLayer2YPosLo
	SEP.b #$20				; A->8
.Return:
	JML.l SMW_ProcessScrollSprites_Return
.Sprite:
	JML.l SMW_ProcessScrollSprites_Layer2_Continue

; One frame of a self-scrolling axis: the speed into the fraction byte,
; the whole pixels that carried out added to what has accumulated, and
; returned in A. A 16-bit and XY 8-bit, so the fraction is one byte both
; ways and the carry is what the word's high byte holds, sign and all.
; Horizontal accumulates in the scroll sprites' sub-position; vertical in
; the load's offset, which the frame placement adds to Layer 1 either way.
SMW_LunarMagicLevels_StepX:
	LDX.w !RAM_SMW_L2ScrollSpr_CurrentState
	TXA
	CLC
	ADC.w !RAM_SMW_L2ScrollSpr_XSpeedLo
	TAX
	STX.w !RAM_SMW_L2ScrollSpr_CurrentState
	JSR.w SMW_LunarMagicLevels_WholePixels
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	CLC
	ADC.w !RAM_SMW_L2ScrollSpr_SubXPosLo
	STA.w !RAM_SMW_L2ScrollSpr_SubXPosLo
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	RTS

SMW_LunarMagicLevels_StepY:
	LDX.w !RAM_SMW_L2ScrollSpr_Timer
	TXA
	CLC
	ADC.w !RAM_SMW_L2ScrollSpr_YSpeedLo
	TAX
	STX.w !RAM_SMW_L2ScrollSpr_Timer
	JSR.w SMW_LunarMagicLevels_WholePixels
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	CLC
	ADC.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo
	STA.w !RAM_SMW_Camera_Layer2YPosRelativeToLayer1Lo
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	RTS

; The high byte of the sum in A as a signed word: the pixels that carried
; out of the fraction this frame.
SMW_LunarMagicLevels_WholePixels:
	AND.w #$FF00
	BPL.b .Forward
	ORA.w #$00FF
.Forward:
	XBA
	RTS

; A position in A scaled by the setting in Y, one of $01-$08: a shift for
; seven of them, six fifths for the eighth. A 16-bit, XY 8-bit; X is kept,
; and the scratch words at $06 and $0C are the only things touched.
SMW_LunarMagicLevels_Scale:
	CPY.b #!Define_SMW_LunarMagicLevels_FastScroll
	BEQ.b .Fast
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	PHX
	TYX
	SEP.b #$20				; A->8
	LDA.l .Shifts,x
	TAX
	REP.b #$20				; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
.Shift:
	DEX
	BMI.b .Shifted
	LSR
	BRA.b .Shift
.Shifted:
	PLX
	RTS

; How many places each setting shifts: none for constant, then medium,
; slow, medium 2, medium 3, medium 4 and slow 2 in the order the settings
; are numbered. The first entry is none's and is never reached.
.Shifts:
	db $00,$00,$01,$05,$02,$03,$04,$06

; Six fifths: the position plus a fifth of it, the fifth by shift and
; subtract over the sixteen bits. Not the divider: under SA-1 Pack the load
; reaches this on the S-CPU and the frame on the SA-1, and neither CPU has
; the other's, where a loop any 65816 runs alike costs a few hundred cycles
; a frame. The dividend shifts out of the scratch word as the quotient
; shifts in behind it.
.Fast:
	STA.b !RAM_SMW_Misc_ScratchRAM0C	;> The position, added back at the end
	STA.b !RAM_SMW_Misc_ScratchRAM06	;> The dividend, then the quotient
	PHX
	LDX.b #$10
	LDA.w #$0000				;> The remainder
.Bit:
	ASL.b !RAM_SMW_Misc_ScratchRAM06	;> The next dividend bit, into the carry
	ROL					;> and into the remainder
	CMP.w #$0005
	BCC.b .Under
	SBC.w #$0005
	INC.b !RAM_SMW_Misc_ScratchRAM06	;> A quotient bit, in the slot the shift opened
.Under:
	DEX
	BNE.b .Bit
	PLX
	LDA.b !RAM_SMW_Misc_ScratchRAM06	;> The quotient
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0C
	RTS

	assert pc() == SMW_LunarMagicLevels_Entrance+!Define_SMW_Block_LunarMagicLevels, "The Lunar Magic tables' block is not the size Config/PackedRuns.asm states. The palettes behind it are read past the same figure, so pin the new figure in Define_SMW_Block_LunarMagicLevels."
endif
endmacro
