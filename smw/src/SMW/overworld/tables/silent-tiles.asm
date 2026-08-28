; The offscreen tiles a flagged event places with no animation: four
; parallel tables, one entry per silent tile. Which event places it, which
; layer it lands on ($00 Layer 1, $01 Layer 2), the location index into
; $7EC800 (Layer 1) or $7F4000 (Layer 2), and the tile: a Map16 number
; padded to 16-bit for Layer 1, an index into the $0C8000 event tile sheets
; for Layer 2.
SilentEventTiles_EventNum:						;\ LM: This data becomes freespace in ROMs with edited overworlds (1.60+)
	db $06,$06,$06,$06,$06,$06,$06,$06				;|
	db $14,$14,$14,$14,$14,$1D,$1D,$1D				;|
	db $1D,$12,$12,$12,$1C,$2F,$2F,$2F				;|
	db $2F,$2F,$34,$34,$34,$47,$4E,$4E				;|
	db $01,$0F,$24,$24,$6C,$0F,$0F,$54				;|
	db $55,$57,$58,$5D						;|
									;|
SilentEventTiles_TileLayer:						;|
	db $00,$00,$00,$00,$00,$00,$01,$01				;|
	db $00,$01,$01,$01,$01,$01,$01,$01				;|
	db $00,$01,$01,$00,$00,$01,$01,$01				;|
	db $01,$01,$01,$01,$01,$00,$01,$00				;|
	db $00,$01,$01,$01,$01,$01,$00,$00				;|
	db $00,$00,$00,$00						;|
									;|
SilentEventTiles_TilemapLocation:					;|
	dw $0215,$0235,$0245,$0255,$0265,$0275,$1114,$1094		;|
	dw $00A9,$05A4,$0524,$0728,$06A4,$01A8,$01AC,$01B0		;|
	dw $003C,$2900,$2880,$0510,$0154,$1830,$18B0,$192E		;|
	dw $192A,$1926,$1824,$1820,$181C,$0597,$2AEC,$057B		;|
	dw $0212,$3194,$32A0,$3320,$1D16,$3114,$0625,$01F0		;|
	dw $01F0,$0304,$0304,$0227					;|
									;|
SilentEventTiles_TileNum:						;|
	dw $0068,$0024,$0024,$0025,$0000,$0081,$0938,$0928		;|
	dw $0066,$099C,$0928,$09F8,$09FC,$0998,$0998,$0928		;|
	dw $0066,$0938,$0928,$0066,$0068,$0A80,$0A84,$0A88		;|
	dw $0998,$0998,$0994,$0998,$0A8C,$0066,$0384,$0066		;|
	dw $0079,$0AA8,$0938,$0938,$09A0,$0A30,$0069,$005F		;|
	dw $005F,$005F,$005F,$005F					;/
