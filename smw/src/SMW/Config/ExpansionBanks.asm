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
;# need.
;#############################################################################################################

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
