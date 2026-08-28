; Which directions you go in after beating a level, indexed by level ID
; ($13BF). Format: nn112233 nn = regular exit 11 = secret exit #1 22 =
; secret exit #2 (unused) 33 = secret exit #3 (unused) 00 is up, 01 is down,
; 10 is left, 11 is right.
PostClearWalkDirections:
	db $00,$C0,$C0,$C0,$30,$C0,$C0,$00				;\ LM: This table becomes unused in ROMs with edited overworlds.
	db $C0,$20,$30,$C0,$C0,$C0,$C0,$D0				;|
	db $40,$40,$40,$D0,$40,$80,$80,$00				;|
	db $00,$00,$00,$40,$00,$80,$20,$80				;|
	db $40,$40,$80,$60,$90,$00,$00,$C0				;|
	db $00,$00,$00,$C0,$40,$20,$40,$C0				;|
	db $E0,$C0,$00,$C0,$00,$00,$C0,$20				;|
	db $80,$80,$80,$80,$30,$40,$E0,$00				;|
	db $40,$E0,$E0,$D0,$70,$FF,$40,$90				;|
	db $55,$80,$80,$80,$80,$00,$C0,$C0				;|
	db $C0,$C0,$40,$00,$80,$A0,$30,$AA				;|
	db $60,$D0,$80,$00,$55,$55,$00,$00				;|
	db $AA,$55,$FF,$FF,$00,$00,$00,$00				;|
	db $00,$00,$00,$00,$00,$00,$00,$00				;|
	db $00								;/
