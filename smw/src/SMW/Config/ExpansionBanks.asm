;#############################################################################################################
;# One reservation, for the three that are made.
;#
;# Three features' worth of tables and streams live in expansion banks, and
;# each takes a whole bank rather than a run inside one: the growable features'
;# reserved bank (Config/ReservedBank.asm), the level bank
;# (Config/LevelBank.asm) and the graphics banks (Config/GraphicsBank.asm).
;# What "reserving a bank" is does not differ between them -- a RATS tag over
;# the whole of it, a label at each end for whatever packs inside, and the two
;# things a bank number has to be -- so it is written once here and each of the
;# three says only which bank, under what name, and what its own occupants
;# need. %SMW_ExpansionBankExists is the other half of that: whether the bank
;# is there at all, for an occupant that has somewhere else to go.
;#############################################################################################################

; Whether <Bank> exists at the size this cartridge is assembled to, as
; !SMW_ExpansionBankExists -- the same test %SMW_ReserveExpansionBank refuses
; on, asked before it rather than after.
;
; For a feature that uses an expansion bank for room it can do without: it
; reserves the bank where the cartridge has one and packs into whatever the
; game's own banks leave where it has not, so the size is a choice rather
; than a requirement (Config/ManagedLevelMemory.asm). A feature with nowhere
; else to put its tables asks nothing and lets the reservation refuse.
; A pass that assembles no cartridge -- the SPC700 engine's, say -- never
; calls %GetROMSize and so has no !MaxROMSize to test. It reserves nothing
; either, so "no bank" is the answer that costs nothing there.
macro SMW_ExpansionBankExists(Bank)
	!SMW_ExpansionBankExists = !FALSE
	if defined("MaxROMSize")
		if !MaxROMSize >= ((<Bank>)+$01)*$8000
			!SMW_ExpansionBankExists = !TRUE
		endif
	endif
endmacro

; Reserve the whole of one expansion bank.
;
; <Bank> is the bank number, <BankDefine> the name of the define it came from
; so an error can say which one to move, and <Name> what to call the
; reservation in that error. <StartLabel> lands past the RATS tag, at the
; bank's $8008, and <EndLabel> at its last byte: a section's budget is the
; distance to the next symbol, so without the end label whatever emitted last
; would have nothing above it in the bank.
;
; The caller brackets the call in pushpc/pullpc, and decides whether the bank
; is wanted at all -- a build with none of a reservation's occupants on
; reserves nothing, so a stock cartridge gains no RATS tag and no symbol. A
; caller reserving several banks in a row calls this once per bank
; (Config/GraphicsBank.asm).
macro SMW_ReserveExpansionBank(Name, BankDefine, Bank, StartLabel, EndLabel)
	if (<Bank>) < $10
		error "<Name> must be an expansion bank, $10 or above: the banks below it are the game's own. Check <BankDefine>."
	endif
	if !MaxROMSize < ((<Bank>)+$01)*$8000
		error "<Name> needs a cartridge it exists in, and this one ends below it -- no expansion bank exists at all in 512 KB. Assemble with --rom-size 1mb or larger."
	endif
	org ((<Bank>)<<$10)|$8000
	%RATSTagStart(<StartLabel>, <EndLabel>)
	org ((<Bank>)<<$10)|$FFFF
	%RATSTagEnd(<EndLabel>)
	assert (<StartLabel>>>$10) == (<Bank>), "<Name>'s run is not in the bank the slot map says it is."
endmacro
