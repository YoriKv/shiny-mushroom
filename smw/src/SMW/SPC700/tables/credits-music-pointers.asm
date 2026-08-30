; The songs the credits music bank can play, one row per music value.
;
; Twelve rows over four songs: the game only ever asks for $09, $0A and
; $0B, and the rows below and above those repeat the same four in the
; same order.
MusicPtrs:
	dw MUSIC_Credits1 ; $01
	dw MUSIC_Credits2 ; $02
	dw MUSIC_Credits3 ; $03
	dw MUSIC_Credits4 ; $04
	dw MUSIC_Credits1 ; $05
	dw MUSIC_Credits2 ; $06
	dw MUSIC_Credits3 ; $07
	dw MUSIC_Credits4 ; $08
	dw MUSIC_Credits1 ; $09
	dw MUSIC_Credits2 ; $0A
	dw MUSIC_Credits3 ; $0B
	dw MUSIC_Credits4 ; $0C
