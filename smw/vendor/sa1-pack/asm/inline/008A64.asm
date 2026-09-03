; SA-1 Pack: the code placed at $008A64, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

	
Reset:						; \ Use the "unused" space
autoclean JML SA1_Reset				;  | to store some vectors.
						;  |
IRQ:						;  |
autoclean JML SA1_IRQ				;  |
						;  |
NMI:						;  |
autoclean JML SA1_NMI				;  |
						;  |
Reset2:						;  |
autoclean JML snes_init				; /


	JML SA1_Loop				; This points to SA-1 main loop.
						; Needed so the Dual ROM system can locate SA-1 main loop easier.

assert pc() <= $8A78
