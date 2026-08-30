includeonce

;#############################################################################################################
;# Per-game-mode code: a game mode runs 65816 of its own, around the game's
;# own routine for it.
;#
;# The stock game dispatches each frame through SMW_InitAndMainLoop's
;# GameModePtrs, one two-byte pointer per mode. Setting
;# !Define_SMW_GameModeCode to !TRUE lets a project put its own routines
;# around any of them, at three moments a frame:
;#
;# - init, on the first frame of a mode, in place of main.
;# - main, on every frame after that, before the game's own routine.
;# - end, on every frame, after the game's own routine.
;#
;# Which frame is a mode's first is one byte of RAM: the mode the last frame
;# ran, kept complemented so the cleared RAM the boot leaves matches no mode
;# (Memory/WRAM_Stack.asm). That is the tool this copies' own answer, and
;# the one that is right for every mode -- most of them run for many frames,
;# and which do is not a fact this file wants to know.
;#
;# **The hook is the main loop's call to the game mode**, the site the
;# global main routine already displaces (Config/GlobalCode.asm), so the
;# game's own pointer table is never touched and nothing is written into
;# the game's banks. The stub there calls SMW_GameModeCode_Before ahead of
;# the game's routine and SMW_GameModeCode_After behind it.
;#
;# **Three tables of one word per mode**, defaulting to an RTL, and a row is
;# entered with a return pushed and JMP (table,x): no scratch, no bank byte,
;# nothing to test. A mode with no code costs the table read. A routine
;# meant for every mode -- the tool's `*` -- is a define the fragment sets
;# and a JSL in front of the table's row.
;#
;# What a routine sees is what UberASM Tool gives it: AXY 8-bit, the data
;# bank pointed at its own bank, and an RTL to return by.
;#
;# The rows and the code they name are two incsrc'd fragments the editor
;# regenerates (code/gamemode/), read from the end of the ROM map like the
;# levels' own code, because the code is variable-size and may hijack the
;# game.
;#
;# The define needs a cartridge assembled at 1 MB or larger, for the level
;# bank the stubs share with the levels' code.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_GameModeCode=1 turns the per-game-mode code on.
if defined("Define_SMW_GameModeCode") == 0
	!Define_SMW_GameModeCode = !FALSE
endif

; How many game modes the game dispatches -- the rows of GameModePtrs, whose
; sublabels are based at zero so the last one is its own row offset, which
; the placement below checks. One word per mode per table.
!Define_SMW_GameModeCount #= $2A
!Define_SMW_GameModeCodeRowsBytes #= !Define_SMW_GameModeCount*$0002

;#############################################################################################################
;# The fragment's lines: one mode's routine at one moment, or every mode's.
;#############################################################################################################

; One mode's routine at one entry point, as the label the mode's own file
; defines. Placed at the mode's own row of the named table, so the
; fragment's lines may come in any order. The row is a word: every routine
; is in this bank.
macro SMW_GameModeCode(table, mode, routine)
	assert (<mode>) < !Define_SMW_GameModeCount, "A game mode code row names a mode the game does not dispatch. Check code/gamemode/gamemode-code.asm."
	assert ((<routine>)>>$10) == !Define_SMW_LevelBank, "A game mode's code is not in the level bank. Every routine the rows name is assembled into it, so the rows can be words. Check code/gamemode/."
	pushpc
	org !SMW_GameModeCode_<table>At+((<mode>)*$0002)
	dw <routine>
	pullpc
endmacro

; A routine every mode runs at one entry point, ahead of the mode's own row.
macro SMW_GameModeCodeAll(table, routine)
	!SMW_GameModeCode_All<table> = <routine>
endmacro

; Run one table's row for the current mode, after the routine every mode
; runs there if the fragment named one. Entered with AXY 8-bit and the data
; bank pointed at this bank; the row is entered with its return pushed, so
; its RTL lands on the instruction after the jump.
macro SMW_GameModeCode_Run(table)
	if defined("SMW_GameModeCode_All<table>")
		JSL.l !SMW_GameModeCode_All<table>
	endif
	LDA.w !RAM_SMW_Misc_GameMode
	ASL				;\ Two bytes a row
	TAX				;/
	PHK				;\ Where the routine's RTL returns:
	PEA.w ?back-1			;/ the byte after this jump
	JMP.w (SMW_GameModeCode_<table>Rows,x)
?back:
endmacro

;#############################################################################################################
;# Where it goes: the tables, the two routines the frame stub calls, and
;# the modes' own code, all in the level bank. Placed from the end of each
;# ROM map, after every bank has emitted, so a file that hijacks the game
;# lands.
;#############################################################################################################

; Place the tables, the routines and the modes' code. Called from the end of
; each ROM map.
macro SMW_PlaceGameModeCode()
if !Define_SMW_GameModeCode == !TRUE
	pushpc
	org !SMW_LevelBankNext
	assert SMW_InitAndMainLoop_GameModePtrs_GameMode29_DoNothingOnTheEndScreen == (!Define_SMW_GameModeCount-1)*$0002, "The game dispatches a different number of modes than Config/GameModeCode.asm states in Define_SMW_GameModeCount."

; What a row names until a fragment line names something else: nothing to
; run. In front of the tables so their fill can name it.
SMW_GameModeCode_None:
	RTL

; One row per mode per entry point.
SMW_GameModeCode_InitRows:
	!SMW_GameModeCode_InitAt #= pc()
	fillword SMW_GameModeCode_None : fill !Define_SMW_GameModeCodeRowsBytes
SMW_GameModeCode_MainRows:
	!SMW_GameModeCode_MainAt #= pc()
	fillword SMW_GameModeCode_None : fill !Define_SMW_GameModeCodeRowsBytes
SMW_GameModeCode_EndRows:
	!SMW_GameModeCode_EndAt #= pc()
	fillword SMW_GameModeCode_None : fill !Define_SMW_GameModeCodeRowsBytes
	incsrc "code/gamemode/gamemode-code.asm"
	assert pc() == SMW_GameModeCode_InitRows+($0003*!Define_SMW_GameModeCodeRowsBytes), "The game mode code tables do not end where their three tables should. Check code/gamemode/gamemode-code.asm."

; Before the game's own routine: the mode's init on its first frame, its
; main on every other. Called by JSL from the frame stub with AXY 8-bit.
SMW_GameModeCode_Before:
	PHB				;\ The routines' data bank is their
	PHK				;| own, so their absolutes reach the
	PLB				;/ code beside them
	LDA.w !RAM_SMW_Misc_GameMode
	EOR.b #$FF			;> Complemented, so cleared RAM matches nothing
	CMP.l !RAM_SMW_GameModeCode_LastMode
	BEQ.b .Main
	STA.l !RAM_SMW_GameModeCode_LastMode
	%SMW_GameModeCode_Run(Init)
	PLB
	RTL
.Main:
	%SMW_GameModeCode_Run(Main)
	PLB
	RTL

; After the game's own routine: the mode's end, on the mode the frame ends
; in -- the game's routine may have advanced it.
SMW_GameModeCode_After:
	PHB
	PHK
	PLB
	%SMW_GameModeCode_Run(End)
	PLB
	RTL

; The modes' own routines, one label and incsrc per mode that has any, and
; the routine every mode runs if there is one.
SMW_GameModeCode_Data:
	incsrc "code/gamemode/gamemode-code-data.asm"
	assert (pc()>>$10) == !Define_SMW_LevelBank, "A game mode's code file left the level bank: an org into the game needs a pushpc/pullpc bracket around it, or the rest of the file assembles over the game. Check code/gamemode/."
	assert pc() <= !Loc_SMW_LevelBank_RunEnd, "The game modes' code has outgrown the level bank: less fits in it than the editor was told. Check code/gamemode/."
	!SMW_LevelBankNext #= pc()
	pullpc
endif
endmacro
