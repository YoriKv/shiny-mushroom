; Which maps each overworld sprite number is disabled on, indexed by the
; sprite number minus one. One byte per number, read by the routine above
; and ANDed with the bit for the map the player is on; a set bit disables.
; Bits are [myvfbSs-]: m = main map, y = Yoshi's Island, v = Vanilla Dome,
; f = Forest of Illusion, b = Valley of Bowser, S = Special World, s = Star
; World, and the last bit is unused.
;
; Which map shows a sprite is a fact about its number, not its slot or its
; position: every slot holding the number obeys this one byte. Positions
; are absolute in the one shared 512x512 space, so a number enabled on two
; maps draws at the same coordinate on both.
DisableSpriteOnXSubmapFlags:
	db %01111111		; Lakitu
	db %00100001		; Blue Bird
	db %01111111		; Cheep Cheep
	db %01111111		; Piranha Plant
	db %01111111		; Cloud
	db %01110111		; Koopa Kid
	db %00111111		; Smoke
	db %11110111		; Bowser Sign
	db %11110111		; Bowser
	db %00000000		; Ghost
