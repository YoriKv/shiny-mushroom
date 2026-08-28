; The palettes the levels wear: one label and incbin per dressed level, each
; a 514-byte .pal beside this file -- the back area colour, then the whole
; palette mirror -- named by that level's row in level-palettes.asm. Only
; assembled under !Define_SMW_LevelCustomPalettes, after the feature's stubs in
; the level bank (Config/LevelBank.asm), growing towards whatever the bank's
; last occupant has left.
;
; The editor regenerates this file and the .pal blobs beside it from the
; project's custom palettes. Shipped empty: every shipped pointer row is
; zero, so there is nothing to name.
