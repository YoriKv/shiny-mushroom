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
;# palettes share, from wherever their blobs ended to the bank's end -- and
;# the padding between the stock placements is emitted nowhere, so the runs
;# are exactly the level data plus that padding. A stream that grows pushes
;# every stream after it along, asar recomputes every pointer-table row from
;# the labels, and a stream that reaches the end of a run is placed at the
;# start of the next: the same thing the relocated overworld tables do, one
;# level up, with the bank boundary as the only line that needs saying.
;# Nothing reaches the level bank until banks $06 and $07 are full. Whatever
;# a run has left when the packing moves past it is filled with $FF, which is
;# what the shipped padding is on the releases that have any and what a
;# reader looking for free space recognises.
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
;# the $200 bytes below the end of bank $07 with its stub directly before,
;# the same slot on every base. It has to be one address the whole toolchain
;# can name without a symbol, and bank $07 is one of the game's own banks,
;# where the level bank moves with the base's reservation. The sprite memory index a base
;# sets (Config/SpriteMemoryIndex.asm) is written by following the pointer
;# table with the loader's bank $07 literal, and under this define its walk
;# reads the bank off this table instead -- by address, since the finalize
;# pass it runs on includes no bank; SA-1 Pack's own copy of that walk reads
;# it the same way when a pack run has it on. The
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
;# The packing is emitted as one sequence from the tail of the ROM map,
;# %SMW_PlaceManagedLevels: the seven level macros are invoked again there
;# in the map's order, and at their own map lines they emit nothing -- the
;# runs the map gave them are holes, and every placement guard after them
;# stays true. Once every bank has emitted, and after the level bank's own
;# sequence, because the fourth run opens where that ended.
;#
;# The level files a project adds are packed here too, after the banks' own
;# streams: levels/added/added-levels.asm is one %SMW_InsertLevelData per
;# added stream, under the labels the pointer tables spell (ShinyLevel_L1_*
;# and ShinyLevel_SP_*, unnamespaced because those tables spell them bare),
;# read by %SMW_PlaceManagedLevels before the runs are closed. Room
;# for them is whatever the runs have left -- and what a deleted level gives
;# back: levels/deleted-levels.asm names the streams the project has deleted,
;# and %SMW_InsertLevelData inserts each as the empty level under its own
;# label. Both fragments the editor regenerates; both ship empty.
;#
;# The define needs a cartridge the level bank exists in, 1 MB or larger,
;# which the bank's reservation says rather than letting the image quietly
;# double (Config/LevelBank.asm).
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
;# Run 3 is the level bank's, from where the bank's own sequence ended --
;# behind the palettes' blobs and the project's code -- to the bank's end
;# label: Config/LevelBank.asm states both.
;#
;# What the packing fills of run 2 stops at the tail this file fixes at the
;# top of bank $07 -- !Loc_SMW_ManagedLevelRun2_PackedEnd, the run's end for
;# everything but the ROM map's own boundary.
;#############################################################################################################

!Loc_SMW_ManagedLevelRun0_Start	#= $068000	;> the first level macro in bank $06
!Loc_SMW_ManagedLevelRun0_End	#= $070000	;> the end of bank $06
!Loc_SMW_ManagedLevelRun1_Start	#= $078000	;> the first level macro in bank $07
!Loc_SMW_ManagedLevelRun1_End	#= $07F000	;> SMW_ProcessNormalSprites, the first routine after the level data
!Loc_SMW_ManagedLevelRun2_Start	#= $07FC90	;> the padding behind the bank's last routine
!Loc_SMW_ManagedLevelRun2_End	#= $080000	;> the end of bank $07

; The sprite-bank stub's size, and the tail it and the table take off the
; run they sit at the top of. Part of that run's budget: the editor prices
; it against the same two numbers, so a change to the stub is a change to
; that budget and not only to this file. The placement asserts both.
!Define_SMW_ManagedLevelStubBytes	#= $11
!Define_SMW_ManagedLevelTail		#= $0200+!Define_SMW_ManagedLevelStubBytes

; Where the tail goes, and what run 2 therefore ends at. The top of bank
; $07, on every base: the tail has to be at one address the whole toolchain
; can name without a symbol, and the level bank moves with the base's
; reservation where bank $07 does not.
!Loc_SMW_ManagedLevelTail_At	#= !Loc_SMW_ManagedLevelRun2_End-!Define_SMW_ManagedLevelTail
!Loc_SMW_ManagedLevelRun2_PackedEnd	#= !Loc_SMW_ManagedLevelTail_At

; Where the packing has got to, and whether the packing is what is being
; emitted. Reset here, which is once per assembler pass, because this file
; is read at the start of each of them.
!SMW_ManagedLevelRun	#= 0
!SMW_ManagedLevelNext	#= !Loc_SMW_ManagedLevelRun0_Start
!SMW_ManagedLevelEnd	#= !Loc_SMW_ManagedLevelRun0_End
!SMW_ManagedLevelEmit = !FALSE
!SMW_ManagedLevelHeadEmitted = !FALSE

;#############################################################################################################

; A level macro's slot in the ROM map, or its turn in the packing. The
; seven macros are invoked twice under the define: from their ROM map lines,
; where each orgs to its stock address as ever and emits nothing -- the run
; the map gave it is a hole, and every placement guard after it stays true
; -- and again from %SMW_PlaceManagedLevels, in map order, where each emits
; its streams wherever the packing has got to. !SMW_ManagedLevelEmit says
; which; %SMW_InsertLevelData reads the same flag. The first turn in the
; packing also emits the run's head: the Chocolate Island 2 hook and its
; bank table, before any stream, so the stub keeps one address whatever the
; streams do.
macro SMW_ManagedLevelSlot(StockAddress)
if !Define_SMW_ManagedLevelMemory == !TRUE && !SMW_ManagedLevelEmit == !TRUE
	if !SMW_ManagedLevelHeadEmitted == !FALSE
		assert pc() == !Loc_SMW_ManagedLevelRun0_Start, "The level packing must open at the first run's start. Check %SMW_PlaceManagedLevels."
		%SMW_ManagedLevelMemory_Head()
		!SMW_ManagedLevelHeadEmitted = !TRUE
	endif
else
	%InsertMacroAtXPosition(<StockAddress>)
endif
endmacro

; Move the packing to the next run, giving the rest of this one to the
; cartridge as $FF. Four runs, so a stream is offered at most three moves
; before the banks are full, and the error says so by name rather than
; leaving asar to report a position. The fourth opens where the level bank's
; own sequence ended -- behind the palettes' blobs and the project's code, or
; at the run's head when none of them is on -- and ends at the bank's end.
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
		!SMW_ManagedLevelEnd #= !Loc_SMW_ManagedLevelRun2_PackedEnd
	elseif !SMW_ManagedLevelRun == 3
		!SMW_ManagedLevelNext #= !SMW_LevelBank_StreamsAt
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
; its label is placed. Called by %SMW_InsertLevelData while the packing is
; being emitted. A sprite list has no bank to keep: the loader reads each
; list's bank off the tail's table, so it goes wherever the packing has got
; to like any other stream.
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
; Emitted from inside a level macro's turn in the packing, every one of
; which has opened the SMW namespace its labels are read under; the
; namespace is closed around the stub so its labels are spelled here
; exactly as the hook names them, and reopened for the streams that follow.
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

; The packing itself, as one sequence: one org at the first run's start,
; then the seven level macros in the ROM map's order -- their turn in the
; packing, each inserting its streams where the packing has got to and
; moving it on a run when one would not fit -- then the level files the
; project adds, a label where the streams end, and the fills: what the run
; they ended in has left, then every run of the stock banks the packing
; never reached -- the stock fills those runs held emit nothing under the
; define, and a run the assembler never wrote is zeroes otherwise. The
; level bank's rest is the reservation's, and stays as the reservation
; left it. Then bank $07's tail, the sprite-bank stub and its table, at its
; fixed address.
;
; Called once from each ROM map after every bank has emitted and after the
; level bank's own sequence, whose end is where the fourth run opens. The
; added fragment's labels are spelled bare because the map calls this
; outside any namespace. Nothing after the ROM map reads the position this
; leaves.
macro SMW_PlaceManagedLevels()
if !Define_SMW_ManagedLevelMemory == !TRUE
	!SMW_ManagedLevelEmit = !TRUE
	org !Loc_SMW_ManagedLevelRun0_Start
	%DATATABLE_RT00_SMW_LevelData(NULLROM)
	%DATATABLE_RT01_SMW_LevelData(NULLROM)
	%DATATABLE_RT02_SMW_LevelData(NULLROM)
	%DATATABLE_RT03_SMW_LevelData(NULLROM)
	%DATATABLE_RT04_SMW_LevelData(NULLROM)
	%DATATABLE_RT05_SMW_LevelData(NULLROM)
	%DATATABLE_RT06_SMW_LevelData(NULLROM)
SMW_ManagedLevelMemory_Added:
	incsrc "levels/added/added-levels.asm"
	!SMW_ManagedLevelEmit = !FALSE
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
		fillbyte $FF : fill !Loc_SMW_ManagedLevelRun2_PackedEnd-!Loc_SMW_ManagedLevelRun2_Start
	endif
	%SMW_ManagedLevelMemory_Tail()
endif
endmacro

; Bank $07's tail: the sprite-bank stub and its table, at the fixed address
; the top of this file states. Called from %SMW_PlaceManagedLevels once the
; packing has closed.
macro SMW_ManagedLevelMemory_Tail()
if !Define_SMW_ManagedLevelMemory == !TRUE
	org !Loc_SMW_ManagedLevelTail_At
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
	assert pc() == !Loc_SMW_ManagedLevelRun2_End, "The managed level banks' tail does not end at the end of bank $07."
endif
endmacro
