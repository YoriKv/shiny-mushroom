includeonce

;#############################################################################################################
;# Managing banks $08-$0B as one packed run, with the graphics banks behind it.
;#
;# The 52 compressed graphics files live in banks $08-$0B as one bank macro,
;# DATATABLE_SMW_CompressedGraphics, placed by RomMap/ at $088000 and packed to
;# the byte against the fitted padding behind it. So a file's room is the
;# sum of what every file leaves: one redrawn with worse-compressing pixels
;# has to be paid for by another shrinking, and no file can be added at all
;# -- the three pointer tables in Banks/Bank00.asm hold fifty rows, in a
;# bank packed to the byte.
;#
;# Setting !Define_SMW_ManagedGraphicsMemory to !TRUE makes the placement a
;# sequence instead, emitted from the tail of the ROM map
;# (%SMW_PlaceManagedGraphics): at its own map line the macro emits nothing
;# and the run the map gave it is a hole, and invoked again from the tail
;# every file it inserts is emitted back to back, in the macro's order,
;# into runs: the stock four banks whole, and then the graphics banks
;# (Config/GraphicsBank.asm), one run each from its head to its last byte. A file that would run past the end of the run being
;# filled is placed at the start of the next, and the packing never goes
;# back; a file may still straddle a bank boundary inside the stock run, as
;# the shipped files do, because the decompressor's ReadByte follows the
;# bank, but never the edge of a run. Whatever a run has left when the
;# packing moves past it is filled with $FF, as is whatever the run the
;# packing ended in has left and every graphics bank the packing never
;# reached. The stock padding behind the files emits nothing.
;#
;# The files a project adds are packed after the game's own:
;# graphics/added/added-graphics.asm is one %SMW_AddedGraphics(GFXnn) per
;# added file, read by %SMW_PlaceManagedGraphics, and each inserts
;# its stream through the same macro the stock files use, so the asset's
;# path and its label follow one rule. File numbers $34-$FE may be added:
;# $FF is the terminator byte's neighbour and never a file, and $80 becomes
;# usable because the upload cache's "no file" sentinel is $FF under this
;# define (Banks/Bank00.asm, HandleMode7BossGFX).
;#
;# The head of the first graphics bank is fixed, and the loader reads it
;# through two hooks, each a JSL of exactly the size of the code it stands
;# in for, both inside the stretch of bank $00 SA-1 Pack leaves alone:
;#
;# - SMW_ManagedGraphics_Pointers, one long pointer per file number, $100
;#   rows: the game's own files' labels in rows $00-$33, an added file's
;#   label in a row the added list names, $000000 elsewhere. The three
;#   reads of the stock tables in SMW_GraphicsDecompressionRoutines_Main
;#   are a JSL to SMW_ManagedGraphics_Pointer, which reads this table
;#   instead; the stock tables stay in bank $00, unread.
;# - SMW_ManagedGraphics_Formats, one byte per file number: 0 is 3bpp, the
;#   stock path, 1 is 4bpp, 2 is the animated tiles' 384 tiles of 3bpp and
;#   3 the player's $5D00 bytes of 4bpp. The stock rows are 0 but for the
;#   two boot-time files' own, $32 and $33; the added rows come from
;#   graphics/added/formats.asm. The decompression at the head of
;#   UploadGFXFile is a JSL to SMW_ManagedGraphics_Upload, which
;#   decompresses as before, reads the byte, and for 4bpp copies the $1000
;#   decompressed bytes to VRAM as they are and returns past the stock
;#   3bpp expansion.
;#
;#   The byte also says **where the file decompresses to**, which is the
;#   pointer stub's other half: a file of 0 or 1 is a slot's worth of tiles
;#   and lands in the stock buffer, and one of 2 or 3 is too big for it and
;#   lands in the WRAM staging area at $7E2000 the boot-time decompression
;#   uses, where a caller that wants such a file goes to read it. Nothing
;#   in the stock game asks the decompressor for $32 or $33 -- they are
;#   decompressed once, by literal address, during the Nintendo Presents
;#   logo -- so the two rows exist for a feature that does, which is the
;#   per-level animated tiles (Config/LevelGraphics.asm).
;#
;# A 4bpp file decompresses to the stock buffer at $7EAD00 and runs $400
;# bytes past its end, over the Layer 2 background buffer at $7EB900. That
;# is harmless at every call: the buffer is built by the level loader and
;# consumed by SMW_InitializeLevelLayer1And2Tilemaps before the graphics
;# are uploaded, and nothing reads it again -- the per-frame Layer 2 table
;# sends a background to Layer2_NoScroll -- the credits build and copy each
;# of theirs before their upload, the overworld's switch-block tables
;# there are written before they are read, and the title screen never
;# uses it. The one path that uploaded graphics first, the enemy rollcall
;# in Banks/Bank00.asm, uploads its tilemaps first under this define, in
;# the order a level does.
;#
;# The define needs a cartridge the graphics banks exist in, 1 MB or
;# larger, which the banks' reservation says rather than letting the image
;# quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_ManagedGraphicsMemory=1 packs the graphics.
if defined("Define_SMW_ManagedGraphicsMemory") == 0
	!Define_SMW_ManagedGraphicsMemory = !FALSE
endif

;#############################################################################################################
;# The runs, in the order the packing fills them.
;#
;# Run 0 is the stock four banks whole, literal like every placement in
;# RomMap/ and checked against the maps rather than derived from them. The
;# runs after it are the graphics banks, one each, from the first bank's
;# streams label -- behind the head below -- or a later bank's first byte
;# past its RATS tag, to the bank's last byte: Config/GraphicsBank.asm
;# states them.
;#############################################################################################################

!Loc_SMW_ManagedGraphicsRun0_Start	#= $088000	;> DATATABLE_SMW_CompressedGraphics, the first file
!Loc_SMW_ManagedGraphicsRun0_End	#= $0C0000	;> the end of bank $0B

; The two stubs' sizes, and the head they and the two tables take off the
; first graphics bank. Part of the run's budget: the editor prices the
; banks against the same numbers, so a change to a stub is a change to
; that budget and not only to this file. The placement asserts all three.
!Define_SMW_ManagedGraphicsPointerStubBytes	#= $38
!Define_SMW_ManagedGraphicsUploadStubBytes	#= $26
!Define_SMW_ManagedGraphicsHeadBytes		#= $0300+$0100+!Define_SMW_ManagedGraphicsPointerStubBytes+!Define_SMW_ManagedGraphicsUploadStubBytes

; Where the packing has got to, and whether the packing is what is being
; emitted. Reset here, which is once per assembler pass, because this file
; is read at the start of each of them. Run 0 is the stock banks; run k is
; the graphics bank k-1 from the bank define.
!SMW_ManagedGraphicsRun		#= 0
!SMW_ManagedGraphicsNext	#= !Loc_SMW_ManagedGraphicsRun0_Start
!SMW_ManagedGraphicsEnd		#= !Loc_SMW_ManagedGraphicsRun0_End
!SMW_ManagedGraphicsEmit	= !FALSE

;#############################################################################################################
;# The added files' two fragments, and the macros their lines are.
;#############################################################################################################

; One added file. Declares its number while the fragment is read at the
; start of the pass -- so the pointer table's row can name its label -- and
; inserts its stream through %SMW_INCGFX, the stock files' own macro, when
; the packing reads the fragment again.
macro SMW_AddedGraphics(graphic)
if !SMW_ManagedGraphicsEmit == !TRUE
	%SMW_INCGFX(<graphic>)
else
	!SMW_<graphic>_Added = !TRUE
endif
endmacro

; One added file's format: 1 for 4bpp. A 3bpp file declares nothing.
macro SMW_GraphicsFormat(graphic, Format)
	assert (<Format>) == 1 || (<Format>) == 2, "A graphics format is 1 for 4bpp or 2 for the animated tiles' shape; a 3bpp file is not listed. Check graphics/added/formats.asm."
	!SMW_<graphic>_Format #= <Format>
endmacro

; One row of the pointer table past the stock files: the label when the
; added list names the number, nothing otherwise.
macro SMW_ManagedGraphicsPointerRow(graphic)
if defined("SMW_<graphic>_Added")
	dl SMW_<graphic>
else
	dl $000000
endif
endmacro

; One row of the format table past the stock files: what the formats
; fragment declares, 0 where it declares nothing. A format for a number
; the added list does not name is refused: a row nothing loads is a
; mistake in the fragment.
macro SMW_ManagedGraphicsFormatRow(graphic)
if defined("SMW_<graphic>_Format")
	assert defined("SMW_<graphic>_Added"), "graphics/added/formats.asm declares a format for a file added-graphics.asm does not list."
	db !SMW_<graphic>_Format
else
	db $00
endif
endmacro

; The added files' numbers and formats, declared. Read here in the
; declaring mode, at the start of every pass and only under the define;
; the streams themselves are read by the packing.
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	incsrc "graphics/added/added-graphics.asm"
	incsrc "graphics/added/formats.asm"
endif

;#############################################################################################################
;# The packing.
;#############################################################################################################

; The stock macro's slot in the ROM map, or its turn in the packing.
; DATATABLE_SMW_CompressedGraphics is invoked twice under the define: from
; its ROM map line, where it orgs to its stock address as ever and emits
; nothing -- the run the map gave it is a hole -- and again from
; %SMW_PlaceManagedGraphics, where it emits every file wherever the packing
; has got to. !SMW_ManagedGraphicsEmit says which; %SMW_INCGFX reads the
; same flag. The turn in the packing has to open at the first run's start,
; which is asserted.
macro SMW_ManagedGraphicsSlot()
if !Define_SMW_ManagedGraphicsMemory == !TRUE && !SMW_ManagedGraphicsEmit == !TRUE
	assert pc() == !Loc_SMW_ManagedGraphicsRun0_Start, "The graphics packing must open at the first run's start. Check %SMW_PlaceManagedGraphics."
endif
endmacro

; Move the packing to the next run, giving the rest of this one to the
; cartridge as $FF. The error names the banks rather than leaving asar to
; report a position.
macro SMW_ManagedGraphicsAdvance()
	if pc() < !SMW_ManagedGraphicsEnd
		fillbyte $FF : fill !SMW_ManagedGraphicsEnd-pc()
	endif
	!SMW_ManagedGraphicsRun #= !SMW_ManagedGraphicsRun+1
	if !SMW_ManagedGraphicsRun > !Define_SMW_GraphicsBankCount
		error "The graphics banks are full: the graphics files no longer fit banks $08-$0B and the graphics banks end to end. Take bytes out of a file, or assemble with more graphics banks (Define_SMW_GraphicsBankCount)."
	endif
	if !SMW_ManagedGraphicsRun == 1
		!SMW_ManagedGraphicsNext #= !Loc_SMW_GraphicsBank_Streams
	else
		!SMW_ManagedGraphicsNext #= ((!Define_SMW_GraphicsBank+!SMW_ManagedGraphicsRun-1)<<$10)|$8008
	endif
	!SMW_ManagedGraphicsEnd #= ((!Define_SMW_GraphicsBank+!SMW_ManagedGraphicsRun-1)<<$10)|$FFFF
	org !SMW_ManagedGraphicsNext
endmacro

; Find the file of <Size> bytes about to be inserted a run it fits, before
; its label is placed. Called by %SMW_INCGFX while the graphics are
; managed. Moves until a run holds it rather than once: the runs are not
; all one size -- the first graphics bank is $7BAF bytes behind its head
; where every bank after it is $7FF7 -- so a file too big for the run it
; moves into can still fit the one after that. Every move fills the run it
; leaves, so a run stepped over reads as $FF to its end like any other.
macro SMW_ManagedGraphicsFit(Size)
	while pc()+(<Size>) > !SMW_ManagedGraphicsEnd
		%SMW_ManagedGraphicsAdvance()
	endwhile
	assert pc()+(<Size>) <= !SMW_ManagedGraphicsEnd, "A graphics file is larger than a graphics bank's run and fits nowhere."
endmacro

;#############################################################################################################
;# The head of the first graphics bank: the two tables, then the two stubs,
;# then the label the packed streams begin at -- a fixed-size occupant at a
;# fixed address, so the packing behind it is measured from the layout
;# rather than from where this ended. Placed from %SMW_PlaceManagedGraphics.
;#############################################################################################################

macro SMW_PlaceManagedGraphicsHead()
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	org !Loc_SMW_GraphicsBank_Packed

; One long pointer per file number, $100 rows.
SMW_ManagedGraphics_Pointers:
	incsrc "graphics/managed/pointer-table.asm"
	assert pc() == SMW_ManagedGraphics_Pointers+$0300, "The managed graphics pointer table must hold one long pointer for each of the $100 file numbers. Check graphics/managed/pointer-table.asm."

; One byte per file number: 0 for 3bpp, 1 for 4bpp, 2 for the animated
; tiles' shape and 3 for the player's. What each is, and where it
; decompresses to, is the top of this file.
SMW_ManagedGraphics_Formats:
	incsrc "graphics/managed/format-table.asm"
	assert pc() == SMW_ManagedGraphics_Formats+$0100, "The managed graphics format table must hold one byte for each of the $100 file numbers. Check graphics/managed/format-table.asm."

; Where a file is and where it decompresses to: the bank $00 hook lands
; here in place of the three reads of the stock tables in
; SMW_GraphicsDecompressionRoutines_Main and the six stores of the
; destination behind them. Entered with A 8-bit and Y the file number,
; 8-bit at every caller; X is saved and the widths are put back as found,
; so a caller of any width gets its registers back.
;
; The source is the pointer table's row: the file number, times three
; because the rows are dl, indexes it through X -- long addressing indexed
; by Y does not exist -- and the three bytes land in the same direct-page
; scratch the displaced reads filled, $8A-$8C, which the decompressor
; takes its source from. $8D is scratch the decompressor overwrites before
; reading. The widening clears the index registers' high bytes, and the
; ASL of a value below $100 leaves the carry clear, so the ADC needs no
; CLC.
;
; The destination is what the file's format byte says it is: a format
; below 2 is a slot's worth of tiles and goes to the stock buffer, as the
; displaced stores always wrote, and 2 and 3 -- the animated tiles' shape
; and the player's -- are larger than that buffer and go to the WRAM
; staging area the boot-time decompression works in. The two differ in one
; byte, which is what the branch picks: both are page-aligned and both are
; in bank $7E, asserted below rather than assumed.
SMW_ManagedGraphics_Pointer:
	PHX
	PHP
	REP.b #$30				; AXY->16
	TYA					;> The file number
	STA.b !RAM_SMW_Misc_ScratchRAM8D
	ASL
	ADC.b !RAM_SMW_Misc_ScratchRAM8D	;> Times three: the rows are dl
	TAX
	SEP.b #$20				; A->8
	LDA.l SMW_ManagedGraphics_Pointers,x
	STA.b !RAM_SMW_Misc_ScratchRAM8A
	LDA.l SMW_ManagedGraphics_Pointers+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM8B
	LDA.l SMW_ManagedGraphics_Pointers+$02,x
	STA.b !RAM_SMW_Misc_ScratchRAM8C
	LDX.b !RAM_SMW_Misc_ScratchRAM8D	;> The file number itself: the format's row
	LDA.l SMW_ManagedGraphics_Formats,x
	CMP.b #$02				;> Below 2 a slot's file, 2 and up too big for the buffer
	LDA.b #!RAM_SMW_Graphics_GraphicDecompressionBuffer>>8
	BCC.b .Destination
	LDA.b #!RAM_SMW_Graphics_DecompressedGFX32>>8
.Destination:
	STA.b !RAM_SMW_Misc_ScratchRAM01
	STZ.b !RAM_SMW_Misc_ScratchRAM00
	LDA.b #!RAM_SMW_Graphics_DecompressedGFX32>>16
	STA.b !RAM_SMW_Misc_ScratchRAM02
	PLP					; the widths as the hook found them
	PLX
	RTL
	assert pc() == SMW_ManagedGraphics_Pointer+!Define_SMW_ManagedGraphicsPointerStubBytes, "The managed graphics pointer stub is not the size its budget states. Check Define_SMW_ManagedGraphicsPointerStubBytes."
	assert (!RAM_SMW_Graphics_GraphicDecompressionBuffer&$FF) == 0, "The decompression buffer is not page-aligned, so the destination stub cannot pick between it and the staging area by one byte."
	assert (!RAM_SMW_Graphics_DecompressedGFX32&$FF) == 0, "The graphics staging area is not page-aligned, so the destination stub cannot pick between it and the buffer by one byte."
	assert (!RAM_SMW_Graphics_GraphicDecompressionBuffer>>16) == (!RAM_SMW_Graphics_DecompressedGFX32>>16), "The decompression buffer and the graphics staging area are in different banks, so the destination stub cannot write one bank byte for both."

; The decompression the bank $00 hook at the head of UploadGFXFile lands
; on, in place of its JSL to the decompressor. Entered with AXY 8-bit, Y
; the file number and the VRAM address and increment already set by the
; caller. The displaced call is repeated -- the file decompresses to the
; stock buffer, $00-$02 pointing at it -- and the file's format byte is
; read through X, the register a long read can index by. A 3bpp file
; returns to the stock expansion untouched. A 4bpp file is the $1000
; decompressed bytes copied to VRAM as they are, a word at a time through
; the port the stock loop writes, and then the stock loop is skipped: the
; JSL's return address comes off the stack, the widths go back to what
; UploadGFXFile's callers expect, and the jump lands on its RTS, in its
; own bank, which returns to whichever of the three JSRs called it. The
; decompressed size is $1000 bytes whatever the stock buffer's length,
; the overrun being harmless at every call -- see the top of this file.
SMW_ManagedGraphics_Upload:
	JSL.l SMW_GraphicsDecompressionRoutines_Main	;> The displaced call: the file, decompressed to the buffer
	TYX					;> The file number, where a long read can index it
	LDA.l SMW_ManagedGraphics_Formats,x
	BEQ.b .Stock
	REP.b #$30				; AXY->16
	LDY.w #$0000
.Copy:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	STA.l !REGISTER_WriteToVRAMPortLo
	INY
	INY
	CPY.w #$1000				;> The whole file: 128 tiles of 32 bytes
	BCC.b .Copy
	PLA					;> The JSL's return address, the word
	SEP.b #$30				; AXY->8, as UploadGFXFile returns them
	PLA					;> and its bank
	JML.l SMW_UploadGraphicsFiles_UploadGFXFileDone
.Stock:
	RTL
	assert pc() == SMW_ManagedGraphics_Upload+!Define_SMW_ManagedGraphicsUploadStubBytes, "The managed graphics upload stub is not the size its budget states. Check Define_SMW_ManagedGraphicsUploadStubBytes."

; Where the packed streams begin, once the packing reaches this bank.
SMW_ManagedGraphics_Streams:
	assert pc() == !Loc_SMW_GraphicsBank_Streams, "The managed graphics head does not end where Config/GraphicsBank.asm says the streams start."
endif
endmacro

;#############################################################################################################
;# The packing, as one sequence: the head, then one org at the first run's
;# start and the stock macro's turn in the packing -- every file inserted
;# where the packing has got to, moved on a run when one would not fit --
;# then the files the project adds, a label where the packed data ends,
;# and the fills.
;#############################################################################################################

; Place the lot. The fills are what the run the packing ended in has left,
; as $FF, then every graphics bank the packing never reached -- the stock
; fill behind the files emits nothing under the define, and a bank the
; assembler never wrote is zeroes otherwise. Called once from each ROM map
; after every bank has emitted, beside the other features' placements; the
; fragment's labels are spelled bare because the map calls this outside any
; namespace. Nothing after the ROM map reads the position this leaves.
macro SMW_PlaceManagedGraphics()
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	%SMW_PlaceManagedGraphicsHead()
	!SMW_ManagedGraphicsEmit = !TRUE
	org !Loc_SMW_ManagedGraphicsRun0_Start
	%DATATABLE_SMW_CompressedGraphics(NULLROM)
SMW_ManagedGraphics_Added:
	incsrc "graphics/added/added-graphics.asm"
	!SMW_ManagedGraphicsEmit = !FALSE
SMW_ManagedGraphics_Free:
	if pc() < !SMW_ManagedGraphicsEnd
		fillbyte $FF : fill !SMW_ManagedGraphicsEnd-pc()
	endif
	!SMW_ManagedGraphicsFillBank #= !SMW_ManagedGraphicsRun
	while !SMW_ManagedGraphicsFillBank < !Define_SMW_GraphicsBankCount
		if !SMW_ManagedGraphicsFillBank == 0
			org !Loc_SMW_GraphicsBank_Streams
		else
			org ((!Define_SMW_GraphicsBank+!SMW_ManagedGraphicsFillBank)<<$10)|$8008
		endif
		fillbyte $FF : fill (((!Define_SMW_GraphicsBank+!SMW_ManagedGraphicsFillBank)<<$10)|$FFFF)-pc()
		!SMW_ManagedGraphicsFillBank #= !SMW_ManagedGraphicsFillBank+1
	endwhile
endif
endmacro
