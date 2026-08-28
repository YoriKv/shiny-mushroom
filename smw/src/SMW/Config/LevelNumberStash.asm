includeonce

;#############################################################################################################
;# The loading level's number, stashed where a hook can read it back.
;#
;# The stock game computes the number of the level it is about to load
;# transiently, in scratch RAM, and nothing keeps it once the load has
;# read the pointer tables. Two features need it later than that: the
;# custom level palettes (Config/LevelCustomPalettes.asm) index their
;# pointer table with it while the level is prepared, and the level
;# graphics (Config/LevelGraphics.asm) index their rows with it while the
;# level's files are uploaded. Both read the same word, so the stash is
;# one piece here, wanted when either define is on, and the seam that
;# plants it is hooked once.
;#
;# The seam is SMW_SpecifySublevelToLoad (Banks/Bank05.asm,
;# LM000Hijack_StoreSublevelNumber): the one moment the number is whole --
;# doors and pipes included -- with the displaced instructions the
;# hijack replaces being exactly one JSL wide. The stub repeats the
;# displaced read and stores the word to
;# !RAM_SMW_LevelNumberStash_LoadedLevel, the unused pair after the
;# save-file number that Lunar Magic's cartridges keep the same number in.
;#
;# Where the stub sits is the level bank's first occupant that is on: the
;# level graphics when they are, the custom palettes otherwise. Placing it
;# with the graphics whenever they are on is what keeps their block one
;# size whatever else the cartridge has, and placing it with the palettes
;# otherwise is what keeps a cartridge with the palettes alone laid out
;# exactly as it was before the graphics existed.
;#############################################################################################################

; Whether anything wants the stash at all. Read after both features' own
; files, which set their switches.
!Define_SMW_LevelNumberStashWanted #= !FALSE
if !Define_SMW_LevelCustomPalettes == !TRUE
	!Define_SMW_LevelNumberStashWanted #= !TRUE
endif
if !Define_SMW_LevelGraphics == !TRUE
	!Define_SMW_LevelNumberStashWanted #= !TRUE
endif

; The stub's size, part of whichever occupant's budget carries it: the
; placement asserts it.
!Define_SMW_LevelNumberStashStubBytes #= $09

; The stash the bank $05 hijack lands on. A is 16-bit and holds the level
; number word, read from the same scratch the displaced instructions read;
; the store is long so the write lands in the mirror whatever the data bank
; is, and A doubles into Y exactly as the displaced ASL/TAY left it.
; Emitted once, by the occupant the file's top names.
macro SMW_LevelNumberStash_Stub()
SMW_LevelNumberStash_Store:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E	;> The displaced read: the level number, whole
	STA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	ASL					;\ The displaced index math for the
	TAY					;/ sprite pointer rows
	RTL
	assert pc() == SMW_LevelNumberStash_Store+!Define_SMW_LevelNumberStashStubBytes, "The level number stash stub is not the size its budget states. Check Define_SMW_LevelNumberStashStubBytes."
endmacro
