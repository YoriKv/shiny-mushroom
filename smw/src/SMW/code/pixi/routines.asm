includeonce

; The shared-routine macros PIXI ships (%GetDrawInfo, %SubHorzPos,
; %SubOffScreen and their siblings), on that tool's own mechanism: each
; file in code/pixi/routines/ is assembled once and reached by a macro
; named after it, so calling one costs a JSL wherever it is written. The
; macros all come first and the bodies after, so a routine may call
; another routine's macro whatever order the folder reads in; each body is
; read inside a namespace of its own, with plain labels -- the import
; rewrites the macro-scoped ?main spelling PIXI's originals carry.
;
; The editor regenerates this file from the project's routine files, which
; arrive from the user's own copy of PIXI the way custom music arrives
; from their AddmusicK -- that tool is GPL-3.0, so a project may carry
; them freely. It is shipped empty because there are none: a macro
; nothing calls is a macro nobody has verified.
