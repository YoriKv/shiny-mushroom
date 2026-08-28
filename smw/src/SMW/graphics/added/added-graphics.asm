; The graphics files the project adds: one %SMW_AddedGraphics(GFXnn) per
; file, ascending, for numbers $34-$FE. Read twice by
; Config/ManagedGraphicsMemory.asm, both times only under
; !Define_SMW_ManagedGraphicsMemory: once at the start of every pass, when
; each line only declares its number so the pointer table's row can name
; the file's label, and once from %SMW_ManagedGraphicsMemory_Close, when
; each line inserts the file's compressed stream after the game's own,
; packed into whatever the runs have left. The stream is
; GFX/<set>/GFXnn.lz2 (or .lz1) of the set the release reads, exactly as
; the game's own files are found, and its label is SMW_GFXnn.
;
; The editor regenerates this file from the project's added files. Shipped
; empty: the checkout adds no files, so there is nothing to insert.
