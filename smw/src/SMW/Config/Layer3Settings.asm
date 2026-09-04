includeonce

;#############################################################################################################
;# Per-level Layer 3: how a level's Layer 3 scrolls, where it starts, and
;# which screen it is drawn on.
;#
;# The stock game gives a level no say in any of it. Which Layer 3 image
;# loads is the tileset's and the secondary header's between them, and how
;# it behaves comes with the image: a tide rises and falls, a
;# tileset-specific background either auto-scrolls at one fixed speed or --
;# in tilesets 1 and 3 alone -- tracks half of Layer 1's X, and everything
;# else is nailed down and the scroll routine is switched off outright
;# (SMW_InitializeLevelLayer3_Main, Banks/Bank00.asm; SMW_ScrollLayer3_Main,
;# Banks/Bank05.asm). Two levels sharing a tileset share all of it.
;#
;# Setting !Define_SMW_Layer3Settings to !TRUE gives every level four bytes
;# of its own, in four $200-byte tables in the level bank, one fragment per
;# byte under levels/properties/:
;#
;# - layer3-horizontal.asm, EC-hhhhh: E turns the level's settings on at
;#   all, C draws Layer 3 through the colour-maths window, hhhhh is the
;#   horizontal scroll setting.
;# - layer3-vertical.asm, S--vvvvv: S moves Layer 3 to the subscreen, so it
;#   is drawn behind the layers on the main screen; vvvvv is the vertical
;#   scroll setting.
;# - layer3-offset-x.asm and layer3-offset-y.asm: where the layer starts,
;#   one signed byte each in 16x16 tiles -- an offset from Layer 1 for a
;#   setting that follows it, and the position outright for one that does
;#   not.
;#
;# Every row ships as $00, so the tables with nothing edited change nothing
;# a stock level does.
;#
;# **A setting is one of thirty-two, the same thirty-two the Layer 2 scroll
;# byte names** (Config/LunarMagicLevels.asm), and with the same meanings:
;#
;#   $00  none: the layer stays where the offset put it
;#   $01  constant, 1:1               $05  1:8
;#   $02  1:2                         $06  1:16
;#   $03  1:32                        $07  1:64
;#   $04  1:4                         $08  6:5, faster than Layer 1
;#   $09-$0F  none
;#   $10-$15  the layer scrolls by itself, $40, $80, $100, $200, $300, $400
;#            256ths of a pixel a frame, rightwards or downwards
;#   $16-$1B  the same six, leftwards or upwards
;#   $1C-$1F  the layer scrolls by itself at no speed
;#
;# **A tide level keeps its tide.** The rising and falling tides are Layer 3
;# with interaction underneath, driven by their own frame code and their own
;# state, and taking that over is a different job from placing a background:
;# a level whose Layer 3 is a tide (!RAM_SMW_Flag_Layer3TideLevel) ignores
;# these tables outright, whatever they say.
;#
;# Two hooks, each exactly one JML over instructions of the same size:
;#
;# - SMW_InitializeLevelLayer3 (Banks/Bank00.asm, CODE_00A01F), after the
;#   stock load has decided the image's behaviour and before it uploads the
;#   image itself: the level's settings go over the colour maths, the screen
;#   Layer 3 is drawn on and the scroll switch, the layer is placed where
;#   its offsets say, and the stock upload runs as it was going to.
;# - SMW_ScrollLayer3 (Banks/Bank05.asm, Main), the once-a-frame placement:
;#   a level with settings of its own is placed by them and the stock
;#   routine does not run at all.
;#
;# A self-scrolling axis keeps the fraction of a pixel it has accumulated in
;# !RAM_SMW_Misc_Layer3XSpeedLo and !RAM_SMW_Misc_Layer3YSpeedLo, which is
;# where the stock routine keeps the tide's speeds -- free here, since a
;# tide level is the one kind these tables do not touch.
;#
;# The block is one occupant of the level bank, behind the Lunar Magic
;# tables and ahead of the custom palettes (Config/LevelBank.asm), and reads
;# the loading level out of the shared stash (Config/LevelNumberStash.asm).
;# The define needs a cartridge assembled at 1 MB or larger, which the
;# bank's reservation says rather than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_Layer3Settings=1 turns the tables on.
if defined("Define_SMW_Layer3Settings") == 0
	!Define_SMW_Layer3Settings = !FALSE
endif

; The four tables, one byte per level each. What the whole block comes to --
; these and the stubs behind them -- is !Define_SMW_Block_Layer3Settings,
; declared with every other block in Config/PackedRuns.asm because the
; palettes behind it are read past the same figure and the editor prices the
; bank against it. The placement asserts what it emitted against it.
!Define_SMW_Layer3SettingsTableBytes	#= $0200

; The horizontal byte's bits, and the vertical byte's.
!Define_SMW_Layer3Settings_Enabled	= $80	;> E: the level places Layer 3 itself
!Define_SMW_Layer3Settings_ColorMath	= $40	;> C: Layer 3 through the colour maths
!Define_SMW_Layer3Settings_Subscreen	= $80	;> S: Layer 3 on the subscreen
!Define_SMW_Layer3Settings_Setting	= $1F	;> hhhhh, vvvvv: the scroll settings

; The settings' bands, as the Layer 2 scroll byte numbers them.
!Define_SMW_Layer3Settings_FastScroll		= $08	;> 6:5, the one ratio that is not a shift
!Define_SMW_Layer3Settings_FirstUnusedScroll	= $09	;> $09-$0F scroll not at all
!Define_SMW_Layer3Settings_FirstSelfScroll	= $10	;> $10 up scroll by themselves
!Define_SMW_Layer3Settings_SelfScrollSpeeds	= $0C	;> six speeds each way

; A tile, in pixels: the unit both offsets are counted in.
!Define_SMW_Layer3Settings_TileShift	= $04

; Layer 3's bit in the colour-maths register and in the two screen-layer
; registers alike -- BG3 is bit 2 of each.
!Define_SMW_Layer3Settings_Layer3Bit	= $04

;#############################################################################################################
;# Where they go: behind the Lunar Magic tables' block, or the per-level
;# code's, or the level graphics', or at the packed head --
;# Config/LevelBank.asm works the address out -- and ahead of the custom
;# palettes, whose blobs are the packed head's growing end.
;#############################################################################################################

; Place the four tables and the stubs. Called from %SMW_PlaceLevelBank
; behind the Lunar Magic tables' block.
macro SMW_PlaceLayer3Settings()
if !Define_SMW_Layer3Settings == !TRUE
	assert pc() == !Loc_SMW_LevelBank_Layer3, "The Layer 3 tables must follow the Lunar Magic tables, the per-level code, the level graphics, or lead the level bank: they have to sit at one address per cartridge."

; The four tables, each a fragment the editor writes rows into.
namespace SMW_Layer3Settings
	incsrc "levels/properties/layer3-horizontal.asm"
	assert pc() == SMW_Layer3Settings_Horizontal+!Define_SMW_Layer3SettingsTableBytes, "The Layer 3 horizontal table is not $200 rows. Check levels/properties/layer3-horizontal.asm."
	incsrc "levels/properties/layer3-vertical.asm"
	assert pc() == SMW_Layer3Settings_Vertical+!Define_SMW_Layer3SettingsTableBytes, "The Layer 3 vertical table is not $200 rows. Check levels/properties/layer3-vertical.asm."
	incsrc "levels/properties/layer3-offset-x.asm"
	assert pc() == SMW_Layer3Settings_OffsetX+!Define_SMW_Layer3SettingsTableBytes, "The Layer 3 X offset table is not $200 rows. Check levels/properties/layer3-offset-x.asm."
	incsrc "levels/properties/layer3-offset-y.asm"
	assert pc() == SMW_Layer3Settings_OffsetY+!Define_SMW_Layer3SettingsTableBytes, "The Layer 3 Y offset table is not $200 rows. Check levels/properties/layer3-offset-y.asm."
namespace off

;#############################################################################################################
;# The load hook.
;#############################################################################################################

; The bank $00 hook lands here, in place of the read and the branch that
; decide whether an image is uploaded -- after the stock load has set the
; Y position, the colour maths and the scroll switch from the image's own
; behaviour, and before the upload itself. Entered with A, X and Y 8-bit
; and the data bank mirroring work RAM. A level with settings of its own
; has them applied here; either way the stock upload runs as it was going
; to.
SMW_Layer3Settings_Init:
	LDA.w !RAM_SMW_Flag_Layer3TideLevel	;\ A tide is driven by its own
	BNE.b .Stock				;/ frame code and is left to it
	JSR.w SMW_Layer3Settings_Level		;> X the level, A its horizontal byte
	BPL.b .Placed				;> E clear: the level says nothing
	STZ.w !RAM_SMW_Flag_DisableLayer3Scroll	;> The frame stub places the layer
	STZ.w !RAM_SMW_Misc_Layer3XSpeedLo	;\ Nothing accumulated yet
	STZ.w !RAM_SMW_Misc_Layer3YSpeedLo	;/
	LDA.b #!Define_SMW_Layer3Settings_Layer3Bit
	TRB.b !RAM_SMW_Mirror_ColorMathSelectAndEnable	;> Off unless the level asks
	LDA.l SMW_Layer3Settings_Horizontal,x
	BIT.b #!Define_SMW_Layer3Settings_ColorMath
	BEQ.b .NoColorMath
	LDA.b #!Define_SMW_Layer3Settings_Layer3Bit
	TSB.b !RAM_SMW_Mirror_ColorMathSelectAndEnable
.NoColorMath:
	LDA.l SMW_Layer3Settings_Vertical,x
	BPL.b .MainScreen
	LDA.b #!Define_SMW_Layer3Settings_Layer3Bit	;\ S: drawn behind whatever
	TRB.w !RAM_SMW_Mirror_MainScreenLayers		;| the main screen holds
	TSB.w !RAM_SMW_Mirror_SubScreenLayers		;/
.MainScreen:
	JSR.w SMW_Layer3Settings_Start		;> Where the offsets say the layer starts
	JSR.w SMW_Layer3Settings_Place		;> ...and where this frame puts it
.Placed:
	SEP.b #$10				; XY->8
.Stock:
	LDA.w !RAM_SMW_Misc_LevelLayer3Settings	;\ The displaced read and branch:
	BNE.b .Image				;| a level with no Layer 3 image
	JML.l SMW_InitializeLevelLayer3_Return00A044	;/ uploads none
.Image:
	JML.l SMW_InitializeLevelLayer3_UploadImage

;#############################################################################################################
;# The frame hook.
;#############################################################################################################

; The bank $05 hook lands here, in place of the read and the branch at the
; head of the stock scroll routine. Entered with A, X and Y 8-bit and the
; data bank $05, once a frame, with Layer 1 already moved. A level with
; settings of its own is placed by them and the stock routine does not run;
; every other level is handed straight back to it.
SMW_Layer3Settings_Scroll:
	LDA.w !RAM_SMW_Flag_Layer3TideLevel
	BNE.b .Tide
	JSR.w SMW_Layer3Settings_Level		;> X the level, A its horizontal byte
	BPL.b .Stock				;> E clear: the stock routine's job
	JSR.w SMW_Layer3Settings_Place
	SEP.b #$10				; XY->8
	JML.l SMW_ScrollLayer3_CODE_05C491	;> The stock tail: the SEP and the RTS
.Stock:
	SEP.b #$10				; XY->8
	JML.l SMW_ScrollLayer3_CODE_05C414	;> The displaced branch, not taken
.Tide:
	JML.l SMW_ScrollLayer3_Layer3Tide	;> ...and taken

;#############################################################################################################
;# The placement.
;#############################################################################################################

; The loading level and what it says: X 16-bit the level, A 8-bit its
; horizontal byte, whose high bit is E. The index registers are left wide,
; because the tables are read with them; a caller returning to stock code
; narrows them again.
SMW_Layer3Settings_Level:
	REP.b #$30				; AXY->16
	LDA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	AND.w #$01FF
	TAX
	SEP.b #$20				; A->8
	LDA.l SMW_Layer3Settings_Horizontal,x
	RTS

; Where the level's offsets put Layer 3 outright, both axes, with no
; account taken of Layer 1: what the load writes so that a self-scrolling
; axis has somewhere to accumulate from. A 8-bit, X 16-bit the level.
SMW_Layer3Settings_Start:
	LDA.l SMW_Layer3Settings_OffsetX,x
	JSR.w SMW_Layer3Settings_Offset
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	SEP.b #$20				; A->8
	LDA.l SMW_Layer3Settings_OffsetY,x
	JSR.w SMW_Layer3Settings_Offset
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
	SEP.b #$20				; A->8
	RTS

; Layer 3 where the level's settings put it this frame, both axes. A 8-bit,
; X 16-bit the level, and A 8-bit on return.
SMW_Layer3Settings_Place:
	LDA.l SMW_Layer3Settings_Horizontal,x
	AND.b #!Define_SMW_Layer3Settings_Setting
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM03	;> The setting is read as a word
	LDA.l SMW_Layer3Settings_OffsetX,x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Misc_Layer3XSpeedLo	;\ The fraction of a pixel a
	STA.b !RAM_SMW_Misc_ScratchRAM06	;| self-scrolling axis has
	STZ.b !RAM_SMW_Misc_ScratchRAM07	;/ accumulated
	REP.b #$20				; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Mirror_Layer3XPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM08
	SEP.b #$20				; A->8
	JSR.w SMW_Layer3Settings_Axis
	STA.b !RAM_SMW_Mirror_Layer3XPosLo
	SEP.b #$20				; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !RAM_SMW_Misc_Layer3XSpeedLo
	LDA.l SMW_Layer3Settings_Vertical,x
	AND.b #!Define_SMW_Layer3Settings_Setting
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM03
	LDA.l SMW_Layer3Settings_OffsetY,x
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	LDA.w !RAM_SMW_Misc_Layer3YSpeedLo
	STA.b !RAM_SMW_Misc_ScratchRAM06
	STZ.b !RAM_SMW_Misc_ScratchRAM07
	REP.b #$20				; A->16
	LDA.b !RAM_SMW_Mirror_CurrentLayer1YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM04
	LDA.b !RAM_SMW_Mirror_Layer3YPosLo
	STA.b !RAM_SMW_Misc_ScratchRAM08
	SEP.b #$20				; A->8
	JSR.w SMW_Layer3Settings_Axis
	STA.b !RAM_SMW_Mirror_Layer3YPosLo
	SEP.b #$20				; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM06
	STA.w !RAM_SMW_Misc_Layer3YSpeedLo
	RTS

; One axis: A 8-bit in, A 16-bit out with the position the layer takes.
; $02 is the setting, $0A the offset in tiles, $04 Layer 1's position on
; this axis, $06 the fraction accumulated so far and $08 the layer's own
; position -- which only a self-scrolling axis reads, so the scaled path
; borrows the pair for the offset it adds. A setting that follows Layer 1 places the layer at Layer 1
; scaled plus the offset; one that does not places it at the offset
; outright; a self-scrolling one steps the fraction and moves the layer by
; the whole pixels that came of it.
SMW_Layer3Settings_Axis:
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	CMP.b #!Define_SMW_Layer3Settings_FirstSelfScroll
	BCS.b .Self
	CMP.b #!Define_SMW_Layer3Settings_FirstUnusedScroll
	BCS.b .Fixed
	CMP.b #$01
	BCC.b .Fixed				;> None
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	JSR.w SMW_Layer3Settings_Offset		;> A->16: the offset, in pixels
	STA.b !RAM_SMW_Misc_ScratchRAM08
	LDA.b !RAM_SMW_Misc_ScratchRAM04	;> Layer 1's position, scaled
	JSR.w SMW_Layer3Settings_Scale
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM08
	RTS
.Fixed:
	LDA.b !RAM_SMW_Misc_ScratchRAM0A
	JMP.w SMW_Layer3Settings_Offset
.Self:
	JSR.w SMW_Layer3Settings_Speed		;> A 16-bit, 256ths of a pixel a frame
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM06
	PHA
	AND.w #$00FF				;\ What is left over, under a
	STA.b !RAM_SMW_Misc_ScratchRAM06	;/ high byte the AND cleared
	PLA
	XBA					;\ The whole pixels, signed
	AND.w #$00FF				;|
	CMP.w #$0080				;|
	BCC.b .Forwards				;|
	ORA.w #$FF00				;/
.Forwards:
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM08	;> ...on from where the layer is
	RTS

; An offset in tiles, as pixels: A 8-bit and signed in, A 16-bit out.
SMW_Layer3Settings_Offset:
	REP.b #$20				; A->16
	AND.w #$00FF
	CMP.w #$0080
	BCC.b .Forwards
	ORA.w #$FF00
.Forwards:
	ASL					;\ Sixteen pixels a tile
	ASL					;|
	ASL					;|
	ASL					;/
	RTS

; Layer 1's position scaled by the setting in $02: A 16-bit in and out, the
; setting one of $01-$08. Every ratio but one is a shift; six fifths is the
; position plus a fifth of it, the fifth by shift and subtract over the
; sixteen bits -- not the divider, since under SA-1 Pack the load reaches
; this on the S-CPU and the frame on the SA-1 and neither has the other's.
; The dividend shifts out of the scratch word as the quotient shifts in
; behind it.
SMW_Layer3Settings_Scale:
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM02
	CPX.w #!Define_SMW_Layer3Settings_FastScroll
	BEQ.b .Fast
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	SEP.b #$20				; A->8
	LDA.l .Shifts,x
	REP.b #$20				; A->16
	AND.w #$00FF				;> The shift count, into a wide X
	TAX
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
.Shift:
	DEX
	BMI.b .Shifted
	LSR
	BRA.b .Shift
.Shifted:
	PLX
	RTS

; How many places each setting shifts: none for constant, then 1:2, 1:32,
; 1:4, 1:8, 1:16 and 1:64 in the order the settings are numbered. The first
; entry is none's and is never reached.
.Shifts:
	db $00,$00,$01,$05,$02,$03,$04,$06

.Fast:
	STA.b !RAM_SMW_Misc_ScratchRAM0C	;> The position, added back at the end
	STA.b !RAM_SMW_Misc_ScratchRAM0E	;> The dividend, then the quotient
	LDX.w #$0010
	LDA.w #$0000				;> The remainder
.Bit:
	ASL.b !RAM_SMW_Misc_ScratchRAM0E	;> The next dividend bit, into the carry
	ROL					;> and into the remainder
	CMP.w #$0005
	BCC.b .Under
	SBC.w #$0005
	INC.b !RAM_SMW_Misc_ScratchRAM0E	;> A quotient bit, in the slot the shift opened
.Under:
	DEX
	BNE.b .Bit
	LDA.b !RAM_SMW_Misc_ScratchRAM0E
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM0C
	PLX
	RTS

; A self-scrolling setting's speed in 256ths of a pixel a frame: the
; setting in $02, A 8-bit in and 16-bit out, zero for the four settings
; that scroll by themselves at no speed.
SMW_Layer3Settings_Speed:
	PHX
	LDA.b !RAM_SMW_Misc_ScratchRAM02
	SEC
	SBC.b #!Define_SMW_Layer3Settings_FirstSelfScroll
	CMP.b #!Define_SMW_Layer3Settings_SelfScrollSpeeds
	BCS.b .Still
	ASL					;> Two bytes a speed
	REP.b #$20				; A->16
	AND.w #$00FF
	TAX
	LDA.l .Speeds,x
	PLX
	RTS
.Still:
	REP.b #$20				; A->16
	LDA.w #$0000
	PLX
	RTS

.Speeds:
	dw $0040,$0080,$0100,$0200,$0300,$0400
	dw $FFC0,$FF80,$FF00,$FE00,$FD00,$FC00

	assert pc()-SMW_Layer3Settings_Horizontal == !Define_SMW_Block_Layer3Settings, "The Layer 3 settings' block is not the size Config/PackedRuns.asm states. The palettes behind it are read past it, so pin the new figure in Define_SMW_Block_Layer3Settings."
	assert pc() <= !Loc_SMW_LevelBank_RunEnd, "The Layer 3 settings have outgrown the level bank."
endif
endmacro
