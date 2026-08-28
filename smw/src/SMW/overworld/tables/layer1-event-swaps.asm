; A 22-byte table of Layer 1 overworld tile numbers that change into other
; tiles, followed by a 22-byte table of the tile numbers that they become.
; Entries $09 [53->43], $0A [52->44], and $15 [54->23] correspond to tiles
; that are unused in the original SMW, so they could be changed to other
; tile numbers if need be. (This is how things such as revealing level tiles
; work: tile numbers from the first list are transformed into the
; corresponding tiles from the second list when activated.)
TilesThatChange:
	db $6E,$6F,$70,$71,$72,$73,$74,$75
	db $59,$53,$52,$83,$4D,$57,$5A,$76
	db $78,$7A,$7B,$7D,$7F,$54

TilesToBecome:
	db $66,$67,$68,$69,$6A,$6B,$6C,$6D
	db $58,$43,$44,$45,$25,$5E,$5F,$77
	db $79,$63,$7C,$7E,$80,$23
