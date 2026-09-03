; SA-1 Pack: the code placed at $03995E, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	STZ $2250
	LDA $04
	STA $2251
	STZ $2252
	LDA #$38
	LDY $05
	BNE +
	STA $2253
	STZ $2254
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
	LDA #$38
	LDY $07
	BNE +
	JML Continue_03995E
	NOP
Return_03995E:
	LDA $2307
	ADC #$00
+	LSR $03
	BCC +
	EOR #$FF
	INC A
+	STA $06
	assert pc() <= $0399A4
