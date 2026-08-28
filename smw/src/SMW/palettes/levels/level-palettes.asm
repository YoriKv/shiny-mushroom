; Which levels wear a palette of their own: one long pointer per level, $200
; rows in level order, read by SMW_LevelCustomPalettes_Apply with the level
; number times three. A zero row is a level on the game's shared colours; a
; row that holds anything names a 514-byte blob in level-palette-data.asm --
; the back area colour, then the whole palette mirror -- that lands over what
; the stock buffering built. Only assembled under
; !Define_SMW_LevelCustomPalettes, into the level bank Config/LevelBank.asm
; reserves; the stock game holds no such table.
;
; The editor regenerates this file and the .pal blobs beside it from the
; project's custom palettes. The shipped rows are all zero: no level wears
; one, so the feature with an unedited table loads exactly what the stock
; cartridge loads.
Pointers:
	fillbyte $00
	fill $0600
