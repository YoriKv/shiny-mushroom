; SA-1 Pack: the code placed at $008494, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	LDA.B #oam_compress
	STA $3180
	LDA.B #oam_compress>>8
	STA $3181
	LDA.B #oam_compress>>16
	STA $3182
	JMP $1E80
	
	; Ensure alignment by 4 bytes
	NOP #2
    
    ; $0084A8 - JSL to flush $0338+ to max buffer #3
    JML call_nmstl_mockup_flush
	
	; $0084AC - (get_slot.asm) JSL to allocate MaxTile slots, for custom sprites.
	JML call_oam_get_slot_sprite
	
	; $0084B0 - (get_slot.asm) JSL to allocate MaxTile slots, for general purpose.
	JML call_oam_get_slot_general
	
	; $0084B4 - (get_slot.asm) JSL to allocate MaxTile slots, for general purpose.
	JML call_finish_oam_write
	
	; $0084B8 - reserved for future expansion
	NOP #4
	
	; $0084BC - reserved for future expansion
	NOP #4
	
    ; $0084C0 - SA-1 Pack signature
    dl $5A123
    
    ; $0084C3 - SA-1 Pack version
    db 140

    ; $0084C4 - Unused
    NOP #4

assert pc() <= $0084C8
