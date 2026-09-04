includeonce

;#############################################################################################################
;# The music and time limit bypasses: two objects a level's own stream
;# carries to overrule its header.
;#
;# A level header names its music out of eight tracks and its time limit out
;# of four values, both read once at the top of the level load
;# (SMW_LoadLevelHeader_Main). Lunar Magic adds two standard objects that say
;# the same things without those lists: object 26 names any track the music
;# register takes, and object 28 any three-digit time limit, with a flag that
;# resets the timer on every entry rather than only on the way in from the
;# map. Setting !Define_SMW_HeaderBypasses to !TRUE gives this cartridge both.
;#
;# **They run where the object pass runs**, which is behind the header parse
;# in SMW_BeginLoadingLevelData_Main and ahead of the music register reaching
;# the sound chip in game mode $11 -- so an object that writes either one
;# wins over the header, and the header's own value was never played or
;# counted.
;#
;# **The records** are three bytes each, the standard shape, and both keep
;# their payload where a placed object keeps its position. That is what makes
;# them settings for the level rather than something standing in it:
;#
;#   26: N10-UUUU 0110uuuu MMMMMMMM   the track, plus one, in MMMMMMMM, and
;#                                    the same value again in UUUUuuuu, which
;#                                    this cartridge carries and does not read
;#   28: N10-BBBB 1000AAAA R---CCCC   the tens in BBBB, the ones in AAAA, the
;#                                    hundreds in CCCC, and R forcing the reset
;#
;# A track of zero names none, and three zero digits name no time limit unless
;# R is set: a record carrying nothing leaves the header's setting standing,
;# which is what makes zero reachable only through the force flag.
;#
;# **The digits are read back off the stream** rather than out of the loader's
;# copy of the record. SMW_LoadLevelDataObject_Main exchanges the two position
;# nibbles in a vertical level, and these are not positions -- read from the
;# record itself, one stream means the same thing in a level of either shape.
;#
;# The two routines are one block in the run the growable features share
;# (Config/ReservedBank.asm), behind the custom tiles and ahead of the text.
;# The define needs a cartridge assembled at 1 MB or larger, which the
;# reservation says rather than letting the image quietly double.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_HeaderBypasses=1 turns the two objects on.
if defined("Define_SMW_HeaderBypasses") == 0
	!Define_SMW_HeaderBypasses = !FALSE
endif

; The records' grammar. A digit is a nibble; the settings byte's high bit is
; object 28's force flag, and the three bytes a record is are what the loader
; has already stepped the level data pointer past.
!Define_SMW_HeaderBypasses_DigitMask	= $0F
!Define_SMW_HeaderBypasses_ForceBit	= $80
!Define_SMW_HeaderBypasses_RecordBytes	= $0003

; What the music register's two high bits mean where the header sets it, and
; where these do: bit 7 says the track playing is not an ordinary one, and
; bit 6 that the track asked for is the one already playing and is not to be
; restarted.
!Define_SMW_HeaderBypasses_MusicSpecial	= $80
!Define_SMW_HeaderBypasses_MusicSameTrack	= $40

;#############################################################################################################
;# Where they go: one occupant of the reserved run, behind the custom tiles
;# and ahead of the text.
;#############################################################################################################

; Place the block. Called from %SMW_PlaceReservedRun at whatever position the
; occupants ahead left.
macro SMW_PlaceHeaderBypasses()
if !Define_SMW_HeaderBypasses == !TRUE

; Object 26: the track the settings byte names, plus one, into the music
; register the header writes -- with the header's own two rules kept, so a
; level re-entered through a pipe does not restart the track it is already
; playing. Entered as every standard object is, from SMW_ExecutePtr_Long out
; of a tileset's dispatch table with A, X and Y 8-bit and the settings byte
; in !RAM_SMW_Blocks_SizeOrType. The dispatch tables in bank $0D name the
; routine by the slot's own label, which on the stock cartridge is an alias
; of the water object.
SMW_StandardObj26_MusicBypass_Main:
SMW_HeaderBypasses_Music:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\ The track, plus one:
	BEQ.b SMW_HeaderBypasses_Return		;| zero names none
	DEC					;/
	LDX.w !RAM_SMW_Misc_MusicRegisterBackup	;\ A special track stays special
	BPL.b .Ordinary				;|
	ORA.b #!Define_SMW_HeaderBypasses_MusicSpecial	;/
.Ordinary:
	CMP.w !RAM_SMW_Misc_MusicRegisterBackup	;\ ...and the track already
	BNE.b .Changed				;| playing is not restarted
	ORA.b #!Define_SMW_HeaderBypasses_MusicSameTrack	;/
.Changed:
	STA.w !RAM_SMW_Misc_MusicRegisterBackup
	BRA.b SMW_HeaderBypasses_Return

; Object 28: the three digits the record spells, into the timer the header
; sets. Without the force flag the timer is written on the way in from the
; map and nowhere else, which is the condition the header's own write is
; under; with it, on every entry.
SMW_StandardObj28_TimeLimitBypass_Main:
SMW_HeaderBypasses_TimeLimit:
	LDA.b !RAM_SMW_Blocks_SizeOrType	;\ The hundreds digit
	AND.b #!Define_SMW_HeaderBypasses_DigitMask	;|
	STA.b !RAM_SMW_Misc_ScratchRAM03	;/
	REP.b #$20				; A->16
	LDA.b !RAM_SMW_Pointer_Layer1DataLo	;\ The record itself, three bytes
	SEC					;| behind where the loader left
	SBC.w #!Define_SMW_HeaderBypasses_RecordBytes	;| the pointer
	STA.b !RAM_SMW_Misc_ScratchRAM00	;|
	SEP.b #$20				; A->8	;|
	LDA.b !RAM_SMW_Pointer_Layer1DataBank	;|
	STA.b !RAM_SMW_Misc_ScratchRAM02	;/
	LDY.b #$00
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	;\ Byte 0: the tens
	AND.b #!Define_SMW_HeaderBypasses_DigitMask	;|
	STA.b !RAM_SMW_Misc_ScratchRAM04	;/
	INY
	LDA.b [!RAM_SMW_Misc_ScratchRAM00],y	;\ Byte 1: the ones
	AND.b #!Define_SMW_HeaderBypasses_DigitMask	;|
	STA.b !RAM_SMW_Misc_ScratchRAM05	;/
	ORA.b !RAM_SMW_Misc_ScratchRAM04	;\ Three zero digits name no time
	ORA.b !RAM_SMW_Misc_ScratchRAM03	;| limit at all, unless the reset
	BNE.b .Named				;| is forced
	BIT.b !RAM_SMW_Blocks_SizeOrType	;|
	BPL.b SMW_HeaderBypasses_Return		;/
.Named:
	LDA.w !RAM_SMW_Counter_SublevelsEntered	;\ On the way in from the map, as
	BEQ.b .Set				;| the header's own timer is --
	BIT.b !RAM_SMW_Blocks_SizeOrType	;| or on every entry, with the
	BPL.b SMW_HeaderBypasses_Return		;/ force flag
.Set:
	LDA.b !RAM_SMW_Misc_ScratchRAM03
	STA.w !RAM_SMW_Counter_TimerHundreds
	LDA.b !RAM_SMW_Misc_ScratchRAM04
	STA.w !RAM_SMW_Counter_TimerTens
	LDA.b !RAM_SMW_Misc_ScratchRAM05
	STA.w !RAM_SMW_Counter_TimerOnes

; Back to the dispatcher in bank $0D, whose RTL ends the object: the return
; the dispatcher's JSR left is pulled and pushed again under that bank, since
; an RTS here would return into this one.
SMW_HeaderBypasses_Return:
	REP.b #$10				; XY->16
	PLX
	LDA.b #SMW_ProcessStandardAndTilesetSpecificObjects_Main>>16
	PHA
	PHX
	SEP.b #$10				; XY->8
	RTL

	assert pc()-SMW_HeaderBypasses_Music == !Define_SMW_Block_HeaderBypasses, "The header bypasses' block is not the size Config/PackedRuns.asm states. The text behind it is read past it, so pin the new figure in Define_SMW_Block_HeaderBypasses."
	assert pc() <= !Loc_SMW_ReservedBank_End, "The header bypasses have outgrown the reserved run."
endif
endmacro
