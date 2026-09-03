includeonce

;#############################################################################################################
;# The third bank an expanded cartridge reserves: the sprite bank, the
;# custom sprites' own.
;#
;# The level bank's packed head has no room for another $D00 of tables --
;# it already carries the level graphics, the per-level code and the
;# custom level palettes in front of the level streams -- so the custom
;# sprites reserve a bank of their own, on the pattern the level bank set:
;# the feature's tables at a fixed head, so the editor reads them at one
;# address per cartridge, the stubs and the project-dependent tables
;# behind them, then the dialect and the sprites' own code packing toward
;# the bank's end.
;#
;# The bank is emitted as one sequence, %SMW_PlaceSpriteBank below: one
;# org at its head, then the occupants one after another, so where each
;# lands is where the assembler has got to and nothing carries a position
;# between them. Once every bank has emitted, because a sprite's file may
;# org into the game.
;#
;# The run is the whole bank behind one RATS tag, for the reserved run's
;# reason: asar's freespace search takes any long enough run of $00, and
;# a rows table of zero rows is exactly that.
;#
;# Which bank it is belongs to the cartridge. The default is one past the
;# level bank's, and deliberately fixed rather than derived from it: the
;# reservations are independent, and fixed, distinct defaults are what
;# keeps any combination of the features collision-free. A build whose
;# $12 is spoken for names another with --define Define_SMW_SpriteBank=$13
;# -- the sa1 base does, its pack holding $10, the shared run $11 and the
;# level bank $12 -- and every bank from $10 to $3F buys the same two
;# things: one address at every cartridge size, and the work RAM mirror
;# underneath. smw_tools.features fills the value in from the base, so
;# the editor reads the cartridge at addresses derived from the same
;# number the assembler was given.
;#
;# The reservation needs a cartridge assembled at 1 MB or larger, and
;# says so rather than letting the image quietly double: the dispatch
;# stubs are what the hooks jump to, and they have nowhere else to go.
;#############################################################################################################

; The bank. %SMW_ReserveSpriteBank asserts that the run landed in it.
if defined("Define_SMW_SpriteBank") == 0
	!Define_SMW_SpriteBank #= $12
endif
!Define_SMW_SpriteBankBase #= (!Define_SMW_SpriteBank<<$10)|$8000

; Whether anything wants the bank at all. A build without the custom
; sprites reserves nothing, so a stock cartridge gains no RATS tag and no
; symbol.
!SMW_SpriteBankWanted #= !FALSE
if !Define_SMW_CustomSprites == !TRUE
	!SMW_SpriteBankWanted #= !TRUE
endif

!Loc_SMW_SpriteBank_Tag		#= !Define_SMW_SpriteBankBase+$0000	;> the RATS tag, 8 bytes
!Loc_SMW_SpriteBank_Head	#= !Define_SMW_SpriteBankBase+$0008	;> the tables, and SMW_SpriteBankStart
!Loc_SMW_SpriteBank_End		#= !Define_SMW_SpriteBankBase+$7FFF	;> SMW_SpriteBankEnd, the bank's last byte

; The reservation (Config/ExpansionBanks.asm), and what this bank may not
; collide with: the growable features' run and the level bank, each a
; whole reservation of its own. Called from each ROM map once every bank
; has emitted -- and once more below, from the initialize pass, which is
; the one that matters: asar chooses freespace against the file as it
; stands when a pass starts, so the tag has to be on disk before the pass
; that assembles a patch (Config/ReservedBank.asm has the measurement).
macro SMW_ReserveSpriteBank()
if !SMW_SpriteBankWanted == !TRUE
	if !SMW_ReservedBankWanted == !TRUE
		if !Define_SMW_SpriteBank == !Define_SMW_ReservedBank
			error "The sprite bank and the growable features are being reserved the same bank, and each reservation is the whole of one. Check the two bank defines."
		endif
	endif
	if !SMW_LevelBankWanted == !TRUE
		if !Define_SMW_SpriteBank == !Define_SMW_LevelBank
			error "The sprite bank and the level bank are being reserved the same bank, and each reservation is the whole of one. Check the two bank defines."
		endif
	endif
	pushpc
	%SMW_ReserveExpansionBank("The sprite bank", "Define_SMW_SpriteBank", !Define_SMW_SpriteBank, SMW_SpriteBankStart, SMW_SpriteBankEnd)
	pullpc
endif
endmacro

; The same reservation, laid down in the initialize pass -- see the macro.
if !SMW_SpriteBankWanted == !TRUE
	if !FileType == !FileType_InitializeROM
		%SMW_ReserveSpriteBank()
	endif
endif

; The bank itself, as one sequence: the feature's tables and stubs at the
; head, the dialect the sprites are spelled in where a build carries it
; (Config/Pixi.asm), then the sprites' own code. Called from the tail of
; each ROM map after the reservation, once every bank has emitted: a
; sprite's file may hijack the game, and a write into a bank that has not
; emitted yet is emitted over in silence. Nothing after the ROM map reads
; the position this leaves.
macro SMW_PlaceSpriteBank()
if !SMW_SpriteBankWanted == !TRUE
	org !Loc_SMW_SpriteBank_Head
	%SMW_PlaceCustomSprites()
; Where the dialect and the sprites' own code begin, for the editor to
; price the bank's remaining room off the build's symbol file; it costs
; no bytes.
SMW_SpriteBank_Code:
	%SMW_PlacePixi()
	%SMW_PlaceCustomSpriteData()
endif
endmacro
