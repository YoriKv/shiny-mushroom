includeonce

;#############################################################################################################
;# The graphics banks: the last reservation an expanded cartridge makes,
;# taking as many banks upward as the managed graphics need.
;#
;# The growable features' run (Config/ReservedBank.asm) and the level bank
;# (Config/LevelBank.asm) are each one bank, because each holds occupants
;# whose appetite is bounded. The graphics are not: a project may redraw
;# every one of the game's 52 files with pixels that compress worse and add
;# files up to $FE, so the room they need is whatever the project makes it.
;# The managed graphics (Config/ManagedGraphicsMemory.asm) therefore pack
;# into a run of whole banks -- !Define_SMW_GraphicsBankCount of them from
;# !Define_SMW_GraphicsBank up -- and that count is a build setting the
;# editor raises with the project's cartridge size.
;#
;# Each bank is reserved whole behind a RATS tag of its own, for the
;# reserved run's reason: asar's freespace search takes any long enough run
;# of $00, and a bank the packing has not reached is exactly that, so what
;# holds a bank is the tag over it and a bank boundary is the only line that
;# needs no tuning. A tag protects one bank at most, so there is one per
;# bank; SMW_GraphicsBankStart names the first bank's run and
;# SMW_GraphicsBankEnd the last bank's last byte, the pair the editor reads
;# the whole reservation by.
;#
;# The first bank's head is fixed: the managed graphics' pointer table, its
;# format table and its two stubs, !Define_SMW_ManagedGraphicsHeadBytes in
;# all, so the loader's hooks and the editor reach them at one address on
;# every cartridge this bank is. The packed streams begin behind them, at
;# SMW_ManagedGraphics_Streams, and every later bank is streams from its
;# first byte past the tag.
;#
;# Graphics is the last reservation, and nothing may ever reserve above
;# it: a run that grows upward has no ceiling to price against but the
;# cartridge's end, and a bank reserved above it would be a ceiling
;# nobody declared. A future feature with a fixed appetite reserves below
;# and bumps this define; the count then moves with it.
;#
;# Which bank the run starts in belongs to the cartridge. The default is
;# one past the level bank's, and deliberately fixed rather than derived
;# from it: the reservations are independent, and fixed, distinct defaults
;# are what keeps any combination of the features collision-free. A build
;# whose $12 is spoken for names another with --define
;# Define_SMW_GraphicsBank=$13 -- the sa1 base does, its pack holding $10,
;# the shared run $11 and the level bank $12 -- and every bank from $10 to
;# $3F buys the same two things the reserved run's does: one address at
;# every cartridge size, and the work RAM mirror underneath. smw_tools
;# fills the value in from the base, so the editor reads the cartridge at
;# addresses derived from the same number the assembler was given.
;#
;# The reservation needs a cartridge every bank of it exists in -- 1 MB for
;# a count that ends at bank $1F or below, more above it -- and says so
;# rather than letting the image quietly double.
;#############################################################################################################

; The first bank, and how many. %SMW_ReserveGraphicsBanks asserts that the
; run landed in it.
if defined("Define_SMW_GraphicsBank") == 0
	!Define_SMW_GraphicsBank #= $12
endif
if defined("Define_SMW_GraphicsBankCount") == 0
	!Define_SMW_GraphicsBankCount #= 1
endif
!Define_SMW_GraphicsBankBase #= (!Define_SMW_GraphicsBank<<$10)|$8000
!Define_SMW_GraphicsBankLast #= !Define_SMW_GraphicsBank+!Define_SMW_GraphicsBankCount-1

; Whether anything wants the banks at all. A build without the managed
; graphics reserves nothing, so a stock cartridge gains no RATS tag and no
; symbol.
!Define_SMW_GraphicsBankWanted #= !FALSE
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	!Define_SMW_GraphicsBankWanted #= !TRUE
endif

!Loc_SMW_GraphicsBank_Tag	#= !Define_SMW_GraphicsBankBase+$0000	;> the first bank's RATS tag, 8 bytes
!Loc_SMW_GraphicsBank_Packed	#= !Define_SMW_GraphicsBankBase+$0008	;> the head, and SMW_GraphicsBankStart
!Loc_SMW_GraphicsBank_Streams	#= !Loc_SMW_GraphicsBank_Packed+!Define_SMW_ManagedGraphicsHeadBytes	;> SMW_ManagedGraphics_Streams, the first run's start
!Loc_SMW_GraphicsBank_End	#= (!Define_SMW_GraphicsBankLast<<$10)|$FFFF	;> SMW_GraphicsBankEnd, the last bank's last byte

; The RATS tags over the banks, and the labels that bound the run. Called
; from each ROM map once the packing has closed -- and once more below,
; from the initialize pass, which is the one that matters: asar chooses
; freespace against the file as it stands when a pass starts, so the tags
; have to be on disk before the pass that assembles a patch
; (Config/ReservedBank.asm has the measurement). The ROM map's call writes
; the same bytes again, which is where the end label the editor prices
; against comes from.
macro SMW_ReserveGraphicsBanks()
if !Define_SMW_GraphicsBankWanted == !TRUE
	if !Define_SMW_GraphicsBankCount < 1
		error "The managed graphics need at least one graphics bank. Check Define_SMW_GraphicsBankCount."
	endif
	if !Define_SMW_GraphicsBankLast > $3F
		error "The graphics banks run past bank $3F, above which the work RAM mirror is gone and the loader's stubs cannot run. Fewer banks, or a lower Define_SMW_GraphicsBank."
	endif
	if !Define_SMW_ReservedBankWanted == !TRUE
		if !Define_SMW_GraphicsBank <= !Define_SMW_ReservedBank
			error "The graphics banks must lie above the growable features' bank: graphics is the last reservation. Check the two bank defines."
		endif
	endif
	if !Define_SMW_LevelBankWanted == !TRUE
		if !Define_SMW_GraphicsBank <= !Define_SMW_LevelBank
			error "The graphics banks must lie above the level bank: graphics is the last reservation. Check the two bank defines."
		endif
	endif
	pushpc
	; One reservation each: the banks are separate RATS tags rather than one
	; over the lot, so a bank the packing never reaches still reads as taken.
	!SMW_GraphicsBankIndex #= 0
	while !SMW_GraphicsBankIndex < !Define_SMW_GraphicsBankCount
		%SMW_ReserveExpansionBank("The graphics banks", "Define_SMW_GraphicsBank", !Define_SMW_GraphicsBank+!SMW_GraphicsBankIndex, SMW_GraphicsBank!{SMW_GraphicsBankIndex}Start, SMW_GraphicsBank!{SMW_GraphicsBankIndex}End)
		!SMW_GraphicsBankIndex #= !SMW_GraphicsBankIndex+1
	endwhile
	; And the run's own two labels over the lot of them: the first bank's head,
	; and the last bank's last byte, which is what the packing is priced
	; against. Placed rather than aliased so a symbol file carries both.
	org !Loc_SMW_GraphicsBank_Packed
SMW_GraphicsBankStart:
	org !Loc_SMW_GraphicsBank_End
SMW_GraphicsBankEnd:
	pullpc
	assert (SMW_GraphicsBankStart>>$10) == !Define_SMW_GraphicsBank, "The graphics banks' run is not in the bank the slot map says it is."
	assert SMW_GraphicsBankEnd == !Loc_SMW_GraphicsBank_End, "The graphics banks' end label is not where the layout says the last bank ends."
endif
endmacro

; The same reservation, laid down in the initialize pass -- see the macro.
if !Define_SMW_GraphicsBankWanted == !TRUE
	if !FileType == !FileType_InitializeROM
		%SMW_ReserveGraphicsBanks()
	endif
endif
