; All the message box texts. They're almost raw tilemaps (doesn't contain
; YXPCCCTT data) to be uploaded to VRAM, but setting the highest bit makes
; it add a newline too.
LevelMsg00:
	db "Welcome!   This i", $52|$80	;!
	db "Dinosaur Land.  I", $4D|$80
	db "this strange  lan", $43|$80
	db "we    find    tha", $53|$80
	db "Princess Toadstoo", $4B|$80	;!
	db "is  missing again", $1A|$80
	db "Looks  like Bowse", $51|$80
	db "is at it again", $1A|$80
