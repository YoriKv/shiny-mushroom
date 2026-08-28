; The castle, fortress and switch palace tiles an event crushes at overworld
; load: five parallel tables describing what a ruin looks like, then two
; parallel tables saying which event ruins which cell.
;
; The scan walks the event numbers from the top down, so the highest-numbered
; match wins -- and it walks $18 of them over a $10-entry table, a shipped
; off-by-$8 that reads the eight bytes following into the search.

; Layer 1 tile numbers that have a destruction event associated with them.
; Essentially, the "before" tiles.
TilesBeforeDestruction:
	db $77,$79,$58,$4C,$A6

; Top tile to write after each destruction, in the order of $13D0. The table
; is only used for two-tile destructions (like the castles), so the first
; three bytes are normally unused.
TopTilesAfterDestruction:
	db $85,$86,$00,$10,$00

; Bottom/base tile to write after each overworld tile destruction, in the
; order of $13D0.
BottomTilesAfterDestruction:
	db $85,$86,$81,$81,$81

; Layer 1 tilemap locations (16-bit) for each of the castle/fortress/switch
; palace destruction events.
DestructionTileLocations:
	dw $0419,$00BD,$061C,$0130
	dw $012A,$00D1,$062A,$06AC
	dw $0547,$0559,$0572,$02BF
	dw $02AC,$0212,$0318,$0306

; Which event numbers will trigger castle/fortress/switch palace tile
; destruction sequences. Due to a coding error by Nintendo, the table is
; treated as 0x18 bytes long when it's really only 0x10 bytes.
EventNums:
	db $06,$0F,$1C,$21,$24,$28,$29,$37
	db $40,$41,$43,$4A,$4D,$02,$61,$35
