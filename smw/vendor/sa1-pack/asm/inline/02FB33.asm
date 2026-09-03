; SA-1 Pack: the code placed at $02FB33, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	STZ $2250
	LDA $04
	STA $2251
	STZ $2252
	LDA #$50
	LDY $05
	BNE +
	STA $2253
	STZ $2254
	NOP
	BRA $00
	ASL $2306
	LDA $2307
	ADC #$00
+	LSR $01
	BCC +
	EOR #$FF
	INC A
+	STA $04
	LDA $06
	STA $2251
	LDA #$50
	LDY $07
	BNE +
	STA $2253
	JML MultiplyFix3
Return_MultiplyFix3:
+	LSR $03
	BCC +
	EOR #$FF
	INC A
+	STA $06

assert pc() <= $02FB77+2
