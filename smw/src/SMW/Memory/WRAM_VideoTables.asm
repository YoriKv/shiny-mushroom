;--- Video tables - $7E0400-$7E0AF4
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.

; OAM extra bits table, with one byte per OAM tile. Used to generate the
; packed table at $0400 during the routine at $008494. Format: %000000SX S -
; Size. Generally, 0 = 8x8, 1 = 16x16. X - Bit 9 of the tile's X position.
; Used to allow tiles to be positioned beyond the left edge of the screen.
; All other bits must remain 0. Sprites can either manually write the
; necessary information here, or they can use the routine at $01B7BE to take
; care of it.
!RAM_SMW_Sprites_OAMTileSizeBuffer #= !Define_SMW_LowRAMLocation+$0420
; HDMA table for windowing effects, such as with the keyhole, level ending
; and titlescreen.
!RAM_SMW_Misc_HDMAWindowEffectTable #= !Define_SMW_LowRAMLocation+$04A0						; $0004A0-$00067F
; Determines which of the three dynamic palette upload tables is being used.
; 00 = $0682; used for most purposes (e.g. the fade effects for the
; Magikoopa, Boo boss, and reappearing ghosts, as well as Bowser's lightning
; effect). 03 = $0905; used for the end-of-level fade, as well as fading
; overworld paths. 06 = $0703; used when switching submaps.
!RAM_SMW_Palettes_PaletteUploadTableIndex #= !Define_SMW_LowRAMLocation+$0680
; Current index to the dynamic palette upload table at $0682.
!RAM_SMW_Palettes_DynamicPaletteUploadIndex #= !Define_SMW_LowRAMLocation+$0681
; Dynamic palette upload table, used for various things like the
; Magikoopa/Boo Boss' fade effects or Bowser's lightning. The current length
; of the table can be obtained from $0681. Each entry starts with a 2-byte
; header; the first byte is the number of bytes to transfer (02 = 1 color),
; and the second is the color ID to start at. Following this, each of the
; 16-bit colors should be written. When adding a new entry, a 00 should be
; written afterwards as a terminator, and $0681 should be updated with the
; new length. This table doesn't actually have to end at $0694, but SMW
; never goes beyond this. As such, the area after this address is listed as
; "empty".
!RAM_SMW_Palettes_DynamicPaletteBytesToUpload #= !Define_SMW_LowRAMLocation+$0682						; Note: Due to how this works, $000682, $000703 and $000905 must all be in the $000000-$001FFF range
!RAM_SMW_Palettes_DynamicPaletteCGRAMAddress #= !RAM_SMW_Palettes_DynamicPaletteBytesToUpload+$01
!RAM_SMW_Palettes_DynamicPaletteColors #= !RAM_SMW_Palettes_DynamicPaletteBytesToUpload+$02
;Empty $000695-$000700
; Background color. Used during gameplay in conjunction with $2132.
!RAM_SMW_Palettes_BackgroundColorLo #= !Define_SMW_LowRAMLocation+$0701
!RAM_SMW_Palettes_BackgroundColorHi #= !RAM_SMW_Palettes_BackgroundColorLo+$01
; The entire palette. It is only uploaded to CGRAM during the level loading
; routine. Also used during overworld load, but not all of it.
!RAM_SMW_Palettes_PaletteMirror #= !RAM_SMW_Palettes_BackgroundColorLo+$02
; Copy of the background color at $0701.
!RAM_SMW_Palettes_CopyOfBackgroundColorLo #= !Define_SMW_LowRAMLocation+$0903
!RAM_SMW_Palettes_CopyOfBackgroundColorHi #= !RAM_SMW_Palettes_CopyOfBackgroundColorLo+$01
; Copy of palettes 0-F from $0703-$08F2. The original game only includes the
; first half of palette F (i.e. up to and including color F7). It is used in
; overworld path events fading in ($04EAA0), and level ending fade in/out
; ($00AF9D). Lunar Magic may expand this up through $0B05 to include the
; entirety of palette F in order to support palette ExAnimations.
!RAM_SMW_Palettes_CopyOfPaletteMirror #= !RAM_SMW_Palettes_CopyOfBackgroundColorLo+$02
