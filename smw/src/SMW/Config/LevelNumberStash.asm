includeonce

;#############################################################################################################
;# The loading level's number, stashed where a hook can read it back.
;#
;# The stock game computes the number of the level it is about to load
;# transiently, in scratch RAM, and nothing keeps it once the load has
;# read the pointer tables. Three features need it later than that: the
;# custom level palettes (Config/LevelCustomPalettes.asm) index their
;# pointer table with it while the level is prepared, and the level
;# graphics (Config/LevelGraphics.asm) index their rows with it while the
;# level's files are uploaded, and the Lunar Magic tables
;# (Config/LunarMagicLevels.asm) index theirs with it later in the same
;# load, and the Layer 3 settings (Config/Layer3Settings.asm) index theirs
;# both at the load and once a frame after it. All read the same word, so the stash is one piece here, wanted
;# when any define is on, and the seam that plants it is hooked once.
;#
;# The seam is SMW_SpecifySublevelToLoad (Banks/Bank05.asm,
;# LM000Hijack_StoreSublevelNumber): the one moment the number is whole --
;# doors and pipes included -- with the displaced instructions the
;# hijack replaces being exactly one JSL wide. The stub repeats the
;# displaced read and stores the word to
;# !RAM_SMW_LevelNumberStash_LoadedLevel, the unused pair after the
;# save-file number that Lunar Magic's cartridges keep the same number in.
;#
;# The stub sits at the level bank's fixed head, ahead of every packed
;# occupant and laid down by the bank rather than by any of them
;# (Config/LevelBank.asm). It is plumbing and not a capability: nothing
;# switches it on by itself, it is wanted whenever any reader is on, and one
;# copy serves all of them. Putting it in front is what keeps every
;# occupant's block one size whatever else the cartridge has -- an occupant
;# that carried it would be a different size depending on who else was
;# there, and a third reader could not be priced at all.
;#############################################################################################################

; Whether anything wants the stash at all. Read after every reader's own
; file, which sets its switch.
!SMW_LevelNumberStashWanted #= !FALSE
if !Define_SMW_LevelCustomPalettes == !TRUE
	!SMW_LevelNumberStashWanted #= !TRUE
endif
if !Define_SMW_LevelGraphics == !TRUE
	!SMW_LevelNumberStashWanted #= !TRUE
endif
if !Define_SMW_LevelCode == !TRUE
	!SMW_LevelNumberStashWanted #= !TRUE
endif
if !Define_SMW_LunarMagicLevels == !TRUE
	!SMW_LevelNumberStashWanted #= !TRUE
endif
if !Define_SMW_Layer3Settings == !TRUE
	!SMW_LevelNumberStashWanted #= !TRUE
endif

; The stash the bank $05 hijack lands on. A is 16-bit and holds the level
; number word, read from the same scratch the displaced instructions read;
; the store is long so the write lands in the mirror whatever the data bank
; is, and A doubles into Y exactly as the displaced ASL/TAY left it.
; Emitted once, by the occupant the file's top names.
; Place it, at the level bank's fixed head. Called from %SMW_PlaceLevelBank
; first of everything in the bank.
macro SMW_PlaceLevelNumberStash()
if !SMW_LevelNumberStashWanted == !TRUE
	assert pc() == !Loc_SMW_LevelBank_Stash, "The level number stash must be the level bank's first thing: every packed occupant behind it starts where it ends."
	%SMW_LevelNumberStash_Stub()
endif
endmacro

macro SMW_LevelNumberStash_Stub()
SMW_LevelNumberStash_Store:
	LDA.b !RAM_SMW_Misc_ScratchRAM0E	;> The displaced read: the level number, whole
	STA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	ASL					;\ The displaced index math for the
	TAY					;/ sprite pointer rows
	RTL
	assert pc() == SMW_LevelNumberStash_Store+!Define_SMW_Block_LevelNumberStash, "The level number stash stub is not the size Config/PackedRuns.asm states. It is part of whichever occupant carries it, so pin the new figure in Define_SMW_Block_LevelNumberStash."
endmacro
