includeonce

;#############################################################################################################
;# Custom sprites: a sprite number that carries code of its own.
;#
;# The stock game dispatches every sprite through inline pointer tables
;# with not one spare byte behind any of them, and every number a level's
;# stream can say is already spoken for. Setting !Define_SMW_CustomSprites
;# to !TRUE gives a project the other answer: a second set of tables in a
;# bank of their own (Config/SpriteBank.asm), reached from the game's own
;# dispatch sites, and a bit that finds room for 256 more normal sprite
;# numbers without touching the level data format.
;#
;# **The custom bit** is bit 3 of a sprite record's first byte -- one of
;# the two extra bits the loader masks into the Y high byte and nothing in
;# the stock game reads. The convention is PIXI's, kept because the level
;# format is shared with that tool's whole ecosystem. The one number that
;# cannot carry it is the goal tape, $7B: Lunar Magic 3.00 spends both of
;# that sprite's extra bits choosing between secret exits, so the spawn
;# stub leaves the flag unset there.
;#
;# **Every hook is a byte-neutral replacement**, because RomMap/ places
;# each routine at a literal address and the banks are packed to the byte
;# -- and because SA-1 Pack's freespace code jumps back to literal bank
;# addresses, pinned by the vendored switch's else arms, so a feature
;# that shifted them would break the coprocessor base even switched on.
;# Ten of the fourteen are the cheapest hook the cartridge has:
;# JSL SMW_ExecutePtr_Absolute is four bytes, JML is four bytes, and
;# the trampoline neither returns nor is returned to, so a JML into a stub
;# that reaches the same table by name displaces nothing at all. All ten
;# dispatch sites and the four remaining seams are bytes SA-1 Pack
;# leaves untouched, measured against the built images of both bases.
;#
;# **How a slot becomes custom.** The spawn seam (Banks/Bank02.asm,
;# SMW_ParseLevelSpriteList CODE_02A971 -- the join both bases pass
;# through, the pack's own loader re-entering just ahead of it) reads the
;# record's extra bits and its number and leaves them as a pending pair.
;# The table-initialize choke every spawn goes through -- stream or
;# code-spawned, on either base -- consumes the pair into the slot's own
;# tables and leaves a slot nothing is pending for clean, which is what
;# keeps a stale flag from surviving into a code-spawned sprite. PIXI
;# clears its flag in ClearTables instead, a seam the pack leaves no four
;# free bytes of.
;#
;# **What the slot then holds.** The true number lives in
;# !RAM_SMW_CustomSprites_TrueSpriteID; $9E keeps holding the acts-like
;# number from the feature's own table, so every comparison the game makes
;# against a sprite number stays right. The init dispatch is where the
;# substitution happens: it stores the acts-like over $9E, copies the six
;# Tweaker bytes and the two extra property bytes from the feature's
;# tables into the slot's RAM -- over the values the spawn loaded from the
;# true number's vanilla row -- and only then runs the sprite's own init.
;#
;# **What a routine sees** is what PIXI gives it: AXY 8-bit, X the sprite
;# slot, the data bank pointed at the sprite bank, and an RTL to return
;# by. A jump, not a call, everywhere above it; only the sprite's own
;# routine is reached through a pushed frame its RTL comes back on.
;#
;# **Words, not long pointers, and a table per fact.** Every custom
;# routine is assembled into the sprite bank, so the bank byte is known
;# when the tables are assembled and each rows table is half the size.
;# A zero row is a number with nothing to run: init runs nothing, main
;# falls back to the acts-like number's own routine, a status entry falls
;# back to the acts-like behaviour.
;#
;# **The other kinds** -- extended, cluster, minor extended, bounce,
;# smoke, generator, shooter -- get one $80-word table each, indexed by
;# the kind's own dispatch index, with numbers past the vanilla table's
;# end. Each kind's hook and table exist only where the rows fragment
;# names a sprite of that kind. The five custom status entry points
;# (mouth, carriable, kicked, carried, goal -- statuses $07, $09, $0A,
;# $0B, $0C) cost their tables the same way, but the status hook itself
;# is the feature's: PIXI runs a custom slot's main at statuses $09 and
;# up whatever the rows declare, so the dispatch stub is always planted.
;#
;# The rows and properties are fragments the editor regenerates
;# (code/sprites/), read here with the defines because the hooks in
;# Banks/ ask what is wanted long before the tables are placed. The
;# sprites' own code is a third fragment, placed from the sprite bank's
;# sequence once every bank has emitted, so a file that hijacks the game
;# lands (Config/SpriteBank.asm).
;#
;# How such a sprite is *spelled* is Config/Pixi.asm: that tool's
;# dialect, thrown with this feature by the one switch -- its define
;# stays its own only so a hand build can take the capability alone.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_CustomSprites=1 turns the custom sprites on.
if defined("Define_SMW_CustomSprites") == 0
	!Define_SMW_CustomSprites = !FALSE
endif

; One rows table's length: a word per number, $100 numbers for the normal
; tables and $80 for every other kind's.
!Define_SMW_CustomSpriteRowsBytes #= $0100*$0002
!Define_SMW_CustomSpriteKindRowsBytes #= $0080*$0002

; The fixed head the tables above the stubs come to: two word tables and
; ten byte tables, asserted at the placement so the editor may read them
; at declared addresses on every cartridge.
!Define_SMW_CustomSpriteTableBytes #= ($0002*!Define_SMW_CustomSpriteRowsBytes)+($000A*$0100)

; The most extra bytes a record may carry: what four covers is nearly the
; whole published corpus, and past it PIXI switches to a pointer scheme
; this cartridge does not make.
!Define_SMW_CustomSpriteExtraByteLimit #= $04

; Which of the five custom status entry points, and which of the seven
; other kinds, some sprite uses -- set by the rows fragment as it names a
; routine. Each hook asks for its own, so an entry point or a kind no
; sprite declares costs no hook and no table at all.
!SMW_CustomSprites_GoalWanted		#= !FALSE
!SMW_CustomSprites_MouthWanted		#= !FALSE
!SMW_CustomSprites_CarriableWanted	#= !FALSE
!SMW_CustomSprites_KickedWanted		#= !FALSE
!SMW_CustomSprites_CarriedWanted	#= !FALSE
!SMW_CustomSprites_ExtendedWanted	#= !FALSE
!SMW_CustomSprites_ClusterWanted	#= !FALSE
!SMW_CustomSprites_MinorExtendedWanted	#= !FALSE
!SMW_CustomSprites_BounceWanted		#= !FALSE
!SMW_CustomSprites_SmokeWanted		#= !FALSE
!SMW_CustomSprites_GeneratorWanted	#= !FALSE
!SMW_CustomSprites_ShooterWanted	#= !FALSE

; The two the feature itself plants whenever it is on; named so the rows
; macro can refuse an entry point that is none of the seven.
!SMW_CustomSprites_InitWanted		#= !FALSE
!SMW_CustomSprites_MainWanted		#= !FALSE

; The vanilla entry counts of the seven other kinds' dispatch tables, over
; the dispatched index -- the generator's and the shooter's sites
; decrement the number before the call, and these counts are over what
; arrives at the dispatch. A custom row below its kind's count would
; shadow one of the game's own sprites, and the rows macro refuses it.
!Define_SMW_CustomSprites_ExtendedCount		#= $13
!Define_SMW_CustomSprites_ClusterCount		#= $09
!Define_SMW_CustomSprites_MinorExtendedCount	#= $0C
!Define_SMW_CustomSprites_BounceCount		#= $08
!Define_SMW_CustomSprites_SmokeCount		#= $06
!Define_SMW_CustomSprites_GeneratorCount	#= $0F
!Define_SMW_CustomSprites_ShooterCount		#= $03

;#############################################################################################################
;# The fragments' lines: a sprite's routines, and a sprite's properties.
;#############################################################################################################

; One normal sprite's routine at one entry point: Init, Main, or one of
; the five status entry points -- Goal, Mouth, Carriable, Kicked, Carried.
; The line declares the row as a define keyed on the table and the number,
; and the placement below emits each table row by row from those -- so the
; fragment's lines may come in any order, a number the fragment names
; twice keeps the later line, and nothing is written anywhere but in
; sequence. Naming a status routine is what plants the status hook. The
; number is evaluated first so the key is one spelling whatever the line
; wrote.
macro SMW_CustomSprite(table, number, routine)
	assert ((<number>)>>8) == 0, "A custom sprite row names a number past $FF. Check code/sprites/custom-sprites.asm."
	assert defined("SMW_CustomSprites_<table>Wanted"), "A custom sprite row names an entry point that is not Init, Main, Goal, Mouth, Carriable, Kicked or Carried. Check code/sprites/custom-sprites.asm."
	!SMW_CustomSprites_<table>Wanted #= !TRUE
	!SMW_CustomSpritesKey #= <number>
	!{SMW_CustomSpriteRow_<table>_!{SMW_CustomSpritesKey}} = <routine>
endmacro

; One sprite of another kind, whose single entry point is its main: the
; kind's dispatch runs the row where the kind's own number is past the
; vanilla table's end. A number the game already dispatches is refused --
; a custom row may not shadow one of the game's own sprites.
macro SMW_CustomSpriteKind(kind, number, routine)
	assert ((<number>)>>7) == 0, "A custom sprite row names a kind number past $7F. Check code/sprites/custom-sprites.asm."
	assert defined("SMW_CustomSprites_<kind>Wanted"), "A custom sprite row names a kind that is not Extended, Cluster, MinorExtended, Bounce, Smoke, Generator or Shooter. Check code/sprites/custom-sprites.asm."
	assert (<number>) >= !Define_SMW_CustomSprites_<kind>Count, "A custom sprite row shadows one of the game's own: its number is below the kind's vanilla entry count. Check code/sprites/custom-sprites.asm."
	!SMW_CustomSprites_<kind>Wanted #= !TRUE
	!SMW_CustomSpritesKey #= <number>
	!{SMW_CustomSpriteRow_<kind>_!{SMW_CustomSpritesKey}} = <routine>
endmacro

; One normal sprite's properties, from the named defines the properties
; fragment writes above this line: the acts-like number, the six Tweaker
; bytes built exactly as sprites/SpritePropertiesTemplate.asm builds them
; for a vanilla sprite, and the two extra property bytes. Declared as
; byte defines keyed on the number; the placement emits each table from
; them, with the unused sprite's $36 as every undeclared acts-like row.
macro SMW_CustomSpriteProperties(number, prefix)
	assert ((<number>)>>8) == 0, "A custom sprite's properties name a number past $FF. Check code/sprites/custom-sprite-properties.asm."
	!SMW_CustomSpritesKey #= <number>
	!{SMW_CustomSpriteFact_ActsLike_!{SMW_CustomSpritesKey}} #= !Define_SMW_<prefix>_ActsLike
	!{SMW_CustomSpriteFact_ExtraProp1_!{SMW_CustomSpritesKey}} #= !Define_SMW_<prefix>_ExtraProp1
	!{SMW_CustomSpriteFact_ExtraProp2_!{SMW_CustomSpritesKey}} #= !Define_SMW_<prefix>_ExtraProp2
	assert (!Define_SMW_<prefix>_ExtraBytes) <= !Define_SMW_CustomSpriteExtraByteLimit, "A custom sprite declares more extra bytes than the four the spawn seam reads. Check code/sprites/custom-sprite-properties.asm."
	!{SMW_CustomSpriteFact_ExtraBytes_!{SMW_CustomSpritesKey}} #= !Define_SMW_<prefix>_ExtraBytes
	!{SMW_CustomSpriteFact_1656_!{SMW_CustomSpritesKey}} #= (!Define_SMW_<prefix>_DisappearAsSmokeCloud<<7)|(!Define_SMW_<prefix>_HopInOrKickShells<<6)|(!Define_SMW_<prefix>_DiesWhenJumpedOn<<5)|(!Define_SMW_<prefix>_SafeToJumpOn<<4)|!Define_SMW_<prefix>_ObjectClipping
	!{SMW_CustomSpriteFact_1662_!{SMW_CustomSpritesKey}} #= (!Define_SMW_<prefix>_FallWhenKilled<<7)|(!Define_SMW_<prefix>_UseShellAsDeathFrame<<6)|!Define_SMW_<prefix>_SpriteClipping
	!{SMW_CustomSpriteFact_166E_!{SMW_CustomSpritesKey}} #= (!Define_SMW_<prefix>_OnlyInteractWithLayer1<<7)|(!Define_SMW_<prefix>_DisableSplashing<<6)|(!Define_SMW_<prefix>_ImmuneToCape<<5)|(!Define_SMW_<prefix>_ImmuneToFire<<4)|(!Define_SMW_<prefix>_Palette<<1)|!Define_SMW_<prefix>_UseSP3And4
	!{SMW_CustomSpriteFact_167A_!{SMW_CustomSpritesKey}} #= (!Define_SMW_<prefix>_UseNonDefaultPlayerInteraction<<7)|(!Define_SMW_<prefix>_GivePowerupWhenEaten<<6)|(!Define_SMW_<prefix>_ProcessPlayerInteractionEveryFrame<<5)|(!Define_SMW_<prefix>_CantBeKickedLikeShell<<4)|(!Define_SMW_<prefix>_DontBecomeShellWhenStunned<<3)|(!Define_SMW_<prefix>_TrackWhenOffScreen<<2)|(!Define_SMW_<prefix>_InvincibleToMostThings<<1)|!Define_SMW_<prefix>_DontDisableClippingWhenStarKilled
	!{SMW_CustomSpriteFact_1686_!{SMW_CustomSpritesKey}} #= (!Define_SMW_<prefix>_DisableObjectClipping<<7)|(!Define_SMW_<prefix>_SpawnsNewSprite<<6)|(!Define_SMW_<prefix>_DontBecomeCoinOnGoalTapeTrigger<<5)|(!Define_SMW_<prefix>_DontChangeDirectionWhenTouched<<4)|(!Define_SMW_<prefix>_DisableSpriteClipping<<3)|(!Define_SMW_<prefix>_DisableGroundShifting<<2)|(!Define_SMW_<prefix>_StayInYoshisMouth<<1)|!Define_SMW_<prefix>_Inedible
	!{SMW_CustomSpriteFact_190F_!{SMW_CustomSpritesKey}} #= (!Define_SMW_<prefix>_DontGetStuckInWallsWhenCarried<<7)|(!Define_SMW_<prefix>_ImmuneToSilverPSwitch<<6)|(!Define_SMW_<prefix>_2TileTallDeathFrame<<5)|(!Define_SMW_<prefix>_CanBeJumpedOnWithUpwardYSpeed<<4)|(!Define_SMW_<prefix>_5FireballHP<<3)|(!Define_SMW_<prefix>_ImmuneToSliding<<2)|(!Define_SMW_<prefix>_DontDespawnOnLevelEnd<<1)|!Define_SMW_<prefix>_CanPassThroughPlaformFromBelow
endmacro

; The two fragments, code/sprites/: the properties first, then the rows
; naming each routine. Read here, with the defines, because the hooks in
; Banks/ ask which entry points and kinds are wanted long before the
; tables are placed.
if !Define_SMW_CustomSprites == !TRUE
	incsrc "code/sprites/custom-sprite-properties.asm"
	incsrc "code/sprites/custom-sprites.asm"
endif

; Whether the status hook is planted at all: whenever the feature is on.
; PIXI's contract is more than the five declared entry points -- a custom
; slot at statuses $09 and up runs its main after the game's behaviour,
; and the second extra property byte's top bits reroute any status -- so
; every custom sprite needs the dispatch, declared status rows or none.
!SMW_CustomSprites_StatusWanted #= !FALSE
if !Define_SMW_CustomSprites == !TRUE
	!SMW_CustomSprites_StatusWanted #= !TRUE
endif

;#############################################################################################################
;# The tables, emitted from the declared rows.
;#############################################################################################################

; One word-rows table: each number's routine where the fragment named one,
; zero where it did not. The bank check is made here rather than at the
; line, because the routine's address is the sprite bank's to know.
macro SMW_CustomSprites_WordRows(table, count)
	!SMW_CustomSpriteRow #= 0
	while !SMW_CustomSpriteRow < <count>
		if defined("SMW_CustomSpriteRow_<table>_!{SMW_CustomSpriteRow}")
			assert ((!{SMW_CustomSpriteRow_<table>_!{SMW_CustomSpriteRow}})>>$10) == !Define_SMW_SpriteBank, "A custom sprite's code is not in the sprite bank. Every routine the rows name is assembled into it, so the rows can be words. Check code/sprites/."
			dw !{SMW_CustomSpriteRow_<table>_!{SMW_CustomSpriteRow}}
		else
			dw $0000
		endif
		!SMW_CustomSpriteRow #= !SMW_CustomSpriteRow+1
	endwhile
endmacro

; One byte-rows table: the declared fact, or the default. $36 -- the
; unused sprite, the community's way of saying no vanilla behaviour at all
; -- is the acts-like default; every other fact defaults to zero.
macro SMW_CustomSprites_ByteRows(fact, default)
	!SMW_CustomSpriteRow #= 0
	while !SMW_CustomSpriteRow < $0100
		if defined("SMW_CustomSpriteFact_<fact>_!{SMW_CustomSpriteRow}")
			db !{SMW_CustomSpriteFact_<fact>_!{SMW_CustomSpriteRow}}
		else
			db <default>
		endif
		!SMW_CustomSpriteRow #= !SMW_CustomSpriteRow+1
	endwhile
endmacro

;#############################################################################################################
;# The stubs' shared pieces.
;#############################################################################################################

; The vanilla half of every dispatch stub: reach the game's own inline
; table by name, keeping SMW_ExecutePtr_Absolute's whole contract -- AXY
; 8-bit on entry and on arrival, Y preserved through $03, A left holding
; the fetched pointer's low byte, scratch $00..$03 clobbered, and a jump
; rather than a call. The bank byte the trampoline took from the JSL's
; return address is the table's own here.
macro SMW_CustomSprites_DispatchVanilla(table)
	STX.b !RAM_SMW_Misc_ScratchRAM03	;> "Push" X: a long read only indexes by it
	LDX.b #(<table>)>>$10		;\ The bank byte the JSL's return
	STX.b !RAM_SMW_Misc_ScratchRAM02	;/ address would have carried
	REP.b #$30			; AXY->16
	AND.w #$00FF
	ASL				;\ Two bytes a row
	TAX				;/
	LDA.l <table>,x			;\ The game's own row, by name
	STA.b !RAM_SMW_Misc_ScratchRAM00	;/
	SEP.b #$30			; AXY->8, A = the pointer's low byte
	LDX.b !RAM_SMW_Misc_ScratchRAM03	; "Pull" X
	JMP.w [!RAM_SMW_Misc_ScratchRAM00]	; Into the game's routine
endmacro

; Read one custom rows table for the slot's true number: leaves A 16-bit
; holding the row -- the routine's address in this bank, or zero -- with
; XY 8-bit and the slot back in X, preserved through $03 because a long
; read only indexes by X. Ends on the row's own compare, so the caller
; branches on it directly.
macro SMW_CustomSprites_Row(table)
	LDA.l !RAM_SMW_CustomSprites_TrueSpriteID,x
	STX.b !RAM_SMW_Misc_ScratchRAM03	; "Push" X
	REP.b #$30			; AXY->16
	AND.w #$00FF
	ASL				;\ Two bytes a row
	TAX				;/
	LDA.l <table>,x
	SEP.b #$10			; XY->8, A still 16
	LDX.b !RAM_SMW_Misc_ScratchRAM03	; "Pull" X
	CMP.w #$0000
endmacro

; One custom status entry point, inside the status stub: run the true
; number's row of one table and return through the game's own RTS, or --
; where the number has no row -- the acts-like behaviour and then the
; main PIXI's contract owes the status, exactly as an undeclared status
; gets.
macro SMW_CustomSprites_StatusEntry(table)
	%SMW_CustomSprites_Row(<table>)
	BEQ.b ?None
	JSR.w SMW_CustomSprites_Call
	JML.l SMW_ProcessNormalSprites_Return018126
?None:
	SEP.b #$20			; A->8
	JMP.w SMW_CustomSprites_Status_VanillaThenMain
endmacro

; One other kind's whole dispatch stub: the game's own numbers go through
; the game's own table, a number past it runs its row, and a rowless
; number runs nothing. Entered exactly as the trampoline would have been
; -- AXY 8-bit, A the kind's dispatch index -- and the custom routine is
; entered with the slot in X, an RTL to return by, and the data bank
; pointed at this bank.
macro SMW_CustomSprites_KindStub(kind, vanillatable, return)
	CMP.b #!Define_SMW_CustomSprites_<kind>Count
	BCC.b ?Vanilla
	STX.b !RAM_SMW_Misc_ScratchRAM03	; "Push" X
	REP.b #$30			; AXY->16
	AND.w #$00FF
	ASL				;\ Two bytes a row
	TAX				;/
	LDA.l SMW_CustomSprites_<kind>Rows,x
	SEP.b #$10			; XY->8, A still 16
	LDX.b !RAM_SMW_Misc_ScratchRAM03	; "Pull" X
	CMP.w #$0000
	BEQ.b ?None
	JSR.w SMW_CustomSprites_Call
	JML.l <return>
?None:
	SEP.b #$30			; AXY->8
	JML.l <return>
?Vanilla:
	%SMW_CustomSprites_DispatchVanilla(<vanillatable>)
endmacro

;#############################################################################################################
;# Where it goes: the tables at the sprite bank's fixed head, the stubs
;# and the wanted tables behind them (Config/SpriteBank.asm), and the
;# sprites' own code from a second placement once the dialect has been
;# read.
;#############################################################################################################

; Place the tables and the stubs. Called from %SMW_PlaceSpriteBank at the
; bank's head.
macro SMW_PlaceCustomSprites()
if !Define_SMW_CustomSprites == !TRUE
	assert pc() == !Loc_SMW_SpriteBank_Head, "The custom sprite tables must lead the sprite bank: the editor reads them at one address per cartridge."

; The fixed head: one row per number of each fact, emitted from the
; fragments' declarations -- no number runs anything until a fragment line
; names a routine, and every undeclared number acts like the unused
; sprite.
SMW_CustomSprites_InitRows:
	%SMW_CustomSprites_WordRows(Init, $0100)
SMW_CustomSprites_MainRows:
	%SMW_CustomSprites_WordRows(Main, $0100)
SMW_CustomSprites_ActsLike:
	%SMW_CustomSprites_ByteRows(ActsLike, $36)
SMW_CustomSprites_ExtraProperty1:
	%SMW_CustomSprites_ByteRows(ExtraProp1, $00)
SMW_CustomSprites_ExtraProperty2:
	%SMW_CustomSprites_ByteRows(ExtraProp2, $00)
SMW_CustomSprites_Tweak1656:
	%SMW_CustomSprites_ByteRows(1656, $00)
SMW_CustomSprites_Tweak1662:
	%SMW_CustomSprites_ByteRows(1662, $00)
SMW_CustomSprites_Tweak166E:
	%SMW_CustomSprites_ByteRows(166E, $00)
SMW_CustomSprites_Tweak167A:
	%SMW_CustomSprites_ByteRows(167A, $00)
SMW_CustomSprites_Tweak1686:
	%SMW_CustomSprites_ByteRows(1686, $00)
SMW_CustomSprites_Tweak190F:
	%SMW_CustomSprites_ByteRows(190F, $00)
; How many extra bytes each number's records carry in the level stream --
; the loader's stride, so it is a table the cartridge reads rather than
; only the editor: the spawn seam advances past them and keeps them for
; the slot.
SMW_CustomSprites_ExtraByteCount:
	%SMW_CustomSprites_ByteRows(ExtraBytes, $00)
	assert pc() == SMW_CustomSprites_InitRows+!Define_SMW_CustomSpriteTableBytes, "The custom sprite tables do not end where their declared head says. The editor reads them at declared addresses, so pin the new figure in Define_SMW_CustomSpriteTableBytes."

; Enter one row's routine and come back. Entered by JSR with A 16-bit
; holding the row -- the routine's address in this bank, or zero, which
; runs nothing. What the routine sees in A is the address's low byte less
; one, not PIXI's entry values ($01 into init, the status into main);
; published sprites read the status from RAM, not from A.
;
; The routine is entered the way it will leave: two frames are pushed --
; the return it will RTL to, then the routine itself, one byte short --
; and the RTL here pops the second and lands on the routine's first byte.
; Its own RTL pops the first and lands on .Back. The data bank it sees is
; this bank, so its absolutes reach the code and tables beside it; X is
; the sprite slot, untouched all the way down.
SMW_CustomSprites_Call:
	CMP.w #$0000			;\ A zero row is a number with
	BEQ.b .None			;/ nothing to run
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

; The spawn seam's stub. Entered by JML from SMW_ParseLevelSpriteList in
; place of INY : INY : LDA $04, the join past the horizontal/vertical
; fork: Y points at the record's first byte, so the extra bits are one
; read away, and the two INYs put it on the number byte. Both are left as
; a pending pair for the initialize choke below to consume -- the slot's
; own tables cannot be written yet, because the initialize would clear
; them again. The goal tape's two extra bits are Lunar Magic's secret-exit
; choice, so its bit 3 is not a custom flag and is dropped here. The index
; registers are 8-bit on the shipped cartridge and 16-bit under the
; pack's loader, and nothing here cares which.
SMW_CustomSprites_Spawn:
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	;\ The extra bits, from the
	AND.b #$0C			;| record's first byte -- PIXI keeps bit 0 too ($0D),
	STA.l !RAM_SMW_CustomSprites_PendingExtraBits	;/ which no published sprite reads
	INY				;\ The displaced INYs: Y onto the
	INY				;/ number byte
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	;\ The true number, pending
	STA.l !RAM_SMW_CustomSprites_PendingSpriteID	;/ beside the bits
	CMP.b #!Define_SMW_SpriteID_NorSpr07B_GoalTape
	BNE.b .NotTape
	LDA.l !RAM_SMW_CustomSprites_PendingExtraBits	;\ The goal tape spends both
	AND.b #$04			;| extra bits on Lunar Magic's
	STA.l !RAM_SMW_CustomSprites_PendingExtraBits	;/ secret exits, not on this
.NotTape:
	LDA.l !RAM_SMW_CustomSprites_PendingExtraBits	;\ A custom record may carry
	AND.b #$08			;| extra bytes behind its three
	BEQ.b .Displaced		;/
	PHX				;\ X pushed at whatever width the base
	PHP				;| runs this loop at, and put back the
	REP.b #$30			;/ same; Y widens with its value kept
	LDA.l !RAM_SMW_CustomSprites_PendingSpriteID	;\ The number, 16-bit so the
	AND.w #$00FF			;| index register is clean on
	TAX				;/ either base
	SEP.b #$20			; A->8
	LDA.l SMW_CustomSprites_ExtraByteCount,x
	STA.l !RAM_SMW_CustomSprites_PendingExtraCount
	BEQ.b .Copied
	INY				;\ The bytes follow the record's three,
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	;| and Y ends on the last one so
	STA.l !RAM_SMW_CustomSprites_PendingExtra1	;/ the loop's own INY steps past
	LDA.l !RAM_SMW_CustomSprites_PendingExtraCount
	CMP.b #$02
	BCC.b .Copied
	INY
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
	STA.l !RAM_SMW_CustomSprites_PendingExtra2
	LDA.l !RAM_SMW_CustomSprites_PendingExtraCount
	CMP.b #$03
	BCC.b .Copied
	INY
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
	STA.l !RAM_SMW_CustomSprites_PendingExtra3
	LDA.l !RAM_SMW_CustomSprites_PendingExtraCount
	CMP.b #$04
	BCC.b .Copied
	INY
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
	STA.l !RAM_SMW_CustomSprites_PendingExtra4
.Copied:
	PLP
	PLX
.Displaced:
	LDA.b !RAM_SMW_Misc_ScratchRAM04	;> The displaced read: the spawn status
	JML.l SMW_ParseLevelSpriteList_CustomSpritesReturn

; The scan's next-record stride, in place of LoadNextSprite's own. The
; spawn seam owns the stride of the record being spawned, but every
; skipped record -- off its screen, or already loaded -- advances here,
; and a plain three-byte step over a custom record would read its extra
; bytes as the next record's head. Entered with Y on the record's second
; byte and X the record's slot in the load-status table, at either
; base's index width, exactly as the seam is; one record is one
; load-status slot whatever it carries, so X steps by one regardless.
SMW_CustomSprites_NextRecord:
	DEY				;\ The custom bit, from the
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y	;| record's first byte
	INY				;/
	AND.b #$08
	BEQ.b .Plain
	INY				;> The number byte
	PHX				;\ The seam's own dance: X and the
	PHP				;| widths put back, Y kept
	REP.b #$30			;/ AXY->16
	LDA.b [!RAM_SMW_Pointer_SpriteListDataLo],y
	AND.w #$00FF
	TAX
	SEP.b #$20			; A->8, over a clean high byte
	LDA.l SMW_CustomSprites_ExtraByteCount,x
	REP.b #$20			; A->16, the count as a word
	PHA				;\ The cursor stepped past the extra
	TYA				;| bytes: Y, plus the count the
	CLC				;| table declares for the number
	ADC.b $01,s			;|
	TAY				;/
	PLA				;> Drop the count
	PLP
	PLX
	INY				;> The next record's first byte
	INX				;> Its slot in the load-status table
	JML.l SMW_ParseLevelSpriteList_LoadSpriteLoopStrt
.Plain:
	INY				;\ The displaced stride
	INY				;|
	INX				;/
	JML.l SMW_ParseLevelSpriteList_LoadSpriteLoopStrt

; The spawn body's number read, in place of the status compare and the
; re-read of the record's number byte just past the seam. The seam leaves
; Y past a custom record's extra bytes -- the spawn tail's own INY is
; what steps the scan onto the next record -- so the byte at Y is no
; longer the number; the seam kept it pending, and every record passes
; the seam, so the pending copy is the same byte for a plain record too.
; The compare's carry is what the branch after reads, and a load leaves
; it alone.
SMW_CustomSprites_SpawnNumber:
	CMP.b #!Define_SMW_NorSprStatus09_Stunned	;> The displaced compare
	LDA.l !RAM_SMW_CustomSprites_PendingSpriteID	;> The number the seam read
	JML.l SMW_ParseLevelSpriteList_SpawnNumberReturn

; The initialize choke's stub. Entered by JML from
; SMW_InitializeNormalSpriteRAMTables_Main in place of its JSL to
; ClearTables -- the one call every spawn makes, stream or code-spawned,
; on either base, with X the slot. A pending pair from the spawn seam is
; consumed into the slot's tables; a spawn nothing is pending for -- every
; code-spawned sprite -- leaves the slot clean, which is what keeps a
; stale custom flag from surviving into it. $FF marks the pair consumed;
; the cleared RAM a boot leaves reads as a pending non-custom spawn,
; which consumes to the same clean slot.
SMW_CustomSprites_ClearSlot:
	LDA.b #$00			;\ A fresh slot, before the pending
	STA.l !RAM_SMW_CustomSprites_ExtraBits,x	;| pair is considered
	STA.l !RAM_SMW_CustomSprites_TrueSpriteID,x	;|
	STA.l !RAM_SMW_CustomSprites_ExtraProp1,x	;|
	STA.l !RAM_SMW_CustomSprites_ExtraProp2,x	;|
	STA.l !RAM_SMW_CustomSprites_ExtraByte1,x	;|
	STA.l !RAM_SMW_CustomSprites_ExtraByte2,x	;|
	STA.l !RAM_SMW_CustomSprites_ExtraByte3,x	;|
	STA.l !RAM_SMW_CustomSprites_ExtraByte4,x	;/
	LDA.l !RAM_SMW_CustomSprites_PendingExtraBits
	BMI.b .Consumed			;> $FF: a code spawn, nothing pending
	STA.l !RAM_SMW_CustomSprites_ExtraBits,x
	AND.b #$08			;\ The custom bit brings the true
	BEQ.b .NotCustom		;| number with it
	LDA.l !RAM_SMW_CustomSprites_PendingSpriteID	;|
	STA.l !RAM_SMW_CustomSprites_TrueSpriteID,x	;/
	LDA.l !RAM_SMW_CustomSprites_PendingExtraCount	;\ ...and its extra bytes,
	BEQ.b .NotCustom		;| however many the count table
	LDA.l !RAM_SMW_CustomSprites_PendingExtra1	;| said the spawn seam read
	STA.l !RAM_SMW_CustomSprites_ExtraByte1,x	;/
	LDA.l !RAM_SMW_CustomSprites_PendingExtraCount
	CMP.b #$02
	BCC.b .NotCustom
	LDA.l !RAM_SMW_CustomSprites_PendingExtra2
	STA.l !RAM_SMW_CustomSprites_ExtraByte2,x
	LDA.l !RAM_SMW_CustomSprites_PendingExtraCount
	CMP.b #$03
	BCC.b .NotCustom
	LDA.l !RAM_SMW_CustomSprites_PendingExtra3
	STA.l !RAM_SMW_CustomSprites_ExtraByte3,x
	LDA.l !RAM_SMW_CustomSprites_PendingExtraCount
	CMP.b #$04
	BCC.b .NotCustom
	LDA.l !RAM_SMW_CustomSprites_PendingExtra4
	STA.l !RAM_SMW_CustomSprites_ExtraByte4,x
.NotCustom:
	LDA.b #$FF			;\ One spawn, one pair
	STA.l !RAM_SMW_CustomSprites_PendingExtraBits	;/
.Consumed:
	JSL.l SMW_InitializeNormalSpriteRAMTables_ClearTables	;> The displaced call
	JML.l SMW_InitializeNormalSpriteRAMTables_CustomSpritesReturn

; The init dispatch's stub, in place of the JSL at the init status
; routine: A is the slot's $9E and X the slot. A vanilla slot goes through
; the game's own table untouched. A custom slot still holds its true
; number in $9E -- the spawn stored it and nothing has run between -- so
; this is where the substitution happens: the true number is kept, the
; acts-like number goes over $9E so every comparison the game makes stays
; right, the slot's six Tweaker bytes, its OAM properties and its two
; extra property bytes come from the feature's tables -- over the values
; the spawn loaded from the true number's vanilla row -- and then the
; sprite's own init runs, if the rows name one.
SMW_CustomSprites_Init:
	LDA.l !RAM_SMW_CustomSprites_ExtraBits,x
	AND.b #$08
	BNE.b .Custom
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	%SMW_CustomSprites_DispatchVanilla(SMW_NorSprStatus01_Init_NormalSpriteInitPointers)
.Custom:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x	;\ The true number, kept before
	STA.l !RAM_SMW_CustomSprites_TrueSpriteID,x	;/ $9E becomes the acts-like
	PHB				;\ The number indexes the feature's
	PHK				;| tables through Y below, so they are
	PLB				;/ read .w with this bank as the data bank
	STY.b !RAM_SMW_Misc_ScratchRAM03	; "Push" Y
	TAY
	LDA.w SMW_CustomSprites_ActsLike,y
	STA.b !RAM_SMW_NorSpr_SpriteID_x
	LDA.w SMW_CustomSprites_Tweak1656,y
	STA.w !RAM_SMW_NorSpr_PropertyBits1656,x
	LDA.w SMW_CustomSprites_Tweak1662,y
	STA.w !RAM_SMW_NorSpr_PropertyBits1662,x
	LDA.w SMW_CustomSprites_Tweak166E,y
	STA.w !RAM_SMW_NorSpr_PropertyBits166E,x
	LDA.w SMW_CustomSprites_Tweak167A,y
	STA.w !RAM_SMW_NorSpr_PropertyBits167A,x
	LDA.w SMW_CustomSprites_Tweak1686,y
	STA.w !RAM_SMW_NorSpr_PropertyBits1686,x
	LDA.w SMW_CustomSprites_Tweak190F,y
	STA.w !RAM_SMW_NorSpr_PropertyBits190F,x
	LDA.w SMW_CustomSprites_Tweak166E,y	;\ The OAM properties the spawn
	AND.b #!Define_SMW_NorSpr_166EProp_Palette|!Define_SMW_NorSpr_166EProp_UseSP3And4	;| loaded from the vanilla row,
	STA.w !RAM_SMW_NorSpr_Table7E15F6,x	;/ redone from the custom one
	LDA.w SMW_CustomSprites_ExtraProperty1,y
	STA.l !RAM_SMW_CustomSprites_ExtraProp1,x
	LDA.w SMW_CustomSprites_ExtraProperty2,y
	STA.l !RAM_SMW_CustomSprites_ExtraProp2,x
	REP.b #$30			; AXY->16
	TYA				;\ The init row, two bytes each
	ASL				;|
	TAY				;|
	LDA.w SMW_CustomSprites_InitRows,y	;/
	SEP.b #$10			; XY->8, A still 16
	LDY.b !RAM_SMW_Misc_ScratchRAM03	; "Pull" Y
	PLB				;> The hook's data bank, before the call frames it again
	JSR.w SMW_CustomSprites_Call	;> A zero row runs nothing
	JML.l SMW_ProcessNormalSprites_Return018126

; The main dispatch's stub, in place of the JSL at the normal status
; routine: A is the slot's $9E and X the slot. A custom slot with a main
; row runs it; one without falls through to the acts-like number's own
; routine, which is what acting like it means.
SMW_CustomSprites_Main:
	LDA.l !RAM_SMW_CustomSprites_ExtraBits,x
	AND.b #$08
	BNE.b .Custom
.Vanilla:
	LDA.b !RAM_SMW_NorSpr_SpriteID_x
	%SMW_CustomSprites_DispatchVanilla(SMW_NorSprStatus08_Normal_NormalSpriteNormalPtrs)
.Custom:
	%SMW_CustomSprites_Row(SMW_CustomSprites_MainRows)
	BEQ.b .None
	JSR.w SMW_CustomSprites_Call
	JML.l SMW_ProcessNormalSprites_Return018126
.None:
	SEP.b #$20			; A->8
	BRA.b .Vanilla

; The status dispatch's stub, in place of the JSL under HandleSprite,
; whenever the feature is on: A is the slot's status. A vanilla slot, and
; a custom slot at statuses $00 and $01, go straight through the game's
; own table, where $9E's acts-like number already chooses the behaviour.
; A custom slot anywhere else follows PIXI's contract, which is more than
; the five declared entry points:
;
; - The second extra property byte's bit 7 runs the sprite's main at
;   every status, in place of everything else.
; - A status one of the five entry points covers runs its row, where the
;   number has one, and nothing after it.
; - Everything else runs the game's own behaviour for the status and
;   then, where the byte's bit 6 asks for it or the status is $09 and up
;   -- carriable, kicked, carried, the goal walk -- the sprite's main.
;   That tail is what a carryable sprite in the wild is written against:
;   its main tests the status itself.
if !SMW_CustomSprites_StatusWanted == !TRUE
SMW_CustomSprites_Status:
	LDA.l !RAM_SMW_CustomSprites_ExtraBits,x
	AND.b #$08
	BNE.b SMW_CustomSprites_Status_CustomSlot	;> A full label: the one below resets the sublabel parent
SMW_CustomSprites_Status_Vanilla:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	%SMW_CustomSprites_DispatchVanilla(SMW_ProcessNormalSprites_SpriteStatusPtr)
SMW_CustomSprites_Status_CustomSlot:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	CMP.b #!Define_SMW_NorSprStatus02_Dead		;\ Empty and init frames are always
	BCC.b SMW_CustomSprites_Status_Vanilla		;/ the game's, whatever the byte says
	LDA.l !RAM_SMW_CustomSprites_ExtraProp2,x	;\ Bit 7: main at every status,
	BPL.b .NotMainOnly				;| in place of everything else
	JMP.w SMW_CustomSprites_Status_Main		;/
.NotMainOnly:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
if !SMW_CustomSprites_GoalWanted == !TRUE
	CMP.b #!Define_SMW_NorSprStatus0C_GoalPowerUp	;> The goal walk, as PIXI dispatches it
	BEQ.b .Goal
endif
if !SMW_CustomSprites_MouthWanted == !TRUE
	CMP.b #!Define_SMW_NorSprStatus07_InLimbo	;> In Yoshi's mouth, as every sprite tool reads it
	BEQ.b .Mouth
endif
if !SMW_CustomSprites_CarriableWanted == !TRUE
	CMP.b #!Define_SMW_NorSprStatus09_Stunned
	BEQ.b .Carriable
endif
if !SMW_CustomSprites_KickedWanted == !TRUE
	CMP.b #!Define_SMW_NorSprStatus0A_Kicked
	BEQ.b .Kicked
endif
if !SMW_CustomSprites_CarriedWanted == !TRUE
	CMP.b #!Define_SMW_NorSprStatus0B_Carried
	BEQ.b .Carried
endif
	JMP.w SMW_CustomSprites_Status_VanillaThenMain
if !SMW_CustomSprites_GoalWanted == !TRUE
.Goal:
	%SMW_CustomSprites_StatusEntry(SMW_CustomSprites_GoalRows)
endif
if !SMW_CustomSprites_MouthWanted == !TRUE
.Mouth:
	%SMW_CustomSprites_StatusEntry(SMW_CustomSprites_MouthRows)
endif
if !SMW_CustomSprites_CarriableWanted == !TRUE
.Carriable:
	%SMW_CustomSprites_StatusEntry(SMW_CustomSprites_CarriableRows)
endif
if !SMW_CustomSprites_KickedWanted == !TRUE
.Kicked:
	%SMW_CustomSprites_StatusEntry(SMW_CustomSprites_KickedRows)
endif
if !SMW_CustomSprites_CarriedWanted == !TRUE
.Carried:
	%SMW_CustomSprites_StatusEntry(SMW_CustomSprites_CarriedRows)
endif

; The game's own behaviour for the status, called rather than jumped to,
; and then the sprite's main where the byte or the status asks for it.
; The call is two pushed frames: where this stub resumes, then a bank $01
; RTL one byte short -- the routine's own RTS lands on the RTL, and the
; RTL lands back here with the game's stack untouched. The status is
; pushed first, because the routine may change the slot's: what decides
; the tail is the status this frame dispatched, as PIXI decides it.
SMW_CustomSprites_Status_VanillaThenMain:
	LDA.w !RAM_SMW_NorSpr_CurrentStatus,x
	PHA					;> The dispatched status, for after
	PHK					;\ Where the stub resumes,
	PEA.w SMW_CustomSprites_Status_AfterVanilla-1	;/ in this bank
	PEA.w SMW_BoostMarioSpeed_Return01AA41-1	;> Any bank $01 RTL, one byte short
	%SMW_CustomSprites_DispatchVanilla(SMW_ProcessNormalSprites_SpriteStatusPtr)
SMW_CustomSprites_Status_AfterVanilla:
	SEP.b #$30			; AXY->8: the routine's exit mode is its own
	LDA.l !RAM_SMW_CustomSprites_ExtraProp2,x
	AND.b #$40			;\ Bit 6: main after the
	BNE.b .Main			;/ game's behaviour
	PLA				;> The dispatched status
	CMP.b #!Define_SMW_NorSprStatus09_Stunned	;\ Carriable and past it:
	BCS.b SMW_CustomSprites_Status_Main		;/ main runs anyway
	JML.l SMW_ProcessNormalSprites_Return018126
.Main:
	PLA				;> Balance the status push

; The sprite's main, and back to the game: the row is zero where the
; number declares none, and the call runs nothing for it.
SMW_CustomSprites_Status_Main:
	%SMW_CustomSprites_Row(SMW_CustomSprites_MainRows)
	JSR.w SMW_CustomSprites_Call
	JML.l SMW_ProcessNormalSprites_Return018126
endif

; The seven other kinds' stubs, each only where the rows name a sprite of
; that kind -- an unhooked kind's dispatch is the stock game's four bytes.
if !SMW_CustomSprites_ExtendedWanted == !TRUE
SMW_CustomSprites_Extended:
	%SMW_CustomSprites_KindStub(Extended, SMW_ProcessExtendedSprites_ExtendedSpritePtrs, SMW_ProcessExtendedSprites_Return029B15)
endif
if !SMW_CustomSprites_ClusterWanted == !TRUE
SMW_CustomSprites_Cluster:
	%SMW_CustomSprites_KindStub(Cluster, SMW_ProcessClusterSprites_ClusterSpritePtrs, SMW_ProcessClusterSprites_Return02F820)
endif
if !SMW_CustomSprites_MinorExtendedWanted == !TRUE
SMW_CustomSprites_MinorExtended:
	%SMW_CustomSprites_KindStub(MinorExtended, SMW_ProcessMinorExtendedSprites_MinorExtendedSpritesPtrs, SMW_ProcessMinorExtendedSprites_Return)
endif
if !SMW_CustomSprites_BounceWanted == !TRUE
SMW_CustomSprites_Bounce:
	%SMW_CustomSprites_KindStub(Bounce, SMW_ProcessBounceAndSmokeSprites_BounceSpritePtrs, SMW_ProcessBounceAndSmokeSprites_Return02904C)
endif
if !SMW_CustomSprites_SmokeWanted == !TRUE
SMW_CustomSprites_Smoke:
	%SMW_CustomSprites_KindStub(Smoke, SMW_ProcessBounceAndSmokeSprites_SmokeSpritePtrs, SMW_ProcessBounceAndSmokeSprites_Return0296D7)
endif
if !SMW_CustomSprites_GeneratorWanted == !TRUE
SMW_CustomSprites_Generator:
	%SMW_CustomSprites_KindStub(Generator, SMW_ProcessGeneratorSprite_GeneratorSprPtrs, SMW_ProcessGeneratorSprite_Return02B02A)
endif
if !SMW_CustomSprites_ShooterWanted == !TRUE
SMW_CustomSprites_Shooter:
	%SMW_CustomSprites_KindStub(Shooter, SMW_ProcessShooterSprites_ShooterSprPtrs, SMW_ProcessShooterSprites_Return02B3AA)
endif

; The wanted status and kind rows tables, behind the stubs because which
; of them exist depends on the project: the editor reads these through its
; own build's symbol file rather than at a declared address.
if !SMW_CustomSprites_GoalWanted == !TRUE
SMW_CustomSprites_GoalRows:
	%SMW_CustomSprites_WordRows(Goal, $0100)
endif
if !SMW_CustomSprites_MouthWanted == !TRUE
SMW_CustomSprites_MouthRows:
	%SMW_CustomSprites_WordRows(Mouth, $0100)
endif
if !SMW_CustomSprites_CarriableWanted == !TRUE
SMW_CustomSprites_CarriableRows:
	%SMW_CustomSprites_WordRows(Carriable, $0100)
endif
if !SMW_CustomSprites_KickedWanted == !TRUE
SMW_CustomSprites_KickedRows:
	%SMW_CustomSprites_WordRows(Kicked, $0100)
endif
if !SMW_CustomSprites_CarriedWanted == !TRUE
SMW_CustomSprites_CarriedRows:
	%SMW_CustomSprites_WordRows(Carried, $0100)
endif
if !SMW_CustomSprites_ExtendedWanted == !TRUE
SMW_CustomSprites_ExtendedRows:
	%SMW_CustomSprites_WordRows(Extended, $0080)
endif
if !SMW_CustomSprites_ClusterWanted == !TRUE
SMW_CustomSprites_ClusterRows:
	%SMW_CustomSprites_WordRows(Cluster, $0080)
endif
if !SMW_CustomSprites_MinorExtendedWanted == !TRUE
SMW_CustomSprites_MinorExtendedRows:
	%SMW_CustomSprites_WordRows(MinorExtended, $0080)
endif
if !SMW_CustomSprites_BounceWanted == !TRUE
SMW_CustomSprites_BounceRows:
	%SMW_CustomSprites_WordRows(Bounce, $0080)
endif
if !SMW_CustomSprites_SmokeWanted == !TRUE
SMW_CustomSprites_SmokeRows:
	%SMW_CustomSprites_WordRows(Smoke, $0080)
endif
if !SMW_CustomSprites_GeneratorWanted == !TRUE
SMW_CustomSprites_GeneratorRows:
	%SMW_CustomSprites_WordRows(Generator, $0080)
endif
if !SMW_CustomSprites_ShooterWanted == !TRUE
SMW_CustomSprites_ShooterRows:
	%SMW_CustomSprites_WordRows(Shooter, $0080)
endif
	assert (pc()>>$10) == !Define_SMW_SpriteBank, "The custom sprite tables and stubs left the sprite bank."
endif
endmacro

; Place the sprites' own code, and whatever it hijacks. Called from
; %SMW_PlaceSpriteBank behind the dialect, and a second placement for the
; level bank's reason: the head is declared sizes and the code is
; whatever the project's files come to, and a file's org into the game
; only survives once every bank has emitted. A file's own
; pushpc/org/pullpc writes into a bank that is already there and comes
; back to the sequence by itself; what is checked is that it came back.
macro SMW_PlaceCustomSpriteData()
if !Define_SMW_CustomSprites == !TRUE
SMW_CustomSprites_Data:
	incsrc "code/sprites/custom-sprites-data.asm"
	assert (pc()>>$10) == !Define_SMW_SpriteBank, "A custom sprite's file left the sprite bank: an org into the game needs a pushpc/pullpc bracket around it, or the rest of the file assembles over the game. Check code/sprites/."
	assert pc() <= !Loc_SMW_SpriteBank_End, "The custom sprites' code has outgrown the sprite bank: less fits in it than the editor was told. Check code/sprites/."
endif
endmacro
