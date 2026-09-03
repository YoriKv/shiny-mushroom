includeonce

;#############################################################################################################
;# Code that belongs to no level and no game mode: the tool's global: and
;# statusbar: tags, and the frame hook the game modes' code shares.
;#
;# Three entry points, none of them dispatched through anything -- there is
;# one of each, so there is nothing to index:
;#
;# - init, once at boot, after the RAM clear and the SPC upload and before
;#   the main loop turns over for the first time.
;# - main, every frame, in front of the game mode's own work.
;# - statusbar, whenever the status bar's counters are drawn, which is what
;#   that tag means.
;#
;# **A routine here returns with RTS, not RTL**, which is the convention the
;# tool this copies uses for these two tags and the reason they cannot be
;# entered the way the levels' and the game modes' code is. An RTS returns
;# within the program bank it was called in, so the call has to be made
;# from the same bank as the routine -- which is what the stubs below are
;# for. The hook jumps here, the stub JSRs the routine beside it, and the
;# routine comes back the way it expects to.
;#
;# **A hook is only there if there is code for it.** The fragment names the
;# routines, is read with the defines rather than with the code, and each
;# hook in Banks/ asks whether its own entry point was named. A project with
;# only statusbar: code has no frame hook at all -- not a branch, not a byte
;# -- where the tool this copies must install all of its hooks always,
;# having no way to know what will be added after it has run.
;#
;# **The frame hook is shared.** The main loop's call to the game mode is
;# where the global main routine runs, and also where a game mode's own
;# code runs around the game's (Config/GameModeCode.asm): one displaced
;# call, one stub, planted when either wants it.
;#
;# Two fragments under code/global/, both the editor's: global-code.asm,
;# which is defines only and is read early, and global-code-data.asm, the
;# routines themselves, emitted in the level bank's sequence with the
;# levels' own code.
;#
;# The define needs a cartridge assembled at 1 MB or larger, for the level
;# bank the stubs share.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_GlobalCode=1 turns it on.
if defined("Define_SMW_GlobalCode") == 0
	!Define_SMW_GlobalCode = !FALSE
endif

; Which entry points the project actually wrote, named by the fragment. Read
; here, with the defines, because the hooks in Banks/ are assembled long
; before the code is placed and each has to know whether to be there at all.
if !Define_SMW_GlobalCode == !TRUE
	incsrc "code/global/global-code.asm"
endif

; Whether each hook is wanted, as one question apiece so a bank file asks it
; without knowing how the answer is spelled.
!SMW_GlobalCode_InitWanted	#= !FALSE
!SMW_GlobalCode_MainWanted	#= !FALSE
!SMW_GlobalCode_StatusWanted	#= !FALSE
if !Define_SMW_GlobalCode == !TRUE
	if defined("SMW_GlobalCode_Init")
		!SMW_GlobalCode_InitWanted #= !TRUE
	endif
	if defined("SMW_GlobalCode_Main")
		!SMW_GlobalCode_MainWanted #= !TRUE
	endif
	if defined("SMW_GlobalCode_Status")
		!SMW_GlobalCode_StatusWanted #= !TRUE
	endif
endif

; The frame hook: wanted by the global main routine, by the game modes' code
; whatever the project wrote, and by the custom music, whose sound driver has
; to be given the frame's mailbox writes once the game mode has made them.
;
; There is one hook and the main loop has room for one: it is five bytes, the
; call to the game mode and the store that ends the frame, and anything wanting
; to run every frame runs from this stub rather than taking those bytes for
; itself. That is what keeps two features from overwriting each other there --
; the trap AddmusicK falls into when it patches a ROM, hijacking the same five
; bytes with no way to know what else wanted them.
!SMW_FrameHookWanted	#= !FALSE
if !SMW_GlobalCode_MainWanted == !TRUE || !Define_SMW_GameModeCode == !TRUE
	!SMW_FrameHookWanted #= !TRUE
endif
if !Define_SMW_CustomMusic == !TRUE
	!SMW_FrameHookWanted #= !TRUE
endif

;#############################################################################################################
;# The stubs, in the level bank beside the routines they call.
;#############################################################################################################

; Call one routine of this file's kind and come back. The JSR is what the
; convention needs -- the routine ends in RTS, and an RTS returns within the
; bank it was called in, so the call is made from the bank the routine is
; in. The data bank is pointed at that bank too, so the routine's absolutes
; reach the code beside it.
macro SMW_GlobalCode_Call(routine)
	PHB
	LDA.b #!Define_SMW_LevelBank
	PHA
	PLB
	JSR.w <routine>
	PLB
endmacro

; Place the stubs and the routines. Called from %SMW_PlaceLevelBank behind
; the levels' and the game modes' own code, for the same two reasons: what
; a project wrote is variable-size, and a file that hijacks the game only
; lands once every bank has emitted.
macro SMW_PlaceGlobalCode()
if !SMW_FrameHookWanted == !TRUE || !Define_SMW_GlobalCode == !TRUE

if !SMW_FrameHookWanted == !TRUE
; The frame, entered by JML from the main loop in place of the call to the
; game mode and the store that ends the frame. The global main routine and
; the mode's own code run first, the game mode's own work is made from here
; through the RTL the hook left in the bytes it freed, and the mode's end
; code runs after it.
SMW_FrameCode_Stub:
if !SMW_GlobalCode_MainWanted == !TRUE
	%SMW_GlobalCode_Call(!SMW_GlobalCode_Main)
endif
if !Define_SMW_GameModeCode == !TRUE
	JSL.l SMW_GameModeCode_Before
endif
	PHK					;\ The long return: this bank, and
	PEA.w ?Back-1				;/ the byte after this call
	PEA.w SMW_InitAndMainLoop_FrameCodeLanding-1	;> The RTS return: the planted RTL
	JML.l SMW_InitAndMainLoop_ProcessGameMode
?Back:
if !Define_SMW_GameModeCode == !TRUE
	JSL.l SMW_GameModeCode_After
endif
if !Define_SMW_CustomMusic == !TRUE
	JSL.l SMW_CustomMusic_FrameHook		;> The sound driver's frame, after the game mode wrote the mailboxes
endif
	STZ.b !RAM_SMW_Flag_Lagging		;> The displaced store: the frame is done
	JML.l SMW_InitAndMainLoop_FrameCodeReturn
endif

if !SMW_GlobalCode_InitWanted == !TRUE
; init, entered by JML from the boot path with AXY 8-bit. The two displaced
; instructions set up OAM, and are repeated here rather than guessed at.
SMW_GlobalCode_InitStub:
	%SMW_GlobalCode_Call(!SMW_GlobalCode_Init)
	LDA.b #!Define_SMW_GlobalSpriteSizeAndVRAMLocation	;> The displaced pair
	STA.w !REGISTER_OAMSizeAndDataAreaDesignation
	JML.l SMW_InitAndMainLoop_GlobalCodeInitReturn
endif

if !SMW_GlobalCode_StatusWanted == !TRUE
; statusbar, entered by JML in place of the read and the OR that open the
; counters' routine, both repeated here so the branch under them sees the
; flags it expects.
SMW_GlobalCode_StatusStub:
	%SMW_GlobalCode_Call(!SMW_GlobalCode_Status)
	LDA.w !RAM_SMW_Timer_EndLevel		;\ The displaced pair, and the
	ORA.b !RAM_SMW_Flag_SpritesLocked	;/ flags the branch reads
	JML.l SMW_UpdateStatusBarCounters_GlobalCodeReturn
endif

if !Define_SMW_GlobalCode == !TRUE
SMW_GlobalCode_Data:
	incsrc "code/global/global-code-data.asm"
	assert (pc()>>$10) == !Define_SMW_LevelBank, "A global code file left the level bank: an org into the game needs a pushpc/pullpc bracket around it, or the rest of the file assembles over the game. Check code/global/."
	assert pc() <= !Loc_SMW_LevelBank_RunEnd, "The global code has outgrown the level bank: less fits in it than the editor was told. Check code/global/."
endif
endif
endmacro
