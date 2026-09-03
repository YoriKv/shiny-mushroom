includeonce

;#############################################################################################################
;# UberASM Tool compatibility: a level's code written the way that tool
;# writes it.
;#
;# Config/LevelCode.asm gives a level routines of its own and says nothing
;# about how they are spelled. This says how: the defines and macros
;# routines in the wild expect, a macro library of the project's own, and a
;# shared library they may call into. All of it is what UberASM Tool
;# provides its own files, so a routine written for that tool assembles
;# here unchanged. The define is the dialect's own, apart from the three
;# code defines, so a source build can assemble a project's code without
;# !addr and !14C8 defined over its head; the editor's one feature,
;# UberASM Support, throws all four defines together.
;#
;# Three fragments under code/uberasm/, all the editor's:
;#
;# - defines.asm, the tool's own names for things this source already has,
;#   and the macros its macro library ships (see the file). Read once, in
;#   front of every routine.
;# - macros.asm, one incsrc per file in code/uberasm/macros/: the project's
;#   own macros and defines, read once and before any code. asar's macros
;#   and defines are global, so a file of them included from two routines
;#   is a redefinition error; this is the one place it is included from.
;# - lib.asm, one namespace and incsrc per file in code/uberasm/lib/. A
;#   library file's labels are reached the way that tool reaches them --
;#   the filename, an underscore, the label -- so math.asm's sqrt is
;#   math_sqrt to every level that calls it.
;#
;# Two things about the library are better here than there, and one is
;# the same. A library file may call another library file's labels, which
;# UberASM Tool cannot do at all, because asar resolves every label in the
;# assembly and nothing has to guess what a file will define. Its labels
;# also cost nothing to declare: they are namespaced, not prefixed by hand.
;# What is the same is that every file in the folder is assembled whether
;# anything calls it or not -- nothing here knows which labels a level's
;# code will reach for, so an unused library file is bytes in the bank.
;#############################################################################################################

; Off unless a build asks for it, guarded so --define wins:
; --define Define_SMW_UberASM=1 turns the compatibility on.
if defined("Define_SMW_UberASM") == 0
	!Define_SMW_UberASM = !FALSE
endif

; It is defines and a library for *some* project code to use, and there are
; three kinds that might: a level's, a game mode's, and the global and
; status bar routines. Any one of them is enough; none of them is an error
; rather than a cartridge carrying a library nothing can call.
if !Define_SMW_UberASM == !TRUE && !Define_SMW_LevelCode == !FALSE && !Define_SMW_GameModeCode == !FALSE && !Define_SMW_GlobalCode == !FALSE
	error "The UberASM compatibility is defines and a library for a project's own code, and this cartridge has none to use them. Turn on Define_SMW_LevelCode, Define_SMW_GameModeCode or Define_SMW_GlobalCode as well."
endif

; What a level's code is read through, in front of the levels' own
; routines: the tool's defines and macros, the project's own, then the
; library they may call into. Placed from %SMW_PlaceLevelBank ahead of
; every kind of project code -- a level's, a game mode's, the global
; routines -- because all three are assembled after this and all three may
; be written in this dialect. Its own placement rather than a call from one
; of theirs, which would tie the dialect to whichever feature happened to
; host it.
macro SMW_PlaceUberASM()
if !Define_SMW_UberASM == !TRUE
	incsrc "code/uberasm/defines.asm"
	incsrc "code/uberasm/macros.asm"

; The library, in the level bank with the code that calls it.
SMW_UberASM_Library:
	incsrc "code/uberasm/lib.asm"
	assert (pc()>>$10) == !Define_SMW_LevelBank, "A library file left the level bank: an org into the game needs a pushpc/pullpc bracket around it, or the rest of the file assembles over the game. Check code/uberasm/lib/."
	assert pc() <= !Loc_SMW_LevelBank_RunEnd, "The shared library has outgrown the level bank: less fits in it than the editor was told. Check code/uberasm/lib/."
endif
endmacro
