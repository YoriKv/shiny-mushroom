; Which levels run code of their own: one word per level, $200 rows in level
; order, read by SMW_LevelCode_Main with the level number times two. A zero
; row is a level the stock game runs unchanged; a row that holds anything
; names a routine in level-code-data.asm beside this file, called once a
; frame while that level is running. Only assembled under
; !Define_SMW_LevelCode, into the level bank Config/LevelBank.asm reserves;
; the stock game runs no such code.
;
; The editor regenerates this file and the routines beside it from the
; project's own code files. The shipped rows are all zero: no level runs
; anything, so the feature with an unedited table runs exactly what the stock
; cartridge runs.
