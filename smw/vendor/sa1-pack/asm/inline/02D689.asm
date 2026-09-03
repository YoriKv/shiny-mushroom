; SA-1 Pack: the code placed at $02D689, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	LDA $04
	STZ $2250
	STA $2251
	STZ $2252
	LDA $3410,X
	LDY $05
	BNE CODE_02D6A3
	STA $2253
	STZ $2254
	NOP
	BRA $00
	ASL $2306
	LDA $2307
	ADC #$00
CODE_02D6A3:
	LSR $01
	BCC CODE_02D6AA
	EOR #$FF
	INC A
CODE_02D6AA:
	STA $04
	LDA $06
	STA $2251
	LDA $3410,X
	LDY $07
	BNE CODE_02D6C6
	JML MultiplyFix
	db $00
CODE_02D6C6:
	assert pc() <= $02D6C6
