; The graphics files the levels name for themselves: one
; %SMW_LevelGraphics(level, fg1, fg2, bg1, fg3, sp1, sp2, sp3, sp4, an2)
; per level with a row, levels ascending -- the level number, then the
; eight file numbers in slot order, $FF where the slot keeps the file the
; level's tileset would load, and then the level's animated tiles, $FF for
; the game's own GFX33. Each line lands on its level's row of the $200-row
; table Config/LevelGraphics.asm fills with $FF first and on its byte of
; the $200 animated files behind it, so a level left out here loads
; exactly what its tilesets say. Only read under
; !Define_SMW_LevelGraphics, into the level bank.
;
; A project build derives this file from its level containers -- the row
; each .mwl keeps in its ExGFX slot -- and writes it into the merged tree;
; nothing keeps it. Shipped empty: no shipped container names a file, so
; the feature with an unedited table loads exactly what the stock
; cartridge loads.
