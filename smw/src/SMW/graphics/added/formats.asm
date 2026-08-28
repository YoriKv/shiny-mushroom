; The format of each added graphics file that is not 3bpp: one
; %SMW_GraphicsFormat(GFXnn, 1) per 4bpp file, ascending. A number left
; out is 3bpp, the stock upload path; 1 is 4bpp, $1000 decompressed bytes
; copied to VRAM as they are. Every number named here must also be listed
; in added-graphics.asm, and the game's own files, $00-$33, take no format
; from here: what each of those is, its slot path decides. Read by
; Config/ManagedGraphicsMemory.asm at the start of every pass, only under
; !Define_SMW_ManagedGraphicsMemory.
;
; The editor regenerates this file from the project's added files. Shipped
; empty: the checkout adds no files.
