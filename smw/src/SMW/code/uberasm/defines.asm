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

if defined("Define_SMW_SA1Pack")
!sa1   = 1
!bank = $800000
!bank8 = $80
else
!sa1   = 0
!bank = $000000
!bank8 = $00
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

if defined("Define_SMW_SA1Pack")
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
!sprite_num = $3200
!sprite_speed_y = $9E
!sprite_speed_x = $B6
!sprite_misc_c2 = $D8
!sprite_y_low = $3216
!sprite_x_low = $322C
!sprite_status = $3242
!sprite_y_high = $3258
!sprite_x_high = $326E
!sprite_speed_y_frac = $74C8
!sprite_speed_x_frac = $74DE
!sprite_misc_1504 = $74F4
!sprite_misc_1510 = $750A
!sprite_misc_151c = $3284
!sprite_misc_1528 = $329A
!sprite_misc_1534 = $32B0
!sprite_misc_1540 = $32C6
!sprite_misc_154c = $32DC
!sprite_misc_1558 = $32F2
!sprite_misc_1564 = $3308
!sprite_misc_1570 = $331E
!sprite_misc_157c = $3334
!sprite_blocked_status = $334A
!sprite_misc_1594 = $3360
!sprite_off_screen_horz = $3376
!sprite_misc_15ac = $338C
!sprite_slope = $7520
!sprite_off_screen = $7536
!sprite_being_eaten = $754C
!sprite_obj_interact = $7562
!sprite_oam_index = $33A2
!sprite_oam_properties = $33B8
!sprite_misc_1602 = $33CE
!sprite_misc_160e = $33E4
!sprite_index_in_level = $7578
!sprite_misc_1626 = $758E
!sprite_behind_scenery = $75A4
!sprite_misc_163e = $33FA
!sprite_in_water = $75BA
!sprite_tweaker_1656 = $75D0
!sprite_tweaker_1662 = $75EA
!sprite_tweaker_166e = $7600
!sprite_tweaker_167a = $7616
!sprite_tweaker_1686 = $762C
!sprite_off_screen_vert = $7642
!sprite_misc_187b = $3410
!sprite_load_table = $418A00
!sprite_tweaker_190f = $7658
!sprite_misc_1fd6 = $766E
!sprite_cape_disable_time = $7FD6
!9E = $3200
!AA = $9E
!B6 = $B6
!C2 = $D8
!D8 = $3216
!E4 = $322C
!14C8 = $3242
!14D4 = $3258
!14E0 = $326E
!14EC = $74C8
!14F8 = $74DE
!1504 = $74F4
!1510 = $750A
!151C = $3284
!1528 = $329A
!1534 = $32B0
!1540 = $32C6
!154C = $32DC
!1558 = $32F2
!1564 = $3308
!1570 = $331E
!157C = $3334
!1588 = $334A
!1594 = $3360
!15A0 = $3376
!15AC = $338C
!15B8 = $7520
!15C4 = $7536
!15D0 = $754C
!15DC = $7562
!15EA = $33A2
!15F6 = $33B8
!1602 = $33CE
!160E = $33E4
!161A = $7578
!1626 = $758E
!1632 = $75A4
!163E = $33FA
!164A = $75BA
!1656 = $75D0
!1662 = $75EA
!166E = $7600
!167A = $7616
!1686 = $762C
!186C = $7642
!187B = $3410
!190F = $7658
!1938 = $418A00
!1FD6 = $766E
!1FE2 = $7FD6
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
!sprite_num = $9E
!sprite_speed_y = $AA
!sprite_speed_x = $B6
!sprite_misc_c2 = $C2
!sprite_y_low = $D8
!sprite_x_low = $E4
!sprite_status = $14C8
!sprite_y_high = $14D4
!sprite_x_high = $14E0
!sprite_speed_y_frac = $14EC
!sprite_speed_x_frac = $14F8
!sprite_misc_1504 = $1504
!sprite_misc_1510 = $1510
!sprite_misc_151c = $151C
!sprite_misc_1528 = $1528
!sprite_misc_1534 = $1534
!sprite_misc_1540 = $1540
!sprite_misc_154c = $154C
!sprite_misc_1558 = $1558
!sprite_misc_1564 = $1564
!sprite_misc_1570 = $1570
!sprite_misc_157c = $157C
!sprite_blocked_status = $1588
!sprite_misc_1594 = $1594
!sprite_off_screen_horz = $15A0
!sprite_misc_15ac = $15AC
!sprite_slope = $15B8
!sprite_off_screen = $15C4
!sprite_being_eaten = $15D0
!sprite_obj_interact = $15DC
!sprite_oam_index = $15EA
!sprite_oam_properties = $15F6
!sprite_misc_1602 = $1602
!sprite_misc_160e = $160E
!sprite_index_in_level = $161A
!sprite_misc_1626 = $1626
!sprite_behind_scenery = $1632
!sprite_misc_163e = $163E
!sprite_in_water = $164A
!sprite_tweaker_1656 = $1656
!sprite_tweaker_1662 = $1662
!sprite_tweaker_166e = $166E
!sprite_tweaker_167a = $167A
!sprite_tweaker_1686 = $1686
!sprite_off_screen_vert = $186C
!sprite_misc_187b = $187B
!sprite_load_table = $1938
!sprite_tweaker_190f = $190F
!sprite_misc_1fd6 = $1FD6
!sprite_cape_disable_time = $1FE2
!9E = $9E
!AA = $AA
!B6 = $B6
!C2 = $C2
!D8 = $D8
!E4 = $E4
!14C8 = $14C8
!14D4 = $14D4
!14E0 = $14E0
!14EC = $14EC
!14F8 = $14F8
!1504 = $1504
!1510 = $1510
!151C = $151C
!1528 = $1528
!1534 = $1534
!1540 = $1540
!154C = $154C
!1558 = $1558
!1564 = $1564
!1570 = $1570
!157C = $157C
!1588 = $1588
!1594 = $1594
!15A0 = $15A0
!15AC = $15AC
!15B8 = $15B8
!15C4 = $15C4
!15D0 = $15D0
!15DC = $15DC
!15EA = $15EA
!15F6 = $15F6
!1602 = $1602
!160E = $160E
!161A = $161A
!1626 = $1626
!1632 = $1632
!163E = $163E
!164A = $164A
!1656 = $1656
!1662 = $1662
!166E = $166E
!167A = $167A
!1686 = $1686
!186C = $186C
!187B = $187B
!190F = $190F
!1938 = $1938
!1FD6 = $1FD6
!1FE2 = $1FE2
endif

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

; One define per base, the tool's own way of spelling the table above.
macro define_sprite_table(name, addr, addr_sa1)
	if !sa1 == 0
		!<name> = <addr>
	else
		!<name> = <addr_sa1>
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
