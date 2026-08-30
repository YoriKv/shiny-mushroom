includeonce

;#############################################################################################################
;# Per-level code: a level runs 65816 of its own.
;#
;# The stock game gives a level no code. Everything a level does differently
;# it does through its header, its objects and its sprites, so two levels
;# wanting different behaviour need different data and nothing else is
;# available. Setting !Define_SMW_LevelCode to !TRUE gives a level the other
;# answer: routines of its own, called at four moments, with the whole
;# machine in front of them.
;#
;# Four entry points, in the order a level reaches them:
;#
;# - load, before the level's objects are drawn (SMW_LoadSublevel, Banks/
;#   Bank05.asm): the Map16 table has just been filled with the empty tile
;#   and nothing has been placed into it, so this is where a level writes
;#   its own tiles into $7EC800 and sets the flags the loader reads.
;# - init, once the level is prepared and before the game mode hands over
;#   (SMW_GameMode12_PrepareLevel, Banks/Bank00.asm).
;# - main, once a frame while the level runs (SMW_GameMode14_InLevel,
;#   Banks/Bank00.asm), at the read of the pause flag that opens the mode's
;#   routine -- so it runs on a paused frame too, which is where UberASM
;#   Tool runs it, and ahead of the Mode 7 fork, so it runs in a boss room
;#   as readily as in an ordinary level.
;# - nmi, in the VBlank handler (SMW_VBlankRoutine, Banks/Bank00.asm), at
;#   the read of the music port at the top of its SPC700 I/O. Gated on a
;#   level actually being on screen, because outside one the stash names a
;#   level that is not loaded. The site is in the handler's
;#   version-independent half, past where SA-1 Pack's own NMI hijack ends.
;#
;# Every hook is a **byte-neutral replacement**, because RomMap/ places each
;# routine at a literal address and the banks are packed to the byte: an
;# added instruction would push the routine into the next placement. Each
;# takes the bytes of an instruction or two and the stub does their work,
;# which is what Config/LevelNumberStash.asm does for its own seam.
;#
;# **A hook is only planted if some level uses that entry point.** The rows
;# fragment sets !SMW_LevelCode_<Entry>Wanted as it names a routine, and
;# each hook in Banks/ asks for its own -- so a project whose levels have no
;# nmi: pays nothing in VBlank, and one with no code at all assembles the
;# stock cartridge with four empty tables behind it.
;#
;# **Where a hook displaces a JSR, the padding it frees becomes an RTL.**
;# A JSR target ends in RTS, which returns to the program bank it was called
;# in, and the stub is in another one -- so the stub pushes a long return of
;# its own, pushes the address of that planted RTL as the RTS return, and
;# JMLs to the target. The target returns to the RTL, which returns to the
;# stub. UberASM Tool does the same thing with an address it happened to
;# find; owning the source means planting the byte where it is needed and
;# naming it.
;#
;# What each stub reads is a table of one word per level, in the level bank
;# (Config/LevelBank.asm), indexed by the level number the load stashed
;# (Config/LevelNumberStash.asm). A zero row is a level with nothing to run
;# at that moment, which is every row as shipped -- the feature with unedited
;# tables runs exactly what the stock cartridge runs.
;#
;# The rows are words and not long pointers. Every level's code is in this
;# one bank, so the bank byte is known when the tables are assembled: each
;# table is $400 rather than $600, and the entry is made with a frame the
;# routine's own RTL unwinds. What a level's code sees is what UberASM Tool
;# gives it -- AXY 8-bit, the data bank pointed at its own bank, and an RTL
;# to return by -- so a routine written for that tool assembles here
;# unchanged.
;#
;# The rows and the code they name are two incsrc'd fragments the editor
;# regenerates (code/levels/). The rows are placed with the tables at the
;# head of the ROM map, because their size is declared; the code at the
;# other end, because its size is not -- and because a file that hijacks
;# the game only lands if every bank has emitted first.
;#
;# The define needs a cartridge assembled at 1 MB or larger, which the
;# bank's reservation says rather than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_LevelCode=1 turns the per-level code on.
if defined("Define_SMW_LevelCode") == 0
	!Define_SMW_LevelCode = !FALSE
endif

; One table's length: one word per level number. Four of them, in the order
; a level reaches them.
!Define_SMW_LevelCodeRowsBytes #= $0200*$0002

; Which entry points some level uses, set by the rows fragment as it names a
; routine. Each hook in Banks/ asks for its own, so an entry point no level
; declares costs no hook at all.
!SMW_LevelCode_LoadWanted	#= !FALSE
!SMW_LevelCode_InitWanted	#= !FALSE
!SMW_LevelCode_MainWanted	#= !FALSE
!SMW_LevelCode_NmiWanted	#= !FALSE

;#############################################################################################################
;# The fragments' lines: one level's routine, per entry point.
;#############################################################################################################

; One level's routine at one entry point, as the label a level's own file
; defines. Placed at the level's own row of the named table, so the
; fragment's lines may come in any order and a level the fragment names
; twice keeps the later line. The row is a word: every routine is in this
; bank, and the stub supplies the bank byte. Naming a routine is what
; plants the entry point's hook.
macro SMW_LevelCode(table, level, routine)
	assert ((<level>)>>9) == 0, "A level code row names a level past $1FF. Check code/levels/level-code.asm."
	assert ((<routine>)>>$10) == !Define_SMW_LevelBank, "A level's code is not in the level bank. Every routine the rows name is assembled into it, so the rows can be words. Check code/levels/."
	!SMW_LevelCode_<table>Wanted #= !TRUE
	pushpc
	org !SMW_LevelCode_<table>At+((<level>)*$0002)
	dw <routine>
	pullpc
endmacro

;#############################################################################################################
;# The two things every entry stub does.
;#############################################################################################################

; Run this level's row of a table, if it has one: the row is read with the
; level number doubled, and handed to the shared entry below.
macro SMW_LevelCode_Run(table)
	JSR.w SMW_LevelCode_Index
	LDA.l <table>,x			;> This level's routine, or nothing
	JSR.w SMW_LevelCode_Call
endmacro

; Call a JSR target in another bank, and come back. The target returns with
; RTS, which lands in the bank it was entered in, so <landing> names the RTL
; a hook planted in the padding it freed: the RTS reaches that, and the RTL
; unwinds the long return pushed here.
macro SMW_LevelCode_CallInBank(target, landing)
	PHK				;\ The long return: this bank, and the
	PEA.w ?back-1			;/ byte after this call
	PEA.w (<landing>)-1		;> The RTS return: the planted RTL
	JML.l <target>
?back:
endmacro

;#############################################################################################################
;# Where it goes: the four tables behind the level graphics' block, then the
;# entry stubs, then the levels' own code. Placed from the top of each ROM
;# map, between the level graphics' placement and the custom level
;# palettes', because the palettes' blobs are the packed head's growing end
;# and nothing may declare an address behind them.
;#############################################################################################################

; Place the levels' own code, and whatever it hijacks. Called from the other
; end of each ROM map, beside the relocated text, and that is the whole point
; of it being a second placement:
;
; - **It is variable-size, and the packed head is not.** The tables and the
;   stubs are a block this occupant declares, and the custom level palettes
;   behind them are read past that figure -- so a level's own code, whose
;   length is whatever the project's files come to, cannot sit inside it. It
;   goes behind the palettes' blobs instead, and the packed level streams
;   open behind it.
; - **A hijack only survives if every bank has emitted.** A code file may org
;   into the game, and written from the head of the map -- before any bank has
;   emitted -- that write is made and then emitted over, silently. Here it
;   sticks.
;
; Read before the managed level banks close, so the packer sees the cursor
; this leaves, and after every bank, so a hijack lands. Nothing is lifted out
; of a file to make that work: a file's own pushpc/org/pullpc writes into a
; bank that is already there, and comes back to the cursor by itself. What
; is checked is that it came back: an org into the game with no bracket
; around it would leave the rest of the file, and every placement after it,
; assembling into the game's own banks.
macro SMW_PlaceLevelCodeData()
if !Define_SMW_LevelCode == !TRUE
	pushpc
	org !SMW_LevelBankNext

; The levels' own routines, one label and incsrc per level that has any,
; growing towards whatever the bank's last occupant has left; the shipped
; fragment is empty because the shipped rows are all zero.
SMW_LevelCode_Data:
	incsrc "code/levels/level-code-data.asm"
	assert (pc()>>$10) == !Define_SMW_LevelBank, "A level's code file left the level bank: an org into the game needs a pushpc/pullpc bracket around it, or the rest of the file assembles over the game. Check code/levels/."
	assert pc() <= !Loc_SMW_LevelBank_RunEnd, "The levels' code has outgrown the level bank: less fits in it than the editor was told. Check code/levels/."
	!SMW_LevelBankNext #= pc()
	pullpc
endif
endmacro

; Place the tables and the stubs. Called from the head of each ROM map, and
; bracketed with pushpc/pullpc like every placement there.
macro SMW_PlaceLevelCode()
if !Define_SMW_LevelCode == !TRUE
	pushpc
	org !SMW_LevelBankNext
	assert pc() == !Loc_SMW_LevelBank_Code, "The per-level code must follow the level graphics, or lead the packed head: its rows have to sit at one address per cartridge."

; One row per level number per entry point, every one of them zero -- no
; level runs anything until a fragment line names a routine.
SMW_LevelCode_LoadRows:
	!SMW_LevelCode_LoadAt #= pc()
	fillbyte $00 : fill !Define_SMW_LevelCodeRowsBytes
SMW_LevelCode_InitRows:
	!SMW_LevelCode_InitAt #= pc()
	fillbyte $00 : fill !Define_SMW_LevelCodeRowsBytes
SMW_LevelCode_MainRows:
	!SMW_LevelCode_MainAt #= pc()
	fillbyte $00 : fill !Define_SMW_LevelCodeRowsBytes
SMW_LevelCode_NmiRows:
	!SMW_LevelCode_NmiAt #= pc()
	fillbyte $00 : fill !Define_SMW_LevelCodeRowsBytes
	incsrc "code/levels/level-code.asm"
	assert pc() == SMW_LevelCode_LoadRows+($0004*!Define_SMW_LevelCodeRowsBytes), "The level code tables do not end where their four $200-row tables should. Check code/levels/level-code.asm."

; Enter one row's routine and come back. Entered by JSR with AXY 16-bit and
; A holding the row, which is the routine's address in this bank or zero.
;
; The routine is entered the way it will leave: two frames are pushed --
; the return it will RTL to, then the routine itself, one byte short -- and
; the RTL here pops the second and lands on the routine's first byte. Its
; own RTL pops the first and lands on .Back. Nothing goes through scratch,
; which is what lets the VBlank stub use this without saving anything: an
; interrupt only borrows the machine's registers, and those the routine is
; expected to leave as it found them.
;
; The routine sees AXY 8-bit and the data bank pointed at this bank, which
; is what UberASM Tool gives it; this returns AXY 8-bit and the data bank
; as it was.
SMW_LevelCode_Call:
	BEQ.b .None			;> A zero row is a level with nothing to run
	DEC				;> The routine, one byte short, for the RTL below
	PHB				;> The hook's data bank, put back at .Back
	PHK				;\ Where the routine's RTL returns:
	PEA.w .Back-1			;/ .Back, in this bank
	PHK				;\ The routine: this bank, then its address,
	PHA				;/ which is the frame the RTL pops
	PHK				;\ The data bank the routine sees is its own,
	PLB				;/ so its absolutes reach the code beside it
	SEP.b #$30			; AXY->8
	RTL				;> Into the routine
.Back:
	PLB
.None:
	SEP.b #$30			; AXY->8
	RTS

; The level number, doubled, as the row index every stub reads its table
; with. Entered by JSR with whatever widths the hook found; returns AXY
; 16-bit. A routine of its own so that the stash's readers are the ones
; the code graph can see, rather than four copies of a macro.
SMW_LevelCode_Index:
	REP.b #$30			; AXY->16
	LDA.l !RAM_SMW_LevelNumberStash_LoadedLevel
	AND.w #$01FF
	ASL				;\ Two bytes a row
	TAX				;/
	RTS

; load, before the level's objects are drawn. Entered by JML in place of the
; JSR that begins the load and the SEP after it; the level's own code runs
; first, so what it writes into the Map16 table is what the objects are
; placed over. The game had A 8-bit and XY 16-bit, and the target it
; displaced wants them that way.
SMW_LevelCode_Load:
	%SMW_LevelCode_Run(SMW_LevelCode_LoadRows)
	REP.b #$10			; XY->16
	%SMW_LevelCode_CallInBank(SMW_BeginLoadingLevelData_Main, SMW_LoadSublevel_LevelCodeLanding)
	SEP.b #$30			; AXY->8, the displaced SEP
	JML.l SMW_LoadSublevel_LevelCodeReturn

; init, once the level is prepared. Entered by JML in place of the two JSRs
; that end the preparation, both of which the stub makes in turn before
; handing back to the JMP that followed them.
SMW_LevelCode_Init:
	%SMW_LevelCode_Run(SMW_LevelCode_InitRows)
	%SMW_LevelCode_CallInBank(SMW_GameMode12_PrepareLevel_CODE_00919B, SMW_GameMode12_PrepareLevel_LevelCodeLanding)
	%SMW_LevelCode_CallInBank(SMW_CompressOAMTileSizeBuffer_Main, SMW_GameMode12_PrepareLevel_LevelCodeLanding)
	JML.l SMW_GameMode12_PrepareLevel_LevelCodeReturn

; main, once a frame while the level runs. Entered by JML in place of the
; read of the pause flag and the branch under it, so the stub repeats both
; and jumps to whichever side the flag chose: the paused frame's handling,
; or the frame proper -- the Mode 7 fork and everything under it.
SMW_LevelCode_Main:
	%SMW_LevelCode_Run(SMW_LevelCode_MainRows)
	LDA.w !RAM_SMW_Flag_Pause	;> The displaced read
	BEQ.b .Running			;> The displaced branch
	JML.l SMW_GameMode14_InLevel_LevelCodePaused
.Running:
	JML.l SMW_GameMode14_InLevel_LevelCodeReturn

; nmi, in the VBlank handler's own time. Entered by JML in place of the read
; of the music port and the branch under it, so the stub repeats both -- and
; leaves A holding what the read loaded, because both sides of that branch
; store it back. It runs only while a level is on screen, because outside
; one the stash names a level that is not loaded.
SMW_LevelCode_Nmi:
	LDA.w !RAM_SMW_Misc_GameMode	;\ The two game modes a loaded level
	CMP.b #!Define_SMW_GameMode13_MosaicFadeInToLevel	;| is on screen in
	BEQ.b .InLevel			;|
	CMP.b #!Define_SMW_GameMode14_InLevel	;|
	BNE.b .Displaced		;/
.InLevel:
	%SMW_LevelCode_Run(SMW_LevelCode_NmiRows)
.Displaced:
	LDA.w !RAM_SMW_IO_MusicCh1	;> The displaced read, and what both sides store
	BNE.b .NoMusicChange		;> The displaced branch
	JML.l SMW_VBlankRoutine_LevelCodeReturn
.NoMusicChange:
	JML.l SMW_VBlankRoutine_NoMusicChange

	assert pc() == SMW_LevelCode_LoadRows+!Define_SMW_Block_LevelCode, "The per-level code block is not the size Config/PackedRuns.asm states. The palettes behind it are read past the same figure, so pin the new figure in Define_SMW_Block_LevelCode."

	!SMW_LevelBankNext #= pc()
	pullpc
endif
endmacro
