; The path exits: 14 entries, searched from the last down when the player
; walks onto an exit tile. Keyed on the player's exact pixel POSITION, not
; on the tile -- and exactly, which is the known vanilla glitch: a player
; misaligned from the Layer 1 paths never matches a row.
;
; The two position tables are (pixel Y word, pixel X word, submap byte) per
; entry, submaps $00 main map through $06 Star World. LandingCells is the
; landing's (grid row, grid column) pair, carried as data rather than
; derived: entry 2 lands mid-walk at Y $0150 but stands the player on grid
; row $14, one row above the division.
TriggerPositions:
	dw $0140,$0028 : db $00
	dw $0150,$0058 : db $00
	dw $0010,$0048 : db $01
	dw $0010,$0098 : db $01
	dw $00A0,$00D8 : db $00
	dw $0140,$0058 : db $02
	dw $0090,$01E8 : db $04
	dw $0160,$00E8 : db $00
	dw $00A0,$01C8 : db $00
	dw $0160,$0088 : db $03
	dw $0108,$0190 : db $00
	dw $01E8,$0010 : db $03
	dw $0110,$01C8 : db $00
	dw $01F0,$0088 : db $03

LandingPositions:
	dw $0000,$0048 : db $01
	dw $0000,$0098 : db $01
	dw $0150,$0028 : db $00
	dw $0160,$0058 : db $00
	dw $0150,$0058 : db $02
	dw $0090,$00D8 : db $00
	dw $0150,$00E8 : db $00
	dw $00A0,$01E8 : db $04
	dw $0150,$0088 : db $03
	dw $00B0,$01C8 : db $00
	dw $01E8,$0000 : db $03
	dw $0108,$01A0 : db $00
	dw $0200,$0088 : db $03
	dw $0100,$01C8 : db $00

LandingCells:
	db $00,$04
	db $00,$09
	db $14,$02
	db $15,$05
	db $14,$05
	db $09,$0D
	db $15,$0E
	db $09,$1E
	db $15,$08
	db $0A,$1C
	db $1E,$00
	db $10,$19
	db $1F,$08
	db $10,$1C
