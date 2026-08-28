;--- Stack and OAM staging - $7E0100-$7E03FF
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

	; Game mode. This manages directing to the different processing modes of
	; the game, such as being in a level, being on the overworld, or being in a
	; loading screen.
	!RAM_SMW_Misc_GameMode #= !Define_SMW_LowRAMLocation+$0100
	; Currently loaded sprite GFX files - stored in reverse order.
	!RAM_SMW_Misc_CurrentlyLoadedSpriteGraphicsFiles #= !Define_SMW_LowRAMLocation+$0101
	; Currently loaded FG/BG GFX files - stored in reverse order.
	!RAM_SMW_Misc_CurrentlyLoadedLayerGraphicsFiles #= !Define_SMW_LowRAMLocation+$0105
	; When set to a non-zero value, the overworld loading routine is overridden
	; by loading a level value stored here, minus #$24 if it's above #$24. For
	; example, the intro level (level C5) is loaded this way by storing #$E9 to
	; this address. Depending on whether the player is on the main overworld or
	; a submap, the level in question is either in the 0xx or 1xx area.
	!RAM_SMW_Misc_IntroLevelFlag #= !Define_SMW_LowRAMLocation+$0109
	; Current save file number.
	!RAM_SMW_Misc_CurrentSaveFile #= !Define_SMW_LowRAMLocation+$010A
	; Which level number the last sublevel load loaded, both bytes. The stock
	; game writes nothing here -- $010B-$010F are unused -- and computes the
	; number transiently in scratch RAM; only a cartridge assembled with
	; !Define_SMW_LevelCustomPalettes or !Define_SMW_LevelGraphics stores it,
	; from the stash the two share in SMW_SpecifySublevelToLoad
	; (Config/LevelNumberStash.asm), for the palette copy in
	; SMW_GameMode12_PrepareLevel and the row overlay in
	; SMW_UploadGraphicsFiles to index their tables with. The same word
	; Lunar Magic keeps the same number in, so code written against its
	; cartridges reads the right value here too.
	!RAM_SMW_LevelNumberStash_LoadedLevel #= !Define_SMW_LowRAMLocation+$010B
	; Which graphics file is expanded into the animated tiles, and the same
	; byte complemented. Only a cartridge assembled with
	; !Define_SMW_LevelGraphics writes them, from the stub that gives a level
	; the animated tiles its row asks for (Config/LevelGraphics.asm): the
	; expansion costs two decompressions, so the stub does it only when this
	; record disagrees with what the level wants. The complement is what
	; makes the record answer for itself, since this page is the one thing
	; the reset does not clear -- a cartridge that has just powered on holds
	; whatever it holds here, and two bytes that are not each other's
	; complement are a record to reload rather than believe.
	!RAM_SMW_LevelGraphics_AnimatedFile #= !Define_SMW_LowRAMLocation+$010D
	!RAM_SMW_LevelGraphics_AnimatedFileCheck #= !RAM_SMW_LevelGraphics_AnimatedFile+$01
	!RAM_SMW_Misc_ScratchRAM0110 #= !Define_SMW_LowRAMLocation+$0110					; RAM address used in SMASE
	!RAM_SMW_Misc_StartOfStack #= !Define_SMW_LowRAMLocation+$01FF
; OAM table. Used to handle all sprite tile data, with 128 slots for tiles.
; Generally, the table is indexed from either $0200 or $0300, with $0300
; being used for normal sprites (and Mario) and $0200 being used for various
; other sprite types. Tiles are drawn to the screen from top to bottom of
; the table; that is, a sprite in slot 0 will always appear visually in
; front of a sprite in slot 1. The table actually consists of two
; sub-tables: $0200-$03FF (512 bytes): Each slot gets four bytes in the
; order of: X position, Y position, tile number, YXPPCCCT. Unused tiles are
; generally marked by giving them a Y position of #$F0 (i.e. offscreen).
; $0400-$041F (32 bytes): Each slot gets 2 bits %SX , with the X bit used to
; handle a 9th bit of the X position (for handling sprite tiles that go past
; the left edge of the screen) and the S bit acting as a "size bit" which
; (generally) controls whether the tile is 8x8 (0) or 16x16 (1). Since each
; tile only requires 2 bits, each byte of this table actually handles four
; separate tiles; see the details table for more information. It is not
; recommended that you write to this table directly, though, and you should
; use the table at $0420 instead. The routine at $008494 is responsible for
; then packing the data from that table back into $0400. See details for a
; more-detailed map of the gane's slot usage.
!RAM_SMW_IO_OAMBuffer #= !Define_SMW_LowRAMLocation+$0200
