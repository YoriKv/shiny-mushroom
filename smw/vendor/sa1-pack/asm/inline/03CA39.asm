; SA-1 Pack: the code placed at $03CA39, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	STZ $2250
	STA $2251
	STZ $2252
	LDA $06                   
	STA $2253
	STZ $2254
	CMP ($00)
	LDA $2307
	LDY $00
	BPL +
	EOR #$FF
	INC
+	STA $02                   
	LDA $01                   
	BPL +
	EOR #$FF                
	INC
+	JML fireworks_fix
fireworks_fix_back:
	NOP
	LDA $2307
assert pc() <= $03CA64+3
