; SA-1 Pack: the code placed at $02D870, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	PHP
	BPL CODE_02D876
	EOR #$FF
	INC A
CODE_02D876:
	STA $2252
	LDA #$01
	STA $2250
	STZ $2251
	LDA $3410,X
	LSR
	STA $2253
	STZ $2254
	NOP
	BRA $00
	LDA $2306
	STA $0E
	LDA $2307
	JML MoreMultiplyFix
Tralalal:
	PLP
	BPL +
	EOR #$FF
	INC A
+	RTS
	assert pc() <= $02D8A1
