; The songs the overworld music bank can play, one row per music value.
;
; Indexed exactly as the level bank's table is, and by the same mailbox:
; which of the two a value means is decided by whichever bank was
; uploaded last, since both occupy the same ARAM.
MusicPtrs:
	dw MUSIC_TitleScreen           ; $01
	dw MUSIC_MainArea              ; $02
	dw MUSIC_YoshisIsland          ; $03
	dw MUSIC_VanillaDome           ; $04
	dw MUSIC_StarRoad              ; $05
	dw MUSIC_ForestofIllusion      ; $06
	dw MUSIC_BowsersValley         ; $07
	dw MUSIC_BowsersValleyRevealed ; $08
	dw MUSIC_SpecialWorld          ; $09
