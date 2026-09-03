; SA-1 Pack: the code placed at $01CC28, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	STZ $2250
	REP #$20
	LDA $00
	AND #$00FF
	STA $2251
	LDA $02
	AND #$00FF
	STA $2253
	NOP
	BRA $00
	LDA $2306
	STA $04
	LDA $03
	AND #$00FF
	STA $2253
	CLC
	BRA $00
	LDA $05
	AND #$00FF
	ADC $2306
	STA $05
	LDA $01
	AND #$00FF
	STA $2251
	LDA $02
	AND #$00FF
	STA $2253
	CLC
	BRA $00
	LDA $2306
	ADC $05
	STA $05
	LDA $03
	AND #$00FF
	STA $2253
	CLC
	BRA $00
	LDA $06
	AND #$00FF
	ADC $2306
	STA $06
	SEP #$20
	RTS
		
	fillbyte $00
	fill $08
	assert pc() <= $01CC94
