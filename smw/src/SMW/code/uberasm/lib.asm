; The shared library a level's code may call into: one namespace and incsrc
; per file in lib/ beside this one, so a file's labels are reached the way
; UberASM Tool reaches them -- the filename, an underscore, the label. A
; library file may call another's, which that tool cannot do.
;
; The editor regenerates this file from the project's own library files. It
; is shipped empty because there are none, and every file it names is
; assembled whether a level calls it or not.
