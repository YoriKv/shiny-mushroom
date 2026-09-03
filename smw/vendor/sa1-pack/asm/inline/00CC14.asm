; SA-1 Pack: the code placed at $00CC14, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	CLV				;
	PHY				;
	LDA #$01			;
	STA $2250			;
	LDA $01				;
	BPL +				;
	LSR				;
	SEP #$40			;
+	STA $2252			;
	STZ $2251			;
	LDA $7433			;
	STA $2253			;
	STZ $2254			;
	NOP				;
	REP #$20			;
	LDA $2306			;
	BVS +				;
	LSR				;
+	TAY				;
	SEP #$20			;
	STZ $2250			;
	LDA $7433			;
	STA $2251			;
	STZ $2252			;
	LDA ($06),y			;
	STA $2253			;
	STZ $2254			;
	JML Jump
Back:	LDA $2307			;
	STA $02				;
	PLY				;
	RTS				;
	assert pc() <= $00CC5C			;
