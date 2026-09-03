;###########################################################################
;# Every level's sprite memory index, set by the base
;###########################################################################
;#
;# The first byte of a sprite list carries the level's sprite memory index
;# in its low five bits, and a base that widens the sprite slots needs
;# every level it can widen to run at one index: the sa1 base sets
;# Define_SMW_SpriteMemoryIndex=$08, the index SA-1 Pack's 22-slot sprite
;# memory is keyed on, and every eligible list's header is rewritten to it
;# on the cartridge's way out. The level files say what the console game
;# said; the cartridge says what the base needs.
;#
;# The walk is the one the pack's More Sprites patch makes, and so are the
;# exclusions, which its header states: indices $10 and $12 are the koopa
;# kid and Bowser battles, whose code addresses the slots by hand; $0A is
;# the wiggler's, whose segments corrupt memory with more slots; level modes
;# $09, $0B and $10 are the boss rooms whose lists the same code reads; and
;# levels 000 and 100, one list between them. A list only code reaches --
;# the Chocolate Island 2 rooms, the roll-call screens -- is not in the
;# table and is left alone, which is what the pack does too.
;#
;# It walks the pointer tables, not the source: the finalize pass reads the
;# image the main pass produced, so each level's sprite header and level
;# mode are read back off the cartridge at the addresses the loader reads
;# them from, whatever file they came from and wherever a packing put the
;# list. The addresses are the loader's, which is why they are literals
;# here: this pass includes no bank, so no label of theirs is in reach. The
;# sprite bank is the loader's $07 on a stock cartridge and the byte per
;# level off the managed level banks' table under that feature, read the
;# same way the loader's stub reads it.
;#
;###########################################################################

; Where the loader's tables are: SMW_SpecifySublevelToLoad's Layer1DataPtrs
; (dl per level) and SpriteDataPtrs (dw per level), and the managed level
; banks' sprite-bank table at the fixed tail of bank $07.
!SMW_SpriteMemoryIndex_Layer1Ptrs = $05E000
!SMW_SpriteMemoryIndex_SpritePtrs = $05EC00
!SMW_SpriteMemoryIndex_SpriteBanks = $07FE00

macro SMW_SpriteMemoryIndex_OneLevel(Level)
	if !Define_SMW_ManagedLevelMemory == !TRUE
		!SMW_SpriteList #= (read1(!SMW_SpriteMemoryIndex_SpriteBanks+<Level>)<<16)|read2(!SMW_SpriteMemoryIndex_SpritePtrs+(<Level>*2))
	else
		!SMW_SpriteList #= $070000|read2(!SMW_SpriteMemoryIndex_SpritePtrs+(<Level>*2))
	endif
	!SMW_SpriteHeader #= read1(!SMW_SpriteList)
	!SMW_SpriteMemory #= !SMW_SpriteHeader&$1F
	!SMW_LevelMode #= read1(read3(!SMW_SpriteMemoryIndex_Layer1Ptrs+(<Level>*3))+$01)&$1F
	if !SMW_SpriteMemory != $12 && !SMW_SpriteMemory != $10 && !SMW_SpriteMemory != $0A && !SMW_LevelMode != $10 && !SMW_LevelMode != $0B && !SMW_LevelMode != $09 && <Level> != $000 && <Level> != $100
		pushpc
		org !SMW_SpriteList
			db (!SMW_SpriteHeader&$E0)|!Define_SMW_SpriteMemoryIndex
		pullpc
	endif
endmacro

; On the finalize pass only: the main pass's image is what read1() sees
; there, and it is complete. Every other pass reads an earlier one's, which
; is empty on the first.
if defined("Define_SMW_SpriteMemoryIndex") && !FileType == !FileType_FinalizeROM
	!SMW_SpriteMemoryIndex_Level #= $000
	while !SMW_SpriteMemoryIndex_Level < $200
		%SMW_SpriteMemoryIndex_OneLevel(!SMW_SpriteMemoryIndex_Level)
		!SMW_SpriteMemoryIndex_Level #= !SMW_SpriteMemoryIndex_Level+1
	endwhile
endif
