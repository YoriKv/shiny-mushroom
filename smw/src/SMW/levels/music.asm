; Which track each of the level header's eight music settings plays.
;
; Header byte 2 bits 4-6 index this table, and the byte a row holds is the
; music value the loader carries into !RAM_SMW_Misc_MusicRegisterBackup and
; from there to the SPC700. So a setting names a row and the row names a
; track: change a row and every level on that setting plays something else.
; A level can choose between these eight and no others.
;
; What a setting is *for* is only what the shipped levels use it for -- the
; three bits carry no meaning of their own, and the notes below are that
; usage rather than a rule.
LevelMusicTable:
	db !Define_SMW_LevelMusic_HereWeGo	; 0 - grassland levels
	db !Define_SMW_LevelMusic_CaveDrums	; 1 - caves
	db !Define_SMW_LevelMusic_Piano		; 2 - rope and sky levels
	db !Define_SMW_LevelMusic_Castle	; 3 - castles and fortresses
	db !Define_SMW_LevelMusic_GhostHouse	; 4 - ghost houses
	db !Define_SMW_LevelMusic_WaterLevel	; 5 - water levels
	db !Define_SMW_LevelMusic_BossBattle	; 6 - boss battles
	db !Define_SMW_LevelMusic_SwitchPalace	; 7 - switch palaces
