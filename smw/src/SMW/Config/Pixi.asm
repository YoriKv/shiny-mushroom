includeonce

;#############################################################################################################
;# PIXI compatibility: a custom sprite written the way that tool writes it.
;#
;# Config/CustomSprites.asm gives a sprite number code of its own and says
;# nothing about how it is spelled. This says how: the defines and macros
;# sprites in the wild expect, the shared-routine macros that tool ships,
;# and a library of the project's own -- so a sprite published for PIXI
;# assembles here unchanged. The custom sprites feature throws this
;# define with its own -- one switch covers the capability and the
;# spelling -- but the define stays separate, so a hand build writing its
;# sprites in this source's own idiom can take the capability alone and
;# not have !14C8 and !Base2 defined over its head.
;#
;# Most of the dialect is UberASM Tool's, shared rather than copied: the
;# two tools' macro libraries name the same addresses the same way, so
;# code/uberasm/defines.asm and code/uberasm/macros.asm are read here too
;# -- each protected by includeonce, so a cartridge carrying both dialects
;# reads them once -- and only what PIXI adds on top lives under
;# code/pixi/:
;#
;# - defines.asm, the names PIXI's own sa1def.asm adds: the !Base1/!Base2
;#   pair that makes one file assemble on both a console cartridge and a
;#   coprocessor one, spelled from the same facts this source already
;#   carries.
;# - routines.asm, one incsrc per file in code/pixi/routines/: the
;#   shared-routine macros (%GetDrawInfo and its siblings). Where the game
;#   has the routine, a macro is a JSL to it by name; where it has none,
;#   it carries the tool's body. The folder ships empty and grows with the
;#   project.
;# - lib.asm, one namespace and incsrc per file in code/sprites/lib/: the
;#   sprite library, on the level code's own mechanism -- a file's labels
;#   are reached as filename_label, a library file may call another's,
;#   and every file is assembled whether anything calls it or not.
;#
;# A sprite may also call the level code's shared library where the
;# cartridge carries it: the uberasm library assembles into the level
;# bank ahead of this bank's sequence, and asar resolves the cross-bank
;# JSL by name. Nothing here duplicates it.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_Pixi=1 turns the compatibility on.
if defined("Define_SMW_Pixi") == 0
	!Define_SMW_Pixi = !FALSE
endif

; It is defines and a library for custom sprites to use, and a cartridge
; with none has nothing to spell.
if !Define_SMW_Pixi == !TRUE && !Define_SMW_CustomSprites == !FALSE
	error "The PIXI compatibility is defines and a library for a project's custom sprites, and this cartridge has none to use them. Turn on Define_SMW_CustomSprites as well."
endif

; What a sprite's code is read through, in front of the sprites' own
; routines: the shared dialect, PIXI's own additions, the shared-routine
; macros, then the library. Placed from %SMW_PlaceSpriteBank ahead of the
; sprites' code; the level bank's sequence runs first, so on a cartridge
; carrying the UberASM dialect too the shared files were already read
; there and the includeonce inside each stands them down here.
macro SMW_PlacePixi()
if !Define_SMW_Pixi == !TRUE
	incsrc "code/uberasm/defines.asm"
	incsrc "code/uberasm/macros.asm"
	incsrc "code/pixi/defines.asm"
	incsrc "code/pixi/routines.asm"

; The sprite library, in the sprite bank with the code that calls it.
SMW_Pixi_Library:
	incsrc "code/pixi/lib.asm"
	assert (pc()>>$10) == !Define_SMW_SpriteBank, "A library file left the sprite bank: an org into the game needs a pushpc/pullpc bracket around it, or the rest of the file assembles over the game. Check code/sprites/lib/."
	assert pc() <= !Loc_SMW_SpriteBank_End, "The sprite library has outgrown the sprite bank: less fits in it than the editor was told. Check code/sprites/lib/."
endif
endmacro
