includeonce

;#############################################################################################################
;# Relocating the overworld's data tables into an expansion bank.
;#
;# Every table in this game is placed at a literal address by RomMap/, so the
;# room it has to grow is the distance to whatever the map put after it. For the
;# overworld that distance is nothing, and that is not a figure of speech: all
;# eleven of its editable fragments fill the run the map gave them to the byte,
;# the 1,484-byte Layer 2 event entries included. The cartridge has nowhere to
;# put the overflow either -- its own padding totals 27,543 bytes across 46
;# runs, half of that the tail of a bank rather than a gap between two
;# routines, and bank $04's share of it is 1,499.
;#
;# Setting !Define_SMW_RelocateOverworldTables to !TRUE moves eight of the
;# overworld's eleven editable table fragments into the reserved bank --
;# twenty-two tables, in nine placements, the Layer 2 event pointers and
;# entries being placed separately -- packed into the run there, and leaves a
;# hole where each one used to be. The tables are named by
;# label everywhere they are read, so most of the code follows them untouched;
;# the twelve sites that read one with a 16-bit address and an index in Y have
;# no long-addressed form and point the data bank at the run instead. Those
;# are written out under this same define in Banks/Bank04.asm.
;#
;# The bank, the RATS tag over it and the cursor the fragments pack at are
;# Config/ReservedBank.asm's, and are shared with the other growable features.
;# This file emits the second of that run's three occupants, so a fragment
;# here lands after the translevel remap table when that feature is on and at
;# the run's head when it is not.
;#
;# They go in back to back, with nothing between them. A fragment's room is
;# the distance to the next thing that cannot move, so padding between two
;# relocated fragments is not room for either of them -- it is room for
;# nobody. Packed, they push each other along and the assembler recomputes
;# every address after the one that grew, which is the same thing the tables
;# inside a single fragment already do. What bounds them is the end of the
;# run, and everything in it shares that bound: whatever these fragments do
;# not use, the relocated strings may. The addresses a build lands on are read
;# back off its own symbol file, so a fragment that grew and pushed the rest
;# along is read where it ended up.
;#
;# Three of the overworld's tables deliberately stay in bank $04:
;#
;# - The level names have 772 bytes where they are, which is more than a slot
;#   here would give them, and the two routines that read them have no room for
;#   the extra byte a long read costs.
;# - The level event numbers have 256, the same a slot would give.
;# - The submap disable flags would gain, but the four bytes the long read costs
;#   do not exist in SMW_CheckIfXIsAllowedOnYSubmap, and the ten they would gain
;#   are worth nothing until there are more overworld sprite routines to read
;#   them.
;#
;# The destruction tables move only because the relocated build also binds
;# their scan to the table's own labels: on a stock build the scan runs 24
;# entries over the 16-entry table and reads the eight bytes after it --
;# %INLINEDATATABLE_SMW_SavePromptLevels, four of them event numbers it acts
;# on -- so the two are one run there, and moving the table alone would change
;# what the game reads. Bound to the labels, the scan reads the table whole and
;# nothing past it, which is also what lets its rows grow.
;#
;# The define needs a cartridge assembled at 1 MB or larger, and the
;# reservation says so rather than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_RelocateOverworldTables=1 relocates them.
if defined("Define_SMW_RelocateOverworldTables") == 0
	!Define_SMW_RelocateOverworldTables = !FALSE
endif

;#############################################################################################################
;# What the move leaves behind.
;#
;# A relocated fragment's line in RomMap/ still orgs to its stock address and
;# now emits nothing, so the run the map gave it becomes a hole -- and nothing
;# in the image says so. The map goes on naming the macro that used to fill it,
;# the bytes are whatever asar left there, and a symbol file has no entry for a
;# run with nothing in it. A reader looking for somewhere to put a routine would
;# have to know which tables moved to know the room is there at all.
;#
;# So each hole is named. %SMW_RelocatableTableEnd drops a label on it, which is
;# what makes it findable: by anyone reading a symbol file, and by the editor's
;# memory map, which shows it as free space (docs/editor/memory-map.md). The
;# label is emitted only when the tables have moved, so a stock build gains no
;# symbol -- and a symbol above a fragment is a symbol that shortens the room
;# smw_tools.asm_regions.room measures for it.
;#
;# Two of the holes are spent again immediately: %SMW_RelocatedRoutineStart
;# starts the routine the table was cut out of at the table's old address,
;# because the data bank swaps it grew by need room the ROM map did not leave
;# it. Those two are not free and are not labelled.
;#
;# Which is which is stated here rather than discovered, because a table's
;# placement is emitted before the routine that would reclaim it and cannot ask.
;# %SMW_RelocatedRoutineStart asserts against this, so the two cannot drift.
;#############################################################################################################

!Vacancy_SMW_WalkDirections		#= !TRUE
!Vacancy_SMW_Layer1EventSwaps		#= !TRUE
!Vacancy_SMW_Layer1EventLocations	#= !TRUE
!Vacancy_SMW_SilentTiles		#= !TRUE
!Vacancy_SMW_StarPipeWarps		#= !FALSE	;> SMW_HandleOverworldStarPipeWarp starts here instead
!Vacancy_SMW_PathExits			#= !FALSE	;> SMW_HandleOverworldPathExits starts here instead
!Vacancy_SMW_Layer2EventPtrs		#= !TRUE
!Vacancy_SMW_Layer2EventEntries		#= !TRUE
!Vacancy_SMW_DestroyedTiles		#= !TRUE

;#############################################################################################################

; Open a table's placement: after whatever went into the run last when the
; tables have moved, and at <StockAddress> otherwise. The relocated case brackets the emission with
; pushpc/pullpc, so the bank the table came out of carries on from where it left
; off -- a hole the size of the table, and every warnpc after it still true.
;
; It is a plain org rather than %InsertMacroAtXPosition because asar refuses a
; warnpc between a pushpc and its pullpc; %SMW_RelocatableTableEnd asserts the
; slot instead, which is an error rather than a warning and so the stronger
; check. Every %SMW_RelocatableTableStart must be closed by one.
;
; Both branches record where the table sat, because a routine the table was cut
; out of gets that address back -- see %SMW_RelocatedRoutineStart.
;
; The relocated branch orgs to <StockAddress> before it pushes, so the PC its
; pullpc restores is the front of the hole rather than wherever the last macro
; happened to stop. Two relocated placements in a row would otherwise both come
; back to the address of whatever preceded the pair -- which is the PC every
; later warnpc is measured against, and the address %SMW_RelocatableTableEnd
; puts the vacancy label on.
macro SMW_RelocatableTableStart(StockAddress, Slot)
!Vac_SMW_<Slot> #= <StockAddress>
if !Define_SMW_RelocateOverworldTables == !TRUE
	org <StockAddress>
	pushpc
	org !SMW_ReservedBankNext
else
	%InsertMacroAtXPosition(<StockAddress>)
endif
endmacro

; Close the placement %SMW_RelocatableTableStart opened: price what went in,
; carry the packed run's position forward, and name the run the move left empty.
;
; <Slot> again rather than a define carried over from the Start: the two macros
; then share no state at all, and an End that names a different slot from its
; Start is a mismatch the reader can see rather than one that silently prices a
; fragment against somebody else's room.
;
; The label goes here rather than beside the org in the Start because a bank
; macro turns its namespace off before closing -- and a namespaced label would
; be SMW_Layer2EventData_SMW_VacatedOverworldTable_Layer2EventPtrs, which is
; not a name anything can look for. pullpc has put the PC on the front of the
; hole by now, so this is the same address either way.
macro SMW_RelocatableTableEnd(Slot)
if !Define_SMW_RelocateOverworldTables == !TRUE
	assert pc() <= !Loc_SMW_ReservedBank_End, "The relocated overworld tables have outgrown the reserved run: less fits in it than the editor was told. Check overworld/tables/."
	!SMW_ReservedBankNext #= pc()
	pullpc
	if !Vacancy_SMW_<Slot> == !TRUE
SMW_VacatedOverworldTable_<Slot>:
	endif
endif
endmacro

; A routine that reads a relocated table with an index in Y has to swap the data
; bank around the reads, and there is no room for that where the ROM map put it.
; There is where its table was: <Slot> named a run of ROM at the front of this
; same routine, and relocating it hands those bytes back. So the routine starts
; at the table's old address instead, and the reads it grew by fit inside what
; the two of them occupied together.
;
; Only for a routine whose own table moved out from directly in front of it, and
; only for a slot the vacancy map says nothing else has a claim on: a run given
; away here and labelled empty above would be offered to a reader who would find
; a routine in it.
macro SMW_RelocatedRoutineStart(StockAddress, Slot)
if !Define_SMW_RelocateOverworldTables == !TRUE
	assert !Vacancy_SMW_<Slot> == !FALSE, "The <Slot> run is taken by a routine and the vacancy map in Config/OverworldTableRelocation.asm still calls it empty."
	%InsertMacroAtXPosition(!Vac_SMW_<Slot>)
else
	%InsertMacroAtXPosition(<StockAddress>)
endif
endmacro
