;####################################################################
;# Bank07.asm -- level data and Map16 tiles.
;#
;# 16 macro definitions. These emit nothing on their own: the ROM map
;# in RomMap/ invokes them, and its order decides the ROM layout.
;####################################################################


;#############################################################################################################
;#############################################################################################################

macro SMWBank07Macros(StartBank, EndBank)
%BANK_START(<StartBank>)
DATATABLE_RT03_SMW_LevelData:	%DATATABLE_RT03_SMW_LevelData(NULLROM)						; $078000
INLINEDATATABLE_RT29_SMW_EmptySpace:	%INLINEDATATABLE_RT29_SMW_EmptySpace(NULLROM)					; $0780ED
DATATABLE_RT04_SMW_LevelData:	%DATATABLE_RT04_SMW_LevelData(NULLROM)						; $078100
INLINEDATATABLE_RT30_SMW_EmptySpace:	%INLINEDATATABLE_RT30_SMW_EmptySpace(NULLROM)					; $07A179
DATATABLE_RT05_SMW_LevelData:	%DATATABLE_RT05_SMW_LevelData(NULLROM)						; $07A600
INLINEDATATABLE_RT31_SMW_EmptySpace:	%INLINEDATATABLE_RT31_SMW_EmptySpace(NULLROM)					; $07C226
DATATABLE_RT06_SMW_LevelData:	%DATATABLE_RT06_SMW_LevelData(NULLROM)						; $07C300
INLINEDATATABLE_RT32_SMW_EmptySpace:	%INLINEDATATABLE_RT32_SMW_EmptySpace(NULLROM)					; $07E76F
ROUTINE_RT02_SMW_ProcessNormalSprites:	%ROUTINE_RT02_SMW_ProcessNormalSprites(NULLROM)				; $07F000
ROUTINE_RT01_SMW_NorSpr07B_GoalTape_Status08:	%ROUTINE_RT01_SMW_NorSpr07B_GoalTape_Status08(NULLROM)				; $07F0C8
ROUTINE_SMW_InitializeNormalSpriteRAMTables:	%ROUTINE_SMW_InitializeNormalSpriteRAMTables(NULLROM)				; $07F26C
DATATABLE_SMW_CircleCoordinates:	%DATATABLE_SMW_CircleCoordinates(NULLROM)					; $07F7DB
DATATABLE_SMW_LineGuideSpeedTable:	%DATATABLE_SMW_LineGuideSpeedTable(NULLROM)					; $07F9DB
ROUTINE_SMW_SpawnSpinJumpStars:	%ROUTINE_SMW_SpawnSpinJumpStars(NULLROM)					; $07FC33
INLINEDATATABLE_RT33_SMW_EmptySpace:	%INLINEDATATABLE_RT33_SMW_EmptySpace(NULLROM)					; $07FC90
%BANK_END(<EndBank>)
endmacro

macro ROUTINE_RT02_SMW_ProcessNormalSprites(Address)
namespace SMW_ProcessNormalSprites
%InsertMacroAtXPosition(<Address>)

NormalSpriteOAMIndexes:
base $000000
; Table of sprite OAM indexes. It is indexed by the values in the table at
; $07F0B4 and used in the routine at $0180D2.
.SpriteMemory00:
.SpriteMemory06:
.SpriteMemory0F:
.SpriteMemory12:
	db $30,$44,$58,$6C,$80,$94,$A8,$BC
	db $D0,$E4,$28,$2C

.SpriteMemory01:
.SpriteMemory11:
	db $80,$94,$A8,$BC,$D0,$E4,$30,$58
	db $00,$00,$28,$2C

.SpriteMemory02:
	db $30,$54,$64,$74,$84,$94,$A4,$B4
	db $00,$00,$28,$2C

.SpriteMemory03:
	db $30,$54,$78,$8C,$A0,$B4,$C8,$DC
	db $F0,$F8,$28,$2C

.SpriteMemory04:
	db $30,$74,$88,$9C,$B0,$C4,$D8,$EC
	db $F8,$FC,$28,$2C

.SpriteMemory05:
	db $30,$84,$D8,$E0,$E8,$F0,$F8,$00
	db $00,$00,$28,$2C

.SpriteMemory07:
	db $00,$60,$74,$88,$9C,$B0,$C4,$00
	db $00,$00,$28,$2C

.SpriteMemory08:
	db $30,$44,$58,$6C,$80,$94,$A8,$00
	db $00,$00,$28,$2C

.SpriteMemory09:
	db $A0,$30,$34,$38,$3C,$40,$44,$48
	db $4C,$50,$28,$2C

.SpriteMemory0A:
	db $30,$48,$60,$78,$8C,$A0,$B4,$C8
	db $DC,$00,$28,$2C

.SpriteMemory0B:
	db $58,$AC,$C0,$D4,$E8,$00,$00,$00
	db $00,$00,$28,$2C

.SpriteMemory0C:
	db $58,$6C,$80,$94,$A8,$BC,$D0,$E4
	db $00,$00,$28,$2C

.SpriteMemory0D:
	db $30,$74,$B8,$C4,$D0,$DC,$E8,$F4
	db $00,$00,$28,$2C

.SpriteMemory0E:
	db $30,$48,$60,$78,$90,$A8,$C0,$D8
	db $00,$00,$28,$2C

.SpriteMemory10:
	db $30,$44,$58,$5C,$60,$64,$68,$6C
	db $70,$00,$28,$2C

.SpriteMemory13:
base off

; Indexes to the table at $07F000. This table itself is indexed by the
; sprite memory setting plus the sprite index.
DATA_07F0B4:
	db NormalSpriteOAMIndexes_SpriteMemory00,NormalSpriteOAMIndexes_SpriteMemory01,NormalSpriteOAMIndexes_SpriteMemory02
	db NormalSpriteOAMIndexes_SpriteMemory03,NormalSpriteOAMIndexes_SpriteMemory04,NormalSpriteOAMIndexes_SpriteMemory05
	db NormalSpriteOAMIndexes_SpriteMemory06,NormalSpriteOAMIndexes_SpriteMemory07,NormalSpriteOAMIndexes_SpriteMemory08
	db NormalSpriteOAMIndexes_SpriteMemory09,NormalSpriteOAMIndexes_SpriteMemory0A,NormalSpriteOAMIndexes_SpriteMemory0B
	db NormalSpriteOAMIndexes_SpriteMemory0C,NormalSpriteOAMIndexes_SpriteMemory0D,NormalSpriteOAMIndexes_SpriteMemory0E
	db NormalSpriteOAMIndexes_SpriteMemory0F,NormalSpriteOAMIndexes_SpriteMemory10,NormalSpriteOAMIndexes_SpriteMemory11
	db NormalSpriteOAMIndexes_SpriteMemory12,NormalSpriteOAMIndexes_SpriteMemory13
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_InitializeNormalSpriteRAMTables(Address)
namespace SMW_InitializeNormalSpriteRAMTables
%InsertMacroAtXPosition(<Address>)

incsrc "sprites/SpriteProperties.asm"

; Zeros out the sprite tables. However, $15A0 (the horizontal off screen
; flag) is set to $01 instead of zero.
ClearTables:
	STZ.w !RAM_SMW_NorSpr_Table7E164A,x
	STZ.w !RAM_SMW_NorSpr_CurrentLayerPriority,x 
	STZ.b !RAM_SMW_NorSpr_Table7E00C2,x
	STZ.w !RAM_SMW_NorSpr_Table7E151C,x
	STZ.w !RAM_SMW_NorSpr_Table7E1528,x
	STZ.w !RAM_SMW_NorSpr_Table7E1534,x
	STZ.w !RAM_SMW_NorSpr_Table7E157C,x
	STZ.w !RAM_SMW_NorSpr_LevelCollisionFlags,x
	STZ.w !RAM_SMW_NorSpr_Table7E15C4,x
	STZ.w !RAM_SMW_NorSpr_Table7E1602,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E1540,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E154C,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E1558,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E1564,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E1FE2,x
	STZ.w !RAM_SMW_NorSpr_Table7E1626,x
	STZ.w !RAM_SMW_NorSpr_Table7E1570,x
	STZ.b !RAM_SMW_NorSpr_XSpeed,x	; Sprite X Speed = 0
	STZ.w !RAM_SMW_NorSpr_SubXPos,x
	STZ.b !RAM_SMW_NorSpr_YSpeed,x	; Sprite Y Speed = 0
	STZ.w !RAM_SMW_NorSpr_SubYPos,x
	STZ.w !RAM_SMW_NorSpr_NoLevelCollisionFlag,x
	STZ.w !RAM_SMW_NorSpr_OnYoshisTongue,x
	STZ.w !RAM_SMW_NorSpr_DecrementingTable7E163E,x
	STZ.w !RAM_SMW_NorSpr_PropertyBits1656,x			;\ Optimization: Unnecessary, as these tables are given new values shortly after
	STZ.w !RAM_SMW_NorSpr_PropertyBits1662,x			;| ClearTables is not called elsewhere besides in this macro
	STZ.w !RAM_SMW_NorSpr_PropertyBits166E,x			;|
	STZ.w !RAM_SMW_NorSpr_PropertyBits167A,x			;|
	STZ.w !RAM_SMW_NorSpr_PropertyBits1686,x			;/
	STZ.w !RAM_SMW_NorSpr_Table7E187B,x
	STZ.w !RAM_SMW_NorSpr_Table7E160E,x
	STZ.w !RAM_SMW_NorSpr_Table7E1594,x
	STZ.w !RAM_SMW_NorSpr_Table7E1504,x
	STZ.w !RAM_SMW_NorSpr_UnusedTable7E1FD6,x			; Optimization: Unused
	LDA.b #$01
	STA.w !RAM_SMW_NorSpr_XOffscreenFlag,x 
	RTL

; The subroutine that loads the necessary bytes for some sprite tables.
; Actually just JSLs to $07F7A0 and sets $15F6,x.
YXPPCCCTAndPropertyTables:
	PHY								; Optimization: There is no need to preserve Y when it's not modified here
	PHX
	LDA.b !RAM_SMW_NorSpr_SpriteID,x
	TAX
	LDA.l Sprite166EVals,x
	AND.b #!Define_SMW_NorSpr_166EProp_Palette|!Define_SMW_NorSpr_166EProp_UseSP3And4
	PLX
	STA.w !RAM_SMW_NorSpr_YXPPCCCT,x
	JSL.l SMW_InitializeNormalSpriteRAMTables_PropertyTables
	PLY
	RTL

; The subroutine that loads the six Tweaker bytes for a sprite when it is
; initialized.
PropertyTables:								; Optimization: This routine can be fused with the above one to save a few bytes
	PHY								; Both because of the removed JSL.l/RTL, but also from removing 1 set of PHX/PHY/PLY/PLX
	PHX								; However, there is one place where SMW_InitializeNormalSpriteRAMTables_PropertyTables is called outside here, so that would need to be modified
	TXY
	LDX.b !RAM_SMW_NorSpr_SpriteID,y
	LDA.l Sprite1656Vals,x
	STA.w !RAM_SMW_NorSpr_PropertyBits1656,y
	LDA.l Sprite1662Vals,x
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,y
	LDA.l Sprite166EVals,x
	STA.w !RAM_SMW_NorSpr_PropertyBits166E,y
	LDA.l Sprite167AVals,x
	STA.w !RAM_SMW_NorSpr_PropertyBits167A,y
	LDA.l Sprite1686Vals,x
	STA.w !RAM_SMW_NorSpr_PropertyBits1686,y
	LDA.l Sprite190FVals,x
	STA.w !RAM_SMW_NorSpr_PropertyBits190F,y
	PLX
	PLY
	RTL

; Resets most sprite tables and loads new values for some of them depending
; on the sprite number. Actually just JSLs to $07F722 and $07F78B.
Main:									; Optimization: This routine can be moved to before ClearTables and have all the routines here execute in sequence.
	JSL.l ClearTables						; ClearTables is not called anywhere outside of here, so its RTL can be removed.
	JSL.l YXPPCCCTAndPropertyTables
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro ROUTINE_SMW_SpawnSpinJumpStars(Address)
namespace SMW_SpawnSpinJumpStars
%InsertMacroAtXPosition(<Address>)

; X speeds for the 4 stars in the spin kill animation. Format: Upper left,
; upper right, bottom left, bottom right.
InitialXSpeed:
	db $E0,$20,$E0,$20

; Y speeds for the 4 stars in the spin kill animation. Format: Upper left,
; upper right, bottom left, bottom right.
InitialYSpeed:
	db $F0,$F0,$10,$10

; Spin Jump Star GFX Subroutine $07FC53 is 4 objects to use for spin jump
; stars
Main:
	PHX
	LDX.b #$03
CODE_07FC3E:
	JSL.l CODE_07FC47
	DEX
	BPL.b CODE_07FC3E
	PLX
	RTL

CODE_07FC47:
	LDY.b #!Define_SMW_MaxExtendedSpriteSlot-$02	; \ Find a free extended sprite slot
CODE_07FC49:
	LDA.w !RAM_SMW_ExtSpr_SpriteID,y
	BEQ.b CODE_07FC52
	DEY
	BPL.b CODE_07FC49
	RTL				; / Return if no free slots

CODE_07FC52:
	LDA.b #!Define_SMW_SpriteID_ExtSpr10_SpinJumpStars	; \ Extended sprite = Spin jump stars
	STA.w !RAM_SMW_ExtSpr_SpriteID,y
	PHX
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	LDA.b !RAM_SMW_NorSpr_YPosLo,x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_ExtSpr_YPosLo,y
	LDA.w !RAM_SMW_NorSpr_YPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_YPosHi,y
	LDA.b !RAM_SMW_NorSpr_XPosLo,x
	CLC
	ADC.b #$04
	STA.w !RAM_SMW_ExtSpr_XPosLo,y
	LDA.w !RAM_SMW_NorSpr_XPosHi,x
	ADC.b #$00
	STA.w !RAM_SMW_ExtSpr_XPosHi,y
	PLX
	LDA.l InitialXSpeed,x
	STA.w !RAM_SMW_ExtSpr_XSpeed,y
	LDA.l InitialYSpeed,x
	STA.w !RAM_SMW_ExtSpr_YSpeed,y
	LDA.b #$17
	STA.w !RAM_SMW_ExtSpr10_SpinJumpStars_DespawnTimer,y
	RTL
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_LineGuideSpeedTable(Address)
namespace SMW_LineGuideSpeedTable
%InsertMacroAtXPosition(<Address>)

; Line-guided sprite speed table. These aren't speed values in the tradition
; sense: when using them, the low nybble of the sprite's X and Y position is
; cleared, and then it is offset a certain number of pixels depending on
; where it was before and which line guide it is on. The high nybble of each
; of these values determines how many pixels to move the sprite on the Y
; axis, and the low nybble determines how many pixels to move the sprite on
; the X axis. The pointers to these are at $07FBF3 and $07FC13.
Main:
Tile076:
	incbin "geometry/lines/76.bin"	;>$07F9DB
Tile077:
	incbin "geometry/lines/77.bin"
Tile078:
	incbin "geometry/lines/78.bin"
Tile079:
	incbin "geometry/lines/79.bin"
Tile07A:
	incbin "geometry/lines/7A.bin"
Tile07B:
	incbin "geometry/lines/7B.bin"	;>$07FA3B
Tile07C:
	incbin "geometry/lines/7C.bin"	;>$07FA4B
Tile07D:
	incbin "geometry/lines/7D.bin"	;>$07FA5B
Tile07E:
	incbin "geometry/lines/7E.bin"	;>$07FA6B
Tile07F:
	incbin "geometry/lines/7F.bin"	;>$07FA7B
Tile080:
	incbin "geometry/lines/80.bin"
Tile081:
	incbin "geometry/lines/81.bin"	;>$07FA93
Tile082:
	incbin "geometry/lines/82.bin"	;>$07FAA3
Tile083:
	incbin "geometry/lines/83.bin"	;>$07FAB3
Tile084:
	incbin "geometry/lines/84.bin"	;>$07FAC3
Tile085:
	incbin "geometry/lines/85.bin"	;>$07FAD3
Tile086:
	incbin "geometry/lines/86.bin"
Tile087:
	incbin "geometry/lines/87.bin"
Tile088:
	incbin "geometry/lines/88.bin"
Tile089:
	incbin "geometry/lines/89.bin"
Tile08A:
	incbin "geometry/lines/8A.bin"
Tile08B:
	incbin "geometry/lines/8B.bin"
Tile08C:
	incbin "geometry/lines/8C.bin"
Tile08D:
	incbin "geometry/lines/8D.bin"
Tile08E:
	incbin "geometry/lines/8E.bin"
Tile08F:
	incbin "geometry/lines/8F.bin"
Tile090:
	incbin "geometry/lines/90.bin"
Tile091:
	incbin "geometry/lines/91.bin"
Tile092:
	incbin "geometry/lines/92.bin"
Tile093:
	incbin "geometry/lines/93.bin"
Tile094:
	incbin "geometry/lines/94.bin"
Tile095:
	incbin "geometry/lines/95.bin"

; Low byte of pointer to line-guided sprite speed table, indexed by the
; Map16 tile number (76-95). The high bytes are at $07FC13, and the bank
; byte is 07.
PtrsLo:
	db Tile076,Tile077,Tile078,Tile079,Tile07A,Tile07B,Tile07C,Tile07D	;>$07FBF3 <-Low byte of pointer to line-guided sprite speed table, indexed by the Map16 tile number (76-95)
	db Tile07E,Tile07F,Tile080,Tile081,Tile082,Tile083,Tile084,Tile085	;>$07FBFB
	db Tile086,Tile087,Tile088,Tile089,Tile08A,Tile08B,Tile08C,Tile08D	;>$07FC03
	db Tile08E,Tile08F,Tile090,Tile091,Tile092,Tile093,Tile094,Tile095	;>$07FC0B

; High byte of pointer to line-guided sprite speed table, indexed by the
; Map16 tile number (76-95). The low bytes are at $07FBF3, and the bank byte
; is 07.
PtrsHi:
	db Tile076>>8,Tile077>>8,Tile078>>8,Tile079>>8,Tile07A>>8,Tile07B>>8,Tile07C>>8,Tile07D>>8	;>$07FC13 <-High byte of pointer to line-guided sprite speed table, indexed by the Map16 tile number (76-95)
	db Tile07E>>8,Tile07F>>8,Tile080>>8,Tile081>>8,Tile082>>8,Tile083>>8,Tile084>>8,Tile085>>8	;>$07FC1B
	db Tile086>>8,Tile087>>8,Tile088>>8,Tile089>>8,Tile08A>>8,Tile08B>>8,Tile08C>>8,Tile08D>>8	;>$07FC23
	db Tile08E>>8,Tile08F>>8,Tile090>>8,Tile091>>8,Tile092>>8,Tile093>>8,Tile094>>8,Tile095>>8	;>$07FC2B
namespace off
endmacro

;#############################################################################################################
;#############################################################################################################

macro DATATABLE_SMW_CircleCoordinates(Address)
namespace SMW_CircleCoordinates
%InsertMacroAtXPosition(<Address>)

; SMW's trigonometry/sine/cosine value table, ordered incrementally from
; decreasing to increasing angle. Note that these are 16-bit values, but
; almost all of the high bytes are 00; additionally, this table only
; contains values for one half of the circle. The actual values in this
; table are not degrees, but rather a scale from 0000 to 01FF (although the
; values in the table only go up to 0100, which is equivalent to 180
; degrees). One "SMW degree" is equivalent to 360/512ths of a real-world
; degree.
Main:
	incbin "geometry/coordinates/circle.bin"
namespace off
endmacro

macro ROUTINE_RT01_SMW_NorSpr07B_GoalTape_Status08(Address)
namespace SMW_NorSpr07B_GoalTape_Status08
%InsertMacroAtXPosition(<Address>)

; X-coordinates of bonus star numbers (FF terminates the string)
DATA_07F0C8:
	db $00,$08,$10,$00,$10,$00,$10,$00
	db $10,$00,$08,$10,$FF,$08,$08,$08
	db $08,$08,$FF,$00,$08,$10,$10,$08
	db $00,$00,$08,$10,$FF,$00,$08,$10
	db $08,$10,$10,$00,$08,$10,$FF,$00
	db $00,$10,$00,$10,$00,$08,$10,$10
	db $FF,$00,$08,$10,$00,$00,$08,$10
	db $10,$00,$08,$10,$FF,$08,$10,$00
	db $00,$08,$10,$00,$10,$00,$08,$10
	db $FF,$00,$08,$10,$10,$0C,$08,$08
	db $FF,$00,$08,$10,$00,$10,$00,$08
	db $10,$00,$10,$00,$08,$10,$FF,$00
	db $08,$10,$00,$10,$00,$08,$10,$10
	db $00,$08,$10,$FF

; Y-coordinates of bonus star numbers (FF terminates the string)
DATA_07F134:
	db $00,$00,$00,$08,$08,$10,$10,$18
	db $18,$20,$20,$20,$FF,$00,$08,$10
	db $18,$20,$FF,$00,$00,$00,$08,$10
	db $18,$20,$20,$20,$FF,$00,$00,$08
	db $10,$10,$18,$20,$20,$20,$FF,$00
	db $08,$08,$10,$10,$18,$18,$18,$20
	db $FF,$00,$00,$00,$08,$10,$10,$10
	db $18,$20,$20,$20,$FF,$00,$00,$08
	db $10,$10,$10,$18,$18,$20,$20,$20
	db $FF,$00,$00,$00,$08,$10,$18,$20
	db $FF,$00,$00,$00,$08,$08,$10,$10
	db $10,$18,$18,$20,$20,$20,$FF,$00
	db $00,$00,$08,$08,$10,$10,$10,$18
	db $20,$20,$20,$FF

; Relative pointers for each bonus star number formation's tilemap (0-9)
DATA_07F1A0:
	db $00,$0D,$13,$1D,$27,$31,$3D,$49
	db $51,$5F

; Table of bonus stars to receive at the goal. The table is x20 bytes long,
; and each byte corresponds to a four-pixel range, from the lowest to the
; highest point. (The values in this table are binary-coded decimal numbers,
; so e.g. if the table says x17 it means you will get 17 (decimal) stars at
; that level.)
BonusStarsEarned:
	db $01,$02,$03,$04,$05,$06,$07,$08
	db $09,$10,$11,$12,$13,$14,$15,$16
	db $17,$18,$19,$20,$21,$22,$23,$24
	db $25,$26,$27,$28,$29,$30,$40,$50

; Routine that draws the bonus stars at level end when touching the goal
; tape. First, it loads the amount of bonus stars the player got by indexing
; the table at $07F1AA using the difference between the starting tape Y
; position and the current Y position, divided by 4. Then, the subroutine at
; $07F200 is called twice, one time for each digit to draw.
BonusStarNumbersGFXRt:
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_DisplayStarsTimer,x
	STA.b !RAM_SMW_Misc_ScratchRAM04
	STZ.b !RAM_SMW_Misc_ScratchRAM02
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_RelativeYPosTapeWasHitAt,x
	LSR
	LSR
	TAX
	LDA.l BonusStarsEarned,x
	PHA
	LSR
	LSR
	LSR
	LSR
	TAX
	BEQ.b CODE_07F1ED
	LDA.l DATA_07F1A0,x
	TAX
	LDY.b #$20
	JSR.w CODE_07F200
CODE_07F1ED:
	PLA
	AND.b #$0F
	TAX
	LDA.l DATA_07F1A0,x
	TAX
	LDA.b #$20
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDY.b #$54
	JSR.w CODE_07F200
	RTL

; Subroutine that draws one digit on the screen using the flashing bonus
; star tiles, called at level end. Inputs: - X: index to the X and Y
; coordinates to use for the digit. - Y: starting OAM index where to draw
; the tiles at (in $0200). - $02: X offset to draw the digit at. - $04:
; value used to determine which tile to use for the digit. This is loaded by
; the caller by using a value that decrements every frame. The routine uses
; X as an index for the tables at $07F0C8 and $07F134, which determine the
; X/Y offset for each tile in the digit. The starting X position is #$64 +
; the value in $02, while the starting Y position is #$40. Then the routine
; uses the value in $04 to determine the tile number: if it's larger than
; #$10, it uses #$EF, otherwise it uses the value in $04 divided by 4 to
; index the table at $07F24E, to create the fading effect at the end. The
; palette is changed every 2 frames to create the flashing effect. This
; routine is called twice by $07F1CA: both times, $04 is loaded from $1540,x
; (set to #$80 when touching the goal tape, and decreasing every frame), and
; X is loaded $07F1A0 (indexed by number of tens first, then by number of
; units). The first time, $02 is #$00 and Y is #$20, while the second time
; $02 is #$20 (so, the second digit will be 32 pixels to the right) and Y is
; #$54.
CODE_07F200:
	LDA.l DATA_07F0C8,x
	BMI.b CODE_07F24A
	CLC
	ADC.b #$64
	CLC
	ADC.b !RAM_SMW_Misc_ScratchRAM02
	STA.w SMW_OAMBuffer[$00].XDisp,y 
	LDA.l DATA_07F134,x
	CLC
	ADC.b #$40
	STA.w SMW_OAMBuffer[$00].YDisp,y 
	LDA.b #$EF
	PHX
	LDX.b !RAM_SMW_Misc_ScratchRAM04
	CPX.b #$10
	BCS.b CODE_07F22A
	TXA
	LSR
	LSR
	TAX
	LDA.l DATA_07F24E,x
CODE_07F22A:
	STA.w SMW_OAMBuffer[$00].Tile,y
	PLX
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
	AND.b #$0E
	ORA.b #$30
	STA.w SMW_OAMBuffer[$00].Prop,y
	PHY
	TYA
	LSR
	LSR
	TAY
	LDA.b #$00
	STA.w SMW_OAMTileSizeBuffer[$00].Slot,y
	PLY
	INY
	INY
	INY
	INY
	INX
	BRA.b CODE_07F200

CODE_07F24A:
	LDX.w !RAM_SMW_NorSpr_CurrentSlotID	; X = Sprite index
	RTS

; Tiles used by Bonus Star formation when the screen fades out
DATA_07F24E:
	db $66,$66,$6E,$FF

; Routine that computes the number of bonus stars to give Mario when
; touching the goal tape. It does so by using the difference between the
; tape's starting Y position and the current Y position, divided by 4, to
; index the table at $07F1AA, which is then stored to $1900. Since the tape
; normally moves 1 pixel per frame, and it changes direction every #$7C
; frames, the highest value in the table (#$50, treated as decimal 50 bonus
; stars, which is loaded when the index is #$7C/4 = #$1F) can only be gotten
; on the single frame the tape is at its highest point. Also the values of
; 30 and 40 can only be gotten in one of the two 4-frame windows preceding
; the peak. If the value is #$50, the GivePoints routine is called to give
; the player a 3Up.
GiveBonusStars:
	PHX
	LDA.w !RAM_SMW_NorSpr07B_GoalTape_RelativeYPosTapeWasHitAt,x
	LSR
	LSR
	TAX
	LDA.l BonusStarsEarned,x
	STA.w !RAM_SMW_Counter_BonusStarsEarned
	PLX
	CMP.b #$50
	; Change to 80 to disable getting a 3up when getting the above number of
	; bonus stars
	BNE.b Return07F26B
	LDA.b #$0A
	JSL.l SMW_GivePoints_Main
Return07F26B:
	RTL
namespace off
endmacro

macro DATATABLE_RT03_SMW_LevelData(Address)
namespace SMW
%InsertMacroAtXPosition(<Address>)

; The bank every sprite list is in on a stock cartridge, read as
; SpriteDataBank>>16 by the loader, which completes each dw sprite pointer
; with it. The managed level banks hook that read to a table of one byte
; per level (Config/ManagedLevelMemory.asm) and pack a sprite list
; wherever the run has got to; the label stays at the macro's stock
; address so the stock build reads what it always read.
SpriteDataBank:
%SMW_ManagedLevelRunStart(<Address>)

	%SMW_InsertLevelData(LEVEL_L1_GhostHouseEntrance, NoYoshiCutscene_GhostHouse, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_BlankEntrance, NoYoshiCutscene_GhostHouse, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_CastleEntrance, NoYoshiCutscene_DayCastle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_104, Level104_YoshisHouse, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_NoYoshiEntrance1, NoYoshiCutscene_Mountains, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_GhostHouseExit2L1, UnusedLevel_GhostHouseExit2, SMW_U, LAYER_1)
	%SMW_InsertLevelData(UnusedLevelData_BushTestL1, UnusedLevel_BushTest, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_CastleEntrance2, NoYoshiCutscene_DarkCastle, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_NoYoshiEntrance2, NoYoshiCutscene_StarrySky, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_NoYoshiEntrance3, NoYoshiCutscene_Craggy, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_108, Level108_SlopeTest, SMW_U, LAYER_1)
%SMW_ManagedLevelRunEnd()
namespace off
endmacro

macro DATATABLE_RT04_SMW_LevelData(Address)
namespace SMW
%SMW_ManagedLevelRunStart(<Address>)

	%SMW_InsertLevelData(LEVEL_L1_01D, 01D, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0EA, 0EA, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_01C, 01C, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0C0, 0C0, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0BD, 0BD, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_01A, 01A, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_01A, 01A, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_0D4, 0D4, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_0D4, 0D4, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_0D3, 0D3, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_018, 018, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0F8, 0F8, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_0F7, Level0F7_SunkenGhostShip_VerticalShaft, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_116, 116, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1E5, 1E5, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1E4, 1E4, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_115, 115, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_115, 115, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_1E3, 1E3, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_1E3, 1E3, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_1E2, 1E2, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_1E2, 1E2, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_0C8, 0C8, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_114, 114, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1DD, 1DD, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1DB, 1DB, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_113, 113, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1BB, 1BB, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_10F, 10F, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1BF, 1BF, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_110, 110, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1FE, 1FE, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_111, 111, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_111, 111, SMW_U, LAYER_2)
%SMW_ManagedLevelRunEnd()
namespace off
endmacro

macro DATATABLE_RT05_SMW_LevelData(Address)
namespace SMW
%SMW_ManagedLevelRunStart(<Address>)

	%SMW_InsertLevelData(LEVEL_L1_10D, 10D, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D4, 1D4, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D3, 1D3, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D2, 1D2, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D1, 1D1, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D0, 1D0, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1CF, 1CF, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_1CF, 1CF, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_1CE, 1CE, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L2_1CE, 1CE, SMW_U, LAYER_2)
	%SMW_InsertLevelData(LEVEL_L1_1CD, 1CD, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1CC, 1CC, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1BD, 1BD, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_10E, 10E, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C7, 1C7, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_134, 134, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D6, 1D6, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_130, 130, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1D5, 1D5, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_132, 132, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_135, 135, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_136, 136, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_12A, 12A, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C4, 1C4, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_12B, 12B, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_12C, 12C, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C9, 1C9, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1C8, 1C8, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_12D, 12D, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_128, 128, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_127, 127, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1E1, 1E1, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_1E0, 1E0, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_126, 126, SMW_U, LAYER_1)
	%SMW_InsertLevelData(LEVEL_L1_125, Level125_Funky_Main, SMW_J, LAYER_1)
%SMW_ManagedLevelRunEnd()
namespace off
endmacro

macro DATATABLE_RT06_SMW_LevelData(Address)
namespace SMW
%SMW_ManagedLevelRunStart(<Address>)

	%SMW_InsertLevelData(UnusedLevelData_RideAmongTheCloudsSpr, UnusedLevel_RideAmongTheClouds, SMW_U, SPRITES)
	%SMW_InsertLevelData(UnusedLevelData_MushroomScalesSpr, UnusedLevel_MushroomScales, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_09B, Level09B_BowserBattle, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_09A, 09A, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_099, 099, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_098, 098, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_097, 097, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_096, Level096_LarryBattle, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_095, Level095_ReznorBattle, SMW_U, SPRITES)
	%SMW_InsertLevelData(UnusedLevelData_LavaCaveSpr, UnusedLevel_LavaCave, SMW_U, SPRITES)
	%SMW_InsertLevelData(UnusedLevelData_FollowTestSpr, UnusedLevel_FollowTest, SMW_U, SPRITES)
	%SMW_InsertLevelData(UnusedLevelData_OldWendysCastleSpr, UnusedLevel_OldWendysCastle, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_093, Level093_LemmyBattle, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_094, Level094_WendyBattle, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0BD, 0BD, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C6, 0C6, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C4, Level0C4_UnusedGhostHouseExit, SMW_U, SPRITES)
	%SMW_InsertLevelData(UnusedLevelData_GoalTape, UnusedLevel_GhostHouseExit1, SMW_U, SPRITES)
	%SMW_InsertLevelData(UnusedLevelData_GoalTape2, UnusedLevel_GhostHouseExit2, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_000, Level000_BonusGame, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0EB, Level0EB_DonutGhostHouse_NormalExit, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0D5, 0D5, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_10D, 10D, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C7, Level0C7_TitleScreen, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C5, Level0C5_IntroLevel, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_014, 014, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0CA, 0CA, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_11B, 11B, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1D8, 1D8, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_121, 121, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1D7, 1D7, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_008, 008, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C9, 0C9, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_003, 003, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_105, 105, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_106, 106, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1CA, 1CA, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_103, 103, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1FD, 1FD, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_102, 102, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1FF, 1FF, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1BE, Level1BE_YoshisIsland4_SideArea, SMW_ARCADE, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_101, 101, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1FC, 1FC, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1F6, 1F6, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_015, 015, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0E3, 0E3, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_009, Level009_DonutPlains2_Main, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0E9, 0E9, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_004, 004, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0DE, 0DE, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0FE, 0FE, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_005, 005, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_006, 006, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0D2, 0D2, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C3, 0C3, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_007, 007, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0E8, 0E8, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0E7, 0E7, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0E5, 0E5, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_00A, 00A, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C2, 0C2, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_013, Level013_DonutSecretHouse_Main, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0ED, Level0ED_DonutSecretHouse_SecondRoom, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0F1, 0F1, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0E4, 0E4, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_10B, 10B, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1C6, 1C6, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_11A, Level11A_VanillaDome1_Main, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1EF, 1EF, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_118, 118, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1C3, 1C3, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_107, 107, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1EA, 1EA, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_10A, 10A, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1C2, 1C2, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_119, 119, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1F5, 1F5, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_11C, Level11C_LemmysCastle_Main, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1F3, 1F3, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1F2, 1F2, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_109, 109, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1F1, 1F1, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1F0, 1F0, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_001, 001, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0D8, 0D8, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_002, 002, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_00B, 00B, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0E0, 0E0, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_00F, 00F, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0BF, 0BF, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_010, 010, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C1, 0C1, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_00E, 00E, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0DC, 0DC, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0DB, 0DB, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0D9, 0D9, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_011, 011, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_00C, 00C, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_00D, 00D, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0DD, 0DD, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_11E, 11E, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_120, 120, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_123, 123, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1F8, 1F8, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_020, 020, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0CC, Level0CC_RoyBattle, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_11D, 11D, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1FA, 1FA, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_11F, 11F, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1DF, 1DF, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1C1, 1C1, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_122, 122, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_01F, 01F, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0D6, 0D6, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_022, 022, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0BE, 0BE, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_021, 021, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0FC, 0FC, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_024, 024, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0CF, 0CF, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_024_1, Level0CF_ChocolateIsland2_Rexes, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_024_2, Level0CF_ChocolateIsland2_Slopes, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0CE, 0CE, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_024_3, Level0CE_ChocolateIsland2_Dinos, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_024_4, Level0CE_ChocolateIsland2_SecretExit, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0CD, 0CD, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_024_5, Level0CD_ChocolateIsland2_NormalExit, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_023, Level023_ChocolateIsland3_Main, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0D7, 0D7, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_01B, 01B, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0EF, 0EF, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_117, 117, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1ED, 1ED, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1EC, 1EC, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1C0, 1C0, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_01D, 01D, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0EA, 0EA, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_01C, 01C, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C0, 0C0, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_01A, 01A, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0D4, 0D4, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0D3, 0D3, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_018, 018, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0F8, 0F8, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0F7, Level0F7_SunkenGhostShip_VerticalShaft, SMW_J, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_116, 116, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1E5, 1E5, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_115, 115, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1E3, 1E3, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1E2, 1E2, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_0C8, 0C8, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_114, 114, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1DD, 1DD, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1DB, 1DB, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_113, 113, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_10F, 10F, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1BF, 1BF, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_110, 110, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1FE, 1FE, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1EB, 1EB, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_111, 111, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1D4, 1D4, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1D3, 1D3, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1D2, 1D2, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1D1, 1D1, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1CF, 1CF, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1CE, 1CE, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1CD, 1CD, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1CC, 1CC, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_10E, 10E, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1C7, 1C7, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_134, 134, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_130, 130, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_132, 132, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_135, 135, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_136, 136, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_12A, 12A, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1C4, 1C4, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_12B, 12B, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_12C, 12C, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_1C8, 1C8, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_12D, 12D, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_128, 128, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_127, 127, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_126, 126, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_125, Level125_Funky_Main, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_104, Level104_YoshisHouse, SMW_U, SPRITES)
	%SMW_InsertLevelData(LEVEL_SP_Test, Level025_TestLevel, SMW_U, SPRITES)
%SMW_ManagedLevelRunEnd()
namespace off
endmacro

macro INLINEDATATABLE_RT29_SMW_EmptySpace(Address)
!SMW_UBytes = $13 : !SMW_JBytes = $13 : !SMW_E1Bytes = $13 : !SMW_E2Bytes = $13 : !SMASW_UBytes = $13 : !SMASW_EBytes = $13 : !SMW_ARCADEBytes = $13
	
if !Define_SMW_ManagedLevelMemory == !TRUE
	; Inside a managed run: the level streams own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 29)
endif
endmacro

macro INLINEDATATABLE_RT30_SMW_EmptySpace(Address)
!SMW_UBytes = $0487 : !SMW_JBytes = $0487 : !SMW_E1Bytes = $0487 : !SMW_E2Bytes = $0487 : !SMASW_UBytes = $0487 : !SMASW_EBytes = $0487 : !SMW_ARCADEBytes = $0487
	
if !Define_SMW_ManagedLevelMemory == !TRUE
	; Inside a managed run: the level streams own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 30)
endif
endmacro

macro INLINEDATATABLE_RT31_SMW_EmptySpace(Address)
!SMW_UBytes = $DA : !SMW_JBytes = $E6 : !SMW_E1Bytes = $DA : !SMW_E2Bytes = $DA : !SMASW_UBytes = $DA : !SMASW_EBytes = $DA : !SMW_ARCADEBytes = $DA
	
if !Define_SMW_ManagedLevelMemory == !TRUE
	; Inside a managed run: the level streams own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 31)
endif
endmacro

macro INLINEDATATABLE_RT32_SMW_EmptySpace(Address)
!SMW_UBytes = $0891 : !SMW_JBytes = $089A : !SMW_E1Bytes = $0891 : !SMW_E2Bytes = $0891 : !SMASW_UBytes = $0891 : !SMASW_EBytes = $0891 : !SMW_ARCADEBytes = $0894
	
if !Define_SMW_ManagedLevelMemory == !TRUE
	; Inside a managed run: the level streams own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 32)
endif
endmacro

macro INLINEDATATABLE_RT33_SMW_EmptySpace(Address)
!SMW_UBytes = $0370 : !SMW_JBytes = $0370 : !SMW_E1Bytes = $0370 : !SMW_E2Bytes = $0370 : !SMASW_UBytes = $0370 : !SMASW_EBytes = $0370 : !SMW_ARCADEBytes = $0370
	
if !Define_SMW_ManagedLevelMemory == !TRUE
	; Inside a managed run: the level streams own these bytes.
else
	%SMW_FitOriginalFreespace(<Address>, !ROMID, 33)
endif
endmacro
