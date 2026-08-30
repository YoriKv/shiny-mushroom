includeonce

;#############################################################################################################
;# Per-level graphics: a level names its own eight files, and its animated tiles.
;#
;# The stock game decides which graphics files a level loads from two
;# fields of its header, each a tileset number indexing a 26-row list in
;# SMW_UploadGraphicsFiles -- FGAndBGGFXList for the four background
;# slots FG1, FG2, BG1, FG3, and SpriteGFXList for the four sprite slots
;# SP1-SP4 -- so a level can only ever load one of the sixteen
;# combinations each list holds, and every file it loads is one the
;# stock lists name. Setting !Define_SMW_LevelGraphics to !TRUE gives a
;# level the other answer: a row of eight file numbers of its own, one
;# per slot in that order, laid over what its tilesets would load. A row
;# byte of $FF keeps the tileset's file for that slot; any other byte is
;# the file that slot loads instead -- a stock file, or one the managed
;# graphics let the project add. The header's tilesets then decide
;# everything else they decide -- Map16 pages, object set, behaviour --
;# and the graphics are the level's.
;#
;# A ninth byte says which file the level's **animated tiles** come out
;# of. The stock game decompresses GFX33 once, during the Nintendo
;# Presents logo, expands it from 3bpp to 4bpp and leaves the result in
;# WRAM at AnimatedTiles, where three four-tile blocks of it are DMA'd
;# into VRAM every frame for the whole session -- so there is no per-level
;# upload to lay a file over, and a level that wants its own animated
;# tiles has to have that decompression run again. The stub does exactly
;# what the boot routine does: the file into the staging area at $7E2000,
;# the 3bpp-to-4bpp expansion from there into AnimatedTiles, and then
;# GFX32 back over the staging area, which is where the player's graphics
;# live and what the boot routine leaves there. A row byte of $FF is the
;# game's own GFX33, as every other slot's $FF is the tileset's file.
;#
;# It costs two decompressions, so it is done only when it has to be:
;# !RAM_SMW_LevelGraphics_AnimatedFile records which file is in the buffer
;# and a level that wants that file is left alone. The record is a byte and
;# its complement, because the page it is in is the one the reset does not
;# clear -- see the RAM map.
;#
;# The file has to be a file the decompressor can be asked for, and 384
;# tiles of 3bpp: GFX33 itself, or one a project added of that shape. Both
;# want the managed graphics (Config/ManagedGraphicsMemory.asm), whose
;# pointer table is the only one that reaches GFX33 and whose format table
;# is what sends a file that size to the staging area rather than the
;# decompression buffer it would overrun. So a row naming one is refused
;# at the assembler on a cartridge without them.
;#
;# The rows are the first occupant of the level bank (Config/LevelBank.asm):
;# $200 rows of eight bytes at the bank's fixed head, one per level
;# number, so their address is the same on every cartridge this bank is,
;# then $200 animated files, one per level, then the stubs. Everything else in the bank -- the custom level
;# palettes, the packed level streams -- is measured from behind them,
;# which is why the block is one size whatever else the cartridge has.
;# Both tables are filled with $FF and then overwritten, level by level,
;# from graphics/levels/level-graphics.asm, a fragment the project build
;# derives from the level containers' ExGFX slots: one
;# %SMW_LevelGraphics(level, nine bytes) per level with a row, placed at
;# its level's row and its level's animated byte whatever order the lines
;# come in. The shipped fragment names no level, since no
;# shipped container does, so the feature with an unedited table loads
;# exactly what the stock cartridge loads.
;#
;# Two hooks in SMW_UploadGraphicsFiles (Banks/Bank00.asm), each a JSL of
;# exactly the size of the loop it stands in for -- the loop that copies a
;# tileset's four files out of its list -- one per list, both inside the
;# stretch of bank $00 SA-1 Pack leaves alone. Each stub repeats the loop
;# and then, when the load is a level's, lays the loading level's row over
;# the four files; the layer half, which is the later of the two, goes on
;# to settle the animated tiles. The level number is the word the shared stash keeps
;# (Config/LevelNumberStash.asm), planted in SMW_SpecifySublevelToLoad at
;# every sublevel load. The upload cache works as before: an overridden
;# slot is compared against what the slot holds, and skipped when it
;# already holds that file.
;#
;# The define needs a cartridge assembled at 1 MB or larger, which the
;# bank's reservation says rather than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_LevelGraphics=1 turns the level graphics on.
if defined("Define_SMW_LevelGraphics") == 0
	!Define_SMW_LevelGraphics = !FALSE
endif

; The two tables: the rows, and one animated file per level. What the whole
; block comes to -- these, the two read stubs with their shared tail, the
; animated tiles' own stub and the level number stash -- is
; !Define_SMW_Block_LevelGraphics, declared with every other block in
; Config/PackedRuns.asm because the palettes behind it are read past the
; same figure and the editor prices the bank against it. The placement
; asserts what it emitted against it, so a change to a stub is caught here
; and answered there.
!Define_SMW_LevelGraphicsRowBytes	#= $0008
!Define_SMW_LevelGraphicsRowsBytes	#= $0200*!Define_SMW_LevelGraphicsRowBytes
!Define_SMW_LevelGraphicsAnimatedBytes	#= $0200

;#############################################################################################################
;# The fragment's line: one level's row.
;#############################################################################################################

; One level's nine files: the eight slots in slot order FG1, FG2, BG1,
; FG3, SP1, SP2, SP3, SP4, where $FF keeps the tileset's file, and then
; the animated tiles, where $FF is the game's own GFX33. Placed at the
; level's own row of one table and its own byte of the other, so the
; fragment's lines may come in any order, and a level the fragment names
; twice keeps the later line. The product is bracketed because the
; assembler's arithmetic is left to right.
macro SMW_LevelGraphics(level, fg1, fg2, bg1, fg3, sp1, sp2, sp3, sp4, an2)
	assert ((<level>)>>9) == 0, "A level graphics row names a level past $1FF. Check graphics/levels/level-graphics.asm."
	assert (((<fg1>)|(<fg2>)|(<bg1>)|(<fg3>)|(<sp1>)|(<sp2>)|(<sp3>)|(<sp4>)|(<an2>))>>8) == 0, "A level graphics row holds a file number past $FF. Check graphics/levels/level-graphics.asm."
if !Define_SMW_ManagedGraphicsMemory == !FALSE
	assert (<an2>) == $FF, "A level names its own animated tiles, which needs the managed graphics: nothing else reaches a file of that shape, or sends it anywhere but the decompression buffer it would overrun. Check graphics/levels/level-graphics.asm."
endif
	pushpc
	org !SMW_LevelGraphics_RowsAt+((<level>)*!Define_SMW_LevelGraphicsRowBytes)
	db <fg1>,<fg2>,<bg1>,<fg3>,<sp1>,<sp2>,<sp3>,<sp4>
	org !SMW_LevelGraphics_AnimatedAt+(<level>)
	db <an2>
	pullpc
endmacro

;#############################################################################################################
;# Where they go: the rows at the level bank's fixed head, then the stubs.
;# Placed from the top of each ROM map, before any bank emits, so the
;# fixed-size occupant is the one everything behind it is measured from:
;# the palettes pack at the cursor this leaves, and the level streams
;# behind them.
;#############################################################################################################

; Place the rows and the stubs. Called from the head of each ROM map,
; before the custom level palettes' placement, and bracketed with
; pushpc/pullpc like every placement there.
macro SMW_PlaceLevelGraphics()
if !Define_SMW_LevelGraphics == !TRUE
	pushpc
	org !SMW_LevelBankNext
	assert pc() == !Loc_SMW_LevelBank_Packed, "The level graphics must be the level bank's first occupant: their rows have to sit at the run's fixed head."

; One row per level number, $200 rows of eight bytes, and then one
; animated tiles file per level: every byte $FF, and then each level the
; fragment names written over its own. The rows come first and keep the
; bank's fixed head, so the arithmetic that reads them is a shift.
SMW_LevelGraphics_Rows:
	!SMW_LevelGraphics_RowsAt #= pc()
	fillbyte $FF : fill !Define_SMW_LevelGraphicsRowsBytes
SMW_LevelGraphics_AnimatedFiles:
	!SMW_LevelGraphics_AnimatedAt #= pc()
	fillbyte $FF : fill !Define_SMW_LevelGraphicsAnimatedBytes
	incsrc "graphics/levels/level-graphics.asm"
	assert pc() == SMW_LevelGraphics_Rows+!Define_SMW_LevelGraphicsRowsBytes+!Define_SMW_LevelGraphicsAnimatedBytes, "The level graphics tables do not end where their $200 rows of eight bytes and $200 animated files should. Check graphics/levels/level-graphics.asm."

; The reads the two bank $00 hooks land on, one per list, each in place of
; the loop that copies a tileset's four files out of its list. Entered as
; the loop was: AXY 8-bit, X = 3, Y = the tileset's row times four, and the
; data bank $00 the list is read through. The loop is repeated -- entry n
; of the row to $07-n, as the uploader expects them -- and then the four
; are handed to the overlay below with X naming which half of a level's
; row they are: bytes 4-7 for the sprite slots, 0-3 for the layers.
SMW_LevelGraphics_Sprites:
.Read:
	LDA.w SMW_UploadGraphicsFiles_SpriteGFXList,y	;\ The displaced loop: the
	STA.b !RAM_SMW_Misc_ScratchRAM04,x		;| tileset's four files, entry n
	INY						;| to $07-n
	DEX						;|
	BPL.b .Read					;/
	LDX.b #$04					;> The row's sprite half
	BRA.b SMW_LevelGraphics_Overlay

SMW_LevelGraphics_Layers:
.Read:
	LDA.w SMW_UploadGraphicsFiles_FGAndBGGFXList,y
	STA.b !RAM_SMW_Misc_ScratchRAM04,x
	INY
	DEX
	BPL.b .Read
	LDX.b #$00					;> The row's layer half

; Lay the loading level's row over the four files in $04-$07, when the
; load is a level's: game mode $12 is the one caller of the uploader that
; is a level being prepared -- the title screen, the credits' Yoshi's
; House and the enemy rollcall prepare levels under other modes and keep
; their tilesets' files, as do the cutscenes and the overworld, whose rows
; ($10-$19) no header can name -- and the row has to be one a header can
; name, which keeps a Mode 7 room's sprite row ($12, $13, $18) exactly as
; it was. Y is four past the row's first entry when the loop is done, so
; $44 is the first row past a header's sixteen. The level number is read
; where SMW_LevelNumberStash_Store left it, times eight for the rows plus
; the half X names: X, the one register a long read can index by, walks
; the row up while Y walks $07 down to $04, and a row byte that is not $FF
; replaces the list's. $0E-$0F is scratch the uploader sets before it
; reads and its caller has finished with.
SMW_LevelGraphics_Overlay:
	CPY.b #$44
	BCS.b .Done					;> Not a header's row
	LDA.l !RAM_SMW_Misc_GameMode
	CMP.b #!Define_SMW_GameMode12_PrepareLevel
	BNE.b .Done					;> Not a level being prepared
	REP.b #$30					; AXY->16
	TXA						;> The half
	STA.b !RAM_SMW_Misc_ScratchRAM0E
	LDA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	AND.w #$01FF
	ASL						;\ Times eight: the rows are eight
	ASL						;| bytes, and the level is below $200
	ASL						;/ so no shift carries
	ADC.b !RAM_SMW_Misc_ScratchRAM0E
	TAX						;> The row's half, as an index
	SEP.b #$20					; A->8
	LDY.w #$0003
.Slot:
	LDA.l SMW_LevelGraphics_Rows,x
	CMP.b #$FF
	BEQ.b .Keep					;> $FF keeps the tileset's file
	STA.w !RAM_SMW_Misc_ScratchRAM04,y
.Keep:
	INX
	DEY
	BPL.b .Slot
	LDA.b !RAM_SMW_Misc_ScratchRAM0E		;\ The layer half, the later of the
	BNE.b .Done					;/ two, settles the animated tiles
	JSR.w SMW_LevelGraphics_Animated
.Done:
	SEP.b #$30					; AXY->8, as the hook found them
	RTL

; The animated tiles the loading level asks for: the file its row names
; expanded into the buffer the frame DMAs come out of, or the game's own
; GFX33. Reached from the layer half of the overlay above, so what that
; half established holds -- the load is a level being prepared, and the
; level number is the one the stash kept. Entered with A 8-bit and XY
; 16-bit, and leaves all three to the caller, which puts them back.
;
; What it does is DecompressGFX32And33 (Banks/Bank00.asm) again, for
; another file: the file into the staging area at $7E2000 -- its format
; byte is what sends it there rather than to the decompression buffer,
; which is $C00 bytes and could not hold it -- then the 3bpp-to-4bpp
; expansion out of there into AnimatedTiles, working backwards so the
; growing output never overruns the input it is still reading, and then
; GFX32 decompressed back over the staging area, which is where the
; player's graphics live and what the expansion borrowed the room from.
;
; The player's tiles are DMA'd out of that area every frame, so a frame
; landing in the middle of this draws the wrong ones. The screen is
; blanked for the whole of a level's preparation and the frame after this
; is right again, which is the same trade the boot routine makes.
SMW_LevelGraphics_Animated:
	REP.b #$30					; AXY->16
	LDA.l !RAM_SMW_LevelNumberStash_LoadedLevel	;\ The level's own byte, one
	AND.w #$01FF					;| per level number, so the
	TAX						;/ index is the number itself
	SEP.b #$20					; A->8
	LDA.l SMW_LevelGraphics_AnimatedFiles,x
	CMP.b #$FF
	BNE.b .Wanted
	LDA.b #$33					;> $FF is the game's own animated tiles
.Wanted:
	STA.b !RAM_SMW_Misc_ScratchRAM0E		;> What the buffer should hold
	LDA.l !RAM_SMW_LevelGraphics_AnimatedFile	;\ What it does hold, if the
	CMP.b !RAM_SMW_Misc_ScratchRAM0E		;| record answers for itself:
	BNE.b .Expand					;| a file and that file
	LDA.l !RAM_SMW_LevelGraphics_AnimatedFileCheck	;| complemented, and anything
	EOR.b #$FF					;| else a page the reset does
	CMP.b !RAM_SMW_Misc_ScratchRAM0E		;| not clear, holding what a
	BEQ.b .Held					;/ cartridge powered on with
.Expand:
	SEP.b #$10					; XY->8, the width the decompressor's callers hand it the number in
	LDY.b !RAM_SMW_Misc_ScratchRAM0E
	JSL.l SMW_GraphicsDecompressionRoutines_Main	;> The file, into the staging area
	LDA.b #!RAM_SMW_Graphics_DecompressedGFX33>>16	;\ The expansion's destination:
	STA.b !RAM_SMW_Misc_ScratchRAM8F		;/ its bank, then its last word
	REP.b #$30					; AXY->16
	LDA.w #!RAM_SMW_Graphics_DecompressedGFX33+$2FFE
	STA.b !RAM_SMW_Misc_ScratchRAM8D
	LDX.w #$23FF					;> The file's last byte
.Tile:
	LDY.w #$0008					;> The tile's eight bp2 bytes
.Plane2:
	LDA.l !RAM_SMW_Graphics_DecompressedGFX32,x
	AND.w #$00FF					;> and no bp3: the file is 3bpp
	STA.b [!RAM_SMW_Misc_ScratchRAM8D]
	DEX
	DEC.b !RAM_SMW_Misc_ScratchRAM8D
	DEC.b !RAM_SMW_Misc_ScratchRAM8D
	DEY
	BNE.b .Plane2
	LDY.w #$0008					;> The tile's eight bp0/bp1 pairs
.Planes01:
	DEX
	LDA.l !RAM_SMW_Graphics_DecompressedGFX32,x
	STA.b [!RAM_SMW_Misc_ScratchRAM8D]
	DEX
	BMI.b .Player					;> Past the file's first byte
	DEC.b !RAM_SMW_Misc_ScratchRAM8D
	DEC.b !RAM_SMW_Misc_ScratchRAM8D
	DEY
	BNE.b .Planes01
	BRA.b .Tile
.Player:
	SEP.b #$30					; AXY->8
	LDY.b #$32					;> The player's graphics, back over the staging area
	JSL.l SMW_GraphicsDecompressionRoutines_Main
	LDA.b !RAM_SMW_Misc_ScratchRAM0E		;\ The record, now the buffer
	STA.l !RAM_SMW_LevelGraphics_AnimatedFile	;| really holds the file: the
	EOR.b #$FF					;| byte and its complement, which
	STA.l !RAM_SMW_LevelGraphics_AnimatedFileCheck	;/ is what makes it answerable
.Held:
	RTS

	assert pc() == SMW_LevelGraphics_Rows+!Define_SMW_Block_LevelGraphics, "The level graphics block is not the size Config/PackedRuns.asm states. A stub that changed size changes what the palettes behind it are read past, so pin the new figure in Define_SMW_Block_LevelGraphics."
	!SMW_LevelBankNext #= pc()
	pullpc
endif
endmacro
