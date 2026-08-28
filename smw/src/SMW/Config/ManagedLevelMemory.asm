includeonce

;#############################################################################################################
;# Managing the level banks as packed runs, with the level bank behind them.
;#
;# The level streams live in banks $06 and $07 as seven bank macros, each
;# placed by RomMap/ at a literal address and each packed to the byte
;# against the padding the map places after it. So a level's room is not
;# its own: an object added to one level has to be paid for by another
;# level in the same macro shrinking, and the 8,991 bytes of padding the
;# two banks hold between and behind those macros are room for nothing.
;#
;# Setting !Define_SMW_ManagedLevelMemory to !TRUE makes the two banks a
;# sequence instead. Every stream the seven macros insert is emitted back to
;# back in ROM-map order into four runs -- the whole of bank $06, bank $07
;# up to the sprite routines at $07F000, bank $07's tail past them, and the
;# level bank (Config/LevelBank.asm): the expansion bank the custom level
;# palettes share, from wherever their blobs ended to the fixed tail below
;# -- and the padding between the stock placements is emitted nowhere, so
;# the runs are exactly the level data plus that padding. A stream that
;# grows pushes every stream after it along, asar recomputes every
;# pointer-table row from the labels, and a stream that reaches the end of
;# a run is placed at the start of the next: the same thing the relocated
;# overworld tables do, one level up, with the bank boundary as the only
;# line that needs saying. Nothing reaches the level bank until banks $06
;# and $07 are full. Whatever a run has left when the packing moves past it
;# is filled with $FF, which is what the shipped padding is on the releases
;# that have any and what a reader looking for free space recognises.
;#
;# Two facts about the loader decide what may land where, and the feature
;# hooks both, each with a JSL of exactly the size of the instructions it
;# stands in for -- SA-1 Pack patches that routine's operands by literal
;# address and nothing in it may move:
;#
;# - The sprite pointer table is dw, and SMW_SpecifySublevelToLoad
;#   completes each address with the one bank every shipped sprite list is
;#   in, SMW_SpriteDataBank>>16 -- which would pin every sprite list to
;#   bank $07. Under the define the two instructions that supply the byte
;#   are a JSL to the stub at the level bank's tail, at the spot Lunar
;#   Magic marks as LM100Hijack_RemoveHardcodedSpriteListBank, which reads
;#   the bank off a table of one byte per level. So a sprite list is a
;#   stream like any other and lands wherever the packing has got to.
;# - Chocolate Island 2 picks one of nine sub-levels out of a dw table in
;#   the same routine, writing only the low and high bytes of the Layer 1
;#   pointer over the row the main path resolved for level $024 -- so on a
;#   stock cartridge the nine share $024's bank by construction. Packed,
;#   they need not, and the hook at the first run's head reads each
;#   sub-level's bank from a table beside it.
;#
;# The tail is fixed, and that is not tidiness: the sprite-bank table is
;# the $200 bytes below the level bank's end label with its stub directly
;# before, the same slot on every cartridge this bank is, because SA-1 Pack
;# rewrites every sprite list's header byte by following the pointer table
;# with the loader's bank $07 literal, and under this define its patch pass
;# reads the bank off this table instead -- by address, since that pass
;# runs after this source has assembled and sees no symbol of ours. The
;# table's rows are levels/pointers/sprite-banks.asm, one `db <label>>>$10`
;# per level naming the label the sprite pointer table names in the same
;# row, so a level remapped in one is remapped in the other; the editor
;# regenerates it whenever it rewrites the sprite table, and the shipped
;# copy mirrors the shipped table.
;#
;# The roll-call screens in bank $0C stay where they are: they are level
;# data inside a routine that reads them through dw pointers and its own
;# bank, and they are not levels a pointer table names.
;#
;# The label a stream is reached by is emitted by the insertion macro rather
;# than the line above it, because the check that moves a stream to the
;# next run has to run before the label is placed -- %SMW_InsertLevelData in
;# SNES_Macros_SMW.asm, which every insertion in banks $06 and $07 goes
;# through.
;#
;# The level files a project adds are packed here too, after the banks' own
;# streams: levels/added/added-levels.asm is one %SMW_InsertLevelData per
;# added stream, under the labels the pointer tables spell (ShinyLevel_L1_*
;# and ShinyLevel_SP_*, unnamespaced because those tables spell them bare),
;# read by %SMW_ManagedLevelMemory_Close before the runs are closed. Room
;# for them is whatever the runs have left -- and what a deleted level gives
;# back: levels/deleted-levels.asm names the streams the project has deleted,
;# and %SMW_InsertLevelData inserts each as the empty level under its own
;# label. Both fragments the editor regenerates; both ship empty.
;#
;# The define needs a cartridge the level bank exists in, 1 MB or larger,
;# which the bank's reservation says rather than letting the image quietly
;# double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_ManagedLevelMemory=1 packs the level banks.
if defined("Define_SMW_ManagedLevelMemory") == 0
	!Define_SMW_ManagedLevelMemory = !FALSE
endif

; The streams the project has deleted, as !SMW_LevelDeleted_<Label> defines.
; Read whatever the define above says: a deleted level is the empty level on
; a stock build as well, where the room it gives back goes to the streams
; after it in its macro and to the fitted padding behind them.
incsrc "levels/deleted-levels.asm"

;#############################################################################################################
;# The runs, in the order the packing fills them.
;#
;# Literal, like every placement in RomMap/, and checked against the maps
;# rather than derived from them: run 0 is bank $06 whole, run 1 is bank
;# $07 from its first level macro to the sprite routines the map places at
;# $07F000, and run 2 is the padding behind the last of those routines to
;# the end of the bank. Every ROM map places the same three boundaries.
;# Run 3 is the level bank's, from the cursor the custom level palettes
;# leave to the tail this file fixes: Config/LevelBank.asm states both.
;#############################################################################################################

!Loc_SMW_ManagedLevelRun0_Start	#= $068000	;> the first level macro in bank $06
!Loc_SMW_ManagedLevelRun0_End	#= $070000	;> the end of bank $06
!Loc_SMW_ManagedLevelRun1_Start	#= $078000	;> the first level macro in bank $07
!Loc_SMW_ManagedLevelRun1_End	#= $07F000	;> SMW_ProcessNormalSprites, the first routine after the level data
!Loc_SMW_ManagedLevelRun2_Start	#= $07FC90	;> the padding behind the bank's last routine
!Loc_SMW_ManagedLevelRun2_End	#= $080000	;> the end of bank $07

; The sprite-bank stub's size, and the tail it and the table take off the
; level bank's run. Part of the run's budget: the editor prices the bank
; against the same two numbers, so a change to the stub is a change to that
; budget and not only to this file. The placement asserts both.
!Define_SMW_ManagedLevelStubBytes	#= $11
!Define_SMW_ManagedLevelTail		#= $0200+!Define_SMW_ManagedLevelStubBytes

; Where the packing has got to. Reset here, which is once per assembler
; pass, because this file is read at the start of each of them.
!SMW_ManagedLevelRun	#= 0
!SMW_ManagedLevelNext	#= !Loc_SMW_ManagedLevelRun0_Start
!SMW_ManagedLevelEnd	#= !Loc_SMW_ManagedLevelRun0_End
!SMW_ManagedLevelPacking = !FALSE
!SMW_ManagedLevelHeadEmitted = !FALSE

;#############################################################################################################

; Open a level macro's placement: at <StockAddress> when the banks are
; stock, and wherever the packing has got to when they are managed. The
; managed case brackets the emission with pushpc/pullpc after an org to the
; stock address, exactly as %SMW_RelocatableTableStart does, so the ROM
; map's own position carries on from the front of the run the macro used
; to fill and every warnpc after it stays true. The first placement also
; emits the run's head: the Chocolate Island 2 hook and its bank table,
; before any stream, so the stub keeps one address whatever the streams do.
macro SMW_ManagedLevelRunStart(StockAddress)
if !Define_SMW_ManagedLevelMemory == !TRUE
	org <StockAddress>
	pushpc
	org !SMW_ManagedLevelNext
	if !SMW_ManagedLevelHeadEmitted == !FALSE
		%SMW_ManagedLevelMemory_Head()
		!SMW_ManagedLevelHeadEmitted = !TRUE
	endif
	!SMW_ManagedLevelPacking = !TRUE
else
	%InsertMacroAtXPosition(<StockAddress>)
endif
endmacro

; Close the placement %SMW_ManagedLevelRunStart opened: carry the packing
; forward and put the ROM map's position back.
macro SMW_ManagedLevelRunEnd()
if !Define_SMW_ManagedLevelMemory == !TRUE
	!SMW_ManagedLevelPacking = !FALSE
	!SMW_ManagedLevelNext #= pc()
	pullpc
endif
endmacro

; Move the packing to the next run, giving the rest of this one to the
; cartridge as $FF. Four runs, so a stream is offered at most three moves
; before the banks are full, and the error says so by name rather than
; leaving asar to report a position. The fourth opens at the cursor the
; custom level palettes left in the level bank -- the run's head when they
; are off -- and ends at the tail below.
macro SMW_ManagedLevelAdvance()
	if pc() < !SMW_ManagedLevelEnd
		fillbyte $FF : fill !SMW_ManagedLevelEnd-pc()
	endif
	!SMW_ManagedLevelRun #= !SMW_ManagedLevelRun+1
	if !SMW_ManagedLevelRun == 1
		!SMW_ManagedLevelNext #= !Loc_SMW_ManagedLevelRun1_Start
		!SMW_ManagedLevelEnd #= !Loc_SMW_ManagedLevelRun1_End
	elseif !SMW_ManagedLevelRun == 2
		!SMW_ManagedLevelNext #= !Loc_SMW_ManagedLevelRun2_Start
		!SMW_ManagedLevelEnd #= !Loc_SMW_ManagedLevelRun2_End
	elseif !SMW_ManagedLevelRun == 3
		!SMW_ManagedLevelNext #= !SMW_LevelBankNext
		!SMW_ManagedLevelEnd #= !Loc_SMW_LevelBank_RunEnd
	else
		error "The level banks are full: the level streams no longer fit banks $06 and $07 and the level bank end to end. Take bytes out of a level."
	endif
	org !SMW_ManagedLevelNext
endmacro

; Whether the stream about to be inserted has to move: it would run past
; the end of this run.
macro SMW_ManagedLevelNeedsMove(Size)
	!SMW_ManagedLevelMove = !FALSE
	if pc()+(<Size>) > !SMW_ManagedLevelEnd
		!SMW_ManagedLevelMove = !TRUE
	endif
endmacro

; Find the stream of <Size> bytes about to be inserted a run it fits, before
; its label is placed. Called by %SMW_InsertLevelData while a level macro is
; open and the banks are managed. A sprite list has no bank to keep: the
; loader reads each list's bank off the tail's table, so it goes wherever
; the packing has got to like any other stream.
macro SMW_ManagedLevelFit(Size)
	%SMW_ManagedLevelNeedsMove(<Size>)
	if !SMW_ManagedLevelMove == !TRUE
		%SMW_ManagedLevelAdvance()
		%SMW_ManagedLevelNeedsMove(<Size>)
	endif
	if !SMW_ManagedLevelMove == !TRUE
		%SMW_ManagedLevelAdvance()
		%SMW_ManagedLevelNeedsMove(<Size>)
	endif
	if !SMW_ManagedLevelMove == !TRUE
		%SMW_ManagedLevelAdvance()
		%SMW_ManagedLevelNeedsMove(<Size>)
	endif
	assert !SMW_ManagedLevelMove == !FALSE, "The level banks are full: a level stream fits no run of banks $06 and $07 or the level bank. Take bytes out of a level."
endmacro

; The first run's head: the Chocolate Island 2 hook and its bank table.
; Entered from the JSL in Banks/Bank05.asm with A 16-bit and X 8-bit, X the
; chosen sub-level's row doubled, exactly as the displaced read indexed its
; dw table. The read is repeated, then the bank the dw row lost comes from
; a word table in the same stride, and A goes back to 16 bits as the hook
; found it. Direct page is the bank $05 routine's own, so the stores land
; where the displaced one did.
;
; Emitted from inside a level macro, every one of which has opened the SMW
; namespace its labels are read under; the namespace is closed around the
; stub so its labels are spelled here exactly as the hook names them, and
; reopened for the streams that follow.
macro SMW_ManagedLevelMemory_Head()
namespace off
SMW_ManagedLevelMemory_Start:
SMW_ManagedLevelMemory_ChocolateIsland2Layer1:
	LDA.l SMW_SpecifySublevelToLoad_Layer1Ptrs,x	;> The displaced read: the sub-level's address, low and high
	STA.b !RAM_SMW_Pointer_Layer1DataLo
	SEP.b #$20				; A->8
	LDA.l .Banks,x
	STA.b !RAM_SMW_Pointer_Layer1DataBank
	REP.b #$20				; A->16, as the hook found it
	RTL
; One word per row of SMW_SpecifySublevelToLoad_Layer1Ptrs, in its order:
; the bank of the stream the row names.
.Banks:
	dw SMW_LEVEL_L1_0CD>>$10
	dw SMW_LEVEL_L1_024_5>>$10
	dw SMW_LEVEL_L1_024_5>>$10
	dw SMW_LEVEL_L1_0CF>>$10
	dw SMW_LEVEL_L1_024_1>>$10
	dw SMW_LEVEL_L1_024_2>>$10
	dw SMW_LEVEL_L1_0CE>>$10
	dw SMW_LEVEL_L1_024_3>>$10
	dw SMW_LEVEL_L1_024_4>>$10
SMW_ManagedLevelMemory_Streams:
namespace SMW
endmacro

; Close the packing: pack the level files the project adds after the banks'
; own streams, label where the streams end, and fill what the run they
; ended in has left with $FF, then every run of the stock banks the packing
; never reached -- the stock fills those runs held emit nothing under the
; define, and a run the assembler never wrote is zeroes otherwise. The
; level bank's rest is the reservation's, and stays as the reservation
; left it. Called once from each ROM map after every bank has emitted,
; beside the other features' placements; the whole of it is bracketed with
; pushpc/pullpc like every placement there, and the added fragment's labels
; are spelled bare because the map calls this outside any namespace.
macro SMW_ManagedLevelMemory_Close()
if !Define_SMW_ManagedLevelMemory == !TRUE
	pushpc
	org !SMW_ManagedLevelNext
	!SMW_ManagedLevelPacking = !TRUE
SMW_ManagedLevelMemory_Added:
	incsrc "levels/added/added-levels.asm"
	!SMW_ManagedLevelPacking = !FALSE
SMW_ManagedLevelMemory_Free:
	if !SMW_ManagedLevelRun < 3
		if pc() < !SMW_ManagedLevelEnd
			fillbyte $FF : fill !SMW_ManagedLevelEnd-pc()
		endif
	endif
	if !SMW_ManagedLevelRun < 1
		org !Loc_SMW_ManagedLevelRun1_Start
		fillbyte $FF : fill !Loc_SMW_ManagedLevelRun1_End-!Loc_SMW_ManagedLevelRun1_Start
	endif
	if !SMW_ManagedLevelRun < 2
		org !Loc_SMW_ManagedLevelRun2_Start
		fillbyte $FF : fill !Loc_SMW_ManagedLevelRun2_End-!Loc_SMW_ManagedLevelRun2_Start
	endif
	pullpc
endif
endmacro

; The level bank's tail: the sprite-bank stub and its table. Called from
; each ROM map after the close, beside the bank's reservation, and
; bracketed with pushpc/pullpc like every placement there.
macro SMW_ManagedLevelMemory_Tail()
if !Define_SMW_ManagedLevelMemory == !TRUE
	pushpc
	org !Loc_SMW_LevelBank_RunEnd
SMW_ManagedLevelMemory_Tail:
; The sprite-list bank, per level. The hook in Banks/Bank05.asm lands here
; with A 8-bit, X and Y 16-bit, and Y the level number doubled -- the
; stride of the dw pointer rows it has just read. Long indexed addressing
; only exists for X, and the table is a byte a level, so the index is
; halved on its way across; X is dead at the hook, reloaded before its next
; use. The accumulator's high byte is not: a TAX below the hook, with A
; 8-bit and X 16-bit, transfers the whole accumulator, hidden high byte
; included, and the loader's entrance tables are then indexed by whatever
; it holds -- the stock path left it zero, so it is cleared before A goes
; back to 8 bits. The store is direct-page, as the two instructions this
; stands in for made it.
SMW_ManagedLevelMemory_SpriteBank:
	REP.b #$20				; A->16
	TYA
	LSR					;> The level number
	TAX
	LDA.w #$0000				;> The high byte too: see above
	SEP.b #$20				; A->8, as the hook found it
	LDA.l SMW_ManagedLevelMemory_SpriteBanks,x
	STA.b !RAM_SMW_Pointer_SpriteListDataBank
	RTL
	assert pc() == SMW_ManagedLevelMemory_Tail+!Define_SMW_ManagedLevelStubBytes, "The managed level banks' sprite-bank stub is not the size its budget states. Check Define_SMW_ManagedLevelStubBytes."
; One byte per level, in level order: the bank of the sprite list the
; pointer table's row names.
SMW_ManagedLevelMemory_SpriteBanks:
	incsrc "levels/pointers/sprite-banks.asm"
	assert pc() == SMW_ManagedLevelMemory_SpriteBanks+$0200, "The sprite-bank table must hold one byte for each of the $200 levels. Check levels/pointers/sprite-banks.asm."
	assert pc() == !Loc_SMW_LevelBank_End, "The managed level banks' tail does not end at the level bank's end label."
	pullpc
endif
endmacro
