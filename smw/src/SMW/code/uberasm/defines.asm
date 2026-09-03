includeonce

; UberASM Tool's defines and macros, so a routine written for that tool
; assembles here unchanged. They are the facts this source already carries
; under its own names, spelled the way the routines in the wild spell them:
; a low RAM address is written $1406|!addr, a long one $7E1406|!bank, code
; that cares which cartridge it is on asks !sa1, and a sprite table is
; written !14C8 or !sprite_status.
;
; Included once, in front of the levels' own code, and only on a cartridge
; that carries the compatibility at all (Config/UberASM.asm) -- nothing in
; this source may read them, or the disassembly would have two names for one
; address.
;
; = rather than #= so a file that defines its own wins, which is what a
; routine carrying a newer copy of them expects.

!dp   = !Define_SMW_DirectPageLocation
!addr = !Define_SMW_LowRAMLocation

; !bank ors a ROM label up into the fast mirror, so it is $800000 on the
; shipped cartridge -- and nothing on the coprocessor one, whose SNES side
; runs the banks where they are. Both tools' libraries agree on this pair,
; and the first shipped copy of this file had them swapped.
if defined("Define_SMW_SA1")
!sa1   = 1
!bank = $000000
!bank8 = $00
else
!sa1   = 0
!bank = $800000
!bank8 = $80
endif

; How many sprite slots the cartridge scans. Routines that walk the sprite
; table count down from this, so it is the sprite engine's own figure rather
; than a constant -- twelve as the game ships, and what the coprocessor
; pack's wider table holds where a base is built with it.
!sprite_slots = !Define_SMW_MaxNormalSpriteSlot+$01

;#############################################################################################################
;# The sprite tables, by the tool's two names for each: the address it has
;# on the stock cartridge (!14C8) and what it holds (!sprite_status), plus
;# the tables the sprite tools add behind $7FAB10.
;#
;# **The coprocessor base's values are the pack's, not |!addr.** SA-1 Pack
;# moves the sprite tables into I-RAM ($3200 and up) and BW-RAM, and patches
;# the game's own readers afterwards; a project's code in the level bank is
;# nothing that pass sees, so it has to be assembled against where the
;# tables end up. This is the tool's own list (UberASM Tool's
;# macro_library.asm), both columns, and a routine that wants a table not
;# here adds one line per column.
;#############################################################################################################

; Where the pack's own tables and flags live: I-RAM and BW-RAM on the
; coprocessor base, the tool's stock addresses otherwise.
if defined("Define_SMW_SA1")
!7FAB10 = $400040
!7FAB1C = $400056
!7FAB28 = $400057
!7FAB34 = $40006D
!7FAB9E = $400083
!7FAB40 = $400099
!7FAB4C = $4000AF
!7FAB58 = $4000C5
!extra_bits = $400040
!new_code_flag = $400056
!extra_prop_1 = $400057
!extra_prop_2 = $40006D
!new_sprite_num = $400083
!extra_byte_1 = $400099
!extra_byte_2 = $4000AF
!extra_byte_3 = $4000C5
!extra_byte_4 = $4000DB
!sprite_load_table = $418A00
!1938 = $418A00
else
!7FAB10 = $7FAB10
!7FAB1C = $7FAB1C
!7FAB28 = $7FAB28
!7FAB34 = $7FAB34
!7FAB9E = $7FAB9E
!7FAB40 = $7FAB40
!7FAB4C = $7FAB4C
!7FAB58 = $7FAB58
!extra_bits = $7FAB10
!new_code_flag = $7FAB1C
!extra_prop_1 = $7FAB28
!extra_prop_2 = $7FAB34
!new_sprite_num = $7FAB9E
!extra_byte_1 = $7FAB40
!extra_byte_2 = $7FAB4C
!extra_byte_3 = $7FAB58
!extra_byte_4 = $7FAB64
!sprite_load_table = $1938
!1938 = $1938
endif

; Every sprite table, from the memory map: the anchor each table is placed
; by, which the sa1 base sets to where SA-1 Pack keeps it, and the stock
; address on every other cartridge. The tool spells a table that stays on
; the direct page as its page offset, so those subtract the page; the three
; the pack takes off it (sprite number, X and Y low) are absolute.
!sprite_num = !Define_SMW_SprTable_009E
!sprite_speed_y = (!Define_SMW_SprTable_00AA)-!Define_SMW_DirectPageLocation
!sprite_speed_x = (!Define_SMW_SprTable_00B6)-!Define_SMW_DirectPageLocation
!sprite_misc_c2 = (!Define_SMW_SprTable_00C2)-!Define_SMW_DirectPageLocation
!sprite_y_low = !Define_SMW_SprTable_00D8
!sprite_x_low = !RAM_SMW_NorSpr_XPosLo
!sprite_status = !Define_SMW_SprTable_14C8
!sprite_y_high = !Define_SMW_SprTable_14D4
!sprite_x_high = !RAM_SMW_NorSpr_XPosHi
!sprite_speed_y_frac = !Define_SMW_SprTable_14EC
!sprite_speed_x_frac = !RAM_SMW_NorSpr_SubXPos
!sprite_misc_1504 = !Define_SMW_SprTable_1504
!sprite_misc_1510 = !RAM_SMW_NorSpr_Table7E1510
!sprite_misc_151c = !Define_SMW_SprTable_151C
!sprite_misc_1528 = !Define_SMW_SprTable_1528
!sprite_misc_1534 = !Define_SMW_SprTable_1534
!sprite_misc_1540 = !Define_SMW_SprTable_1540
!sprite_misc_154c = !Define_SMW_SprTable_154C
!sprite_misc_1558 = !Define_SMW_SprTable_1558
!sprite_misc_1564 = !Define_SMW_SprTable_1564
!sprite_misc_1570 = !Define_SMW_SprTable_1570
!sprite_misc_157c = !Define_SMW_SprTable_157C
!sprite_blocked_status = !RAM_SMW_NorSpr_Table7E1588
!sprite_misc_1594 = !Define_SMW_SprTable_1594
!sprite_off_screen_horz = !Define_SMW_SprTable_15A0
!sprite_misc_15ac = !Define_SMW_SprTable_15AC
!sprite_slope = !Define_SMW_SprTable_15B8
!sprite_off_screen = !Define_SMW_SprTable_15C4
!sprite_being_eaten = !RAM_SMW_NorSpr_Table7E15D0
!sprite_obj_interact = !Define_SMW_SprTable_15DC
!sprite_oam_index = !Define_SMW_SprTable_15EA
!sprite_oam_properties = !Define_SMW_SprTable_15F6
!sprite_misc_1602 = !Define_SMW_SprTable_1602
!sprite_misc_160e = !Define_SMW_SprTable_160E
!sprite_index_in_level = !Define_SMW_SprTable_161A
!sprite_misc_1626 = !Define_SMW_SprTable_1626
!sprite_behind_scenery = !RAM_SMW_NorSpr_Table7E1632
!sprite_misc_163e = !Define_SMW_SprTable_163E
!sprite_in_water = !Define_SMW_SprTable_164A
!sprite_tweaker_1656 = !Define_SMW_SprTable_1656
!sprite_tweaker_1662 = !Define_SMW_SprTable_1662
!sprite_tweaker_166e = !Define_SMW_SprTable_166E
!sprite_tweaker_167a = !Define_SMW_SprTable_167A
!sprite_tweaker_1686 = !Define_SMW_SprTable_1686
!sprite_off_screen_vert = !Define_SMW_SprTable_186C
!sprite_misc_187b = !Define_SMW_SprTable_187B
!sprite_tweaker_190f = !Define_SMW_SprTable_190F
!sprite_misc_1fd6 = !Define_SMW_SprTable_1FD6
!sprite_cape_disable_time = !Define_SMW_SprTable_1FE2
!9E = !Define_SMW_SprTable_009E
!AA = (!Define_SMW_SprTable_00AA)-!Define_SMW_DirectPageLocation
!B6 = (!Define_SMW_SprTable_00B6)-!Define_SMW_DirectPageLocation
!C2 = (!Define_SMW_SprTable_00C2)-!Define_SMW_DirectPageLocation
!D8 = !Define_SMW_SprTable_00D8
!E4 = !RAM_SMW_NorSpr_XPosLo
!14C8 = !Define_SMW_SprTable_14C8
!14D4 = !Define_SMW_SprTable_14D4
!14E0 = !RAM_SMW_NorSpr_XPosHi
!14EC = !Define_SMW_SprTable_14EC
!14F8 = !RAM_SMW_NorSpr_SubXPos
!1504 = !Define_SMW_SprTable_1504
!1510 = !RAM_SMW_NorSpr_Table7E1510
!151C = !Define_SMW_SprTable_151C
!1528 = !Define_SMW_SprTable_1528
!1534 = !Define_SMW_SprTable_1534
!1540 = !Define_SMW_SprTable_1540
!154C = !Define_SMW_SprTable_154C
!1558 = !Define_SMW_SprTable_1558
!1564 = !Define_SMW_SprTable_1564
!1570 = !Define_SMW_SprTable_1570
!157C = !Define_SMW_SprTable_157C
!1588 = !RAM_SMW_NorSpr_Table7E1588
!1594 = !Define_SMW_SprTable_1594
!15A0 = !Define_SMW_SprTable_15A0
!15AC = !Define_SMW_SprTable_15AC
!15B8 = !Define_SMW_SprTable_15B8
!15C4 = !Define_SMW_SprTable_15C4
!15D0 = !RAM_SMW_NorSpr_Table7E15D0
!15DC = !Define_SMW_SprTable_15DC
!15EA = !Define_SMW_SprTable_15EA
!15F6 = !Define_SMW_SprTable_15F6
!1602 = !Define_SMW_SprTable_1602
!160E = !Define_SMW_SprTable_160E
!161A = !Define_SMW_SprTable_161A
!1626 = !Define_SMW_SprTable_1626
!1632 = !RAM_SMW_NorSpr_Table7E1632
!163E = !Define_SMW_SprTable_163E
!164A = !Define_SMW_SprTable_164A
!1656 = !Define_SMW_SprTable_1656
!1662 = !Define_SMW_SprTable_1662
!166E = !Define_SMW_SprTable_166E
!167A = !Define_SMW_SprTable_167A
!1686 = !Define_SMW_SprTable_1686
!186C = !Define_SMW_SprTable_186C
!187B = !Define_SMW_SprTable_187B
!190F = !Define_SMW_SprTable_190F
!1FD6 = !Define_SMW_SprTable_1FD6
!1FE2 = !Define_SMW_SprTable_1FE2

;#############################################################################################################
;# The macros the tool's macro library ships, so a file that reaches for one
;# assembles. A file the project writes for itself goes in
;# code/uberasm/macros/ instead (Config/UberASM.asm).
;#
;# %prot_file and %prot_source name a file to include, relative to this
;# folder (code/uberasm/): with that tool the file gets a bank of its own,
;# here it goes with the code that names it, which is what the levels' own
;# placement already gives every file.
;#############################################################################################################

macro prot_file(file, label)
<label>:
	incbin "<file>"
endmacro

macro prot_source(file, label)
<label>:
	incsrc "<file>"
endmacro

; Which version of the tool a file was written for. Every file this source
; assembles is assembled the same way, so there is nothing to check.
macro require_uber_ver(major, minor)
endmacro

; One define per base, the tool's own way of spelling the table above --
; in both spellings the wild has. UberASM Tool's macro library gives it
; two columns, stock and SA-1; SA-1 Pack's sprite_tables.asm gives it
; three, the third for the pack's wider tables, and that file is read
; into the same assembly on the coprocessor base. asar allows one macro
; per name, so this one takes either, and Config/SA1Pack.asm tells the
; pack's file to leave its own out (sa1_sprite_table_macro_external). A
; three-column call on the coprocessor base takes the third column,
; which is what the pack's own file would have done.
macro define_sprite_table(name, addr, ...)
	if !sa1 == 0
		!<name> = <addr>
	elseif sizeof(...) == 1
		!<name> = <...[0]>
	else
		!<name> = <...[1]>
	endif
endmacro

; Copy a block of memory. Destroys A, X and Y.
macro move_block(src, dest, len)
	PHB
	REP.b #$30
	LDA.w #<len>-1
	LDX.w #<src>
	LDY.w #<dest>
	MVN <dest>>>16,<src>>>16
	SEP.b #$30
	PLB
endmacro

; Run a routine on the SA-1 CPU, or on the SNES CPU from the SA-1. Both
; are the pack's own protocol and mean nothing on a cartridge without it;
; the routine ends in RTL, and the data bank is the callee's to set.
macro invoke_sa1(label)
	LDA.b #<label>
	STA.w $3180
	LDA.b #<label>>>8
	STA.w $3181
	LDA.b #<label>>>16
	STA.w $3182
	JSR.w $1E80
endmacro

macro invoke_snes(addr)
	LDA.b #<addr>
	STA.w $0183
	LDA.b #<addr>>>8
	STA.w $0184
	LDA.b #<addr>>>16
	STA.w $0185
	LDA.b #$D0
	STA.w $2209
-	LDA.w $018A
	BEQ.b -
	STZ.w $018A
endmacro
