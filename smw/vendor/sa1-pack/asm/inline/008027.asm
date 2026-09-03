; SA-1 Pack: the code placed at $008027, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	NOP #13		; If any routine hijack this, things won't blow up.
	; PC is now $00:8034, aligned with the looping LDA #$008D opcode (low hijack probability)
	
	PEA.w $0040
	PLB
	
	JML oam_init_tables	
	NOP
	
oam_transfer_clear_invoker:
	LDA #oam_clear_invoke_end-oam_clear_invoke-1
	LDX #oam_clear_invoke
	LDY #$8000
	MVN $7F, oam_clear_invoke>>16
	PLB
	
	; PC is now $00:804A, aligned with the original code.
assert pc() <= $00804A
