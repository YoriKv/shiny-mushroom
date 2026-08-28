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
; one message; the Japanese cartridge orders its messages by slot.
MessagePointers:
	dw LevelMsg00,LevelMsg00,LevelMsg00,LevelMsg00
	dw LevelMsg01,LevelMsg02,LevelMsg03,LevelMsg04
	dw LevelMsg05,LevelMsg06,LevelMsg07,LevelMsg08
	dw LevelMsg09,LevelMsg0A,LevelMsg0B,LevelMsg0C
	dw LevelMsg0D,LevelMsg0E,LevelMsg0F,LevelMsg10
	dw LevelMsg11,LevelMsg12,LevelMsg13,LevelMsg14
	dw LevelMsg15
