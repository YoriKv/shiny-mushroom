includeonce

;#############################################################################################################
;# The blocks the packed runs are made of, all of them, in one place.
;#
;# Two runs in this cartridge are packed rather than placed: the reserved
;# bank the growable features share (Config/ReservedBank.asm) and the head of
;# the level bank (Config/LevelBank.asm). Each occupant of one is switched on
;# by itself, so each emits as though the run were empty in front of it, and
;# what an occupant is actually read at is its own address plus the blocks of
;# whichever occupants ahead of it the cartridge also has.
;#
;# That makes a block a shared fact rather than a file's own business: the
;# occupant behind is read past it, the reservation is priced by it, and the
;# editor greys a switch out with it (smw_tools.features, whose Feature.
;# block_bytes reads these defines rather than restating them). So the figures
;# are declared here, once, and each occupant asserts its own against what it
;# emitted -- which is what keeps a hand-held number honest without anything
;# having to know two of them.
;#
;# Every figure is the block **unedited**, because that is what a declared
;# address is: a project that reworded a message or dressed a level reads its
;# own build's symbol file. The two blocks that are editable data all through
;# -- the relocated overworld tables and the relocated text -- therefore
;# cannot assert theirs, and the tests measure them against a build instead.
;# The three whose size is fixed do assert, at the spot they finish emitting.
;#############################################################################################################

;#############################################################################################################
;# The reserved run, in the order Config/ReservedBank.asm emits it.
;#############################################################################################################

; The lookup stub the bank $05 JML lands on, and the $60 rows of two bytes
; behind it (Config/TranslevelRemap.asm). Fixed: the rows are the one count
; in this run a project cannot change.
!Define_SMW_Block_TranslevelRemap		#= $00DA

; The eight relocated fragments and the Layer 2 divider table
; (Config/OverworldTableRelocation.asm), from the run's head to the first
; byte the next occupant may have. Every byte of it is a fragment the editor
; rewords, so this is the shipped length and nothing asserts it.
!Define_SMW_Block_RelocatedOverworldTables	#= $0B02

; The three stubs, the line positions, the name offset tables and both sets
; of text (Config/StringTableRelocation.asm). The shipped length again, and
; the one figure here a release decides -- the arcade wording measures $0EE3
; against this $0F05. Harmless only because the text is the run's last
; occupant: nothing is read past it. Nothing may be placed behind the text
; until this is per-target.
!Define_SMW_Block_RelocatedStrings		#= $0F05

;#############################################################################################################
;# The level bank's fixed head, ahead of the packed occupants
;# (Config/LevelBank.asm). One copy of the level number stash, laid down by
;# the bank itself whenever any occupant wants it, so no occupant carries it
;# and every occupant's block is one size whatever else the cartridge has.
;# Not a packed occupant: nothing switches it on by itself, and nothing is
;# read past it that does not also start behind it.
;#############################################################################################################

!Define_SMW_Block_LevelNumberStash		#= $0009

;#############################################################################################################
;# The level bank's packed head, in the order Config/LevelBank.asm emits it.
;# The level streams behind these are the bank's last occupant and pack at
;# the cursor they leave, so they have no block here.
;#############################################################################################################

; The $200 rows of eight bytes, the $200 animated files and the read stubs
; (Config/LevelGraphics.asm). Fixed, and one size on every cartridge.
!Define_SMW_Block_LevelGraphics			#= $12D3

; Four $200-row tables of two bytes -- one per entry point -- and the
; dispatch and entry stubs behind them (Config/LevelCode.asm), from this
; occupant's head to the first level's own routine. Fixed, and one size on
; every cartridge.
!Define_SMW_Block_LevelCode			#= $1099

; The $200 long pointers and the stubs (Config/LevelCustomPalettes.asm), from
; this occupant's head to the first blob. Fixed, and one size on every
; cartridge.
!Define_SMW_Block_LevelCustomPalettes		#= $0637
