; Which game modes run code of their own: one %SMW_GameModeCode line per
; mode per entry point, naming the routine in gamemode-code-data.asm beside
; this file, placed at the mode's row of that entry point's table:
;
;	%SMW_GameModeCode(Init, $14, <label>)	the mode's first frame
;	%SMW_GameModeCode(Main, $14, <label>)	every frame after, before the game's routine
;	%SMW_GameModeCode(End, $14, <label>)	every frame, after the game's routine
;	%SMW_GameModeCodeAll(Main, <label>)	every mode, ahead of its own row
;
; A mode with no line keeps the RTL its rows default to. Only assembled
; under !Define_SMW_GameModeCode.
;
; The editor regenerates this file and the routines beside it from the
; project's own game mode files. It is shipped empty because no mode runs
; anything, so the feature with an unedited fragment runs exactly what the
; stock cartridge runs.
