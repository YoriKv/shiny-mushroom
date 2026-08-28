@includeonce

; INIDISP - Screen Display x---bbbb x = Force blank on when set. bbbb =
; Screen brightness, F=max, 0="off". Note that force blank CAN be disabled
; mid-scanline. However, this can result in glitched graphics on that
; scanline, as the internal rendering buffers will not have been updated
; during force blank. Current theory is that BGs will be glitched for a few
; tiles (depending on how far in advance the PPU operates), and OBJ will be
; glitched for the entire scanline. Also, writing this register on the first
; line of V-Blank (225 or 240, depending on overscan) when force blank is
; currently active causes the OAM Address Reset to occur.
!REGISTER_ScreenDisplayRegister = $002100
	!ScreenDisplayRegister_MinBrightness00 = $00			;\ Screen brightness
	!ScreenDisplayRegister_Brightness01 = $01			;|
	!ScreenDisplayRegister_Brightness02 = $02			;|
	!ScreenDisplayRegister_Brightness03 = $03			;|
	!ScreenDisplayRegister_Brightness04 = $04			;|
	!ScreenDisplayRegister_Brightness05 = $05			;|
	!ScreenDisplayRegister_Brightness06 = $06			;|
	!ScreenDisplayRegister_Brightness07 = $07			;|
	!ScreenDisplayRegister_Brightness08 = $08			;|
	!ScreenDisplayRegister_Brightness09 = $09			;|
	!ScreenDisplayRegister_Brightness0A = $0A			;|
	!ScreenDisplayRegister_Brightness0B = $0B			;|
	!ScreenDisplayRegister_Brightness0C = $0C			;|
	!ScreenDisplayRegister_Brightness0D = $0D			;|
	!ScreenDisplayRegister_Brightness0E = $0E			;|
	!ScreenDisplayRegister_MaxBrightness0F = $0F			;/
	!ScreenDisplayRegister_SetForceBlank = $80
; OBSEL - Object Size and Chr Address sssnnbbb sss = Object size: 000 = 8x8
; and 16x16 sprites 001 = 8x8 and 32x32 sprites 010 = 8x8 and 64x64 sprites
; 011 = 16x16 and 32x32 sprites 100 = 16x16 and 64x64 sprites 101 = 32x32
; and 64x64 sprites 110 = 16x32 and 32x64 sprites ('undocumented') 111 =
; 16x32 and 32x32 sprites ('undocumented') nn = Name Select bbb = Name Base
; Select (Addr>>14) See the section "SPRITES" below for details.
!REGISTER_OAMSizeAndDataAreaDesignation = $002101
	!SpriteGFXLocationInVRAMLo_0000 = $00				;\ Location of the first half of the sprite graphics in VRAM.
	!SpriteGFXLocationInVRAMLo_2000 = $01				;| Note that the SNES does not have enough VRAM for the last 4 settings to work as expected
	!SpriteGFXLocationInVRAMLo_4000 = $02				;| Don't use them unless you're using an emulator build/flashcart/custom made cartridge that supports 128 KB of VRAM
	!SpriteGFXLocationInVRAMLo_6000 = $03				;|
	!SpriteGFXLocationInVRAMLo_8000 = $04				;| 
	!SpriteGFXLocationInVRAMLo_A000 = $05				;|
	!SpriteGFXLocationInVRAMLo_C000 = $06				;|
	!SpriteGFXLocationInVRAMLo_E000 = $07				;/
	!SpriteGFXLocationInVRAMHi_Add1000 = $00			;\ Location of the second half of the sprite graphics in VRAM in relation to the first half
	!SpriteGFXLocationInVRAMHi_Add2000 = $08			;|
	!SpriteGFXLocationInVRAMHi_Add3000 = $10			;|
	!SpriteGFXLocationInVRAMHi_Add4000 = $18			;/
	!SpriteSize_8x8_16x16 = $00					;\ The sizes to use for sprites. The last two are not recommended to use.
	!SpriteSize_8x8_32x32 = $20					;|
	!SpriteSize_8x8_64x64 = $40					;|
	!SpriteSize_16x16_32x32 = $60					;|
	!SpriteSize_16x16_64x64 = $80					;|
	!SpriteSize_32x32_64x64 = $A0					;|
	!SpriteSize_16x32_32x64 = $C0					;|
	!SpriteSize_16x32_32x32 = $E0					;/
; wl++?- OAMADDL - OAM Address low byte wh++?- OAMADDH - OAM Address high
; bit and Obj Priority p------b aaaaaaaa p = Obj Priority activation bit
; When this bit is set, an Obj other than Sprite 0 may be given priority.
; See the section "SPRITES" below for details. b aaaaaaaa = OAM address This
; can be thought of in two ways, depending on your conception of OAM. If you
; consider OAM as a 544-byte table, baaaaaaaa is the word address into that
; table. If you consider OAM to be a 512-byte table and a 32-byte table, b
; is the table selector and aaaaaaaa is the word address in the table. See
; the section "SPRITES" below for details. The internal OAM address is
; invalidated when scanlines are being rendered. This invalidation is
; deterministic, but we do not know how it is determined. Thus, the last
; value written to these registers is reloaded into the internal OAM address
; at the beginning of V-Blank if that occurs outside of a force-blank
; period. This is known as 'OAM reset'. 'OAM reset' also occurs on certain
; writes to $2100. Writing to either $2102 or $2103 resets the entire
; internal OAM Address to the values last written to this register. E.g., if
; you set $104 to this register, write 4 bytes, then write $1 to $2103, the
; internal OAM address will point to word 4, not word 6.
!REGISTER_OAMAddressLo = $002102
!REGISTER_OAMAddressHi = $002103
; OAMDATA - Data for OAM write dddddddd Note that OAM writes are done in an
; odd manner, in particular the low table of OAM is not affected until the
; high byte of a word is written (however, the high table is affected
; immediately). Thus, if you set the address, then alternate writes and
; reads, OAM will never be affected until you reach the high table!
; Similarly, if you set the address to 0, then write 1, 2, read, then write
; 3, OAM will end up as "01 02 01 03", rather than "01 02 xx 03" as you
; might expect. Technically, this register CAN be written during H-blank
; (and probably mid-scanline as well). However, due to OAM address
; invalidation, the actual OAM byte written will probably not be what you
; expect. Note that writing during force-blank will only work as expected if
; that force-blank was begun during V-Blank, or (probably) if $2102/3 have
; been reset during that force-blank period. See the section "SPRITES" below
; for details.
!REGISTER_OAMDataWritePort = $002104
; BGMODE - BG Mode and Character Size DCBAemmm A/B/C/D = BG character size
; for BG1/BG2/BG3/BG4 If the bit is set, then the BG is made of 16x16 tiles.
; Otherwise, 8x8 tiles are used. However, note that Modes 5 and 6 always use
; 16-pixel wide tiles, and Mode 7 always uses 8x8 tiles. See the section
; "BACKGROUNDS" below for details. mmm = BG Mode e = Mode 1 BG3 priority bit
; Mode BG depth OPT Priorities 1 2 3 4 Front -> Back
; -=-------=-=-=-=----=---============--- 0 2 2 2 2 n 3AB2ab1CD0cd 1 4 4 2 n
; 3AB2ab1C 0c * if e set: C3AB2ab1 0c 2 4 4 y 3A 2B 1a 0b 3 8 4 n 3A 2B 1a
; 0b 4 8 2 y 3A 2B 1a 0b 5 4 2 n 3A 2B 1a 0b 6 4 y 3A 2 1a 0 7 8 n 3 2 1a 0
; 7+EXTBG 8 7 n 3 2B 1a 0b "OPT" means "Offset-per-tile mode". For the
; priorities, numbers mean sprites with that priority. Letters correspond to
; BGs (A=1, B=2, etc), with upper/lower case indicating tile priority 1/0.
; See the section "BACKGROUNDS" below for details. Mode 7's EXTBG mode
; allows you to enable BG2, which uses the same tilemap and character data
; as BG1 but interprets bit 7 of the pixel data as a priority bit. BG2 also
; has some oddness to do with some of the per-BG registers below. See the
; Mode 7 section under BACKGROUNDS for details.
!REGISTER_BGModeAndTileSizeSetting = $002105
	!BGModeAndTileSizeSetting_Mode00Enable = $00
	!BGModeAndTileSizeSetting_Mode01Enable = $01
	!BGModeAndTileSizeSetting_Mode02Enable = $02
	!BGModeAndTileSizeSetting_Mode03Enable = $03
	!BGModeAndTileSizeSetting_Mode04Enable = $04
	!BGModeAndTileSizeSetting_Mode05Enable = $05
	!BGModeAndTileSizeSetting_Mode06Enable = $06
	!BGModeAndTileSizeSetting_Mode07Enable = $07
	!BGModeAndTileSizeSetting_Mode01Layer3Priority = $08
	!BGModeAndTileSizeSetting_Use16x16Layer1Tiles = $10
	!BGModeAndTileSizeSetting_Use16x16Layer2Tiles = $20
	!BGModeAndTileSizeSetting_Use16x16Layer3Tiles = $40
	!BGModeAndTileSizeSetting_Use16x16Layer4Tiles = $80
; MOSAIC - Screen Pixelation xxxxDCBA A/B/C/D = Affect BG1/BG2/BG3/BG4 xxxx
; = pixel size, 0=1x1, F=16x16 The mosaic filter goes over the BG and covers
; each x-by-x square with the upper-left pixel of that square, with the top
; of the first row of squares on the 'starting scanline'. If this register
; is set during the frame, the 'starting scanline' is the current scanline,
; otherwise it is the first visible scanline of the frame. I.e. if even
; scanlines are completely red and odd scanlines are completely blue,
; setting the xxxx=1 mid-frame will make the rest of the screen either
; completely red or completely blue depending on whether you set xxxx on an
; even or an odd scanline. XXX: It seems that writing the same value to this
; register does not reset the 'starting scanline', but which changes do
; reset it? Note that mosaic is applied after scrolling, but before any clip
; windows, color windows, or math. So the XxX block can be partially
; clipped, and it can be mathed as normal with a non-mosaiced BG. But
; scrolling can't make it partially one color and partially another. Modes
; 5-6 should 'double' the expansion factor to expand half-pixels. This
; actually makes xxxx=0 have a visible effect, since the even half-pixels
; (usually on the subscreen) hide the odd half-pixels. The same thing
; happens vertically with interlace mode. Mode 7, of course, is weird. BG1
; mosaics about like normal, as long as you remember that the Mode 7
; transformations have no effect on the XxX blocks. BG2 uses bit A to
; control 'vertical mosaic' and bit B to control 'horizontal mosaic', so you
; could be expanding over 1xX, Xx1, or XxX blocks. This can get really
; interesting as BG1 still uses bit A as normal, so you could have the BG1
; pixels expanded XxX with high-priority BG2 pixels expanded 1xX on top of
; them. See the section "BACKGROUNDS" below for details.
!REGISTER_MosaicSizeAndBGEnable = $002106
	!MosaicSizeAndBGEnable_Layer1 = $01
	!MosaicSizeAndBGEnable_Layer2 = $02
	!MosaicSizeAndBGEnable_Layer3 = $04
	!MosaicSizeAndBGEnable_Layer4 = $08
	!MosaicSizeAndBGEnable_PixelSize1x1 = $00
	!MosaicSizeAndBGEnable_PixelSize2x2 = $10
	!MosaicSizeAndBGEnable_PixelSize3x3 = $20
	!MosaicSizeAndBGEnable_PixelSize4x4 = $30
	!MosaicSizeAndBGEnable_PixelSize5x5 = $40
	!MosaicSizeAndBGEnable_PixelSize6x6 = $50
	!MosaicSizeAndBGEnable_PixelSize7x7 = $60
	!MosaicSizeAndBGEnable_PixelSize8x8 = $70
	!MosaicSizeAndBGEnable_PixelSize9x9 = $80
	!MosaicSizeAndBGEnable_PixelSize10x10 = $90
	!MosaicSizeAndBGEnable_PixelSize11x11 = $A0
	!MosaicSizeAndBGEnable_PixelSize12x12 = $B0
	!MosaicSizeAndBGEnable_PixelSize13x13 = $C0
	!MosaicSizeAndBGEnable_PixelSize14x14 = $D0
	!MosaicSizeAndBGEnable_PixelSize15x15 = $E0
	!MosaicSizeAndBGEnable_PixelSize16x16 = $F0
; BG1SC - BG1 Tilemap Address and Size wb++?- BG2SC - BG2 Tilemap Address
; and Size wb++?- BG3SC - BG3 Tilemap Address and Size wb++?- BG4SC - BG4
; Tilemap Address and Size aaaaaayx aaaaaa = Tilemap address in VRAM
; (Addr>>10) x = Tilemap horizontal mirroring y = Tilemap veritcal mirroring
; All tilemaps are 32x32 tiles. If x and y are both unset, there is one
; tilemap at Addr. If x is set, a second tilemap follows the first that
; should be considered "to the right of" the first. If y is set, a second
; tilemap follows the first that should be considered "below" the first. If
; both are set, then a second follows "to the right", then a third "below",
; and a fourth "below and to the right". See the section "BACKGROUNDS" below
; for more details.
!REGISTER_BG1AddressAndSize = $002107
!REGISTER_BG2AddressAndSize = $002108
!REGISTER_BG3AddressAndSize = $002109
!REGISTER_BG4AddressAndSize = $00210A
	!BGXAddressAndSize_EnableXMirroring = $01
	!BGXAddressAndSize_EnableYMirroring = $02
	!BGXAddressAndSize_VRAMAddr000000 = $00
	!BGXAddressAndSize_VRAMAddr000800 = $04
	!BGXAddressAndSize_VRAMAddr001000 = $08
	!BGXAddressAndSize_VRAMAddr001800 = $0C
	!BGXAddressAndSize_VRAMAddr002000 = $10
	!BGXAddressAndSize_VRAMAddr002800 = $14
	!BGXAddressAndSize_VRAMAddr003000 = $18
	!BGXAddressAndSize_VRAMAddr003800 = $1C
	!BGXAddressAndSize_VRAMAddr004000 = $20
	!BGXAddressAndSize_VRAMAddr004800 = $24
	!BGXAddressAndSize_VRAMAddr005000 = $28
	!BGXAddressAndSize_VRAMAddr005800 = $2C
	!BGXAddressAndSize_VRAMAddr006000 = $30
	!BGXAddressAndSize_VRAMAddr006800 = $34
	!BGXAddressAndSize_VRAMAddr007000 = $38
	!BGXAddressAndSize_VRAMAddr007800 = $3C
	!BGXAddressAndSize_VRAMAddr008000 = $40
	!BGXAddressAndSize_VRAMAddr008800 = $44
	!BGXAddressAndSize_VRAMAddr009000 = $48
	!BGXAddressAndSize_VRAMAddr009800 = $4C
	!BGXAddressAndSize_VRAMAddr00A000 = $50
	!BGXAddressAndSize_VRAMAddr00A800 = $54
	!BGXAddressAndSize_VRAMAddr00B000 = $58
	!BGXAddressAndSize_VRAMAddr00B800 = $5C
	!BGXAddressAndSize_VRAMAddr00C000 = $60
	!BGXAddressAndSize_VRAMAddr00C800 = $64
	!BGXAddressAndSize_VRAMAddr00D000 = $68
	!BGXAddressAndSize_VRAMAddr00D800 = $6C
	!BGXAddressAndSize_VRAMAddr00E000 = $70
	!BGXAddressAndSize_VRAMAddr00E800 = $74
	!BGXAddressAndSize_VRAMAddr00F000 = $78
	!BGXAddressAndSize_VRAMAddr00F800 = $7C
	!BGXAddressAndSize_VRAMAddr010000 = $80								;\ Note: The SNES only has 64 KB of VRAM, so these settings go unused.
	!BGXAddressAndSize_VRAMAddr010800 = $84								;|
	!BGXAddressAndSize_VRAMAddr011000 = $88								;|
	!BGXAddressAndSize_VRAMAddr011800 = $8C								;|
	!BGXAddressAndSize_VRAMAddr012000 = $90								;|
	!BGXAddressAndSize_VRAMAddr012800 = $94								;|
	!BGXAddressAndSize_VRAMAddr013000 = $98								;|
	!BGXAddressAndSize_VRAMAddr013800 = $9C								;|
	!BGXAddressAndSize_VRAMAddr014000 = $A0								;|
	!BGXAddressAndSize_VRAMAddr014800 = $A4								;|
	!BGXAddressAndSize_VRAMAddr015000 = $A8								;|
	!BGXAddressAndSize_VRAMAddr015800 = $AC								;|
	!BGXAddressAndSize_VRAMAddr016000 = $B0								;|
	!BGXAddressAndSize_VRAMAddr016800 = $B4								;|
	!BGXAddressAndSize_VRAMAddr017000 = $B8								;|
	!BGXAddressAndSize_VRAMAddr017800 = $BC								;|
	!BGXAddressAndSize_VRAMAddr018000 = $C0								;|
	!BGXAddressAndSize_VRAMAddr018800 = $C4								;|
	!BGXAddressAndSize_VRAMAddr019000 = $C8								;|
	!BGXAddressAndSize_VRAMAddr019800 = $CC								;|
	!BGXAddressAndSize_VRAMAddr01A000 = $D0								;|
	!BGXAddressAndSize_VRAMAddr01A800 = $D4								;|
	!BGXAddressAndSize_VRAMAddr01B000 = $D8								;|
	!BGXAddressAndSize_VRAMAddr01B800 = $DC								;|
	!BGXAddressAndSize_VRAMAddr01C000 = $E0								;|
	!BGXAddressAndSize_VRAMAddr01C800 = $E4								;|
	!BGXAddressAndSize_VRAMAddr01D000 = $E8								;|
	!BGXAddressAndSize_VRAMAddr01D800 = $EC								;|
	!BGXAddressAndSize_VRAMAddr01E000 = $F0								;|
	!BGXAddressAndSize_VRAMAddr01E800 = $F4								;|
	!BGXAddressAndSize_VRAMAddr01F000 = $F8								;|
	!BGXAddressAndSize_VRAMAddr01F800 = $FC								;/

; BG12NBA - BG1 and 2 Chr Address wb++?- BG34NBA - BG3 and 4 Chr Address
; bbbbaaaa aaaa = Base address for BG1/3 (Addr>>13) bbbb = Base address for
; BG2/4 (Addr>>13) See the section "BACKGROUNDS" below for details.
!REGISTER_BG1And2TileDataDesignation = $00210B
	!BG1And2TileDataDesignation_Layer1Addr000000 = $00
	!BG1And2TileDataDesignation_Layer1Addr002000 = $01
	!BG1And2TileDataDesignation_Layer1Addr004000 = $02
	!BG1And2TileDataDesignation_Layer1Addr006000 = $03
	!BG1And2TileDataDesignation_Layer1Addr008000 = $04
	!BG1And2TileDataDesignation_Layer1Addr00A000 = $05
	!BG1And2TileDataDesignation_Layer1Addr00C000 = $06
	!BG1And2TileDataDesignation_Layer1Addr00E000 = $07
	!BG1And2TileDataDesignation_Layer1Addr010000 = $08						;\ Note: The SNES only has 64 KB of VRAM, so these settings go unused.
	!BG1And2TileDataDesignation_Layer1Addr012000 = $09						;|
	!BG1And2TileDataDesignation_Layer1Addr014000 = $0A						;|
	!BG1And2TileDataDesignation_Layer1Addr016000 = $0B						;|
	!BG1And2TileDataDesignation_Layer1Addr018000 = $0C						;|
	!BG1And2TileDataDesignation_Layer1Addr01A000 = $0D						;|
	!BG1And2TileDataDesignation_Layer1Addr01C000 = $0E						;|
	!BG1And2TileDataDesignation_Layer1Addr01E000 = $0F						;/
	!BG1And2TileDataDesignation_Layer2Addr000000 = $00
	!BG1And2TileDataDesignation_Layer2Addr002000 = $10
	!BG1And2TileDataDesignation_Layer2Addr004000 = $20
	!BG1And2TileDataDesignation_Layer2Addr006000 = $30
	!BG1And2TileDataDesignation_Layer2Addr008000 = $40
	!BG1And2TileDataDesignation_Layer2Addr00A000 = $50
	!BG1And2TileDataDesignation_Layer2Addr00C000 = $60
	!BG1And2TileDataDesignation_Layer2Addr00E000 = $70
	!BG1And2TileDataDesignation_Layer2Addr010000 = $80						;\ Note: The SNES only has 64 KB of VRAM, so these settings go unused.
	!BG1And2TileDataDesignation_Layer2Addr012000 = $90						;|
	!BG1And2TileDataDesignation_Layer2Addr014000 = $A0						;|
	!BG1And2TileDataDesignation_Layer2Addr016000 = $B0						;|
	!BG1And2TileDataDesignation_Layer2Addr018000 = $C0						;|
	!BG1And2TileDataDesignation_Layer2Addr01A000 = $D0						;|
	!BG1And2TileDataDesignation_Layer2Addr01C000 = $E0						;|
	!BG1And2TileDataDesignation_Layer2Addr01E000 = $F0						;/
!REGISTER_BG3And4TileDataDesignation = $00210C
	!BG1And2TileDataDesignation_Layer3Addr000000 = $00
	!BG1And2TileDataDesignation_Layer3Addr002000 = $01
	!BG1And2TileDataDesignation_Layer3Addr004000 = $02
	!BG1And2TileDataDesignation_Layer3Addr006000 = $03
	!BG1And2TileDataDesignation_Layer3Addr008000 = $04
	!BG1And2TileDataDesignation_Layer3Addr00A000 = $05
	!BG1And2TileDataDesignation_Layer3Addr00C000 = $06
	!BG1And2TileDataDesignation_Layer3Addr00E000 = $07
	!BG1And2TileDataDesignation_Layer3Addr010000 = $08						;\ Note: The SNES only has 64 KB of VRAM, so these settings go unused.
	!BG1And2TileDataDesignation_Layer3Addr012000 = $09						;|
	!BG1And2TileDataDesignation_Layer3Addr014000 = $0A						;|
	!BG1And2TileDataDesignation_Layer3Addr016000 = $0B						;|
	!BG1And2TileDataDesignation_Layer3Addr018000 = $0C						;|
	!BG1And2TileDataDesignation_Layer3Addr01A000 = $0D						;|
	!BG1And2TileDataDesignation_Layer3Addr01C000 = $0E						;|
	!BG1And2TileDataDesignation_Layer3Addr01E000 = $0F						;/
	!BG1And2TileDataDesignation_Layer4Addr000000 = $00
	!BG1And2TileDataDesignation_Layer4Addr002000 = $10
	!BG1And2TileDataDesignation_Layer4Addr004000 = $20
	!BG1And2TileDataDesignation_Layer4Addr006000 = $30
	!BG1And2TileDataDesignation_Layer4Addr008000 = $40
	!BG1And2TileDataDesignation_Layer4Addr00A000 = $50
	!BG1And2TileDataDesignation_Layer4Addr00C000 = $60
	!BG1And2TileDataDesignation_Layer4Addr00E000 = $70
	!BG1And2TileDataDesignation_Layer4Addr010000 = $80						;\ Note: The SNES only has 64 KB of VRAM, so these settings go unused.
	!BG1And2TileDataDesignation_Layer4Addr012000 = $90						;|
	!BG1And2TileDataDesignation_Layer4Addr014000 = $A0						;|
	!BG1And2TileDataDesignation_Layer4Addr016000 = $B0						;|
	!BG1And2TileDataDesignation_Layer4Addr018000 = $C0						;|
	!BG1And2TileDataDesignation_Layer4Addr01A000 = $D0						;|
	!BG1And2TileDataDesignation_Layer4Addr01C000 = $E0						;|
	!BG1And2TileDataDesignation_Layer4Addr01E000 = $F0						;/
; BG1HOFS - BG1 Horizontal Scroll ww+++- M7HOFS - Mode 7 BG Horizontal
; Scroll ww+++- BG1VOFS - BG1 Vertical Scroll ww+++- M7VOFS - Mode 7 BG
; Vertical Scroll ------xx xxxxxxxx ---mmmmm mmmmmmmm x = The BG offset, 10
; bits. m = The Mode 7 BG offset, 13 bits two's-complement signed. These are
; actually two registers in one (or would that be "4 registers in 2"?).
; Anyway, writing $210d will write both BG1HOFS which works exactly like the
; rest of the BGnxOFS registers below ($210f-$2114), and M7HOFS which works
; with the M7* registers ($211b-$2120) instead. Modes 0-6 use BG1xOFS and
; ignore M7xOFS, while Mode 7 uses M7xOFS and ignores BG1HOFS. See the
; appropriate sections below for details, and note the different formulas
; for BG1HOFS versus M7HOFS.
!REGISTER_BG1HorizScrollOffset = $00210D
!REGISTER_BG1VertScrollOffset = $00210E
; BG2HOFS - BG2 Horizontal Scroll ww+++- BG2VOFS - BG2 Vertical Scroll
; ww+++- BG3HOFS - BG3 Horizontal Scroll ww+++- BG3VOFS - BG3 Vertical
; Scroll ww+++- BG4HOFS - BG4 Horizontal Scroll ww+++- BG4VOFS - BG4
; Vertical Scroll ------xx xxxxxxxx Note that these are "write twice"
; registers, first the low byte is written then the high. Current theory is
; that writes to the register work like this: BGnHOFS = (Current<<8) |
; (Prev&~7) | ((Reg>>8)&7); Prev = Current; or BGnVOFS = (Current<<8) |
; Prev; Prev = Current; Note that there is only one Prev shared by all the
; BGnxOFS registers. This is NOT shared with the M7* registers (not even
; M7xOFS and BG1xOFS). x = The BG offset, at most 10 bits (some modes
; effectively use as few as 8). Note that all BGs wrap if you try to go past
; their edges. Thus, the maximum offset value in BG Modes 0-6 is 1023, since
; you have at most 64 tiles (if x/y of BGnSC is set) of 16 pixels each (if
; the appropriate bit of BGMODE is set). Horizontal scrolling scrolls in
; units of full pixels no matter if we're rendering a 256-pixel wide screen
; or a 512-half-pixel wide screen. However, vertical scrolling will move in
; half-line increments if interlace mode is active. See the section
; "BACKGROUNDS" below for details.
!REGISTER_BG2HorizScrollOffset = $00210F
!REGISTER_BG2VertScrollOffset = $002110
!REGISTER_BG3HorizScrollOffset = $002111
!REGISTER_BG3VertScrollOffset = $002112
!REGISTER_BG4HorizScrollOffset = $002113
!REGISTER_BG4VertScrollOffset = $002114
; VMAIN - Video Port Control i---mmii i = Address increment mode: 0 =>
; increment after writing $2118/reading $2139 1 => increment after writing
; $2119/reading $213a Note that a word write stores low first, then high.
; Thus, if you're storing a word value to $2118/9, you'll probably want to
; set 1 here. ii = Address increment amount 00 = Normal increment by 1 01 =
; Increment by 32 10 = Increment by 128 11 = Increment by 128 mm = Address
; remapping 00 = No remapping 01 = Remap addressing aaaaaaaaBBBccccc =>
; aaaaaaaacccccBBB 10 = Remap addressing aaaaaaaBBBcccccc =>
; aaaaaaaccccccBBB 11 = Remap addressing aaaaaaBBBccccccc =>
; aaaaaacccccccBBB The "remap" modes basically implement address
; translation. If $2116/7 are set to #$0003, then word address #$0018 will
; be written instead, and $2116/7 will be incremented to $0004.
!REGISTER_VRAMAddressIncrementValue = $002115
	!VRAMAddressIncrementValue_IncrementBy01 = $00
	!VRAMAddressIncrementValue_IncrementBy20 = $01
	!VRAMAddressIncrementValue_IncrementBy80 = $02
	!VRAMAddressIncrementValue_CopyOfIncrementBy80 = $03
	!VRAMAddressIncrementValue_IncrementOnLoByte = $00
	!VRAMAddressIncrementValue_IncrementOnHiByte = $80
	!VRAMAddressIncrementValue_NoAddrRemap = $00
	!VRAMAddressIncrementValue_08BitRotate = $04			;\ Note: These are intended for 4 color, 16 color, and 256 color bitmaps respectively.
	!VRAMAddressIncrementValue_09BitRotate = $08			;|
	!VRAMAddressIncrementValue_10BitRotate = $0A			;/
; wl++?- VMADDL - VRAM Address low byte wh++?- VMADDH - VRAM Address high
; byte aaaaaaaa aaaaaaaa This sets the address for $2118/9 and $2139/a. Note
; that this is a word address, not a byte address! See the sections
; "BACKGROUNDS" and "SPRITES" below for details.
!REGISTER_VRAMAddressLo = $002116
!REGISTER_VRAMAddressHi = $002117
; wl++-- VMDATAL - VRAM Data Write low byte wh++-- VMDATAH - VRAM Data Write
; high byte xxxxxxxx xxxxxxxx This writes data to VRAM. The writes take
; effect immediately(?), even if no increment is performed. The address is
; incremented when one of the two bytes is written; which one depends on the
; setting of bit 7 of register $2115. Keep in mind the address translation
; bits of $2115 as well. The interaction between these registers and $2139/a
; is unknown. See the sections "BACKGROUNDS" and "SPRITES" below for
; details.
!REGISTER_WriteToVRAMPortLo = $002118
!REGISTER_WriteToVRAMPortHi = $002119
; M7SEL - Mode 7 Settings rc----yx r = Playing field size: When clear, the
; playing field is 1024x1024 pixels (so the tilemap completely fills it).
; When set, the playing field is much larger, and the 'empty space' fill is
; controlled by bit 6. c = Empty space fill, when bit 7 is set: 0 =
; Transparent. 1 = Fill with character 0. Note that the fill is matrix
; transformed like all other Mode 7 tiles. x/y = Horizontal/Veritcal
; mirroring. If the bit is set, flip the 256x256 pixel 'screen' in that
; direction. See the section "BACKGROUNDS" below for details.
!REGISTER_Mode7TilemapSettings = $00211A
	!Mode7TilemapSettings_EnableXMirroring = $01
	!Mode7TilemapSettings_EnableYMirroring = $02
	!Mode7TilemapSettings_WrapTilemap = $00
	!Mode7TilemapSettings_CopyOfWrapTilemap = $40
	!Mode7TilemapSettings_TransparentBlankArea = $80
	!Mode7TilemapSettings_FillBlankAreaWithTile00 = $C0
; M7A - Mode 7 Matrix A (also used with $2134/6) ww+++- M7B - Mode 7 Matrix
; B (also used with $2134/6) ww+++- M7C - Mode 7 Matrix C ww+++- M7D - Mode
; 7 Matrix D aaaaaaaa aaaaaaaa Note that these are "write twice" registers,
; first the low byte is written then the high. Current theory is that writes
; to the register work like this: Reg = (Current<<8) | Prev; Prev = Current;
; Note that there is only one Prev shared by all these registers. This Prev
; is NOT shared with the BGnxOFS registers, but it IS shared with the M7xOFS
; registers. These set the matrix parameters for Mode 7. The values are an
; 8-bit fixed point, i.e. the value should be divided by 256.0 when used in
; calculations. The product A*(B>>8) may be read from registers $2134/6.
; There is supposedly no important delay. It may not be operative during
; Mode 7 rendering. See the section "BACKGROUNDS" below for details.
!REGISTER_Mode7MatrixParameterA = $00211B
!REGISTER_Mode7MatrixParameterB = $00211C
!REGISTER_Mode7MatrixParameterC = $00211D
!REGISTER_Mode7MatrixParameterD = $00211E
; M7X - Mode 7 Center X ww+++- M7Y - Mode 7 Center Y ---xxxxx xxxxxxxx Note
; that these are "write twice" registers, like the other M7* registers. See
; above for the write semantics. The value is 13 bit two's-complement
; signed. The matrix transformation formula is: [ X ] [ A B ] [ SX + M7HOFS
; - CX ] [ CX ] [ ] = [ ] * [ ] + [ ] [ Y ] [ C D ] [ SY + M7VOFS - CY ] [
; CY ] Note: SX/SY are screen coordinates. X/Y are coordinates in the
; playing field from which the pixel is taken. If $211a bit 7 is clear, the
; result is then restricted to 0<=X<=1023 and 0<=Y<=1023. If $211a bits 6
; and 7 are both set and X or Y is less than 0 or greater than 1023, use the
; low 3 bits of each to choose the pixel from character 0. The bit-accurate
; formula seems to be something along the lines of: #define CLIP(a)
; (((a)&0x2000)?((a)|~0x3ff):((a)&0x3ff)) X[0,y] = ((A*CLIP(HOFS-CX))&~63) +
; ((B*y)&~63) + ((B*CLIP(VOFS-CY))&~63) + (CX<<8) Y[0,y] =
; ((C*CLIP(HOFS-CX))&~63) + ((D*y)&~63) + ((D*CLIP(VOFS-CY))&~63) + (CY<<8)
; X[x,y] = X[x-1,y] + A Y[x,y] = Y[x-1,y] + C (In all cases, X[] and Y[] are
; fixed point with 8 bits of fraction) See the section "BACKGROUNDS" below
; for details.
!REGISTER_Mode7CenterX = $00211F
!REGISTER_Mode7CenterY = $002120
; CGADD - CGRAM Address cccccccc This sets the word address (i.e. color)
; which will be affected by $2122 and $213b.
!REGISTER_CGRAMAddress = $002121
; CGDATA - CGRAM Data write -bbbbbgg gggrrrrr This writes to CGRAM,
; effectively setting the palette colors. Accesses to CGRAM are handled just
; like accesses to the low table of OAM, see $2104 for details. Note that
; the color values are stored in BGR order.
!REGISTER_WriteToCGRAMPort = $002122
; W12SEL - Window Mask Settings for BG1 and BG2 wb+++- W34SEL - Window Mask
; Settings for BG3 and BG4 wb+++- WOBJSEL - Window Mask Settings for OBJ and
; Color Window ABCDabcd c = Enable window 1 for BG1/BG3/OBJ a = Enable
; window 2 for BG1/BG3/OBJ C/A = Enable window 1/2 for BG2/BG4/Color When
; the bit is set, the corresponding window will affect the corresponding
; background (subject to the settings of $212e/f). d = Window 1 Inversion
; for BG1/BG3/OBJ b = Window 2 Inversion for BG1/BG3/OBJ D/B = Window 1/2
; Inversion for BG2/BG4/Color When the bit is set, "W" should be replaced by
; "~W" (not-W) in the window combination formulae below. See the section
; "WINDOWS" below for more details.
!REGISTER_BG1And2WindowMaskSettings = $002123
	!BGXAndYWindowMaskSettings_Window1_BG1_Disable = $00
	!BGXAndYWindowMaskSettings_Window1_BG1_CopyOfDisable = $01
	!BGXAndYWindowMaskSettings_Window1_BG1_Inside = $02
	!BGXAndYWindowMaskSettings_Window1_BG1_Outside = $03
	!BGXAndYWindowMaskSettings_Window2_BG1_Disable = $00
	!BGXAndYWindowMaskSettings_Window2_BG1_CopyOfDisable = $04
	!BGXAndYWindowMaskSettings_Window2_BG1_Inside = $08
	!BGXAndYWindowMaskSettings_Window2_BG1_Outside = $0C
	!BGXAndYWindowMaskSettings_Window1_BG2_Disable = $00
	!BGXAndYWindowMaskSettings_Window1_BG2_CopyOfDisable = $10
	!BGXAndYWindowMaskSettings_Window1_BG2_Inside = $20
	!BGXAndYWindowMaskSettings_Window1_BG2_Outside = $30
	!BGXAndYWindowMaskSettings_Window2_BG2_Disable = $00
	!BGXAndYWindowMaskSettings_Window2_BG2_CopyOfDisable = $40
	!BGXAndYWindowMaskSettings_Window2_BG2_Inside = $80
	!BGXAndYWindowMaskSettings_Window2_BG2_Outside = $C0
!REGISTER_BG3And4WindowMaskSettings = $002124
	!BGXAndYWindowMaskSettings_Window1_BG3_Disable = $00
	!BGXAndYWindowMaskSettings_Window1_BG3_CopyOfDisable = $01
	!BGXAndYWindowMaskSettings_Window1_BG3_Inside = $02
	!BGXAndYWindowMaskSettings_Window1_BG3_Outside = $03
	!BGXAndYWindowMaskSettings_Window2_BG3_Disable = $00
	!BGXAndYWindowMaskSettings_Window2_BG3_CopyOfDisable = $04
	!BGXAndYWindowMaskSettings_Window2_BG3_Inside = $08
	!BGXAndYWindowMaskSettings_Window2_BG3_Outside = $0C
	!BGXAndYWindowMaskSettings_Window1_BG4_Disable = $00
	!BGXAndYWindowMaskSettings_Window1_BG4_CopyOfDisable = $10
	!BGXAndYWindowMaskSettings_Window1_BG4_Inside = $20
	!BGXAndYWindowMaskSettings_Window1_BG4_Outside = $30
	!BGXAndYWindowMaskSettings_Window2_BG4_Disable = $00
	!BGXAndYWindowMaskSettings_Window2_BG4_CopyOfDisable = $40
	!BGXAndYWindowMaskSettings_Window2_BG4_Inside = $80
	!BGXAndYWindowMaskSettings_Window2_BG4_Outside = $C0
!REGISTER_ObjectAndColorWindowSettings = $002125
	!BGXAndYWindowMaskSettings_Window1_Sprite_Disable = $00
	!BGXAndYWindowMaskSettings_Window1_Sprite_CopyOfDisable = $01
	!BGXAndYWindowMaskSettings_Window1_Sprite_Inside = $02
	!BGXAndYWindowMaskSettings_Window1_Sprite_Outside = $03
	!BGXAndYWindowMaskSettings_Window2_Sprite_Disable = $00
	!BGXAndYWindowMaskSettings_Window2_Sprite_CopyOfDisable = $04
	!BGXAndYWindowMaskSettings_Window2_Sprite_Inside = $08
	!BGXAndYWindowMaskSettings_Window2_Sprite_Outside = $0C
	!BGXAndYWindowMaskSettings_Window1_ColorMath_Disable = $00
	!BGXAndYWindowMaskSettings_Window1_ColorMath_CopyOfDisable = $10
	!BGXAndYWindowMaskSettings_Window1_ColorMath_Inside = $20
	!BGXAndYWindowMaskSettings_Window1_ColorMath_Outside = $30
	!BGXAndYWindowMaskSettings_Window2_ColorMath_Disable = $00
	!BGXAndYWindowMaskSettings_Window2_ColorMath_CopyOfDisable = $40
	!BGXAndYWindowMaskSettings_Window2_ColorMath_Inside = $80
	!BGXAndYWindowMaskSettings_Window2_ColorMath_Outside = $C0
; WH0 - Window 1 Left Position wb+++- WH1 - Window 1 Right Position wb+++-
; WH2 - Window 2 Left Position wb+++- WH3 - Window 2 Right Position xxxxxxxx
; These set the offset of the appropriate edge of the appropriate window.
; Note that if the left edge is greater than the right edge, the window is
; considered to have no range at all (and thus "W" always is false). See the
; section "WINDOWS" below for more details.
!REGISTER_Window1LeftPositionDesignation = $002126
!REGISTER_Window1RightPositionDesignation = $002127
!REGISTER_Window2LeftPositionDesignation = $002128
!REGISTER_Window2RightPositionDesignation = $002129
; WBGLOG - Window mask logic for BGs 44332211 wb+++- WOBJLOG - Window mask
; logic for OBJs and Color Window ----ccoo 44/33/22/11/oo/cc = Mask logic
; for BG1/BG2/BG3/BG4/OBJ/Color This specified the window combination
; method, using standard boolean operators: 00 = OR 01 = AND 10 = XOR 11 =
; XNOR Consider two variables, W1 and W2, which are true for pixels between
; the appropriate left and right bounds as set in $2126-$2129 and false
; otherwise. Then, you have the following possibilities: (replace "W#" with
; "~W#", depending on the Inversion settings of $2123-$2125) Neither window
; enabled => nothing masked. One window enabled => Either W1 or W2, as
; appropriate. Both windows enabled => W1 op W2, where "op" is as above.
; Where the function is true, the BG will be masked. See the section
; "WINDOWS" below for more details.
!REGISTER_BGWindowLogicSettings = $00212A
	!BGXAndYWindowMaskSettings_BG1_OR = $00
	!BGXAndYWindowMaskSettings_BG1_AND = $01
	!BGXAndYWindowMaskSettings_BG1_XOR = $02
	!BGXAndYWindowMaskSettings_BG1_XNOR = $03
	!BGXAndYWindowMaskSettings_BG2_OR = $00
	!BGXAndYWindowMaskSettings_BG2_AND = $04
	!BGXAndYWindowMaskSettings_BG2_XOR = $08
	!BGXAndYWindowMaskSettings_BG2_XNOR = $0C
	!BGXAndYWindowMaskSettings_BG3_OR = $00
	!BGXAndYWindowMaskSettings_BG3_AND = $10
	!BGXAndYWindowMaskSettings_BG3_XOR = $20
	!BGXAndYWindowMaskSettings_BG3_XNOR = $30
	!BGXAndYWindowMaskSettings_BG4_OR = $00
	!BGXAndYWindowMaskSettings_BG4_AND = $40
	!BGXAndYWindowMaskSettings_BG4_XOR = $80
	!BGXAndYWindowMaskSettings_BG4_XNOR = $C0
!REGISTER_ColorAndObjectWindowLogicSettings = $00212B
	!BGXAndYWindowMaskSettings_Sprite_OR = $00
	!BGXAndYWindowMaskSettings_Sprite_AND = $01
	!BGXAndYWindowMaskSettings_Sprite_XOR = $02
	!BGXAndYWindowMaskSettings_Sprite_XNOR = $03
	!BGXAndYWindowMaskSettings_BG2_OR = $00
	!BGXAndYWindowMaskSettings_ColorMath_AND = $04
	!BGXAndYWindowMaskSettings_ColorMath_XOR = $08
	!BGXAndYWindowMaskSettings_ColorMath_XNOR = $0C
; TM - Main Screen Designation wb+++- TS - Subscreen Designation ---o4321
; 1/2/3/4/o = Enable BG1/BG2/BG3/BG4/OBJ for display on the main (or sub)
; screen. See the section "BACKGROUNDS" below for details.
!REGISTER_MainScreenLayers = $00212C
!REGISTER_SubScreenLayers = $00212D
	!XScreenLayers_EnableLayer1 = $01
	!XScreenLayers_EnableLayer2 = $02
	!XScreenLayers_EnableLayer3 = $04
	!XScreenLayers_EnableLayer4 = $08
	!XScreenLayers_EnableSprites = $10
; TMW - Window Mask Designation for the Main Screen wb+++- TSW - Window Mask
; Designation for the Subscreen ---o4321 1/2/3/4/o = Enable window masking
; for BG1/BG2/BG3/BG4/OBJ on the main (or sub) screen. See the section
; "BACKGROUNDS" below for details.
!REGISTER_MainScreenWindowMask = $00212E
!REGISTER_SubScreenWindowMask = $00212F
	!XScreenWindowMask_EnableLayer1 = $01
	!XScreenWindowMask_EnableLayer2 = $02
	!XScreenWindowMask_EnableLayer3 = $04
	!XScreenWindowMask_EnableLayer4 = $08
	!XScreenWindowMask_EnableSprites = $10
; CGWSEL - Color Addition Select ccmm--sd cc = Clip colors to black before
; math 00 => Never 01 => Outside Color Window only 10 => Inside Color Window
; only 11 => Always mm = Prevent color math 00 => Never 01 => Outside Color
; Window only 10 => Inside Color Window only 11 => Always s = Add subscreen
; (instead of fixed color) d = Direct color mode for 256-color BGs See the
; sections "BACKGROUNDS", "WINDOWS", and "RENDERING THE SCREEN" below for
; details.
!REGISTER_ColorMathInitialSettings = $002130
	!ColorMathSelectAndEnable_DisableDirectColorMode = $00
	!ColorMathSelectAndEnable_EnableDirectColorMode = $01
	!ColorMathSelectAndEnable_EnableColorMathOnSubscreen = $02
	!ColorMathSelectAndEnable_NeverPrevenColorMath = $00
	!ColorMathSelectAndEnable_PrevenColorMathOutsideWindow = $10
	!ColorMathSelectAndEnable_PrevenColorMathInsideWindow = $20
	!ColorMathSelectAndEnable_AlwaysPrevenColorMath = $30
	!ColorMathSelectAndEnable_NeverClipColorsToBlack = $00
	!ColorMathSelectAndEnable_ClipColorsToBlackOutsideWindow = $40
	!ColorMathSelectAndEnable_ClipColorsToBlackInsideWindow = $80
	!ColorMathSelectAndEnable_AlwaysClipColorsToBlack = $C0
; CGADSUB - Color math designation shbo4321 s = Add/subtract select 0 => Add
; the colors 1 => Subtract the colors h = Half color math. When set, the
; result of the color math is divided by 2 (except when $2130 bit 1 is set
; and the fixed color is used, or when color is cliped). 4/3/2/1/o/b =
; Enable color math on BG1/BG2/BG3/BG4/OBJ/Backdrop See the sections
; "BACKGROUNDS", "WINDOWS", and "RENDERING THE SCREEN" below for details.
!REGISTER_ColorMathSelectAndEnable = $002131
	!ColorMathSelectAndEnable_EnableLayer1 = $01
	!ColorMathSelectAndEnable_EnableLayer2 = $02
	!ColorMathSelectAndEnable_EnableLayer3 = $04
	!ColorMathSelectAndEnable_EnableLayer4 = $08
	!ColorMathSelectAndEnable_EnableSprites = $10
	!ColorMathSelectAndEnable_EnableBackdrop = $20
	!ColorMathSelectAndEnable_HalfColorMath = $40
	!ColorMathSelectAndEnable_Addition = $00
	!ColorMathSelectAndEnable_Subtraction = $80
; COLDATA - Fixed Color Data bgrccccc b/g/r = Which color plane(s) to set
; the intensity for. ccccc = Color intensity. So basically, to set an orange
; you'd do something along the lines of: LDA #$3f STA $2132 LDA #$4f STA
; $2132 LDA #$80 STA $2132 See the sections "BACKGROUNDS" and "WINDOWS"
; below for details.
!REGISTER_FixedColorData = $002132
; SETINI - Screen Mode/Video Select se--poIi s = "External Sync". Used for
; superimposing "sfx" graphics, whatever that means. Usually 0. Not much is
; known about this bit. Interestingly, the SPPU chip has a pin named
; "EXTSYNC" (or not-EXTSYNC, since it has a bar over it) which is tied to
; Vcc. e = Mode 7 EXTBG ("Extra BG"). When this bit is set, you may enable
; BG2 on Mode 7. BG2 uses the same tile and character data as BG1, but
; interprets the high bit of the color data as a priority for the pixel.
; Various sources report additional effects for this bit, possibly related
; to bit 7. For example, "Enable the Data Supplied From the External Lsi.",
; whatever that means. Of course, maybe that's a typo and it's supposed to
; apply to bit 7 instead. p = Enable pseudo-hires mode. This creates a
; 512-pixel horizontal resolution by taking pixels from the subscreen for
; the even-numbered pixels (zero based) and from the main screen for the
; odd-numbered pixels. Color math behaves just as with Mode 5/6 hires. The
; interlace bit still has no effect. Mosaic operates as normal (not like
; Mode 5/6). The 'subscreen' pixel is clipped (by windows) when the
; main-screen pixel to the LEFT is clipped, not when the one to the RIGHT is
; clipped as you'd expect. What happens with pixel column 0 is unknown.
; Enabling this bit in Modes 5 or 6 has no effect. o = Overscan mode. When
; set, 239 lines will be displayed instead of the normal 224. This also
; means V-Blank will occur that much later, and be shorter. All that happens
; is that extra lines get added to the display, and it seems the TV will
; like to move the display up 8 pixels. I = OBJ Interlace. When set
; regardless of BG mode, the OBJ will be interlaced (see bit 0 below), and
; thus will appear half-height. Note that this only controls whether obj are
; drawn as normal or not; the interlace signal is only output to the TV
; based on bit 0 below. i = Screen interlace. When set in BG mode 5 (and
; probably 6), the effective screen height will be 448 (or 478) pixles,
; rather than 224 (or 239). When set in any other mode, the screen will just
; get a bit jumpy. However, toggling the tilemap each field would simulate
; the increased screen height (much like pseudo-hires simulares hires). In
; hardware, setting this bit makes the SNES output a normal interlace signal
; rather than always forcing one frame. See the sections "BACKGROUNDS" and
; "SPRITES" below for details. Overscan: The bit only matters at the very
; end of the frame, if you change the setting on line 0xE0 before the normal
; NMI trigger point then it's the same as if you had it on all frame. Note
; that this affects both the NMI trigger point and when HDMA stops for the
; frame. If you turn the bit off at the very beginning of scanline X (for
; 0xE1<=X<=0xF0), NMI will occur on line X and the last HDMA transfer will
; occur on line X-1. However, on my TV at least, the display will remain in
; the normal no-overscan position for lines E1-EC, it will move up only one
; pixel for line ED, and it will lose vertical sync for lines EF-F4! Turning
; the bit on, only line E1 gives any effect: NMI will occur on line E2,
; although the last HDMA will still occur on line E0. Anything else acts
; like you left the bit off the whole time. Note, however, that if you wait
; too long after the beginning of the scanline then you will get no effect.
; Even if there is no visible effect, the overscan setting still affects
; VRAM writes. In particular, executing "LDA #'-' / STA $2118 / LDA r2133 /
; STA $2133 / LDA #'+' / STA $2118" during the E1-F0 period will write only
; + or only - to VRAM, depending on whether the overscan bit was set to 0 or
; 1.
!REGISTER_InitialScreenSettings = $002133
	!InitialScreenSettings_ScreenInterlaceFlag = $01
	!InitialScreenSettings_SpriteInterlaceFlag = $02
	!InitialScreenSettings_EnableOverscanFlag = $04
	!InitialScreenSettings_EnablePseudoHiResFlag = $08
	!InitialScreenSettings_EnableMode7EXTBG = $40
	!InitialScreenSettings_NormalExternalSync = $00
	!InitialScreenSettings_SuperImposeExternalSync = $80
; r l+++? MPYL - Multiplication Result low byte r m+++? MPYM -
; Multiplication Result middle byte r h+++? MPYH - Multiplication Result
; high byte xxxxxxxx xxxxxxxx xxxxxxxx This is the 2's compliment product of
; the 16-bit value written to $211b and the 8-bit value most recently
; written to $211c. There is supposedly no important delay. It may not be
; operative during Mode 7 rendering.
!REGISTER_PPUMultiplicationProductLo = $002134
!REGISTER_PPUMultiplicationProductMid = $002135
!REGISTER_PPUMultiplicationProductHi = $002136
; SLHV - Software Latch for H/V Counter -------- When read, the H/V counter
; (as read from $213c and $213d) will be latched to the current X and Y
; position if bit 7 of $4201 is set. The data actually read is open bus.
!REGISTER_SoftwareLatchForHVCounter = $002137
; r w++?- OAMDATAREAD* - Data for OAM read xxxxxxxx OAM reads are
; straightforward: the current byte as set in $2102/3 and incremented by
; reads from this register and writes to $2104 will be returned. Note that
; writes to the lower table are not affected so logically. See register
; $2104 and the section "SPRITES" below for details. Also, note that OAM
; address invalidation probably affects the address read by this register as
; well.
!REGISTER_ReadFromOAMPort = $002138
; r l++?- VMDATALREAD* - VRAM Data Read low byte r h++?- VMDATAHREAD* - VRAM
; Data Read high byte xxxxxxxx xxxxxxxx Simply, this reads data from VRAM.
; The address is incremented when either $2139 or $213a is read, depending
; on the setting of bit 7 of $2115. Actually, the reading is more complex.
; When either of these registers is read, the appropriate byte from a
; word-sized buffer is returned. A word from VRAM is loaded into this buffer
; just *before* the VRAM address is incremented. The actual data read and
; the amount of the increment depend on the low 4 bits of $2115. The effect
; of this is that a 'dummy read' is required after setting $2116-7 before
; you start getting the actual data. The interaction between these registers
; and $2118/9 is unknown. See the sections "BACKGROUNDS" and "SPRITES" below
; for details.
!REGISTER_ReadFromVRAMPortLo = $002139
!REGISTER_ReadFromVRAMPortHi = $00213A
; r w++?- CGDATAREAD* - CGRAM Data read -bbbbbgg gggrrrrr This reads from
; CGRAM. Accesses to CGRAM are handled just like accesses to the low table
; of OAM, see $2138 for details. Note that the color values are stored in
; BGR order. The '-' bit is PPU2 Open Bus.
!REGISTER_ReadFromCGRAMPort = $00213B
; r w++++ OPHCT - Horizontal Scanline Location r w++++ OPVCT - Vertical
; Scanline Location -------x xxxxxxxx These values are latched by reading
; $2137 when bit 7 of $4201 is set, or by clearing-and-setting bit 7 of
; $4201 either by writing $4201 or by pin 6 of Controller Port 2 (the latch
; occurs on the 1->0 transition). Note that the value read is only 9 bits:
; bits 1-7 of the high byte are PPU2 Open Bus. Each register keeps seperate
; track of whether to return the low or high byte. The high/low selector is
; reset to 'low' when $213f is read (the selector is NOT reset when the
; counter is latched). H Counter values range from 0 to 339, with 22-277
; being visible on the screen. V Counter values range from 0 to 261 in NTSC
; mode (262 is possible every other frame when interlace is active) and 0 to
; 311 in PAL mode (312 in interlace?), with 1-224 (or 1-239(?) if overscan
; is enabled) visible on the screen.
!REGISTER_HCounter = $00213C
!REGISTER_VCounter = $00213D
; r b++++ STAT77 - PPU Status Flag and Version trm-vvvv t = Time Over Flag.
; If more than 34 sprite-tiles (e.g. a 16x16 sprite has 2 sprite-tiles) were
; encountered on a single line, this flag will be set. The flag is reset at
; the end of V-Blank. See the section "SPRITES" below for details. r = Range
; Over Flag. If more than 32 sprites were encountered on a single line, this
; flag will be set. The flag is reset at the end of V-Blank. See the section
; "SPRITES" below for details. Note that the above two flags are set whether
; or not OBJ are actually enabled at the time. m = "Master/slave mode
; select". Little is known about this bit. Current theory is that it
; indicates the status of the "MASTER" pin on the S-PPU chip, which in the
; normal SNES is always Gnd. We always seem to read back 0 here. vvvv = 5c77
; chip version number. So far, we've only encountered version 1. The '-' bit
; is PPU Open Bus.
!REGISTER_PPUStatusFlag1 = $00213E
	!PPUStatusFlag1_PPU1VersionNumber = $0F
	!PPUStatusFlag1_MasterSlaveModeFlag = $20
	!PPUStatusFlag1_RangeOverFlag = $40
	!PPUStatusFlag1_TimeOverFlag = $80
; r b++++ STAT78 - PPU Status Flag and Version fl-pvvvv f = Interlace Field.
; This will toggle every V-Blank. l = External latch flag. When the PPU
; counters are latched, this flag gets set. The flag is reset on read, but
; only when $4201 bit 7 is set. p = NTSC/Pal Mode. If this is a PAL SNES,
; this bit will be set, otherwise it will be clear. vvvv = 5C78 chip version
; number. So far, we've encountered at least 2 and 3. Possibly 1 as well.
; The '-' bit is PPU2 Open Bus. Note: as a side effect of reading this
; register, the high/low byte selector for $213c/d is reset to 'low'.
!REGISTER_PPUStatusFlag2 = $00213F
	!PPUStatusFlag1_PPU2VersionNumber = $0F
	!PPUStatusFlag2_ConsoleRegion = $10
	!PPUStatusFlag2_PPULatchFlag = $40
	!PPUStatusFlag2_InterlaceField = $80
; APUIO0 - APU I/O register 0 rwb++++ APUIO1 - APU I/O register 1 rwb++++
; APUIO2 - APU I/O register 2 rwb++++ APUIO3 - APU I/O register 3 xxxxxxxx
; These registers are used in communication with the SPC700. Note that the
; value written here is not the value read back. Rather, the value written
; shows up in the SPC700's registers $f4-7, and the values written to those
; registers by the SPC700 are what you read here. If the SPC700 writes the
; register during a read, the value read will be the logical OR of the old
; and new values. The exact cycles during which the 'read' actually occurs
; is not known, although a good guess would be some portion of the final 3
; master cycles of the 6-cycle memory access. Note that these registers are
; mirrored throughout the range $2140-$217f.
!REGISTER_APUPort0 = $002140
!REGISTER_APUPort1 = $002141
!REGISTER_APUPort2 = $002142
!REGISTER_APUPort3 = $002143
; WMDATA - WRAM Data read/write xxxxxxxx This register reads to or writes
; from the WRAM address set in $2181-3. The address is then incremented. The
; effect of mixed reads and writes is unknown, but it is suspected that they
; are handled logically. Note that attempting a DMA from WRAM to this
; register will not work, WRAM will not be written. Attempting a DMA from
; this register to WRAM will similarly not work, the value written is
; (initially) the Open Bus value. In either case, the address in $2181-3 is
; not incremented.
!REGISTER_ReadOrWriteToWRAMPort = $002180
; wl++++ WMADDL - WRAM Address low byte wm++++ WMADDM - WRAM Address middle
; byte wh++++ WMADDH - WRAM Address high bit -------x xxxxxxxx xxxxxxxx This
; is the address that will be read or written by accesses to $2180. Note
; that WRAM is also mapped in the SNES memory space from $7E:0000 to
; $7F:FFFF, and from $0000 to $1FFF in banks $00 through $3F and $80 through
; $BF. Verious docs indicate that these registers may be read as well as
; written. However, they are wrong. These registers are open bus. DMA from
; WRAM to these registers has no effect. Otherwise, however, DMA writes them
; as normal. This means you could use DMA mode 4 to $2180 and a table in ROM
; to write any sequence of RAM addresses. The value does not wrap at page
; boundaries on increment.
!REGISTER_WRAMAddressLo = $002181
!REGISTER_WRAMAddressHi = $002182
!REGISTER_WRAMAddressBank = $002183
; JOYSER0 - NES-style Joypad Access Port 1 Rd: ------ca Wr: -------l r?b++++
; JOYSER1 - NES-style Joypad Access Port 2 ---111db These registers
; basically have a direct connection to the controller ports on the front of
; the SNES. l = Writing this bit controlls the Latch line of both controller
; ports. When 1 is set, the Latch goes high (or is it low? At any rate,
; whichever one makes the pads latch their state). When cleared, the Latch
; goes the other way. a/b = These bits return the state of the Data1 line.
; c/d = These bits return the state of the Data2 line. Reading $4016 drives
; the Clock line of Controller Port 1 low. The SNES then reads the Data1 and
; Data2 lines, and Clock is set back to high. $4017 does the same for Port
; 2. Note the 1-bits in $4017: the CPU chip has pins for these bits, but
; these pins are tied to Gnd and thus always 1. Data for normal joypads is
; returned in the order: B, Y, Select, Start, Up, Down, Left, Right, A, X,
; L, R, 0, 0, 0, 0, then ones until latched again. Note that Auto-Joypad
; Read (see register $4200) will effectively write 1 then 0 to bit 'l', then
; read 16 times from both $4016 and $4017. The 'a' bits will end up in
; $4218/9, with the first bit read (e.g. the B button) in bit 15 of the
; word. Similarly, the 'b' bits end up in $421a/b, the 'c' bits in $42c/d,
; and the 'd' bits in $421e/f. Any further bits the device may return may be
; read from $4016/$4017 as normal. The effect of reading these during
; auto-joypad read is unknown. See the section "CONTROLLERS" below for
; details.
!REGISTER_JoypadSerialPort1 = $004016
!REGISTER_JoypadSerialPort2 = $004017
; NMITIMEN - Interrupt Enable Flags n-yx---a n = Enable NMI. If clear, NMI
; will not occur. If set, NMI will fire just after the start of V-Blank. NMI
; fires shortly after the V Counter reaches $E1 (or presumably $F0 if
; overscan is enabled, see register $2133). x/y = IRQ enable. 0/0 = No IRQ
; will occur 0/1 = An IRQ will occur sometime just after the V Counter
; reaches the value set in $4209/$420A. 1/0 = An IRQ will occur sometime
; just after the H Counter reaches the value set in $4207/$4208. 1/1 = An
; IRQ will occur sometime just after the H Counter reaches the value set in
; $4207/$4208 when V Counter equals the value set in $4209/$420A. a =
; Auto-Joypad Read Enable. When set, the registers $4218-$421F will be
; updated at about V Counter = $E3 (or presumably $F2). Some games try to
; read this register. However, they work only because open bus behavior
; gives them values they expect. This register is initialized to $00 on
; power on or reset.
!REGISTER_IRQNMIAndJoypadEnableFlags = $004200
	!IRQNMIAndJoypadEnableFlags_EnableAutoJoypadRead = $01
	!IRQNMIAndJoypadEnableFlags_DisableIRQs = $00
	!IRQNMIAndJoypadEnableFlags_EanbleIRQsAtVPos = $10
	!IRQNMIAndJoypadEnableFlags_EanbleIRQsAtHPos = $20
	!IRQNMIAndJoypadEnableFlags_EanbleIRQsAtHVPos = $30
	!IRQNMIAndJoypadEnableFlags_DisableNMI = $00
	!IRQNMIAndJoypadEnableFlags_EnableNMI = $80
; WRIO - Programmable I/O port (out-port) abxxxxxx This is basically just an
; 8-bit I/O Port. 'b' is connected to pin 6 of Controller Port 1. 'a' is
; connected to pin 6 of Controller Port 2, and to the PPU Latch line. Thus,
; writing a 0 then a 1 to bit 'a' will latch the H and V Counters much like
; reading $2137 (the latch happens on the transition to 0). When bit 'a' is
; 0, no latching can occur. Any other effects of this register are unknown.
; See $4213 for the I half of the I/O Port. Note that the IO Port is
; initialized as if this register were written with all 1-bits at power up,
; unchanged on reset(?).
!REGISTER_ProgrammableIOPortOutput = $004201
	!ProgrammableIOPortOutput_Joypad1Pin6 = $40
	!ProgrammableIOPortOutput_Joypad2Pin6 = $80
; WRMPYA - Multiplicand A wb++++ WRMPYB - Multiplicand B mmmmmmmm Write
; $4202, then $4203. 8 "machine cycles" (probably 48 master cycles) after
; $4203 is set, the product may be read from $4216/7. $4202 will not be
; altered by this process, thus a new value may be written to $4203 to
; perform another multiplication without resetting $4202. The multiplication
; is unsigned. $4202 holds the value $ff on power on and is unchanged on
; reset.
!REGISTER_Multiplicand = $004202
!REGISTER_Multiplier = $004203
; wl++++ WRDIVL - Dividend C low byte wh++++ WRDIVH - Dividend C high byte
; dddddddd dddddddd wb++++ WRDIVB - Divisor B bbbbbbbb Write $4204/5, then
; $4206. 16 "machine cycles" (probably 96 master cycles) after $4206 is set,
; the quotient may be read from $4214/5, and the remainder from $4216/7.
; Presumably, $4204/5 are not altered by this process, much like $4202. The
; division is unsigned. Division by 0 gives a quotient of $FFFF and a
; remainder of C. WRDIV holds the value $ffff on power on and is unchanged
; on reset.
!REGISTER_DividendLo = $004204
!REGISTER_DividendHi = $004205
!REGISTER_Divisor = $004206
; wl++++ HTIMEL - H Timer low byte wh++++ HTIMEH - H Timer high byte
; -------h hhhhhhhh If bit 4 of $4200 is set and bit 5 is clear, an IRQ will
; fire every scanline when the H Counter reaches the value set here. If bits
; 4 and 5 are both set, the IRQ will fire only when the V Counter equals the
; value set in $4209/a. Note that the H Counter ranges from 0 to 339, thus
; greater values will result in no IRQ firing. HTIME is initialized to $1ff
; on power on, unchanged on reset.
!REGISTER_HCountTimerLo = $004207
!REGISTER_HCountTimerHi = $004208
; wl++++ VTIMEL - V Timer low byte wh++++ VTIMEH - V Timer high byte
; -------v vvvvvvvv If bit 5 of $4200 is set and bit 4 is clear, an IRQ will
; fire just after the V Counter reaches the value set here. If bits 4 and 5
; are both set, the IRQ will fire instead when the V Counter equals the
; value set here and the H Counter reaches the value set in $4207/8. Note
; that the V Counter ranges from 0 to 261 in NTSC mode (262 is possible
; every other frame whan interlace is active) and 0 to 311 in PAL mode (312
; in interlace?), thus greater values will result in no IRQ firing. VTIME is
; initialized to $1ff on power on, unchanged on reset.
!REGISTER_VCountTimerLo = $004209
!REGISTER_VCountTimerHi = $00420A
; MDMAEN - DMA Enable 76543210 7/6/5/4/3/2/1/0 = Enable the selected DMA
; channels. The CPU will be paused until all DMAs complete. DMAs will be
; executed in order from 0 to 7 (?). See registers $43x0-$43xA for more
; details. If HDMA (init or transfer) occurs while a DMA is in progress, the
; DMA will be paused for the duration. If the HDMA happens to involve the
; current DMA channel, the DMA will be immediately terminated and the HDMA
; will progress using the then-current values of the registers. Other DMA
; channels will be unaffected. This register is initialized to $00 on power
; on or reset. See the section "DMA AND HDMA" below for more information.
!REGISTER_DMAEnable = $00420B
; HDMAEN - HDMA Enable 76543210 7/6/5/4/3/2/1/0 = Enable the selected HDMA
; channels. HDMAs will be executed in order from 0 to 7 (?). See registers
; $43x0-$43xA for more details. If HDMA (init or transfer) occurs while a
; DMA is in progress, the DMA will be paused for the duration. If the HDMA
; happens to involve the current DMA channel, the DMA will be immediately
; terminated and the HDMA will progress using the then-current values of the
; registers. Other DMA channels will be unaffected. Note that enabling a
; channel mid-frame will begin HDMA at the next HDMA point. However, the
; HDMA register initialization only occurs before the HDMA point on scanline
; 0, so those registers will have to be initialized by hand before enabling
; HDMA. A channel that has already terminated for the frame cannot be
; restarted in this manner. Writing 0 to a bit will pause an ongoing HDMA;
; the transfer may be continued by writing 1 to the bit. This register is
; initialized to $00 on power on or reset. See the section "DMA AND HDMA"
; below for more information.
!REGISTER_HDMAEnable = $00420C
	!DMAEnable_Channel0 = $01
	!DMAEnable_Channel1 = $02
	!DMAEnable_Channel2 = $04
	!DMAEnable_Channel3 = $08
	!DMAEnable_Channel4 = $10
	!DMAEnable_Channel5 = $20
	!DMAEnable_Channel6 = $40
	!DMAEnable_Channel7 = $80
; MEMSEL - ROM Access Speed -------f f = FastROM select. The SNES uses a
; master clock running at about 21.477 MHz (current theory is 1.89e9/88 Hz).
; By default, the SNES takes 8 master cycles for each ROM access. If this
; bit is set and ROM is accessed via banks $80-$FF, only 6 master cycles
; will be used. This register is initialized to $00 on power on (or reset?).
; See my memory map and timing doc (memmap.txt) for more details.
!REGISTER_EnableFastROM = $00420D
; r b++++ RDNMI - NMI Flag and 5A22 Version n---vvvv n = NMI Flag. This bit
; is set at the start of V-Blank (at the moment, we suspect when H-Counter
; is somewhere between $28 and $4E), and cleared on read or at the end of
; V-Blank. Supposedly, it is required that this register be read during NMI.
; Note that this bit is not affected by bit 7 of $4200. vvvv = 5A22 chip
; version number. So far, we've encountered at least 2, maybe 1 as well. NMI
; is cleared on power on or reset. The '-' bits are open bus.
!REGISTER_NMIEnable = $004210
	!NMIEnable_5A22ChipVersionNumber = $0F
	!NMIEnable_NMIFlag = $80
; r b++++ TIMEUP - IRQ Flag i------- i = IRQ Flag. This bit is set just
; after an IRQ fires (at the moment, it seems to have the same delay as the
; NMI Flag of $4210 has following NMI), and is cleared on read or write.
; Supposedly, it is required that this register be read during the IRQ
; handler. If this really is the case, then I suspect that that read is what
; actually clears the CPU's IRQ line. This register is marked read/write in
; another doc, with no explanation. IRQ is cleared on power on or reset. The
; '-' bits are open bus.
!REGISTER_IRQEnable = $004211
	!IRQEnable_IRQFlag = $80
; r b++++ HVBJOY - PPU Status vh-----a v = V-Blank Flag. If we're currently
; in V-Blank, this flag is set, otherwise it is clear. The setting seems to
; occur at H Counter about $16-$17 when V Counter is $E1, and the clearing
; at about $1E with V Counter 0. h = H-Blank Flag. If we're currently in
; H-Blank, this flag is set, otherwise it is clear. The setting seems to
; occur at H Counter about $121-$122, and the clearing at about $12-$18. a =
; Auto-Joypad Status. This is set while Auto-Joypad Read is in progress, and
; cleared when complete. It typically turns on at the start of V-Blank, and
; completes 3 scanlines later. This register is marked read/write in another
; doc, with no explanation.
!REGISTER_HVBlankFlagsAndJoypadStatus = $004212
	!HVBlankFlagsAndJoypadStatus_AutoJoypadReadStatus = $01
	!HVBlankFlagsAndJoypadStatus_HBlankFlag = $40
	!HVBlankFlagsAndJoypadStatus_VBlankFlag = $80
; r b++++ RDIO - Programmable I/O port (in-port) abxxxxxx Reading this
; register reads data from the I/O Port. The way the I/O Port works, any bit
; set to 0 in $4201 will be 0 here. Any bit set to 1 in $4201 may be 1 or 0
; here, depending on whether any other device connected to the I/O Port has
; set a 0 to that bit. Bit 'b' is connected to pin 6 of Controller Port 1.
; Bit 'a' is connected to pin 6 of Controller Port 2, and to the PPU Latch
; line. See register $4201 for the O side of the I/O Port.
!REGISTER_ProgrammableIOPortInput = $004213
; r l++++ RDDIVL - Quotient of Divide Result low byte r h++++ RDDIVH -
; Quotient of Divide Result high byte qqqqqqqq qqqqqqqq Write $4204/5, then
; $4206. 16 "machine cycles" (probably 96 master cycles) after $4206 is set,
; the quotient may be read from these registers, and the remainder from
; $4216/7. The division is unsigned.
!REGISTER_QuotientLo = $004214
!REGISTER_QuotientHi = $004215
; r l++++ RDMPYL - Multiplication Product or Divide Remainder low byte r
; h++++ RDMPYH - Multiplication Product or Divide Remainder high byte
; xxxxxxxx xxxxxxxx Write $4202, then $4203. 8 "machine cycles" (probably 48
; master cycles) after $4203 is set, the product may be read from these
; registers. Write $4204/5, then $4206. 16 "machine cycles" (probably 96
; master cycles) after $4206 is set, the quotient may be read from $4214/5,
; and the remainder from these registers. The multiplication and division
; are both unsigned.
!REGISTER_ProductOrRemainderLo = $004216
!REGISTER_ProductOrRemainderHi = $004217
; r l++++ JOY1L - Controller Port 1 Data1 Register low byte r h++++ JOY1H -
; Controller Port 1 Data1 Register high byte r l++++ JOY2L - Controller Port
; 2 Data1 Register low byte r h++++ JOY2H - Controller Port 2 Data1 Register
; high byte r l++++ JOY3L - Controller Port 1 Data2 Register low byte r
; h++++ JOY3H - Controller Port 1 Data2 Register high byte r l++++ JOY4L -
; Controller Port 2 Data2 Register low byte r h++++ JOY4H - Controller Port
; 2 Data2 Register high byte byetUDLR axlr0000 The bitmap above only applies
; for joypads, obviously. More generically, Auto Joypad Read effectively
; sets 1 then 0 to $4016, then reads $4016/7 16 times to get the bits for
; these registers. a/b/x/y/l/r/e/t = A/B/X/Y/L/R/Select/Start button status.
; U/D/L/R = Up/Down/Left/Right control pad status. Note that only one of L/R
; and only one of U/D may be set, due to the pad hardware. These registers
; are only updated when the Auto-Joypad Read bit (bit 0) of $4200 is set.
; They are being updated while the Auto-Joypad Status bit (bit 0) of $4212
; is set. Reading during this time will return incorrect values. See the
; section "CONTROLLERS" below for details.
!REGISTER_Joypad1Lo = $004218
!REGISTER_Joypad1Hi = $004219
!REGISTER_Joypad2Lo = $00421A
!REGISTER_Joypad2Hi = $00421B
!REGISTER_Joypad3Lo = $00421C
!REGISTER_Joypad3Hi = $00421D
!REGISTER_Joypad4Lo = $00421E
!REGISTER_Joypad4Hi = $00421F

org $000000
struct DMA $004300
	; DMAP0 - DMA Control for Channel 0 da-ifttt d = Transfer Direction. When
	; clear, data will be read from the CPU memory and written to the PPU
	; register. When set, vice versa. Contrary to previous belief, this bit
	; DOES affect HDMA! Indirect mode is more useful, it will read the table as
	; normal and write from Bus B to the Bus A address specified. Direct mode
	; will work as expected though, it will read counts from the table and try
	; to write the data values into the table. a = HDMA Addressing Mode. When
	; clear, the HDMA table contains the data to transfer. When set, the HDMA
	; table contains pointers to the data. This bit does not affect DMA. i =
	; DMA Address Increment. When clear, the DMA address will be incremented
	; for each byte. When set, the DMA address will be decremented. This bit
	; does not affect HDMA. f = DMA Fixed Transfer. When set, the DMA address
	; will not be adjusted. When clear, the address will be adjusted as
	; specified by bit 4. This bit does not affect HDMA. ttt = Transfer Mode.
	; 000 => 1 register write once (1 byte: p ) 001 => 2 registers write once
	; (2 bytes: p, p+1 ) 010 => 1 register write twice (2 bytes: p, p ) 011 =>
	; 2 registers write twice each (4 bytes: p, p, p+1, p+1) 100 => 4 registers
	; write once (4 bytes: p, p+1, p+2, p+3) 101 => 2 registers write twice
	; alternate (4 bytes: p, p+1, p, p+1) 110 => 1 register write twice (2
	; bytes: p, p ) 111 => 2 registers write twice each (4 bytes: p, p, p+1,
	; p+1) The effect of writing this register during HDMA to the associated
	; channel is unknown. Most likely, the change takes effect for the next
	; HDMA transfer. This register is set to $FF on power on, and is unchanged
	; on reset.
	.Parameters: skip $01
	; BBAD0 - DMA Destination Register for Channel 0 pppppppp This specifies
	; the Bus B address to access. Considering the standard CPU memory space,
	; this specifies which address $00:2100-$00:21FF to access, with two- and
	; four-register modes wrapping $21FF->$2100, not $2200. The effect of
	; writing this register during HDMA to the associated channel is unknown.
	; Most likely, the change takes effect for the next transfer. This register
	; is set to $FF on power on, and is unchanged on reset.
	.Destination: skip $01
	; rwl++++ A1T0L - DMA Source Address for Channel 0 low byte rwh++++ A1T0H -
	; DMA Source Address for Channel 0 high byte rwb++++ A1B0 - DMA Source
	; Address for Channel 0 bank byte bbbbbbbb hhhhhhhh llllllll This specifies
	; the starting Address Bus A address for the DMA transfer, or the beginning
	; of the HDMA table for HDMA transfers. Note that Bus A does not access the
	; Bus B registers, so pointing this address at say $00:2100 results in open
	; bus. The effect of writing this register during HDMA to the associated
	; channel is unknown. However, current theory is that only $4304 will
	; affect the transfer. The changes will take effect at the next HDMA init.
	; During DMA, $4302/3 will be incremented or decremented as specified by
	; $4300. However $4304 will NOT be adjusted. These registers will not be
	; affected by HDMA. This register is set to $FF on power on, and is
	; unchanged on reset.
	.SourceLo: skip $01
	.SourceHi: skip $01
	.SourceBank: skip $01
	; rwl++++ DAS0L - DMA Size/HDMA Indirect Address low byte rwh++++ DAS0H -
	; DMA Size/HDMA Indirect Address high byte rwb++++ DASB0 - HDMA Indirect
	; Address bank byte bbbbbbbb hhhhhhhh llllllll For DMA, $4305/6 indicate
	; the number of bytes to transfer. Note that this is a strict limit: if
	; this is set to 1 then only 1 byte will be written, even if the transfer
	; mode specifies 2 or 4 registers (and if this is 5, all 4 registers would
	; be written once, then the first only would be written a second time).
	; Note, however, that writing $0000 to this register actually results in a
	; transfer of $10000 bytes, not 0. $4305/6 are decremented during DMA, and
	; thus typically end up set to 0 when DMA is complete. For HDMA, $4307
	; specifies the bank for indirect addressing mode. The indirect address is
	; copied into $4305/6 and incremented appropriately. For direct HDMA, these
	; registers are not used or altered. Writes to $4307 during indirect HDMA
	; will take effect for the next transfer. Writes to $4305/6 during indirect
	; HDMA will also take effect for the next HDMA transfer, however this is
	; only noticable during repeat mode (for normal mode, a new indirect
	; address will be read from the table before the transfer). For a direct
	; transfer, presumably nothing will happen. This register is set to $FF on
	; power on, and is unchanged on reset.
	.SizeLo: skip $01
	.SizeHi: skip $01
endstruct align $10

struct HDMA $004300
	.Parameters: skip $01
	.Destination: skip $01
	.SourceLo: skip $01
	.SourceHi: skip $01
	.SourceBank: skip $01
	.IndirectSourceLo: skip $01
	.IndirectSourceHi: skip $01
	.IndirectSourceBank: skip $01
	; rwl++++ A2A0L - HDMA Table Address low byte rwh++++ A2A0H - HDMA Table
	; Address high byte aaaaaaaa aaaaaaaa At the beginning of the frame $4302/3
	; are copied into this register for all active HDMA channels, and then this
	; register is updated as the table is read. Thus, if a game wishes to start
	; HDMA mid-frame (or change tables mid-frame), this register must be
	; written. Writing this register mid-frame changes the table address for
	; the next scanline. This register is not used for DMA. This register is
	; set to $FF on power on, and is unchanged on reset.
	.TableSourceLo: skip $01
	.TableSourceHi: skip $01
	; NLTR0 - HDMA Line Counter rccccccc r = Repeat Select. When set, the HDMA
	; transfer will be performed every line, rather than only when this
	; register is loaded from the table. However, this byte (and the indirect
	; HDMA address) will only be reloaded from the table when the counter
	; reaches 0. ccccccc = Line count. This is decremented every scanline. When
	; it reaches 0, a byte is read from the HDMA table into this register (and
	; the indirect HDMA address is read into $4305/6 if applicable). One
	; oddity: the register is decremeted before being checked for r status or
	; c==0. Thus, setting a value of $80 is really "128 lines with no repeat"
	; rather than "0 lines with repeat". Similarly, a value of $00 will be "128
	; lines with repeat" when it doesn't mean "terminate the channel". This
	; register is initialized at the end of V-Blank for every active HDMA
	; channel. Note that if a game wishes to begin HDMA during the frame, it
	; will most likely have to initalize this register. Writing this
	; mid-transfer will similarly change the count and repeat to take effect
	; next scanline. Remember though that 'repeat' won't take effect until
	; after the next transfer period. This register is set to $ff on power on,
	; and is unchanged on reset. See the section "DMA AND HDMA" below for more
	; information.
	.LineCount: skip $01
endstruct align $10

	!DMAParams_TransferMode_1Reg1Write = $00
	!DMAParams_TransferMode_2Regs1Write = $01
	!DMAParams_TransferMode_1Reg2Writes = $02
	!DMAParams_TransferMode_2Regs2Writes = $03
	!DMAParams_TransferMode_4Regs1Write = $04
	!DMAParams_TransferMode_2Regs2WritesAlternating = $05
	!DMAParams_TransferMode_CopyOf1Reg2Writes = $06
	!DMAParams_TransferMode_CopyOf2Regs2Writes = $07
	!DMAParams_EnableFixedTransfer = $08
	!DMAParams_IncrementSourceAddr = $00
	!DMAParams_DecrementSourceAddr = $10
	!DMAParams_HDMAUseDirectAddr = $00
	!DMAParams_HDMAUseIndirectAddr = $40
	!DMAParams_TransferDirection_ABusToBBus = $00
	!DMAParams_TransferDirection_BBusToABus = $80

;---------------------------------------------------------------------------

; Main ROM assembly specific macros

macro BANK_START(Bank)
assert !InBank == !FALSE, "You must put a BANK_END macro before calling BANK_START again!"
assert !BANKType_<Bank>&$04 == $00, "Bank $<Bank> has already been inserted!"
assert !CurrentBank <= $<Bank>, "It's risky inserting banks in non-ascending order! Please insert bank $<Bank> before bank !CurrentBank."

;if $<Bank> >= !StartOfMirrorBanks|((!FastROMAddressOffset|!HiROMAddressOffset)>>16)
	if $<Bank> > $FF
		error "Bank $<Bank> is beyond what the SNES can address."
	;else
	;	error "Bank $<Bank> is outside the range of the chosen ROM size. Use %HandleROMMirroring() if you intend to use ROM mirroring or set the ROM Layout to one of the FastROM settings if you wanted FastROM addressing."
	endif
;endif
if !BANKType_<Bank> == $FF
	error "Bank $<Bank> is not a valid ROM bank in this memory map!"
else
	!BANKType_<Bank> #= !BANKType_<Bank>|$04
endif
;if !BANKType_<Bank>&$02 != $00
;else
	if !BANKType_<Bank>&$01 == $00
		org (($<Bank><<16)+$8000)|!FastROMAddressOffset|!HiROMAddressOffset
		!InLoROMBank #= !TRUE
	else
		org ($<Bank><<16)|!FastROMAddressOffset|!HiROMAddressOffset
		!InLoROMBank #= !FALSE
	endif
	ROMBANK<Bank>_START:
	!InBank = !TRUE
	!CurrentBank = $<Bank>
;endif
endmacro

;---------------------------------------------------------------------------

macro BANK_END(Bank)
assert !InBank == !TRUE, "You must put a BANK_START macro before calling BANK_END!"
assert !CurrentBank <= $<Bank>, "The bank parameter of BANK_END must be greater than or equal to the bank parameter in the previous BANK_START!"
assert !InROMMirror == 0, "You must turn off ROM mirroring via EndROMMirroring() before a BANK_END() macro!"
if !BANKType_<Bank>&$20 != $00
	if !NumOfInsertedSNESHeader == $00
		%SNES_Header(!SNESHeaderLoc)
	endif
endif
;if $<Bank> >= !StartOfMirrorBanks|((!FastROMAddressOffset|!HiROMAddressOffset)>>16)
;	error "Bank $<Bank> is outside the range of the chosen ROM size. Use %HandleROMMirroring() if you intend to use ROM mirroring or set the ROM Layout to one of the FastROM settings if you wanted FastROM addressing."
;endif

if !InSuperFXHiROMMirror == !TRUE
	if (!CurrentBank/$02)|$40 == ($<Bank>/$02)|$40
		print "- Bank $",hex(($<Bank>/$02)|$40)," bytes: ", bytes
	else
		print "- Bank $",hex((!CurrentBank/$02)|$40),"-$",hex(($<Bank>/$02)|$40)," bytes: ", bytes
	endif
else
	if !ROMBankSplitFlag == !TRUE
		print "- Bank $<Bank> (Upper) bytes: ", bytes
	elseif !CurrentBank == $<Bank>
		print "- Bank $<Bank> bytes: ", bytes
	else
		print "- Bank !CurrentBank-$<Bank> bytes: ", bytes
	endif
endif
if !CurrentBank != $FF
	if !InSuperFXHiROMMirror == !TRUE
		warnpc ((($<Bank>/$02)<<16)|$400000)+$10000
		!InSuperFXHiROMMirror = !FALSE
	else
		if !ROMBankSplitFlag == !TRUE
			warnpc ((($<Bank><<16)+$10000)|!FastROMAddressOffset)^!HiROMAddressOffset
		else
			warnpc (($<Bank><<16)+$10000)|!FastROMAddressOffset|!HiROMAddressOffset
		endif
	endif
endif
	reset bytes
	!InBank = !FALSE
	!CurrentBank = $<Bank>
	ROMBANK<Bank>_END:
endmacro

;---------------------------------------------------------------------------

macro HiROMBankSplit()
if !InLoROMBank == !FALSE
	if !Define_Global_CustomChip&$7F == !Chip_SA1
		if !Define_Global_ROMSize > !ROMSize_4MB
		else
			warnpc ((!CurrentBank<<16)+$8000)|!FastROMAddressOffset|!HiROMAddressOffset
			org (((!CurrentBank<<16)+$8000)|!FastROMAddressOffset)^!HiROMAddressOffset
		endif
	else
		warnpc ((!CurrentBank<<16)+$8000)|!FastROMAddressOffset|!HiROMAddressOffset
		org (((!CurrentBank<<16)+$8000)|!FastROMAddressOffset)^!HiROMAddressOffset
	endif
	!ROMBankSplitFlag = !TRUE
	print "- Bank !CurrentBank (Lower) bytes: ", bytes
	reset bytes
else
	error "%HiROMBankSplit() is only meant to be used in HiROM banks!"
endif
endmacro

;---------------------------------------------------------------------------

macro BeginROMMirroring(Address, Offset, Flip)
if !Define_Global_IgnoreCodeAlignments|!Define_Global_DisableROMMirroring == !FALSE
	if !StartOfMirrorBanks < $0100
		assert !InROMMirror == !FALSE, "You must end ROM mirroring via EndROMMirroring() before starting another mirror block."
		!TEMP = (<Flip>^<Address>)+((<Offset>*!StartOfMirrorBanks)<<16)&$00FFFFFF
		if (!TEMP>>16)&$FE == $7E
			error "This HandleROMMirroring() macro call points to a RAM bank!"
		else
			warnpc <Address>
			!InROMMirror = !TRUE
			base !TEMP
		endif
	else
		error "This ROM has no ROM mirror banks, so you must set \!Define_Global_DisableROMMirroring to \!TRUE or else pointers affected by HandleROMMirroring() will point to the wrong addresses!"
	endif
endif
endmacro

;---------------------------------------------------------------------------

macro EndROMMirroring()
if !Define_Global_IgnoreCodeAlignments|!Define_Global_DisableROMMirroring == !FALSE
	if !StartOfMirrorBanks < $0100
		assert !InROMMirror == !TRUE, "You must start ROM mirroring via BeginROMMirroring() before ending a mirror block."
		!InROMMirror = !FALSE
		base off
	endif
endif
endmacro

;---------------------------------------------------------------------------
