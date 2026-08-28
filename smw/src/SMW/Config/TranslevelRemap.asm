includeonce

;#############################################################################################################
;# Remapping which level an overworld tile loads.
;#
;# The stock game stores nothing per tile. The overworld scan hands out
;# translevel numbers positionally -- walking the pristine Layer 1 tilemap and
;# counting level tiles -- and SMW_SpecifySublevelToLoad computes the level
;# number from the translevel: subtract $24 past the main map's range, add
;# $100 on a submap. So which level a tile loads is a function of its position
;# among the map's level tiles, and nothing an editor could point elsewhere.
;#
;# Setting !Define_SMW_TranslevelRemap to !TRUE turns the computation for the
;# overworld-tile path into a table lookup: SMW_TranslevelRemap_LevelNumbers,
;# one word per translevel, $60 rows, read in Banks/Bank05.asm under this same
;# define. Remapping a tile's level is editing its row. The shipped rows
;# reproduce the arithmetic for the shipped tilemap, so the feature with an
;# unedited table loads exactly what the stock cartridge loads.
;#
;# Translevels themselves stay derived: every per-translevel table -- the
;# names, the events, the walk directions, the save flags -- is indexed
;# exactly as before. Only the last hop, translevel to level number, moves.
;# The intro-override path through the same routine keeps the arithmetic too:
;# the value in !RAM_SMW_Misc_IntroLevelFlag is not a scan translevel, and the
;# table does not speak for it.
;#
;# The table lives in the run the growable features share
;# (Config/ReservedBank.asm), so this define needs a cartridge the reserved
;# bank exists in -- and says so rather than assembling half a feature. It is
;# placed from the head of each ROM map, before any other occupant emits,
;# which is what puts it at the run's head: it is the one occupant whose rows
;# are a fixed count -- one word per translevel -- so nothing is gained by
;# giving it the growing end, and everything behind it is spared having to
;# know whether it is there.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_TranslevelRemap=1 turns the table on.
if defined("Define_SMW_TranslevelRemap") == 0
	!Define_SMW_TranslevelRemap = !FALSE
endif

; Place the lookup and the table at the head of the reserved run. Called from
; the head of each ROM map, before any bank has emitted into it, so
; !SMW_ReservedBankNext is still the run's first byte. Bracketed with
; pushpc/pullpc like the fragments themselves, and bounded by the same assert
; -- warnpc is unavailable between a pushpc and its pullpc.
;
; The lookup is the code the bank $05 JML lands on, and it lives here because
; its run of bank $05 is packed to the byte: the JML costs three bytes fewer
; than the two instructions it stands in for, and the run has slack where the
; bank has none. It runs with bank $05's own state -- DBR $05 (so the
; absolute store still lands in the WRAM mirror), direct page zero, A 8-bit,
; X/Y 16-bit, X the tile's Map16 index -- and executing from this bank is
; nothing special: the reservation is data to the freespace search, not to
; the processor. Its bytes are not the editable fragment's rows, so the
; feature's TablePool declares them as `reserved`, the way the relocation
; declares the Layer 2 divider table.
macro SMW_PlaceTranslevelLevelTable()
if !Define_SMW_TranslevelRemap == !TRUE
	pushpc
	org !SMW_ReservedBankNext
SMW_TranslevelRemap_TileLevelLookup:
if defined("Define_SMW_SA1Pack")
	LDA.l $40D000,x			;\ The scan's per-tile translevels, where SA-1
					;| Pack keeps them: the pack moves $7ED000 to
					;| BW-RAM after this source assembles, patching
					;/ every reader by address -- this one by us.
else
	LDA.l !RAM_SMW_Overworld_LevelNumberOfEachTileTBL,x	;> The read the JML stands in for
endif
	STA.w !RAM_SMW_Overworld_LevelNumberLo	;> The tile's translevel, stored as ever
	REP.b #$20			; A->16
	AND.w #$00FF			; The high byte is stale from the tile index math
	ASL
	TAX
	LDA.l SMW_TranslevelRemap_LevelNumbers,x
	STA.b !RAM_SMW_Misc_ScratchRAM0E	; Both bytes: the level number, whole
	SEP.b #$20			; A->8
	JML.l SMW_SpecifySublevelToLoad_CODE_05D8B7
namespace SMW_TranslevelRemap
	incsrc "overworld/tables/translevel-levels.asm"
namespace off
	assert pc() <= !Loc_SMW_ReservedBank_End, "The translevel remap table has outgrown the reserved run: less fits in it than the editor was told. Check overworld/tables/."
	!SMW_ReservedBankNext #= pc()
	pullpc
endif
endmacro
