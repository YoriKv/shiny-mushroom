includeonce

;#############################################################################################################
;# Custom tiles: Map16 pages past the stock two, and the objects that place
;# them.
;#
;# The stock game defines 512 Map16 tiles -- pages $00 and $01 -- resolved
;# per tileset at level load through !RAM_SMW_Pointer_Map16Tiles, and every
;# object routine writes one of them. Lunar Magic adds pages $02 upward as
;# one flat table, a tile there meaning the same block in every level, with
;# a two-byte "acts-like" word per tile naming the vanilla tile it borrows
;# its interaction from, and four standard objects that put such tiles into
;# a level. Setting !Define_SMW_CustomTiles to !TRUE gives this cartridge
;# the same four pages, $02 to $05, and the same four objects.
;#
;# **The tables are one Lunar Magic .map16 container, sliced.** The
;# definitions and the acts-like words are incbin'd by offset out of
;# GFX/Map16/CustomTiles.map16, the container Lunar Magic's own Map16
;# editor reads and writes, so a project overlays one file and either tool
;# edits it. The tree's copy holds the stock tables on pages $00 and $01,
;# the custom pages empty, and every custom acts-like word $0130, the
;# cement block -- Lunar Magic's own default -- so the feature with nothing
;# edited draws nothing a stock level did not.
;#
;# **The objects**, dispatched from the five tileset tables in bank $0D in
;# place of the five aliases of the water object that hold those numbers on
;# the stock cartridge, and read past the three bytes every standard object
;# has, advancing the level data pointer as the screen exit does:
;#
;# - 22 and 23, four bytes: one page-0 or page-1 tile, its low byte in
;#   byte 3, over the HHHHWWWW rectangle the settings byte spells -- the
;#   generic repeated-tile family's shape, with the tile in the record.
;# - 27 and 29, five to eight bytes: byte 3 is ffpppppp, the form in its
;#   top two bits and the page in the rest, 29 setting page bit 6; byte 4
;#   the tile's low byte. Form 00 places that one tile over HHHHWWWW blocks;
;#   form 01 an hhhhwwww rectangle of consecutive tiles -- a row of the
;#   page being sixteen tiles -- as it is; form 10 such a rectangle, in a
;#   fifth byte, tiled over HHHHWWWW blocks; form 11 the same over 0WWWWWWW
;#   blocks across and, in a sixth byte, HHHHHHHH down. With the settings
;#   byte's high bit set in form 11 an eighth byte names one of Lunar
;#   Magic's conditional flags, which this cartridge reads past and does
;#   not act on: the tiles are placed whatever the flag.
;# - 2D, five bytes: Lunar Magic's reserved user-defined object, read past
;#   and drawing nothing, so a stream carrying one stays in step.
;#
;# The rectangle is walked the way objects 01-0E walk theirs, with the
;# same screen-crossing arithmetic, so a wide object runs on into the next
;# screen and a tall one into the rows below, and a vertical level swaps
;# the axes for these as it does for every object. A count is a nibble --
;# or, in form 11, a byte -- holding blocks less one; the height counts
;# down through a signed byte, so past 128 rows it stops after two, which
;# is Lunar Magic's own limit.
;#
;# **Drawing a custom tile.** The four column builders in bank $05 --
;# Layer 1 and Layer 2, horizontal and vertical -- resolve a tile through
;# the pointer table, which has no row past $1FF. A JSL over the two
;# instructions that read it lands on SMW_CustomTiles_Definition, which
;# hands a vanilla tile the same pointer and a custom one the address of
;# its eight bytes here, the bank byte moved to this one for the read and
;# put back to the tables' for the next vanilla tile. A tile past the pages
;# held draws SMW_CustomTiles_Undefined, four zero words.
;#
;# **Colliding with one.** The player, the sprites, the fireballs and the
;# cape each fetch the tile under a point and hand its page in A and its
;# low byte in !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo to
;# SMW_ModifyMap16IDForSpecialBlocks, at the four spots Lunar Magic hooks
;# for its own block code. Each JSL becomes one to SMW_CustomTiles_ActsLikeOf,
;# which replaces a custom tile by the word its acts-like entry holds --
;# looked up again while that word is itself custom, up to eight times, and
;# $0130 past the pages held or past the eighth lookup -- and goes on to the
;# stock routine with the vanilla tile in place. Everything downstream, the
;# solid ranges and the special blocks included, sees the vanilla tile.
;#
;# **A generated tile drops the page.** SMW_GenerateTile keeps bit 0 of the
;# high byte when a page-0 tile is generated over another, and sets it for a
;# page-1 one -- which over a custom tile would leave the page in place. Under
;# the define the two become a store of the page outright, the change Lunar
;# Magic makes there.
;#
;# The pages, the acts-like words, the undefined tile and the stubs are one
;# block in the run the growable features share (Config/ReservedBank.asm),
;# behind the relocated overworld tables and ahead of the text; the stubs
;# run on either CPU under SA-1 Pack and use no divider. The define needs a
;# cartridge assembled at 1 MB or larger, which the reservation says rather
;# than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_CustomTiles=1 turns the pages and the objects on.
if defined("Define_SMW_CustomTiles") == 0
	!Define_SMW_CustomTiles = !FALSE
endif

; The pages held: four from page $02, tiles $0200-$05FF.
!Define_SMW_CustomTiles_FirstPage	#= $02
!Define_SMW_CustomTiles_Pages		#= $04
!Define_SMW_CustomTiles_FirstTile	#= !Define_SMW_CustomTiles_FirstPage*$0100
!Define_SMW_CustomTiles_Tiles		#= !Define_SMW_CustomTiles_Pages*$0100
!Define_SMW_CustomTiles_EndTile		#= !Define_SMW_CustomTiles_FirstTile+!Define_SMW_CustomTiles_Tiles

; What the two tables come to: eight bytes a definition, two an acts-like word.
!Define_SMW_CustomTiles_DefinitionBytes	#= !Define_SMW_CustomTiles_Tiles*$0008
!Define_SMW_CustomTiles_ActsLikeBytes	#= !Define_SMW_CustomTiles_Tiles*$0002

; What a tile acts like when its chain of acts-like words never reaches a
; vanilla tile, or when it is past the pages held: the cement block, Lunar
; Magic's default for a fresh custom tile. And how long a chain is followed.
!Define_SMW_CustomTiles_ActsLikeDefault	#= $0130
!Define_SMW_CustomTiles_ActsLikeDepth	#= $08

; Where the two tables sit in the container: page $02's definitions, eight
; bytes a tile from the container's $B0, and its acts-like words, two a tile
; from $800B0 -- the offsets Lunar Magic's format fixes.
!Define_SMW_CustomTiles_ContainerDefinitions	#= $10B0
!Define_SMW_CustomTiles_ContainerDefinitionsEnd	#= !Define_SMW_CustomTiles_ContainerDefinitions+!Define_SMW_CustomTiles_DefinitionBytes
!Define_SMW_CustomTiles_ContainerActsLike	#= $804B0
!Define_SMW_CustomTiles_ContainerActsLikeEnd	#= !Define_SMW_CustomTiles_ContainerActsLike+!Define_SMW_CustomTiles_ActsLikeBytes

; The objects' record grammar. Byte 3 of a 27 or 29: the form in the top
; two bits, the page in the rest; object 29 adds page bit 6.
!Define_SMW_CustomTiles_FormMask	= $C0
!Define_SMW_CustomTiles_PageMask	= $3F
!Define_SMW_CustomTiles_HighPageBit	= $40
!Define_SMW_CustomTiles_WideWidthMask	= $7F	;> form 11's settings byte: the width, less one
!Define_SMW_CustomTiles_ConditionalBit	= $80	;> ...and, set, the eighth byte's presence

;#############################################################################################################
;# Where they go: the two tables, the undefined tile, then the stubs, as one
;# occupant of the reserved run behind the relocated overworld tables and
;# ahead of the text. The tables lead so that their address is the run's
;# head plus the blocks ahead, the way every occupant's is declared.
;#############################################################################################################

; Place the block. Called from %SMW_PlaceReservedRun at whatever position the
; occupants ahead left.
macro SMW_PlaceCustomTiles()
if !Define_SMW_CustomTiles == !TRUE

; The definitions: pages $02-$05, eight bytes a tile, straight out of the
; container.
SMW_CustomTiles_Definitions:
	incbin "GFX/Map16/CustomTiles.map16":!Define_SMW_CustomTiles_ContainerDefinitions..!Define_SMW_CustomTiles_ContainerDefinitionsEnd
	assert pc() == SMW_CustomTiles_Definitions+!Define_SMW_CustomTiles_DefinitionBytes, "The custom tiles' definitions are not four pages of eight bytes a tile. Check the incbin range against the container's layout."

; The acts-like words for the same tiles, two bytes each, out of the
; container's one acts-like table.
SMW_CustomTiles_ActsLike:
	incbin "GFX/Map16/CustomTiles.map16":!Define_SMW_CustomTiles_ContainerActsLike..!Define_SMW_CustomTiles_ContainerActsLikeEnd
	assert pc() == SMW_CustomTiles_ActsLike+!Define_SMW_CustomTiles_ActsLikeBytes, "The custom tiles' acts-like words are not four pages of two bytes a tile. Check the incbin range against the container's layout."

; What a tile past the pages held draws: four zero words, character 0 in
; palette 0, which is what the console shows for a tile nothing defines.
SMW_CustomTiles_Undefined:
	dw $0000,$0000,$0000,$0000

;#############################################################################################################
;# The column builders' hook.
;#############################################################################################################

; Entered from the four column builders in bank $05 in place of the two
; instructions that turn a tile number into the address of its definition:
; A and the index registers 16-bit, Y the tile number doubled, and the
; three bytes at !RAM_SMW_Misc_ScratchRAM0A the pointer the builder reads
; the eight bytes through, its bank byte already the tables'. Leaves the
; pointer on the tile's definition: the stock pointer for a vanilla tile,
; the block above for a custom one, SMW_CustomTiles_Undefined past the
; pages held. The bank byte is moved to this bank for a custom tile and put
; back to the tables' for the next vanilla one, since the builder sets it
; once per column; the overworld never names a custom tile, so its own bank
; is never the one being put back.
SMW_CustomTiles_Definition:
	CPY.w #!Define_SMW_CustomTiles_FirstTile*2
	BCS.b .Custom
	LDA.w !RAM_SMW_Pointer_Map16Tiles,y	;> The displaced pair: the vanilla definition
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	SEP.b #$20				; A->8
	LDA.b !RAM_SMW_Misc_ScratchRAM0C
	CMP.b #SMW_CustomTiles_Definitions>>16
	BNE.b .Vanilla
	LDA.b #SMW_Map16Data_Main>>16		;> A custom tile earlier in the column moved it
	STA.b !RAM_SMW_Misc_ScratchRAM0C
.Vanilla:
	REP.b #$20				; A->16
	RTL
.Custom:
	CPY.w #!Define_SMW_CustomTiles_EndTile*2
	BCS.b .Undefined
	TYA
	SEC
	SBC.w #!Define_SMW_CustomTiles_FirstTile*2
	ASL					;\ The tile's place in the pages,
	ASL					;/ eight bytes each
	CLC
	ADC.w #SMW_CustomTiles_Definitions&$FFFF
	BRA.b .Point
.Undefined:
	LDA.w #SMW_CustomTiles_Undefined&$FFFF
.Point:
	STA.b !RAM_SMW_Misc_ScratchRAM0A
	SEP.b #$20				; A->8
	LDA.b #SMW_CustomTiles_Definitions>>16
	STA.b !RAM_SMW_Misc_ScratchRAM0C
	REP.b #$20				; A->16
	RTL

;#############################################################################################################
;# The collision hook.
;#############################################################################################################

; Entered in place of the JSL to SMW_ModifyMap16IDForSpecialBlocks_Main at
; the four spots that fetch the tile under a point: A 8-bit and the tile's
; page, !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo its low byte, X and
; Y the caller's own. A vanilla tile goes straight on to the stock routine.
; A custom one is replaced first by the word its acts-like entry holds --
; and that word by its own while it names a custom tile, up to the depth
; above -- so the stock routine, and everything after it, sees a vanilla
; tile: its page in A, its low byte in the same RAM byte.
SMW_CustomTiles_ActsLikeOf:
	CMP.b #!Define_SMW_CustomTiles_FirstPage
	BCC.b .Vanilla
	PHX
	PHY
	PHP
	REP.b #$10				; XY->16
	SEP.b #$20				; A->8
	XBA					;> The page into B
	LDA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	REP.b #$20				; A->16: the tile
	LDY.w #!Define_SMW_CustomTiles_ActsLikeDepth
.Resolve:
	CMP.w #!Define_SMW_CustomTiles_FirstTile
	BCC.b .Resolved
	CMP.w #!Define_SMW_CustomTiles_EndTile
	BCS.b .Default
	SEC
	SBC.w #!Define_SMW_CustomTiles_FirstTile
	ASL
	TAX
	LDA.l SMW_CustomTiles_ActsLike,x
	DEY
	BNE.b .Resolve
.Default:
	LDA.w #!Define_SMW_CustomTiles_ActsLikeDefault
.Resolved:
	SEP.b #$20				; A->8
	STA.w !RAM_SMW_Blocks_CurrentlyProcessedMap16TileLo
	XBA					;> The page it acts on
	PLP
	PLY
	PLX
.Vanilla:
	JML.l SMW_ModifyMap16IDForSpecialBlocks_Main

;#############################################################################################################
;# The objects. Each is entered as every standard object is -- from
;# SMW_ExecutePtr_Long out of a tileset's dispatch table, A, X and Y 8-bit,
;# the level data pointer on the byte after the record's third, the
;# position in !RAM_SMW_Blocks_SubScrPos, the settings byte in
;# !RAM_SMW_Blocks_SizeOrType and the two Map16 write pointers on the
;# screen -- and leaves as one, back into bank $0D's dispatcher, which
;# returns to the loop.
;#
;# The scratch bytes the walk works in:
;#   $00 the width less one, $01 the rows left, $02 the columns left in
;#   the row; $04-$05 the row's start, the two bytes the stock primitives
;#   preserve; $06-$07 the base tile; $08-$09 the selection's width and
;#   height, each less one; $0C-$0D how far into the selection the column
;#   and the row are; $0E-$0F the tile the row starts on.
;#############################################################################################################

; Objects 22 and 23: one tile, its low byte the fourth record byte, its
; page the object number's low bit, over the settings byte's HHHHWWWW.
; The dispatch tables in bank $0D name each routine by the slot's own
; label, which on the stock cartridge is an alias of the water object.
SMW_StandardObj22_DirectTilePage0_Main:
SMW_StandardObj23_DirectTilePage1_Main:
SMW_CustomTiles_Object23:
SMW_CustomTiles_Object22:
	LDY.b #$00
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	;> Byte 3: the tile's low byte
	STA.b !RAM_SMW_Misc_ScratchRAM06
	LDA.b !RAM_SMW_Blocks_ObjectNumber
	AND.b #$01				;> 22 is page 0, 23 page 1
	STA.b !RAM_SMW_Misc_ScratchRAM07
	JSR.w SMW_CustomTiles_SizedByNibbles
	STZ.b !RAM_SMW_Misc_ScratchRAM08		;\ A one-tile selection
	STZ.b !RAM_SMW_Misc_ScratchRAM09		;/
	LDA.b #$01				;> One byte past the three
	JMP.w SMW_CustomTiles_Draw

; Object 2D: Lunar Magic's reserved five-byte object, read past.
SMW_StandardObj2D_UserDefined_Main:
SMW_CustomTiles_Object2D:
	LDA.b #$02
	JSR.w SMW_CustomTiles_Advance
	JMP.w SMW_CustomTiles_Return

; Objects 27 and 29: the tile's page and form in byte 3, its low byte in
; byte 4, and what the form adds after.
SMW_StandardObj27_DirectTiles_Main:
SMW_StandardObj29_DirectTilesHighPages_Main:
SMW_CustomTiles_Object29:
SMW_CustomTiles_Object27:
	LDY.b #$00
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	;> Byte 3: ffpppppp
	PHA
	AND.b #!Define_SMW_CustomTiles_PageMask
	STA.b !RAM_SMW_Misc_ScratchRAM07
	LDA.b !RAM_SMW_Blocks_ObjectNumber
	CMP.b #$29
	BNE.b .LowPages
	LDA.b #!Define_SMW_CustomTiles_HighPageBit
	TSB.b !RAM_SMW_Misc_ScratchRAM07
.LowPages:
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	;> Byte 4: the tile's low byte
	STA.b !RAM_SMW_Misc_ScratchRAM06
	PLA
	ASL					;\ The form, out of the top
	ROL					;| two bits
	ROL					;|
	AND.b #$03				;/
	BEQ.b .OneTile
	CMP.b #$01
	BEQ.b .AsItIs
	CMP.b #$02
	BEQ.b .Tiled
; Form 11, multi-screen: 0WWWWWWW in the settings byte, hhhhwwww in byte
; 5, HHHHHHHH in byte 6, and an eighth byte with the settings' high bit.
	LDA.b !RAM_SMW_Blocks_SizeOrType
	AND.b #!Define_SMW_CustomTiles_WideWidthMask
	STA.b !RAM_SMW_Misc_ScratchRAM00
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	;> Byte 5: the selection
	JSR.w SMW_CustomTiles_Selection
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	;> Byte 6: the height, less one
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$04
	BIT.b !RAM_SMW_Blocks_SizeOrType
	BPL.b .Sized
	INC					;> The conditional byte, read past
	BRA.b .Sized
; Form 10, a selection tiled over the settings byte's rectangle.
.Tiled:
	JSR.w SMW_CustomTiles_SizedByNibbles
	INY
	LDA.b [!RAM_SMW_Pointer_Layer1DataLo],y	;> Byte 5: the selection
	JSR.w SMW_CustomTiles_Selection
	LDA.b #$03
	BRA.b .Sized
; Form 01, a selection placed as it is: the rectangle is the selection.
.AsItIs:
	LDA.b !RAM_SMW_Blocks_SizeOrType
	JSR.w SMW_CustomTiles_Selection
	LDA.b !RAM_SMW_Misc_ScratchRAM08
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Misc_ScratchRAM09
	STA.b !RAM_SMW_Misc_ScratchRAM01
	LDA.b #$02
	BRA.b .Sized
; Form 00, one tile over the settings byte's rectangle.
.OneTile:
	JSR.w SMW_CustomTiles_SizedByNibbles
	STZ.b !RAM_SMW_Misc_ScratchRAM08
	STZ.b !RAM_SMW_Misc_ScratchRAM09
	LDA.b #$02
.Sized:
	JMP.w SMW_CustomTiles_Draw

; The settings byte's HHHHWWWW as the rectangle: the width less one into
; $00, the height less one into $01.
SMW_CustomTiles_SizedByNibbles:
	LDA.b !RAM_SMW_Blocks_SizeOrType
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b !RAM_SMW_Blocks_SizeOrType
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM01
	RTS

; A's hhhhwwww as the selection: its width less one into $08, its height
; less one into $09.
SMW_CustomTiles_Selection:
	PHA
	AND.b #$0F
	STA.b !RAM_SMW_Misc_ScratchRAM08
	PLA
	LSR
	LSR
	LSR
	LSR
	STA.b !RAM_SMW_Misc_ScratchRAM09
	RTS

; Move the level data pointer A bytes on, past what the record added to
; the three the loop read.
SMW_CustomTiles_Advance:
	CLC
	ADC.b !RAM_SMW_Pointer_Layer1DataLo
	STA.b !RAM_SMW_Pointer_Layer1DataLo
	LDA.b !RAM_SMW_Pointer_Layer1DataHi
	ADC.b #$00
	STA.b !RAM_SMW_Pointer_Layer1DataHi
	RTS

; The walk, entered with A the bytes to read past and $00, $01, $06-$09
; set: the rectangle row by row, each row column by column, the selection
; repeating along both. Each tile's page goes to the high table and its low
; byte to the low table through the stock primitives' own arithmetic, the
; column crossing a screen boundary by stepping both pointers a screen on
; and the row crossing sixteen rows by carrying into their high bytes.
SMW_CustomTiles_Draw:
	JSR.w SMW_CustomTiles_Advance
	STZ.b !RAM_SMW_Misc_ScratchRAM0C
	STZ.b !RAM_SMW_Misc_ScratchRAM0D
	LDA.b !RAM_SMW_Misc_ScratchRAM06		;\ The first row starts
	STA.b !RAM_SMW_Misc_ScratchRAM0E		;| on the base tile
	LDA.b !RAM_SMW_Misc_ScratchRAM07		;|
	STA.b !RAM_SMW_Misc_ScratchRAM0F		;/
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataLo	;\ Preserve the row's start,
	STA.b !RAM_SMW_Misc_ScratchRAM04		;| as the stock primitive does
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;|
	STA.b !RAM_SMW_Misc_ScratchRAM05		;/
	LDY.b !RAM_SMW_Blocks_SubScrPos
.Tile:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C		;\ The tile: the row's first
	REP.b #$20				; A->16	;| plus how far along the
	AND.w #$00FF				;| selection the column is
	CLC					;|
	ADC.b !RAM_SMW_Misc_ScratchRAM0E		;/
	SEP.b #$20				; A->8
	XBA
	STA.b [!RAM_SMW_Pointer_HiMap16BlockDataLo],y	;> The page
	XBA
	STA.b [!RAM_SMW_Pointer_LoMap16BlockDataLo],y	;> The low byte
	INY
	TYA
	AND.b #$0F
	BNE.b .SameScreen
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataLo	;\ Past the screen's last
	CLC					;| column: both pointers
	ADC.b #$B0				;| a screen on, as the
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo	;| horizontal crossing
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo	;| primitive steps them
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;|
	ADC.b #$01				;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;/
	INC.w !RAM_SMW_Blocks_ScreenToPlaceNextObject
	LDA.b !RAM_SMW_Blocks_SubScrPos
	AND.b #$F0
	TAY
.SameScreen:
	LDA.b !RAM_SMW_Misc_ScratchRAM0C		;\ Along the selection,
	CMP.b !RAM_SMW_Misc_ScratchRAM08		;| and round again past
	BCC.b .Along				;| its last column
	LDA.b #$FF				;|
.Along:						;|
	INC					;|
	STA.b !RAM_SMW_Misc_ScratchRAM0C		;/
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	BPL.b .Tile
	LDA.b !RAM_SMW_Misc_ScratchRAM04		;\ Back to the row's start,
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataLo	;| as the stock primitive
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataLo	;| restores it
	LDA.b !RAM_SMW_Misc_ScratchRAM05		;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;|
	LDA.w !RAM_SMW_Blocks_ScreenToPlaceCurrentObject	;|
	STA.w !RAM_SMW_Blocks_ScreenToPlaceNextObject	;/
	LDA.b !RAM_SMW_Blocks_SubScrPos		;\ A row down, carrying
	CLC					;| into the pointers' high
	ADC.b #$10				;| bytes past the sixteenth,
	STA.b !RAM_SMW_Blocks_SubScrPos		;| as the vertical crossing
	TAY					;| primitive does
	BCC.b .Row				;|
	LDA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;|
	ADC.b #$00				;|
	STA.b !RAM_SMW_Pointer_LoMap16BlockDataHi	;|
	STA.b !RAM_SMW_Pointer_HiMap16BlockDataHi	;|
	STA.b !RAM_SMW_Misc_ScratchRAM05		;/
.Row:
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM0C
	LDA.b !RAM_SMW_Misc_ScratchRAM0D		;\ Down the selection, and
	CMP.b !RAM_SMW_Misc_ScratchRAM09		;| round again past its
	BCC.b .Down				;| last row: the row's first
	STZ.b !RAM_SMW_Misc_ScratchRAM0D		;| tile back on the base
	LDA.b !RAM_SMW_Misc_ScratchRAM06		;|
	STA.b !RAM_SMW_Misc_ScratchRAM0E		;|
	LDA.b !RAM_SMW_Misc_ScratchRAM07		;|
	STA.b !RAM_SMW_Misc_ScratchRAM0F		;|
	BRA.b .Rows				;|
.Down:						;|
	INC.b !RAM_SMW_Misc_ScratchRAM0D		;|
	REP.b #$20				; A->16	;| ...or a page row on
	LDA.b !RAM_SMW_Misc_ScratchRAM0E		;|
	CLC					;|
	ADC.w #$0010				;|
	STA.b !RAM_SMW_Misc_ScratchRAM0E		;|
	SEP.b #$20				; A->8	;/
.Rows:
	DEC.b !RAM_SMW_Misc_ScratchRAM01
	BMI.b SMW_CustomTiles_Return
	JMP.w .Tile

; Back to the dispatcher in bank $0D, whose RTL ends the object: the
; return the dispatcher's JSR left is pulled and pushed again under that
; bank, since an RTS here would return into this one.
SMW_CustomTiles_Return:
	REP.b #$10				; XY->16
	PLX
	LDA.b #SMW_ProcessStandardAndTilesetSpecificObjects_Main>>16
	PHA
	PHX
	SEP.b #$10				; XY->8
	RTL

	assert pc()-SMW_CustomTiles_Definitions == !Define_SMW_Block_CustomTiles, "The custom tiles' block is not the size Config/PackedRuns.asm states. The text behind it is read past it, so pin the new figure in Define_SMW_Block_CustomTiles."
	assert pc() <= !Loc_SMW_ReservedBank_End, "The custom tiles have outgrown the reserved run."
endif
endmacro
