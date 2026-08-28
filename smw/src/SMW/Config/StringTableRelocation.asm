includeonce

;#############################################################################################################
;# Relocating the game's text into an expansion bank.
;#
;# The two runs of text an editor can reword -- the 22 message boxes with
;# their slot tables, and the strings a level's name is assembled from --
;# each fill the run the ROM map gave them to the byte, and the pointers into
;# either are offsets the assembler computes. So a message may grow only by
;# what another shrank, and a name part the same. Setting
;# !Define_SMW_RelocateStringTables to !TRUE moves both sets of tables into
;# the run the growable features share (Config/ReservedBank.asm), where they
;# have whatever the rest of it has left, and leaves a labelled hole where
;# each set was.
;#
;# This is the last of that run's three occupants, so the text lands behind
;# the translevel remap table and the relocated overworld tables, each of
;# which is there or is not. Last is the place for it: the text is the
;# occupant whose length a release decides -- the Japanese cartridge is
;# refused outright, and the international ones word a message as they please
;# -- and behind it there is nothing for that to move.
;#
;# The code that reads them cannot follow: SMW_DisplayMessage indexes the
;# text with Y and SMW_UpdateLevelName every table it has, and a 16-bit read
;# indexed by Y has no long-addressed form. Nor is there room where the ROM
;# map put either routine for the data bank swap the overworld's readers
;# grew by. So each reader is hooked instead, the way a Lunar Magic cartridge
;# hooks the same two routines: a JSL over exactly the bytes it displaces,
;# to a stub placed at the head of the moved block that does the reading with
;# the data bank pointed at itself, and comes back to the routine's own code
;# for everything else. Three hooks, three stubs:
;#
;# - SMW_DisplayMessage's DisplayText (Banks/Bank05.asm): the search of the
;#   slot tables for the level being played, which hands the slot back in X
;#   and returns to the switch-palace drawing that follows it.
;# - CODE_05B1DB in the same routine: the upload of the slot's text into the
;#   stripe image, which returns to the window code after it.
;# - SMW_UpdateLevelName's Main (Banks/Bank04.asm): the whole of the name
;#   box, since every line of it reads a moved table.
;#
;# The stubs are the routines' own loops, moved rather than rewritten, and
;# read RAM through the work RAM mirror every bank below $40 has -- which is
;# why the reserved bank is one of those. The stock code the hooks displace
;# stays in place, dead, so nothing else in either bank moves a byte.
;#
;# The Japanese cartridge is refused: its messages are kana in a format of
;# their own and its name box a routine of its own, and neither stub speaks
;# it.
;#
;# The define needs a cartridge assembled at 1 MB or larger, and the
;# reservation says so rather than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_RelocateStringTables=1 relocates the text.
if defined("Define_SMW_RelocateStringTables") == 0
	!Define_SMW_RelocateStringTables = !FALSE
endif

if !Define_SMW_RelocateStringTables == !TRUE
	if ver_is_japanese(!Define_Global_ROMToAssemble)
		error "The string tables cannot be relocated on the Japanese cartridge: its messages and its name box are in formats of their own that the stubs do not speak."
	endif
endif

;#############################################################################################################
;# Where they go: the stubs first, then the tables packed back to back behind
;# them -- the level-name strings and their offset tables out of bank $04,
;# then the line positions, the slot tables and the text out of bank $05 --
;# growing towards the reserved run's end label.
;#
;# **One block, emitted from one place.** A ROM map's bank macros run in the
;# map's order, and the two sets of text sit either side of half the
;# relocated overworld tables, so leaving each set to emit at its own slot
;# would thread the text through the middle of them -- and what address any
;# fragment in the run had would then depend on which of the features the
;# build had on. Instead the bank macros leave a labelled hole at their slot
;# and hand their tables to %SMW_PlaceRelocatedStrings, which emits the lot in
;# one block at the tail: the text is one contiguous occupant, and everything
;# ahead of it keeps the address it would have had without this feature at
;# all.
;#
;# smw_tools.features declares the whole reserved run as one TablePool: what
;# any occupant does not use, the others may. Three things in this block are
;# nobody's editable fragment and are counted as the pool's reservation -- the
;# stubs, the line positions (16 bytes) and the three name offset tables
;# (118), the last two derived by the assembler from the strings' labels.
;#############################################################################################################

; The three stubs together, in bytes. Part of the run's budget the same way
; the palettes' stubs are: the tables start where the stubs end, so a change
; to a stub is a change to where every table lands, and the editor's tests
; hold the figure against a build.
!Define_SMW_RelocatedStringsStubBytes #= $0144

;#############################################################################################################

; A relocated set's slot in the bank it came out of. The ROM map orgs here
; either way; what a relocated build leaves behind is a labelled hole, so a
; symbol file and the editor's memory map both show it as free.
macro SMW_RelocatableStringSlot(StockAddress, Slot)
%InsertMacroAtXPosition(<StockAddress>)
if !Define_SMW_RelocateStringTables == !TRUE
SMW_VacatedStringTable_<Slot>:
endif
endmacro

; The whole of the relocated text -- the stubs, then both sets of tables --
; at the tail of the reserved run. Called from each ROM map once every bank
; has emitted, so !SMW_ReservedBankNext is the run's first free byte, and
; bracketed with pushpc/pullpc like every placement there.
macro SMW_PlaceRelocatedStrings()
if !Define_SMW_RelocateStringTables == !TRUE
!SMW_RelocatedStringsAt #= !SMW_ReservedBankNext
	pushpc
	org !SMW_ReservedBankNext

; The search DisplayText hooks into, entered with AXY 8-bit and the data
; bank on bank $05: which slot is for the level being played and the message
; number it wants -- walked from the last level slot down, and landing on
; slot 0 without a compare when none matches, exactly as the stock loop
; does. The last slot is the tables' own length rather than the stock $16,
; so a grown table is searched whole: up to $7E level slots, past which the
; doubled pointer index the upload takes would leave 8 bits. The Yoshi-thanks
; message is picked here too, as the pointer past the riding-Yoshi one --
; the two the stock code keeps at $17 and $18, kept at the tables' end.
; Hands the slot back in X.
SMW_RelocatedStrings_FindSlot:
	PHB
	PHK
	PLB
	LDY.w !RAM_SMW_Misc_DisplayMessage
	CPY.b #$03
	BNE.b .Search
	LDX.b #SMW_DisplayMessage_MessagePointers-SMW_DisplayMessage_MessageLevels+$01
	BRA.b .Found
.Search:
	LDX.b #SMW_DisplayMessage_MessagePointers-SMW_DisplayMessage_MessageLevels-$01
.Next:
	LDY.b #$01
	LDA.w SMW_DisplayMessage_MessageLevels,x
	BPL.b .First
	INY
	AND.b #$7F
.First:
	CPY.w !RAM_SMW_Misc_DisplayMessage
	BNE.b .Miss
	CMP.w !RAM_SMW_Overworld_LevelNumberLo
	BEQ.b .Found
.Miss:
	DEX
	BNE.b .Next
.Found:
	PLB
	RTL

; The upload CODE_05B1D1 hooks into, entered with AXY 8-bit and X the slot:
; the riding-Yoshi pick first -- the last level slot's level, with the
; player on Yoshi, shows the pointer after the level slots' -- then the
; slot's text into the stripe image, eight rows of eighteen tiles, the rest
; of a row filled with spaces once a line's bit-7 tile has been seen.
; Returns with AXY 8-bit and the window's own code left to run.
SMW_RelocatedStrings_Upload:
	PHB
	PHK
	PLB
	CPX.b #SMW_DisplayMessage_MessagePointers-SMW_DisplayMessage_MessageLevels-$01
	BNE.b .Pointer
	LDA.w !RAM_SMW_Player_RidingYoshiFlag
	BEQ.b .Pointer
	INX
.Pointer:
	TXA
	ASL
	TAX
	REP.b #$20				; A->16
	LDA.w SMW_DisplayMessage_MessagePointers,x
	STA.b !RAM_SMW_Misc_ScratchRAM00
	REP.b #$10				; XY->16
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	LDY.w #$000E
.Line:
	LDA.w SMW_DisplayMessage_LineVRAM,y
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	LDA.w #$2300
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	PHY
	SEP.b #$20				; A->8
	LDA.b #$12
	STA.b !RAM_SMW_Misc_ScratchRAM02
	STZ.b !RAM_SMW_Misc_ScratchRAM03
	LDY.b !RAM_SMW_Misc_ScratchRAM00
.Tile:
	LDA.b #$1F
	BIT.w !RAM_SMW_Misc_ScratchRAM03
	BMI.b .Store
	LDA.w SMW_DisplayMessage_MessageText,y
	STA.w !RAM_SMW_Misc_ScratchRAM03
	AND.b #$7F
	INY
.Store:
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	LDA.b #$39
	STA.l SMW_StripeImageUploadTable[$02].HighByte,x
	INX
	INX
	DEC.b !RAM_SMW_Misc_ScratchRAM02
	BNE.b .Tile
	STY.b !RAM_SMW_Misc_ScratchRAM00
	REP.b #$20				; A->16
	INX
	INX
	INX
	INX
	PLY
	DEY
	DEY
	BPL.b .Line
	LDA.w #$00FF
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	TXA
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	SEP.b #$30				; AXY->8
	LDA.b #$01
	STA.w !RAM_SMW_Flag_DisableLayer3Scroll
	STZ.b !RAM_SMW_Mirror_Layer3XPosLo
	STZ.b !RAM_SMW_Mirror_Layer3XPosHi
	STZ.b !RAM_SMW_Mirror_Layer3YPosLo
	STZ.b !RAM_SMW_Mirror_Layer3YPosHi
	PLB
	RTL

; The name box SMW_UpdateLevelName's Main hooks into, entered with AXY
; 16-bit: the level's three parts into the stripe image, padded with the
; lone terminated space to the box's width. Returns with A 16-bit, as the
; routine's own RTS would.
SMW_RelocatedStrings_LevelName:
	PHB
	PHK
	PLB
	LDA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	TAX
	CLC
	ADC.w #$0026
	STA.b !RAM_SMW_Misc_ScratchRAM02
	CLC
	ADC.w #$0004
	STA.l !RAM_SMW_Misc_StripeImageUploadIndexLo
	LDA.w #$2500
	STA.l SMW_StripeImageUploadTable[$01].LowByte,x
	LDA.w #$8B50
	STA.l SMW_StripeImageUploadTable[$00].LowByte,x
	LDA.b !RAM_SMW_Misc_ScratchRAM01
	AND.w #$007F
	ASL
	TAY
	LDA.w SMW_UpdateLevelName_Part1Offsets,y
	TAY
	SEP.b #$20				; A->8
	LDA.w SMW_UpdateLevelName_LevelNameStrings,y
	BMI.b .Part2
	JSR.w .Emit
.Part2:
	REP.b #$20				; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$00F0
	LSR
	LSR
	LSR
	TAY
	LDA.w SMW_UpdateLevelName_Part2Offsets,y
	TAY
	SEP.b #$20				; A->8
	LDA.w SMW_UpdateLevelName_LevelNameStrings,y
	CMP.b #$9F
	BEQ.b .Part3
	JSR.w .Emit
.Part3:
	REP.b #$20				; A->16
	LDA.b !RAM_SMW_Misc_ScratchRAM00
	AND.w #$000F
	ASL
	TAY
	LDA.w SMW_UpdateLevelName_Part3Offsets,y
	TAY
	SEP.b #$20				; A->8
	JSR.w .Emit
.Pad:
	CPX.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b .Done
	LDY.w #SMW_UpdateLevelName_LevelStr_None
	JSR.w .Emit
	BRA.b .Pad
.Done:
	LDA.b #$FF
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	REP.b #$20				; A->16
	PLB
	RTL
; One part: its tiles until the bit-7 one, that last one kept masked, and
; nothing past the box's width.
.Emit:
	LDA.w SMW_UpdateLevelName_LevelNameStrings,y
	PHP
	CPX.b !RAM_SMW_Misc_ScratchRAM02
	BCS.b .Skip
	AND.b #$7F
	STA.l SMW_StripeImageUploadTable[$02].LowByte,x
	LDA.b #$39
	STA.l SMW_StripeImageUploadTable[$02].HighByte,x
	INX
	INX
.Skip:
	INY
	PLP
	BPL.b .Emit
	RTS

	assert pc()-!SMW_RelocatedStringsAt == !Define_SMW_RelocatedStringsStubBytes, "The relocated strings' stubs are not the size Define_SMW_RelocatedStringsStubBytes states: every table's address follows from it, so pin the new figure in Config/StringTableRelocation.asm."

; Where the stubs end and the text begins. Both sets are emitted out of the
; same macros the stock build inserts in place, so the bytes are the bank's
; own either way and only where they land differs.
SMW_RelocatedStringsTables:
	%SMW_UpdateLevelName_Tables()
	%SMW_DisplayMessage_Tables()
	assert pc() <= !Loc_SMW_ReservedBank_End, "The relocated strings have outgrown the reserved run: less text fits than the editor was told. Check strings/."
	!SMW_ReservedBankNext #= pc()
	pullpc
endif
endmacro
