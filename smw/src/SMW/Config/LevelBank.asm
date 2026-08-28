includeonce

;#############################################################################################################
;# The second bank an expanded cartridge reserves: the level bank, shared by
;# the level graphics, the custom level palettes and the managed level
;# banks.
;#
;# The growable features' run (Config/ReservedBank.asm) holds tables the
;# game reads with the data bank pointed at them, and is priced as one pool
;# of rows. The features here are a different shape -- a fixed table of
;# eight bytes per level, a 514-byte blob per dressed level, and whole
;# level streams the two level banks no longer hold -- so they share a bank
;# of their own rather than a run of that one. Sharing it is what makes the
;# room fungible: a level that grew into the bank pays for it out of what
;# the palettes did not take, and the other way round.
;#
;# Three occupants, and the order is fixed by what each needs:
;#
;# - The level graphics, at the head (Config/LevelGraphics.asm): $200 rows
;#   of eight bytes at the run's fixed start, so their address is the same
;#   on every cartridge this bank is, then their stubs -- one block of one
;#   size, whatever else is on. Placed from the top of each ROM map, before
;#   any bank emits.
;# - The custom level palettes, after them (Config/LevelCustomPalettes.asm):
;#   the pointer table at the run's start, or that one fixed size behind
;#   it, so its address is one number per cartridge, then the stubs, then
;#   the blobs. Placed from the top of each ROM map too.
;# - The managed level banks, after those (Config/ManagedLevelMemory.asm):
;#   the level streams that reached the end of banks $06 and $07 are packed
;#   from where the occupants before them ended, and the level files the
;#   project adds after those. The feature's sprite-bank stub and its per-level table
;#   sit at the bank's fixed tail, where the loader's hook and SA-1 Pack's
;#   patch pass can both find the table without a symbol.
;#
;# The run is the whole bank behind one RATS tag, for the reserved run's
;# reason: asar's freespace search takes any long enough run of $00, and a
;# pointer table of zero rows is exactly that, so what holds the run is the
;# tag over it and a bank boundary is the only line that needs no tuning.
;#
;# Which bank it is belongs to the cartridge. The default is one past the
;# growable features' run, and deliberately fixed rather than derived from
;# it: the two banks are independent, and fixed, distinct defaults are what
;# keeps any combination of the features collision-free. A build whose $11
;# is spoken for names another with --define Define_SMW_LevelBank=$12 -- the
;# sa1 base does, its pack holding $10 and the shared run $11 -- and every
;# bank from $10 to $3F buys the same two things the reserved run's does:
;# one address at every cartridge size, and the work RAM mirror underneath.
;# smw_tools.features fills the value in from the base, so the editor reads
;# the cartridge at addresses derived from the same number the assembler
;# was given.
;#
;# The reservation needs a cartridge assembled at 1 MB or larger, and says so
;# rather than letting the image quietly double.
;#############################################################################################################

; The bank. %SMW_ReserveLevelBank asserts that the run landed in it.
if defined("Define_SMW_LevelBank") == 0
	!Define_SMW_LevelBank #= $11
endif
!Define_SMW_LevelBankBase #= (!Define_SMW_LevelBank<<$10)|$8000

; Whether anything wants the bank at all. A build with none of the three
; on reserves nothing, so a stock cartridge gains no RATS tag and no
; symbol.
!Define_SMW_LevelBankWanted #= !FALSE
if !Define_SMW_LevelGraphics == !TRUE
	!Define_SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_LevelCustomPalettes == !TRUE
	!Define_SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_ManagedLevelMemory == !TRUE
	!Define_SMW_LevelBankWanted #= !TRUE
endif

!Loc_SMW_LevelBank_Tag		#= !Define_SMW_LevelBankBase+$0000	;> the RATS tag, 8 bytes
!Loc_SMW_LevelBank_Packed	#= !Define_SMW_LevelBankBase+$0008	;> the run, and SMW_LevelBankStart
!Loc_SMW_LevelBank_End		#= !Define_SMW_LevelBankBase+$7FFF	;> SMW_LevelBankEnd, the bank's last byte

; Where the run ends for whatever packs into it: the bank's last byte, or
; the managed level banks' fixed tail when that feature is on -- its
; sprite-bank table is the $200 bytes below the end label and its stub sits
; directly before them, !Define_SMW_ManagedLevelTail bytes in all
; (Config/ManagedLevelMemory.asm, which places them from this figure).
if !Define_SMW_ManagedLevelMemory == !TRUE
	!Loc_SMW_LevelBank_RunEnd	#= !Loc_SMW_LevelBank_End-!Define_SMW_ManagedLevelTail
else
	!Loc_SMW_LevelBank_RunEnd	#= !Loc_SMW_LevelBank_End
endif

; Where the custom level palettes' pointer table goes: the run's head, or
; the level graphics' fixed-size block behind it when that feature is on
; (Config/LevelGraphics.asm states the size). The palettes' placement
; asserts it landed here.
if !Define_SMW_LevelGraphics == !TRUE
	!Loc_SMW_LevelBank_Palettes	#= !Loc_SMW_LevelBank_Packed+!Define_SMW_LevelGraphicsBytes
else
	!Loc_SMW_LevelBank_Palettes	#= !Loc_SMW_LevelBank_Packed
endif

; Where the run has got to: the cursor the level graphics and the palettes
; pack at and carry forward, and the packer opens its fourth run from.
; Reset here, which is once per assembler pass, because this file is read
; at the start of each of them.
!SMW_LevelBankNext #= !Loc_SMW_LevelBank_Packed

; The reservation (Config/ExpansionBanks.asm), and the one thing this bank has
; to be that the others do not: not the bank the growable features were
; reserved. Called from each ROM map once every occupant has emitted -- and
; once more below, from the initialize pass, which is the one that matters:
; asar chooses freespace against the file as it stands when a pass starts, so
; the tag has to be on disk before the pass that assembles a patch
; (Config/ReservedBank.asm has the measurement). The ROM map's call writes the
; same bytes again, which is where the end label the editor prices against
; comes from.
macro SMW_ReserveLevelBank()
if !Define_SMW_LevelBankWanted == !TRUE
	if !Define_SMW_ReservedBankWanted == !TRUE
		if !Define_SMW_LevelBank == !Define_SMW_ReservedBank
			error "The level bank and the growable features are being reserved the same bank, and each reservation is the whole of one. Check the two bank defines."
		endif
	endif
	pushpc
	%SMW_ReserveExpansionBank("The level bank", "Define_SMW_LevelBank", !Define_SMW_LevelBank, SMW_LevelBankStart, SMW_LevelBankEnd)
	pullpc
endif
endmacro

; The same reservation, laid down in the initialize pass -- see the macro.
if !Define_SMW_LevelBankWanted == !TRUE
	if !FileType == !FileType_InitializeROM
		%SMW_ReserveLevelBank()
	endif
endif
