;--- Guarded by a define rather than `includeonce`: the main pass reaches this
;--- file under two spellings -- `Config/Versions.asm` through
;--- Misc_Defines_SMW.asm and `../SMW/Config/Versions.asm` through the SRAM
;--- map's Global-side loader -- and `includeonce` keys on the spelling, so it
;--- let the functions be defined twice. `defined()` does not care how the
;--- file was reached.
if not(defined("SMW_VersionPredicatesDefined"))
!SMW_VersionPredicatesDefined = 1

;--- Version predicates.
;---
;--- Upstream spells every version check as a bitmask against
;--- !Define_Global_ROMToAssemble. These name the recurring masks so a reader
;--- learns which releases a block applies to without decoding bit patterns.
;---
;--- Each predicate is EXACTLY the mask it replaces -- named for membership,
;--- not for an inferred purpose. Negate with `== 0`, e.g.
;---     if ver_is_japanese(!Define_Global_ROMToAssemble) == 0
;---
;--- The mask is a parameter because asar rejects a zero-argument function,
;--- and because passing it keeps the value read at the call site.
function ver_is_japanese(v) = notequal(v&(!ROM_SMW_J),$00)
function ver_is_pal(v) = notequal(v&(!ROM_SMW_E1|!ROM_SMW_E2|!ROM_SMASW_E),$00)
function ver_is_pal_rev1(v) = notequal(v&(!ROM_SMW_E2|!ROM_SMASW_E),$00)
function ver_is_smasw(v) = notequal(v&(!ROM_SMASW_U|!ROM_SMASW_E),$00)
function ver_is_arcade(v) = notequal(v&(!ROM_SMW_ARCADE),$00)
function ver_is_smasw_usa(v) = notequal(v&(!ROM_SMASW_U),$00)
function ver_is_smasw_europe(v) = notequal(v&(!ROM_SMASW_E),$00)
function ver_is_pal_rev0(v) = notequal(v&(!ROM_SMW_E1),$00)
endif
