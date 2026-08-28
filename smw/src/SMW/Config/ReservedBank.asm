includeonce

;#############################################################################################################
;# The bank an expanded cartridge reserves, and the run the growable features share.
;#
;# Every table in this game is placed at a literal address by RomMap/, so the
;# room it has to grow is the distance to whatever the map put after it -- and
;# for the fragments an editor rewords, that distance is nothing. The cure is
;# an expansion bank: a run with a RATS tag over it, fragments packed back to
;# back inside, and the assembler recomputing every address after the one that
;# grew.
;#
;# There is one such run, and the features that need room share it. That is
;# not thrift about banks -- it is what makes the room fungible. A fragment's
;# ceiling is the end of the run, so text that shrank pays for an overworld
;# table that grew, and neither feature has to guess how much of a bank the
;# other will want. smw_tools.features declares the run as a single TablePool
;# and the editor prices every save in it against the total.
;#
;# Three occupants, in the order the ROM map emits them:
;#
;# - The translevel remap table, at the head (Config/TranslevelRemap.asm).
;# - The relocated overworld tables (Config/OverworldTableRelocation.asm).
;# - The relocated strings, with their stubs (Config/StringTableRelocation.asm).
;#
;# The order is fixed, and it is a fact the reading side depends on: an
;# occupant's address is the run's head plus whatever the occupants ahead of
;# it emitted, so smw_tools.features declares the same order and the same
;# unedited lengths, and reads an unbuilt cartridge without a symbol file.
;# Each occupant is switched on by itself -- one absent contributes nothing
;# and the rest close up behind it.
;#
;# The run is the whole bank behind one RATS tag, and that is not generosity.
;# asar's freespace search does not respect written data -- it takes any long
;# enough run of $00, and a table full of them is exactly that: measured, a
;# four-byte freedata over this cartridge with the RATS tag removed lands a few
;# hundred bytes into the run, inside the relocated overworld tables. What
;# holds a run is the tag over it, so the useful question is not how much to
;# reserve but where to draw the line, and a bank boundary is the only line
;# that needs no tuning. The banks above are untouched and are where a
;# freespace patch goes.
;#
;# Which bank it is belongs to the cartridge rather than to any feature. Every
;# bank from $10 to $3F buys the same two things: one address at every
;# cartridge size from 1 MB up, and the work RAM mirror at $0000-$1FFF
;# underneath, so a routine may point the data bank at the run and keep
;# reading the RAM it needs in the same breath. A base whose $10 is spoken for
;# names another with --define Define_SMW_ReservedBank=$11 -- the sa1 base
;# does, SA-1 Pack running after this source assembles and landing its own
;# code in $10 -- and smw_tools.bases.RomBase.reservation_bank is where each
;# base answers, so the editor reads the run at addresses derived from the
;# same number the assembler was given.
;#
;# The reservation needs a cartridge assembled at 1 MB or larger, and says so
;# rather than letting the image quietly double.
;#############################################################################################################

; The bank, defaulting to the first one an expanded cartridge adds.
; %SMW_ReserveBank asserts that the run landed in it.
if defined("Define_SMW_ReservedBank") == 0
	!Define_SMW_ReservedBank #= $10
endif
!Define_SMW_ReservedBankBase #= (!Define_SMW_ReservedBank<<$10)|$8000

; The value a PEA pushes to put the data bank on the run: both bytes are the
; bank, so either of the two PLBs that follow lands on it.
!Define_SMW_ReservedBankDBR #= !Define_SMW_ReservedBank*$0101

; Whether anything wants the bank at all. A build with none of the three
; features on reserves nothing, so a stock cartridge gains no RATS tag and no
; symbol -- and the editor's memory map draws the expansion banks free from
; end to end, which is what they are.
!Define_SMW_ReservedBankWanted #= !FALSE
if !Define_SMW_RelocateOverworldTables == !TRUE
	!Define_SMW_ReservedBankWanted #= !TRUE
endif
if !Define_SMW_TranslevelRemap == !TRUE
	!Define_SMW_ReservedBankWanted #= !TRUE
endif
if !Define_SMW_RelocateStringTables == !TRUE
	!Define_SMW_ReservedBankWanted #= !TRUE
endif

!Loc_SMW_ReservedBank_Tag	#= !Define_SMW_ReservedBankBase+$0000	;> the RATS tag, 8 bytes
!Loc_SMW_ReservedBank_Packed	#= !Define_SMW_ReservedBankBase+$0008	;> the run, and SMW_ReservedBankStart
!Loc_SMW_ReservedBank_End	#= !Define_SMW_ReservedBankBase+$7FFF	;> SMW_ReservedBankEnd, the bank's last byte

; Where the run has got to: the cursor every occupant packs at and carries
; forward. Reset here, which is once per assembler pass, because this file is
; read at the start of each of them.
!SMW_ReservedBankNext #= !Loc_SMW_ReservedBank_Packed

; The reservation (Config/ExpansionBanks.asm). Called from each ROM map once
; every occupant has emitted -- and once more below, from the initialize pass,
; which is the one that matters.
;
; **asar chooses freespace against the file as it stands when a pass starts.**
; It does not see what that pass writes: measured, a freedata assembled in the
; same pass as these tables lands on top of them and stamps its own RATS tag
; over this one. So the tag has to be on disk before the pass that assembles a
; patch, and that is the initialize pass. The ROM map's call writes the same
; bytes again, which is where the end label the editor prices against comes
; from.
macro SMW_ReserveBank()
if !Define_SMW_ReservedBankWanted == !TRUE
	pushpc
	%SMW_ReserveExpansionBank("The growable features' reserved bank", "Define_SMW_ReservedBank", !Define_SMW_ReservedBank, SMW_ReservedBankStart, SMW_ReservedBankEnd)
	pullpc
endif
endmacro

; The same reservation, laid down in the initialize pass. Guarded on the pass
; rather than left to the ROM map, because by the time the ROM map runs the
; freespace search for that pass has already been answered from the file this
; writes into.
if !Define_SMW_ReservedBankWanted == !TRUE
	if !FileType == !FileType_InitializeROM
		%SMW_ReserveBank()
	endif
endif
