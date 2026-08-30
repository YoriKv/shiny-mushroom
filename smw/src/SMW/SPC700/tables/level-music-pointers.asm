; The songs the level music bank can play, one row per music value.
;
; The value the game writes to !RAM_SMW_IO_SoundCh3 indexes this table
; from one, with no bound check -- a value past the last row reads
; whatever follows it as a pointer. Two rows may name one song, which is
; how a value is made an alias of another.
MusicPtrs:
	dw MUSIC_Piano            ; $01
	dw MUSIC_HereWeGo         ; $02
	dw MUSIC_Water            ; $03
	dw MUSIC_BowserFight1     ; $04
	dw MUSIC_BossBattle       ; $05
	dw MUSIC_Cave             ; $06
	dw MUSIC_GhostHouse       ; $07
	dw MUSIC_Castle           ; $08
	dw MUSIC_PlayerDied       ; $09
	dw MUSIC_GameOver         ; $0A
	dw MUSIC_PassedBoss       ; $0B
	dw MUSIC_PassedLevel      ; $0C
	dw MUSIC_Star             ; $0D
	dw MUSIC_DirectionalCoins ; $0E
	dw MUSIC_IntoKeyhole      ; $0F
	dw MUSIC_IntoKeyhole      ; $10
	dw MUSIC_ZoomIn           ; $11
	dw MUSIC_SwitchPalace     ; $12
	dw MUSIC_Welcome          ; $13
	dw MUSIC_DoneBonusGame    ; $14
	dw MUSIC_RescueEgg        ; $15
	dw MUSIC_BowserFight1     ; $16
	dw MUSIC_BowserZoomOut    ; $17
	dw MUSIC_BowserZoomIn     ; $18
	dw MUSIC_BowserFight2     ; $19
	dw MUSIC_BowserFight3     ; $1A
	dw MUSIC_BowserDied       ; $1B
	dw MUSIC_PrincessKiss     ; $1C
	dw MUSIC_BowserInterlude  ; $1D
