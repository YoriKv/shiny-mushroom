; Which levels run code of their own: one %SMW_LevelCode line per level per
; entry point, naming the routine in level-code-data.asm beside this file,
; placed at the level's row of that entry point's table:
;
;	%SMW_LevelCode(Load, $105, <label>)	as the load begins, before objects
;	%SMW_LevelCode(Init, $105, <label>)	the level built, before the hand-over
;	%SMW_LevelCode(Main, $105, <label>)	once a frame, paused frames included
;	%SMW_LevelCode(Nmi, $105, <label>)	VBlank, in modes $13 and $14 only
;
; A level with no line keeps the zero its rows default to; a level named
; twice at one entry point keeps the later line. Naming a routine is what
; plants that entry point's hook in Banks/. Only assembled under
; !Define_SMW_LevelCode.
;
; The editor regenerates this file and the routines beside it from the
; project's own code files. It is shipped empty because no level runs
; anything, so the feature with an unedited fragment runs exactly what the
; stock cartridge runs.
