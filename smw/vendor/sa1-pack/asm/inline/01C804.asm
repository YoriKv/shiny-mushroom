; SA-1 Pack: the code placed at $01C804, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	PHA
	LDA #$01
	STA $2250
	PLA
	STA $2252
	STZ $2251
	LDA #$05
	STA $2253
	STZ $2254
	NOP
	BRA $00
	LDA $2306
	STA $02
	STA $06
	LDA $2307
	STA $03
	STA $07
	LDY #$00
	LDA $74B8
	SEC
	SBC $74B0
	BPL +
	EOR #$FF
	INC A
	INY
+	STY $01
	STA $2252
	STZ $2251
	LDA #$05
	STA $2253
	STZ $2254
	JSL Continue_01C804
	assert pc() <= $01C84D
