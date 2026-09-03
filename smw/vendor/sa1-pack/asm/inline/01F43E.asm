; SA-1 Pack: the code placed at $01F43E, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	LDA #$01
	STA $2250
	LDA $3284,x
	STA $2252
	STZ $2251
	LDA #$04
	STA $2253
	STZ $2254
	;NOP
	;BRA $00
	LDA $3334,x
	STA $07
	LSR
	LDA $2307
assert pc() <= $01F45A+3
