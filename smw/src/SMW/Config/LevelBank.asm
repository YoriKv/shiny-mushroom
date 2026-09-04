includeonce

;#############################################################################################################
;# The second bank an expanded cartridge reserves: the level bank, shared by
;# the level graphics, the per-level code, the custom level palettes, the
;# project's own code and the managed level banks.
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
;# Six occupants, and the order is fixed by what each needs:
;#
;# - The level graphics, at the head (Config/LevelGraphics.asm): $200 rows
;#   of eight bytes at the run's fixed start, so their address is the same
;#   on every cartridge this bank is, then their stubs -- one block of one
;#   size, whatever else is on.
;# - The per-level code's tables and stubs behind them (Config/LevelCode.asm),
;#   one block of one size too.
;# - The Lunar Magic tables behind those (Config/LunarMagicLevels.asm): four
;#   $200-row tables and their stubs, one block of one size too.
;# - The Layer 3 tables behind those (Config/Layer3Settings.asm): four
;#   $200-row tables and their stubs, one block of one size too.
;# - The custom level palettes, after those (Config/LevelCustomPalettes.asm):
;#   the pointer table at the run's start, or the fixed sizes behind it, so
;#   its address is one number per cartridge, then the stubs, then the
;#   blobs -- the packed head's growing end.
;# - The project's own code behind the blobs: the tool's dialect and library
;#   (Config/UberASM.asm), the levels' routines (Config/LevelCode.asm), the
;#   game modes' (Config/GameModeCode.asm) and the global ones
;#   (Config/GlobalCode.asm), each whatever length the project's files come
;#   to.
;# - The managed level banks, last (Config/ManagedLevelMemory.asm):
;#   the level streams that reached the end of banks $06 and $07 are packed
;#   from where the occupants before them ended, and the level files the
;#   project adds after those. The feature's sprite-bank stub and its per-level table
;#   sit at the top of bank $07 rather than in this bank at all, where the
;#   loader's hook and SA-1 Pack's sprite-memory rewrite can both find the
;#   table without a symbol on every base -- this bank moves with the
;#   reservation, and bank $07 does not.
;#
;# The bank is emitted as one sequence, %SMW_PlaceLevelBank below: one org
;# at its head, then the occupants one after another, so where each lands
;# is where the assembler has got to and nothing carries a position between
;# them. Once every bank has emitted, because the project's code may hijack
;# the game.
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

; Whether anything wants the bank at all. A build with none of its
; occupants on reserves nothing, so a stock cartridge gains no RATS tag and
; no symbol. Every occupant wants it whatever the cartridge is, and the
; reservation refuses a cartridge without one.
!SMW_LevelBankWanted #= !FALSE
if !Define_SMW_LevelGraphics == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_LevelCustomPalettes == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_LevelCode == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_LunarMagicLevels == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_Layer3Settings == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_GameModeCode == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_GlobalCode == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_UberASM == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
; The frame stub lives here too, and the custom music wants it without
; wanting anything else of this bank's (Config/GlobalCode.asm).
if !SMW_FrameHookWanted == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif
if !Define_SMW_ManagedLevelMemory == !TRUE
	!SMW_LevelBankWanted #= !TRUE
endif

!Loc_SMW_LevelBank_Tag		#= !Define_SMW_LevelBankBase+$0000	;> the RATS tag, 8 bytes
!Loc_SMW_LevelBank_Stash	#= !Define_SMW_LevelBankBase+$0008	;> the run, and SMW_LevelBankStart
!Loc_SMW_LevelBank_End		#= !Define_SMW_LevelBankBase+$7FFF	;> SMW_LevelBankEnd, the bank's last byte

; The fixed head, then the packed one. The level number stash goes in front
; of every occupant, laid down by this bank rather than by any of them
; (Config/LevelNumberStash.asm), so no occupant's block depends on which
; others the cartridge has and a new reader of the stash costs nothing but
; its own switch.
if !SMW_LevelNumberStashWanted == !TRUE
	!Loc_SMW_LevelBank_Packed	#= !Loc_SMW_LevelBank_Stash+!Define_SMW_Block_LevelNumberStash
else
	!Loc_SMW_LevelBank_Packed	#= !Loc_SMW_LevelBank_Stash
endif

; Where the run ends for whatever packs into it: the bank's last byte, and
; nothing is held back from it. The managed level banks' sprite-bank tail
; sits at the top of bank $07 rather than here -- one address on every base
; (Config/ManagedLevelMemory.asm).
!Loc_SMW_LevelBank_RunEnd	#= !Loc_SMW_LevelBank_End

; Where the per-level code's rows go: the packed head, or the level
; graphics' fixed-size block behind it when that feature is on
; (Config/PackedRuns.asm states the size). The code's placement asserts it
; landed here.
if !Define_SMW_LevelGraphics == !TRUE
	!Loc_SMW_LevelBank_Code		#= !Loc_SMW_LevelBank_Packed+!Define_SMW_Block_LevelGraphics
else
	!Loc_SMW_LevelBank_Code		#= !Loc_SMW_LevelBank_Packed
endif

; Where the Lunar Magic tables go: behind the code's block where that
; feature is on too (Config/LunarMagicLevels.asm). Their placement asserts
; it landed here.
if !Define_SMW_LevelCode == !TRUE
	!Loc_SMW_LevelBank_LunarMagic	#= !Loc_SMW_LevelBank_Code+!Define_SMW_Block_LevelCode
else
	!Loc_SMW_LevelBank_LunarMagic	#= !Loc_SMW_LevelBank_Code
endif

; Where the Layer 3 tables go: behind the Lunar Magic tables' block where
; that feature is on too (Config/Layer3Settings.asm). Their placement
; asserts it landed here.
if !Define_SMW_LunarMagicLevels == !TRUE
	!Loc_SMW_LevelBank_Layer3	#= !Loc_SMW_LevelBank_LunarMagic+!Define_SMW_Block_LunarMagicLevels
else
	!Loc_SMW_LevelBank_Layer3	#= !Loc_SMW_LevelBank_LunarMagic
endif

; And where the custom level palettes' pointer table goes: behind the Layer
; 3 tables' block where that feature is on too. The palettes are the packed
; head's last occupant, because their blobs are its growing end and nothing
; may declare an address behind them. Their placement asserts it landed
; here.
if !Define_SMW_Layer3Settings == !TRUE
	!Loc_SMW_LevelBank_Palettes	#= !Loc_SMW_LevelBank_Layer3+!Define_SMW_Block_Layer3Settings
else
	!Loc_SMW_LevelBank_Palettes	#= !Loc_SMW_LevelBank_Layer3
endif

; Where the bank's sequence ended, and so where the packer opens its
; fourth run: set by %SMW_PlaceLevelBank below once every occupant has
; emitted, and read by %SMW_ManagedLevelAdvance. Reset here, which is once
; per assembler pass, because this file is read at the start of each of
; them.
!SMW_LevelBank_StreamsAt #= !Loc_SMW_LevelBank_Stash

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
if !SMW_LevelBankWanted == !TRUE
	if !SMW_ReservedBankWanted == !TRUE
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
if !SMW_LevelBankWanted == !TRUE
	if !FileType == !FileType_InitializeROM
		%SMW_ReserveLevelBank()
	endif
endif

; The bank itself, as one sequence: one org at its head, then every
; occupant in the order the top of this file states, each emitting nothing
; where its feature is off so the ones behind close up -- the stash, the
; fixed-size blocks the packed head is made of, the palettes' blobs, the
; tool's dialect and library, then the project's own code: a level's, a
; game mode's, the global routines. The packed level streams open where
; that ended, which is the one position handed on rather than read off the
; assembler, because the packing fills banks $06 and $07 first and reaches
; this bank from a different org.
;
; Called from the tail of each ROM map after the reservation, once every
; bank has emitted: the project's code may hijack the game, and a write into
; a bank that has not emitted yet is emitted over in silence. Nothing after
; the ROM map reads the position this leaves.
macro SMW_PlaceLevelBank()
if !SMW_LevelBankWanted == !TRUE
	org !Loc_SMW_LevelBank_Stash
	%SMW_PlaceLevelNumberStash()
	%SMW_PlaceLevelGraphics()
	%SMW_PlaceLevelCode()
	%SMW_PlaceLunarMagicLevels()
	%SMW_PlaceLayer3Settings()
	%SMW_PlaceLevelCustomPalettes()
; Where the project's own code begins and where it ends -- and so where the
; packed streams open. Two labels the build's symbol file carries and
; nothing else reads, so the editor prices the streams behind the code's
; assembled length rather than guess at it; they cost no bytes.
SMW_LevelBank_Code:
	%SMW_PlaceUberASM()
	%SMW_PlaceLevelCodeData()
	%SMW_PlaceGameModeCode()
	%SMW_PlaceGlobalCode()
SMW_LevelBank_Streams:
	!SMW_LevelBank_StreamsAt #= pc()
endif
endmacro
