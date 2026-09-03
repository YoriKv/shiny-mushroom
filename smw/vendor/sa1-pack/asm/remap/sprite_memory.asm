
; LOCAL MODIFICATION (shiny-mushroom, intended for upstream): the bank a
; sprite list is completed with. The loader hardcodes $07 and so did this,
; and both are right for every list the stock cartridge has. Under
; Define_SMW_ManagedLevelMemory -- on the assemble's command line with
; the rest of the build's defines -- the loader instead
; reads a byte per level off a table at the fixed tail of bank $07
; (Config/ManagedLevelMemory.asm), because that feature packs sprite lists
; into whichever bank has room; so this reads the same table, by address,
; and follows the list wherever it went. Inert on a stock build.
;
; A literal, because that is what the table is: it sits at the top of bank
; $07 on every cartridge and every base, the feature's expansion bank being
; room it may not have -- and a run of the pack on its own has no symbol
; of ours to name.
if defined("Define_SMW_ManagedLevelMemory")
	!sprite_banks #= $07FE00
endif

macro remap_memory()
if defined("Define_SMW_ManagedLevelMemory")
	!ptr #= (read1(!sprite_banks+!count)<<16)|read2(!count*2+$05EC00)
else
	!ptr #= $070000|read2(!count*2+$05EC00)
endif
    
    !spr_bit #= read1(!ptr)
    !spr_mask = !spr_bit&$E0
    !spr_mem = !spr_bit&$1F
    
    !level_mode #= read1(read3(!count*3+$05E000)+1)&$1F
    
    ; Sprite memory $12 and $10 is used on bosses battles and cannot be changed due of hardcoded-specific code.
    ; Sprite memory $0A is used on wigglers and cannot be changed to avoid memory corruption.
    
    if !spr_mem != $12 && !spr_mem != $10 && !spr_mem != $0A && !level_mode != $10 && !level_mode != $0B && !level_mode != $09 && !count != 0 && !count != $0100
        org !ptr
            db !spr_mask|$08
    ; else
    ;    print "Skipping level ",hex(!count)," with memory ",hex(!spr_mem)
    endif
	
	!count #= !count+1
endmacro

; LOCAL MODIFICATION (shiny-mushroom, intended for upstream): gated on an
; explicit switch rather than on a byte remap/addr.asm rewrites. %remap_memory
; is idempotent by construction -- it masks the low five bits off and writes
; mask|$08, so a second application writes what the first did -- which is why
; the clean-ROM probe was belt-and-braces rather than load-bearing. Borrowing
; addr.asm's probe meant any base that remaps work RAM in its own source read
; as "already patched" and silently lost this block.
if defined("remap_sprite_memory") == 0
	!remap_sprite_memory = 1
endif
if !remap_sprite_memory
	!count = 0
	for i = 0..512 : %remap_memory() : endfor
endif
