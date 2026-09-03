;###########################################################################
;# SA-1 Pack, assembled inside the build
;###########################################################################
;#
;# On a coprocessor base the pack's own entry file is included here, from
;# the end of the ROM map, after every bank has been emitted -- so its
;# engine, its boosts and More Sprites' code assemble as part of this pass,
;# and no pass runs after the build. The tree is the vendored one, reached through the include
;# path the build passes; nothing of it is copied here.
;#
;# What the pack would also do, the source has already done, and each of
;# those parts is switched off below: the work-RAM remap, the Map16, save
;# and DMA remaps, the sprite memory index, every sprite table's move with
;# the slot count, the pointer-indirect rewrites of the three tables that
;# left the direct page (the memory map's access defines spell those for
;# both cartridges), and every same-length hijack over the game's banks,
;# which Banks/ carries as a Define_SMW_SA1 conditional at its site -- the
;# larger bodies included from asm/inline/ under the pack's own namespace,
;# so the labels its freespace code jumps back to are the ones it expects.
;# What remains of the pack here is its code in freespace and the labels
;# the sites name; nothing rewrites a byte the banks emitted.
;#
;# Why this works in the main pass and could never work from an earlier
;# one: the pack's clean-ROM guards read1() the image the pass started
;# from, and the initialize pass never runs the ROM map, so that image is
;# empty here -- every guard answers as it would on a clean cartridge, and
;# every `autoclean` finds nothing to free. The pack's freespace search
;# then runs over the banks this pass has already written and lands where
;# it always has, in bank $10.
;#
;###########################################################################

macro SMW_SA1Pack()
if defined("Define_SMW_SA1")
	; Already the memory map's, so the pack's copies are off.
	!remap_dp = 0
	!remap_addr = 0
	!remap_sram = 0
	!remap_map16 = 0
	!remap_dma = 0
	!remap_sprite_memory = 0
	!more_sprites_moves = 0
	!more_sprites_dp_nontrivial = 0
	!sa1_hijacks_external = 1
	; The dialect's defines.asm carries define_sprite_table in both the
	; tool's and the pack's spellings, and asar allows one macro per name,
	; so the pack's own copy stands down where the dialect is read --
	; which the PIXI compatibility does too, sharing that same file.
	if !Define_SMW_UberASM == !TRUE || !Define_SMW_Pixi == !TRUE
		!sa1_sprite_table_macro_external = 1
	endif
	; The pack's own `asar 1.90` line is left out (sa1_code_in_pass): a
	; version directive sets the math mode of the *whole* assembly it
	; appears in, bytes emitted before it included. The pack's files
	; assemble under this tree's mode, and at the pinned revision that
	; makes no difference to a byte -- measured both ways. A revision that
	; did depend on its mode would show against a cartridge with the pack
	; applied, which is the check the pin asks for after any upgrade.
	!sa1_code_in_pass = 1
	; Past 4 MB the pack's own size files used to finish the image; the
	; framework pads it to the size named now, and the three things those
	; files did besides are done here: the Super MMC bank switch takes the
	; values for a cartridge that large (read by the entry below), a 6 MB
	; cartridge keeps the two 64 KB blocks ZSNES needs to load it, and the
	; cartridge header is mirrored at $407FC0 -- the whole header, where the
	; pack copied its last 64 bytes; its checksum field is the declared one,
	; the real one being fixed at $00:FFDC after this, which is the only copy
	; the console reads.
	if !Define_Global_ROMSize > !ROMSize_4MB
		!sa1_rom_past_4mb = 1
	endif
	pushpc
	; Lunar Magic's record of the graphics compression, one byte at $0F:FFEB
	; the pack's LZ boost reads to choose between LZ2 and LZ3: $01, LZ2, as
	; the pack itself writes over a cartridge that has none.
	org $0FFFEB
	db $01
	incsrc "asm/sa1.asm"
	if !Define_Global_ROMSize > !ROMSize_4MB
		norom
		if !Define_Global_ROMSize == !ROMSize_6MB
			org $400000
			fillbyte $55 : fill $010000
			org $410000
			fillbyte $55 : fill $010000
			fillbyte $00
			org $400000
			db "STAR" : dw $FFF7 : dw $0008
			org $410000
			db "STAR" : dw $FFF7 : dw $0008
		endif
		if !Define_Global_ROMSize == !ROMSize_8MB
			org $407FB8
			db "STAR" : dw $003F : dw $FFC0
		endif
		org $407FB0
		%SNES_Header($407FB0)
		fullsa1rom
	endif
	pullpc
endif
endmacro

