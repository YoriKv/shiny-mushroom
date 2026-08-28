; Which message each level's message box shows. One byte per slot, $17 of
; them: the translevel number, with bit 7 set for the level's second message
; (!RAM_SMW_Misc_DisplayMessage = 2) and clear for its first. DisplayText
; walks the slots from $16 down to 1 looking for the level being played, and
; a level in none of them lands on slot 0 without a compare -- so slot 0 is
; the default as much as an entry, and vanilla keeps the Yellow Switch Palace
; there. Slots 0-3 are the four switch palaces, and picking one of them also
; draws the palace's coloured blocks (DrawSwitchBlocks).
MessageLevels:
	db $14,$45,$3F,$08,$00,$29,$AA,$27
	db $26,$84,$95,$A9,$15,$13,$CE,$A7
	db $A4,$25,$A5,$05,$A6,$2A,$28

; The text each slot shows, as an offset into MessageText -- one word per
; slot, $19 of them: the $17 above, then slot $17 for slot $16's level with
; the player riding Yoshi, and slot $18 for the Yoshi-thanks message
; (DisplayMessage = 3), which needs no level at all. Several slots may name
; one message; the base $0000 around the text is what makes an offset of
; each message's label.
MessagePointers:
	dw LevelMsg01,LevelMsg01,LevelMsg01,LevelMsg01
	dw LevelMsg00,LevelMsg05,LevelMsg08,LevelMsg0A
	dw LevelMsg0C,LevelMsg11,LevelMsg0F,LevelMsg06
	dw LevelMsg10,LevelMsg13,LevelMsg15,LevelMsg09
	dw LevelMsg14,LevelMsg0D,LevelMsg0E,LevelMsg12
	dw LevelMsg0B,LevelMsg07,LevelMsg02,LevelMsg04
	dw LevelMsg03
