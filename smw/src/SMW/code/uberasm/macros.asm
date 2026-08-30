; The project's own macro library: one incsrc per file in macros/ beside
; this one, read once, in front of every routine and of the shared library.
; asar's macros and defines are global, so a file of them included from two
; routines is a redefinition error -- this is the one place such a file is
; included from, which is what UberASM Tool's macrolib is for.
;
; The editor regenerates this file from the project's own macro files. It
; is shipped empty because there are none.
