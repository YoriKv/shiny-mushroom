includeonce

;#############################################################################################################
;# Per-level custom palettes.
;#
;# The stock game has no palette a level owns: every level assembles its
;# colours out of the global tables by header setting, in
;# SMW_BufferPalettesRoutines_Levels, so two levels picking the same setting
;# share every colour of it. Setting !Define_SMW_LevelCustomPalettes to !TRUE
;# gives a level the other answer: a 514-byte blob of its own -- its back
;# area colour, then all 256 palette-mirror entries -- copied whole over what
;# the stock buffering built, so recolouring it touches no other level.
;#
;# Two hooks, each exactly one JSL over bytes of the same size, at the two
;# spots Lunar Magic marks for its own version of this feature:
;#
;# - SMW_SpecifySublevelToLoad (Banks/Bank05.asm, LM000Hijack_
;#   StoreSublevelNumber): the level number stash, shared with the level
;#   graphics and kept in Config/LevelNumberStash.asm -- the one moment
;#   the loading level's number is whole, stored to
;#   !RAM_SMW_LevelNumberStash_LoadedLevel for the copy below to read.
;# - SMW_GameMode12_PrepareLevel (Banks/Bank00.asm, LM000Hijack_
;#   CustomLevelPalettes), directly after the stock buffering. Game mode $12
;#   is the one palette-buffering caller that is a level being prepared, so
;#   the copy reaches exactly the level path: the castle-destruction
;#   cutscene, "The End" and the enemy rollcall buffer through the same
;#   routine and stay stock, and the Mode 7 rooms branch to their own path
;#   before the hijack, as they do under Lunar Magic.
;#
;# What the copy reads is a pointer table and the blobs it names, in the
;# level bank (Config/LevelBank.asm) -- the expansion bank this feature
;# shares with the level graphics, whose fixed-size rows go in front of
;# the table when that feature is on, and with the managed level banks,
;# which pack the level streams that outgrew banks $06 and $07 after
;# these blobs. One long pointer
;# per level, $200 rows; a zero row is a level on the game's shared colours,
;# which is every row as shipped -- the feature with an unedited table loads
;# exactly what the stock cartridge loads. The rows and the blobs are two
;# incsrc'd fragments the editor regenerates (palettes/levels/), the same
;# shape as the relocated overworld tables' fragments.
;#
;# The define needs a cartridge assembled at 1 MB or larger, which the bank's
;# reservation says rather than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_LevelCustomPalettes=1 turns the palettes on.
if defined("Define_SMW_LevelCustomPalettes") == 0
	!Define_SMW_LevelCustomPalettes = !FALSE
endif

; The block this occupant takes of the level bank's head: the pointer table
; and the stubs behind it, up to the first blob. Declared with every other
; block in Config/PackedRuns.asm, because where the blobs start -- and so
; how many fit before the packed streams -- follows from it, and the editor
; prices the bank against the same number.
;
; One size on every cartridge: the level number stash the copy below reads
; is at the bank's fixed head, in front of every occupant and carried by
; none of them (Config/LevelBank.asm). The placement asserts it.

;#############################################################################################################
;# Where they go: the pointer table at the level bank's head -- or directly
;# behind the fixed-size blocks the level graphics and the per-level code
;# put there when those are on -- then the stubs, then the blobs, growing
;# towards whatever the bank's last occupant has left. The packed head's
;# last occupant in the level bank's sequence (Config/LevelBank.asm): the
;# project's code and the packed streams open behind the blobs.
;#############################################################################################################

; Place the pointer table, the stubs and the blobs. Called from
; %SMW_PlaceLevelBank behind the per-level code's block.
macro SMW_PlaceLevelCustomPalettes()
if !Define_SMW_LevelCustomPalettes == !TRUE
	assert pc() == !Loc_SMW_LevelBank_Palettes, "The custom level palettes must follow the level graphics, or lead the level bank: their pointer table has to sit at one address per cartridge."

; The pointer table: one long pointer per level, $200 rows, at the run's
; head or a fixed distance behind it, so its address is the same on every
; cartridge this bank is.
namespace SMW_LevelCustomPalettes
	incsrc "palettes/levels/level-palettes.asm"
namespace off

; The stubs, the tail of the block above: the copy alone.

; The copy the bank $00 hijack lands on, entered with AXY 8-bit right after
; the stock buffering returned. If the stashed level's pointer row holds
; anything, its 514 bytes land over the back area colour and the whole
; palette mirror -- one contiguous run at !RAM_SMW_Palettes_BackgroundColorLo
; -- and either way the displaced JSL's target is tail-called, so its RTL
; returns to the game-mode routine. Scratch $00-$02 is dead between the two
; JSRs this sits between, like everywhere else at the top level of a game
; mode.
SMW_LevelCustomPalettes_Apply:
	REP.b #$30				; AXY->16
	LDA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	AND.w #$01FF
	STA.b !RAM_SMW_Misc_ScratchRAM00
	ASL					;\ Times three: the pointer
	CLC					;| rows are dl
	ADC.b !RAM_SMW_Misc_ScratchRAM00	;/
	TAX
	LDA.l SMW_LevelCustomPalettes_Pointers,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	LDA.l SMW_LevelCustomPalettes_Pointers+$01,x
	STA.b !RAM_SMW_Misc_ScratchRAM01	;> $00-$02: the blob, as a long pointer
	ORA.b !RAM_SMW_Misc_ScratchRAM00	;> All three bytes zero is no palette
	BEQ.b .Stock
	LDY.w #$0000
.Copy:
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y
	TYX
	STA.l !RAM_SMW_Palettes_BackgroundColorLo,x
	INY
	INY
	CPY.w #$0202				;> The blob whole: backdrop word, then the mirror
	BCC.b .Copy
.Stock:
	SEP.b #$30				; AXY->8, as the hook found them
	JML.l SMW_GameMode12_PrepareLevel_InitializeLayer3RAM

; The blobs, one label and incbin per dressed level, growing towards the
; run's end; the shipped fragment is empty because the shipped rows are
; zero. The label marks where they start -- the stubs' end -- so the budget
; the comment above states is a distance a symbol file can be asked for.
SMW_LevelCustomPalettes_Data:
	assert SMW_LevelCustomPalettes_Data-SMW_LevelCustomPalettes_Pointers == !Define_SMW_Block_LevelCustomPalettes, "The custom level palettes' block is not the size Config/PackedRuns.asm states. Where the blobs start follows from it, so pin the new figure in Define_SMW_Block_LevelCustomPalettes."
namespace SMW_LevelCustomPalettes
	incsrc "palettes/levels/level-palette-data.asm"
namespace off
	assert pc() <= !Loc_SMW_LevelBank_RunEnd, "The custom level palettes have outgrown the level bank: fewer levels can wear one than the editor was told. Check palettes/levels/."
endif
endmacro
