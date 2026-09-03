;--- Direct page - $7E0000-$7E00FF
;--- Addresses and names are upstream's; only the grouping is ours.
;--- Order is the original file's -- many defines are relative to an
;--- earlier one, so this list cannot be reordered.


; Where SMW's work RAM lives. Both are $0000 for every shipped cartridge and
; are read, not written, by everything below -- a ROM map sets one or both
; before the memory map is included, which is how a base that relocates work
; RAM does it without a second copy of this file.
;
; Guarded so a ROM map's value survives: this file is included after
; %SMW_GameSpecificAssemblySettings(), so an unconditional assignment here
; would overwrite whatever the base had chosen.
if defined("Define_SMW_DirectPageLocation") == 0
!Define_SMW_DirectPageLocation #= $0000
endif
if defined("Define_SMW_LowRAMLocation") == 0
!Define_SMW_LowRAMLocation #= $0000
endif
; SA-1 Pack's More Sprites layout, selected by the base that carries the
; pack: 22 slots, the tables that stay on the direct page shuffled to make
; room, three taken off it into I-RAM and reached through pointers, and the
; rest moved out of low RAM into I-RAM ($3242 and up, the hot ones) or the
; BW-RAM window ($74C8 and up). The addresses are the pack's own, so code
; written against an SA-1 Pack cartridge reads the same bytes here; the
; four tables not anchored below follow the one before them at one
; slot-width, in this layout as in the stock one.
if defined("Define_SMW_SA1")
!Define_SMW_SpriteMemorySetting08_LastSlot = !Define_SMW_MaxNormalSpriteSlot-$02
!Define_SMW_SprTable_009E #= $3200
!Define_SMW_SprTable_00AA #= !Define_SMW_DirectPageLocation+$9E
!Define_SMW_SprTable_00B6 #= !Define_SMW_DirectPageLocation+$B6
!Define_SMW_SprTable_00C2 #= !Define_SMW_DirectPageLocation+$D8
!Define_SMW_SprTable_00D8 #= $3216
!Define_SMW_SprTable_14C8 #= $3242
!Define_SMW_SprTable_14D4 #= $3258
!Define_SMW_SprTable_14EC #= $74C8
!Define_SMW_SprTable_1504 #= $74F4
!Define_SMW_SprTable_151C #= $3284
!Define_SMW_SprTable_1528 #= $329A
!Define_SMW_SprTable_1534 #= $32B0
!Define_SMW_SprTable_1540 #= $32C6
!Define_SMW_SprTable_154C #= $32DC
!Define_SMW_SprTable_1558 #= $32F2
!Define_SMW_SprTable_1564 #= $3308
!Define_SMW_SprTable_1570 #= $331E
!Define_SMW_SprTable_157C #= $3334
!Define_SMW_SprTable_1594 #= $3360
!Define_SMW_SprTable_15A0 #= $3376
!Define_SMW_SprTable_15AC #= $338C
!Define_SMW_SprTable_15B8 #= $7520
!Define_SMW_SprTable_15C4 #= $7536
!Define_SMW_SprTable_15DC #= $7562
!Define_SMW_SprTable_15EA #= $33A2
!Define_SMW_SprTable_15F6 #= $33B8
!Define_SMW_SprTable_1602 #= $33CE
!Define_SMW_SprTable_160E #= $33E4
!Define_SMW_SprTable_161A #= $7578
!Define_SMW_SprTable_1626 #= $758E
!Define_SMW_SprTable_163E #= $33FA
!Define_SMW_SprTable_164A #= $75BA
!Define_SMW_SprTable_1656 #= $75D0
!Define_SMW_SprTable_1662 #= $75EA
!Define_SMW_SprTable_166E #= $7600
!Define_SMW_SprTable_167A #= $7616
!Define_SMW_SprTable_1686 #= $762C
!Define_SMW_SprTable_186C #= $7642
!Define_SMW_SprTable_187B #= $3410
!Define_SMW_SprTable_190F #= $7658
!Define_SMW_SprTable_1FD6 #= $766E
!Define_SMW_SprTable_1FE2 #= $7FD6
endif
; Each relocatable sprite table, defaulting to where it is today.
; A base that moves the sprite tables sets these instead; every
; per-sprite alias below is defined against the table rather than an
; address, so the aliases and every call site follow automatically.
if defined("Define_SMW_SprTable_14C8") == 0
!Define_SMW_SprTable_14C8 #= !Define_SMW_LowRAMLocation+$14C8
endif
if defined("Define_SMW_SprTable_14D4") == 0
!Define_SMW_SprTable_14D4 #= !Define_SMW_LowRAMLocation+$14D4
endif
if defined("Define_SMW_SprTable_14EC") == 0
!Define_SMW_SprTable_14EC #= !Define_SMW_LowRAMLocation+$14EC
endif
if defined("Define_SMW_SprTable_1504") == 0
!Define_SMW_SprTable_1504 #= !Define_SMW_LowRAMLocation+$1504
endif
if defined("Define_SMW_SprTable_151C") == 0
!Define_SMW_SprTable_151C #= !Define_SMW_LowRAMLocation+$151C
endif
if defined("Define_SMW_SprTable_1528") == 0
!Define_SMW_SprTable_1528 #= !Define_SMW_LowRAMLocation+$1528
endif
if defined("Define_SMW_SprTable_1534") == 0
!Define_SMW_SprTable_1534 #= !Define_SMW_LowRAMLocation+$1534
endif
if defined("Define_SMW_SprTable_1540") == 0
!Define_SMW_SprTable_1540 #= !Define_SMW_LowRAMLocation+$1540
endif
if defined("Define_SMW_SprTable_154C") == 0
!Define_SMW_SprTable_154C #= !Define_SMW_LowRAMLocation+$154C
endif
if defined("Define_SMW_SprTable_1558") == 0
!Define_SMW_SprTable_1558 #= !Define_SMW_LowRAMLocation+$1558
endif
if defined("Define_SMW_SprTable_1564") == 0
!Define_SMW_SprTable_1564 #= !Define_SMW_LowRAMLocation+$1564
endif
if defined("Define_SMW_SprTable_1570") == 0
!Define_SMW_SprTable_1570 #= !Define_SMW_LowRAMLocation+$1570
endif
if defined("Define_SMW_SprTable_157C") == 0
!Define_SMW_SprTable_157C #= !Define_SMW_LowRAMLocation+$157C
endif
if defined("Define_SMW_SprTable_1594") == 0
!Define_SMW_SprTable_1594 #= !Define_SMW_LowRAMLocation+$1594
endif
if defined("Define_SMW_SprTable_15A0") == 0
!Define_SMW_SprTable_15A0 #= !Define_SMW_LowRAMLocation+$15A0
endif
if defined("Define_SMW_SprTable_15AC") == 0
!Define_SMW_SprTable_15AC #= !Define_SMW_LowRAMLocation+$15AC
endif
if defined("Define_SMW_SprTable_15B8") == 0
!Define_SMW_SprTable_15B8 #= !Define_SMW_LowRAMLocation+$15B8
endif
if defined("Define_SMW_SprTable_15C4") == 0
!Define_SMW_SprTable_15C4 #= !Define_SMW_LowRAMLocation+$15C4
endif
if defined("Define_SMW_SprTable_15DC") == 0
!Define_SMW_SprTable_15DC #= !Define_SMW_LowRAMLocation+$15DC
endif
if defined("Define_SMW_SprTable_15EA") == 0
!Define_SMW_SprTable_15EA #= !Define_SMW_LowRAMLocation+$15EA
endif
if defined("Define_SMW_SprTable_15F6") == 0
!Define_SMW_SprTable_15F6 #= !Define_SMW_LowRAMLocation+$15F6
endif
if defined("Define_SMW_SprTable_1602") == 0
!Define_SMW_SprTable_1602 #= !Define_SMW_LowRAMLocation+$1602
endif
if defined("Define_SMW_SprTable_160E") == 0
!Define_SMW_SprTable_160E #= !Define_SMW_LowRAMLocation+$160E
endif
if defined("Define_SMW_SprTable_161A") == 0
!Define_SMW_SprTable_161A #= !Define_SMW_LowRAMLocation+$161A
endif
if defined("Define_SMW_SprTable_1626") == 0
!Define_SMW_SprTable_1626 #= !Define_SMW_LowRAMLocation+$1626
endif
if defined("Define_SMW_SprTable_163E") == 0
!Define_SMW_SprTable_163E #= !Define_SMW_LowRAMLocation+$163E
endif
if defined("Define_SMW_SprTable_164A") == 0
!Define_SMW_SprTable_164A #= !Define_SMW_LowRAMLocation+$164A
endif
if defined("Define_SMW_SprTable_1656") == 0
!Define_SMW_SprTable_1656 #= !Define_SMW_LowRAMLocation+$1656
endif
if defined("Define_SMW_SprTable_1662") == 0
!Define_SMW_SprTable_1662 #= !Define_SMW_LowRAMLocation+$1662
endif
if defined("Define_SMW_SprTable_166E") == 0
!Define_SMW_SprTable_166E #= !Define_SMW_LowRAMLocation+$166E
endif
if defined("Define_SMW_SprTable_167A") == 0
!Define_SMW_SprTable_167A #= !Define_SMW_LowRAMLocation+$167A
endif
if defined("Define_SMW_SprTable_1686") == 0
!Define_SMW_SprTable_1686 #= !Define_SMW_LowRAMLocation+$1686
endif
if defined("Define_SMW_SprTable_186C") == 0
!Define_SMW_SprTable_186C #= !Define_SMW_LowRAMLocation+$186C
endif
if defined("Define_SMW_SprTable_187B") == 0
!Define_SMW_SprTable_187B #= !Define_SMW_LowRAMLocation+$187B
endif
; Slot 9 of the table at $187B, not a table of its own: the koopa kid
; battle reads a background number out of it, and it follows that table
; wherever a layout puts it.
!Define_SMW_SprTable_1884 #= !Define_SMW_SprTable_187B+$09
if defined("Define_SMW_SprTable_190F") == 0
!Define_SMW_SprTable_190F #= !Define_SMW_LowRAMLocation+$190F
endif
if defined("Define_SMW_SprTable_1FD6") == 0
!Define_SMW_SprTable_1FD6 #= !Define_SMW_LowRAMLocation+$1FD6
endif
if defined("Define_SMW_SprTable_1FE2") == 0
!Define_SMW_SprTable_1FE2 #= !Define_SMW_LowRAMLocation+$1FE2
endif
;Mirrored RAM
; Temporary scratch RAM used to store values for later use within a routine.
; Commonly used to pass values to or from subroutines beyond just what can
; be carried in A/X/Y. Notably, in custom blocks, $03 contains the 16-bit
; Map16 tile number of the block.
!RAM_SMW_Misc_ScratchRAM00 #= !Define_SMW_DirectPageLocation+$00
!RAM_SMW_Misc_ScratchRAM01 #= !Define_SMW_DirectPageLocation+$01
!RAM_SMW_Misc_ScratchRAM02 #= !Define_SMW_DirectPageLocation+$02
!RAM_SMW_Misc_ScratchRAM03 #= !Define_SMW_DirectPageLocation+$03
!RAM_SMW_Misc_ScratchRAM04 #= !Define_SMW_DirectPageLocation+$04
!RAM_SMW_Misc_ScratchRAM05 #= !Define_SMW_DirectPageLocation+$05
!RAM_SMW_Misc_ScratchRAM06 #= !Define_SMW_DirectPageLocation+$06
!RAM_SMW_Misc_ScratchRAM07 #= !Define_SMW_DirectPageLocation+$07
!RAM_SMW_Misc_ScratchRAM08 #= !Define_SMW_DirectPageLocation+$08
!RAM_SMW_Misc_ScratchRAM09 #= !Define_SMW_DirectPageLocation+$09
!RAM_SMW_Misc_ScratchRAM0A #= !Define_SMW_DirectPageLocation+$0A
!RAM_SMW_Misc_ScratchRAM0B #= !Define_SMW_DirectPageLocation+$0B
!RAM_SMW_Misc_ScratchRAM0C #= !Define_SMW_DirectPageLocation+$0C
!RAM_SMW_Misc_ScratchRAM0D #= !Define_SMW_DirectPageLocation+$0D
!RAM_SMW_Misc_ScratchRAM0E #= !Define_SMW_DirectPageLocation+$0E
!RAM_SMW_Misc_ScratchRAM0F #= !Define_SMW_DirectPageLocation+$0F
; If the value in it is not zero, run the actual game; otherwise, loop
; forever. It's set to a non-zero value during NMI, and it's set to zero
; after the game mode has been run, so that the game runs exactly once a
; frame - one NMI trigger per frame.
!RAM_SMW_Flag_Lagging #= !Define_SMW_DirectPageLocation+$10
; Used to distinguish IRQ #1 from IRQ #2's code. (Inside the
; Morton/Ludwig/Roy room, where IRQ is used twice, although it can be used
; in other areas that run IRQ as well.) #$00 = IRQ #1; #$01 = IRQ #2.
!RAM_SMW_Flag_IRQToUse #= !Define_SMW_DirectPageLocation+$11
; Stripe image loader - value must be divisible by 3.
!RAM_SMW_Graphics_StripeImageToUpload #= !Define_SMW_DirectPageLocation+$12
; True frame counter. Increments once per frame, except when the game is
; lagging. Note that $7E:0014 is better suited for most purposes.
!RAM_SMW_Counter_GlobalFrames #= !Define_SMW_DirectPageLocation+$13
; Effective frame counter. Stops when, for example, RAM addresses such as
; $7E:009D are not zero (lock sprite flag, usually indicates the player is
; dying, grabbing a powerup, or something similar). Inside sprite code, this
; address is often preferred over $7E:0013, especially in graphics routines,
; as graphics will not be updated when the player dies if this address is
; used as an index to the tilemap.
!RAM_SMW_Counter_LocalFrames #= !Define_SMW_DirectPageLocation+$14
; Controller buttons currently held down. Format: byetUDLR b = A or B; y = X
; or Y; e = select; t = Start; U = up; D = down; L = left, R = right.
!RAM_SMW_IO_ControllerHold1 #= !Define_SMW_DirectPageLocation+$15
; Controller buttons newly pressed this frame. Format: byetUDLR b = B only;
; y = X or Y; e = select; t = Start; U = up; D = down; L = left, R = right.
!RAM_SMW_IO_ControllerPress1 #= !Define_SMW_DirectPageLocation+$16
; Controller buttons currently held down. Format: axlr---- a = A; x = X; l =
; L; r = R, - = null/unused.
!RAM_SMW_IO_ControllerHold2 #= !Define_SMW_DirectPageLocation+$17
; Controller buttons newly pressed this frame. Format: axlr---- a = A; x =
; X; l = L; r = R, - = null/unused.
!RAM_SMW_IO_ControllerPress2 #= !Define_SMW_DirectPageLocation+$18
; Current player powerup status.
!RAM_SMW_Player_CurrentPowerUp #= !Define_SMW_DirectPageLocation+$19
; Layer 1 X position, current frame. Mirror of SNES register $210D. For
; autoscrolling Layer 1, see $1462 instead.
!RAM_SMW_Mirror_CurrentLayer1XPosLo #= !Define_SMW_DirectPageLocation+$1A
!RAM_SMW_Mirror_CurrentLayer1XPosHi #= !RAM_SMW_Mirror_CurrentLayer1XPosLo+$01
; Layer 1 Y position, current frame. Mirror of SNES register $210E. For
; autoscrolling Layer 1, see $1464 instead.
!RAM_SMW_Mirror_CurrentLayer1YPosLo #= !RAM_SMW_Mirror_CurrentLayer1XPosLo+$02
!RAM_SMW_Mirror_CurrentLayer1YPosHi #= !RAM_SMW_Mirror_CurrentLayer1YPosLo+$01
; Layer 2 X position, current frame. Mirror of SNES register $210F. For
; autoscrolling Layer 2, see $1466 instead.
!RAM_SMW_Mirror_CurrentLayer2XPosLo #= !RAM_SMW_Mirror_CurrentLayer1XPosLo+$04
!RAM_SMW_Mirror_CurrentLayer2XPosHi #= !RAM_SMW_Mirror_CurrentLayer2XPosLo+$01
; Layer 2 Y position, current frame. Mirror of SNES register $2110. For
; autoscrolling Layer 2, see $1468 instead.
!RAM_SMW_Mirror_CurrentLayer2YPosLo #= !RAM_SMW_Mirror_CurrentLayer1XPosLo+$06
!RAM_SMW_Mirror_CurrentLayer2YPosHi #= !RAM_SMW_Mirror_CurrentLayer2YPosLo+$01
; Layer 3 X position. Mirror of SNES register $2111.
!RAM_SMW_Mirror_Layer3XPosLo #= !RAM_SMW_Mirror_CurrentLayer1XPosLo+$08
!RAM_SMW_Mirror_Layer3XPosHi #= !RAM_SMW_Mirror_Layer3XPosLo+$01
; Layer 3 Y position. Mirror of SNES register $2112.
!RAM_SMW_Mirror_Layer3YPosLo #= !RAM_SMW_Mirror_CurrentLayer1XPosLo+$0A
!RAM_SMW_Mirror_Layer3YPosHi #= !RAM_SMW_Mirror_Layer3YPosLo+$01
; If Layer 3 tides are disabled, this is the X offset of Layer 2 from Layer
; 1, calculated as $1466 - $1462. If Layer 3 tides are enabled, it is
; instead the X offset of Layer 3 from Layer 1, calculated as $22 - $1462.
; Used for handling interaction with Layer 2/3.
!RAM_SMW_Misc_SecondLevelLayerXPosLo #= !Define_SMW_DirectPageLocation+$26
!RAM_SMW_Misc_SecondLevelLayerXPosHi #= !RAM_SMW_Misc_SecondLevelLayerXPosLo+$01
; If Layer 3 tides are disabled, this is the Y offset of Layer 2 from Layer
; 1, calculated as $1468 - $1464. If Layer 3 tides are enabled, it is
; instead the Y offset of Layer 3 from Layer 1, calculated as $24 - $1464.
; Used for handling interaction with Layer 2/3.
!RAM_SMW_Misc_SecondLevelLayerYPosLo #= !Define_SMW_DirectPageLocation+$28
!RAM_SMW_Misc_SecondLevelLayerYPosHi #= !RAM_SMW_Misc_SecondLevelLayerYPosLo+$01
; Mode 7 Center X position. Mirror of SNES register $211F, + #$0080.
!RAM_SMW_Mirror_M7CenterXPosLo #= !Define_SMW_DirectPageLocation+$2A
!RAM_SMW_Mirror_M7CenterXPosHi #= !RAM_SMW_Mirror_M7CenterXPosLo+$01
; Mode 7 Center Y position. Mirror of SNES register $2120, + #$0080.
!RAM_SMW_Mirror_M7CenterYPosLo #= !Define_SMW_DirectPageLocation+$2C
!RAM_SMW_Mirror_M7CenterYPosHi #= !RAM_SMW_Mirror_M7CenterYPosLo+$01
; Mode 7 matrix parameter A. Mirror of SNES register $211B.
!RAM_SMW_Mirror_M7MatrixALo #= !Define_SMW_DirectPageLocation+$2E
!RAM_SMW_Mirror_M7MatrixAHi #= !RAM_SMW_Mirror_M7MatrixALo+$01
; Mode 7 matrix parameter B. Mirror of SNES register $211C.
!RAM_SMW_Mirror_M7MatrixBLo #= !Define_SMW_DirectPageLocation+$30
!RAM_SMW_Mirror_M7MatrixBHi #= !RAM_SMW_Mirror_M7MatrixBLo+$01
; Mode 7 matrix parameter C. Mirror of SNES register $211D.
!RAM_SMW_Mirror_M7MatrixCLo #= !Define_SMW_DirectPageLocation+$32
!RAM_SMW_Mirror_M7MatrixCHi #= !RAM_SMW_Mirror_M7MatrixCLo+$01
; Mode 7 matrix parameter D. Mirror of SNES register $211E.
!RAM_SMW_Mirror_M7MatrixDLo #= !Define_SMW_DirectPageLocation+$34
!RAM_SMW_Mirror_M7MatrixDHi #= !RAM_SMW_Mirror_M7MatrixDLo+$01
; Mode 7 rotation. Its values are calculated and stored into the respective
; Mode 7 parameter mirrors at $2E through $35. Values 0000-01FF cover one
; full rotation, with higher values simply looping that. This address is
; also used by the brown chained platform as an index to the sine and cosine
; tables at $07F7DB.
!RAM_SMW_Misc_M7RotationLo #= !Define_SMW_DirectPageLocation+$36
!RAM_SMW_Misc_M7RotationHi #= !RAM_SMW_Misc_M7RotationLo+$01
; Mode 7 scaling, i.e. making Layer 1 shrink or grow. Its values are
; calculated and stored into the respective Mode 7 parameter mirrors at $2E
; through $35. The first byte ($38) is used for horizontal scaling, while
; the second ($39) is vertical. These both default to #$20, with smaller
; values stretching the layer larger.
!RAM_SMW_Misc_M7AngleLo #= !Define_SMW_DirectPageLocation+$38
!RAM_SMW_Misc_M7AngleHi #= !RAM_SMW_Misc_M7AngleLo+$01
; Mode 7 Layer 1 X position. Mirror of SNES register $210D.
!RAM_SMW_Mirror_M7XPosLo #= !Define_SMW_DirectPageLocation+$3A
!RAM_SMW_Mirror_M7XPosHi #= !RAM_SMW_Mirror_M7XPosLo+$01
; Mode 7 Layer 1 Y position. Mirror of SNES register $210E.
!RAM_SMW_Mirror_M7YPosLo #= !RAM_SMW_Mirror_M7XPosLo+$02
!RAM_SMW_Mirror_M7YPosHi #= !RAM_SMW_Mirror_M7XPosLo+$03
; Background mode select applied with IRQ below status bar (so the area
; above IRQ is not affected by this). Format: 4321pmmm 4321 = Layer 1/2/3/4
; uses 8x8 tiles when clear, 16x16 tiles when set; p = Layer 3 absolute
; priority (only in background mode 1); mmm = background mode # (0-7).
; Mirror of SNES register $2105.
!RAM_SMW_Mirror_BGModeAndTileSizeSetting #= !Define_SMW_DirectPageLocation+$3E
; OAM Address, low byte. Also known as the mirror of SNES register $2102.
; High byte is at $00846B. Is sometimes used to alter priority of various
; sprite tiles, such as with the sprite backgrounds in the boss rooms.
!RAM_SMW_Mirror_OAMAddressLo #= !Define_SMW_DirectPageLocation+$3F
; Color math designation settings (CGADSUB), mirror of $2131. Format:
; shbo4321 s = 0 to add layers, 1 to subtract layers h = half-color mode b =
; enable on fixed color o = enable on sprites 4321 = enable on Layer 4, 3,
; 2, 1 (Layer 3 is only affected below the status bar)
!RAM_SMW_Mirror_ColorMathSelectAndEnable #= !Define_SMW_DirectPageLocation+$40
; Window mask settings, mirroring $2123-$2125. These control what layers
; each window is active on, as well as whether the window is inverted. Each
; of the three addresses has the binary format ABCDabcd : A/a = Enable
; window 2 B/b = Invert window 2 C/c = Enable window 1 D/d = Invert window 1
; The lowercase letters affect BG1, BG3, and sprites, while the upper case
; letters affect BG2, BG4, and the fixed color. Which of the layers in each
; set of three is then determined by the particular address you modify: $41:
; BG1 and BG2 $42: BG3 and BG4 $43: Sprites and fixed color
!RAM_SMW_Mirror_BG1And2WindowMaskSettings #= !Define_SMW_DirectPageLocation+$41
!RAM_SMW_Mirror_BG3And4WindowMaskSettings #= !Define_SMW_DirectPageLocation+$42
!RAM_SMW_Mirror_ObjectAndColorWindowSettings #= !Define_SMW_DirectPageLocation+$43
; Color addition select, mirror of $2130. Format: ccmm--sd cc = clip colors
; to black before math mm = prevent color math s = add subscreen (instead of
; fixed color) d = enables direct color mode for 8bpp graphics (modes 3, 4,
; and 7) For cc and mm, the values they are set to determine when they
; apply: 00 = never, 01 = outside color window only, 10 = inside color
; window only, 11 = always.
!RAM_SMW_Mirror_ColorMathInitialSettings #= !Define_SMW_DirectPageLocation+$44
; Column/row of Map16 tiles to use for VRAM upload when layer 1 is scrolling
; left/up. Its value is equal to $1A (or $1C if vertical) divided by #$10,
; minus #$08.
!RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo #= !Define_SMW_DirectPageLocation+$45
!RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpHi #= !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo+$01
; Column/row of Map16 tiles to use for VRAM upload when layer 1 is scrolling
; right/down. Its value is equal to $7E:001A (or $7E:001C if vertical)
; divided by #$10, plus #$17.
!RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownLo #= !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo+$02
!RAM_SMW_Camera_Layer1RowColumnToUpdateRightDownHi #= !RAM_SMW_Camera_Layer1RowColumnToUpdateLeftUpLo+$03
; Column/row of Map16 tiles to use for VRAM upload when interactive layer 2
; is scrolling left/up. Its value is equal to $7E:001E (or $7E:0020 if
; vertical) divided by #$10 (16), minus #$08.
!RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo #= !Define_SMW_DirectPageLocation+$49
!RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpHi #= !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo+$01
; Column/row of Map16 tiles to use for VRAM upload when interactive layer 2
; is scrolling right/down. Its value is equal to $7E:001E (or $7E:0020 if
; vertical) divided by #$10, plus #$17.
!RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateRightDownLo #= !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo+$02
!RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateRightDownHi #= !RAM_SMW_Camera_InteractiveLayer2RowColumnToUpdateLeftUpLo+$03
; Last X/Y value of layer 1 where VRAM upload of Map16 tiles was performed
; when scrolling left/up. The low 4 bits are forced to zero (AND #$FFF0) in
; order to get scroll values on a 16 pixel boundary. It is used to determine
; if a VRAM update is necessary during scrolling.
!RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo #= !Define_SMW_DirectPageLocation+$4D
!RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpHi #= !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo+$01
; Last X/Y value of layer 1 where VRAM upload of Map16 tiles was performed
; when scrolling right/down. The low 4 bits are forced to zero (AND #$FFF0)
; in order to get scroll values on a 16 pixel boundary. It is used to
; determine if a VRAM update is necessary during scrolling.
!RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateRightDownLo #= !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo+$02
!RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateRightDownHi #= !RAM_SMW_Camera_XYPositionOfLastLayer1VRAMUpdateLeftUpLo+$03
; Last X/Y value of interactive layer 2 where VRAM upload of Map16 tiles was
; performed when scrolling left/up. The low 4 bits are forced to zero (AND
; #$FFF0) in order to get scroll values on a 16 pixel boundary. It is used
; to determine if a VRAM update is necessary during scrolling.
!RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo #= !Define_SMW_DirectPageLocation+$51
!RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpHi #= !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo+$01
; Last X/Y value of interactive layer 2 where VRAM upload of Map16 tiles was
; performed when scrolling right/down. The low 4 bits are forced to zero
; (AND #$FFF0) in order to get scroll values on a 16 pixel boundary. It is
; used to determine if a VRAM update is necessary during scrolling.
!RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateRightDownLo #= !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo+$02
!RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateRightDownHi #= !RAM_SMW_Camera_XYPositionOfLastInteractiveLayer2VRAMUpdateLeftUpLo+$03
; Direction of scrolling for Layer 1. #$00 = left (or up); #$02 = right (or
; down). Used to index the various camera tables at $7E0045 to $7E0048 and
; $7E004D to $7E0050. When handling routine $00F70D, it is set to $00 if the
; player's on-screen X position is less than the value of $142A and $02
; otherwise. This is used to determine which side to enable spawning sprites
; depending which side the player is on compared to $142A. It is also
; temporarily set to #$01 during level load for loading onscreen sprites.
!RAM_SMW_Camera_Layer1ScrollingDirection #= !Define_SMW_DirectPageLocation+$55
; Direction of scrolling for Layer 2. #$00 = left (or up); #$02 = right (or
; down). Used to index the various camera tables at $7E:0049 through
; $7E:004C and $7E:0051 through $7E:0054.
!RAM_SMW_Camera_Layer2ScrollingDirection #= !Define_SMW_DirectPageLocation+$56
; Used in the level loading code. It's the position within the subscreen.
; Format: yyyyxxxx, where yyyy is the Y position (units of 16 pixels) and
; xxxx is the X position.
!RAM_SMW_Blocks_SubScrPos #= !Define_SMW_DirectPageLocation+$57
;Empty $000058
; Used in the level loading routine as an indicator for the size of the
; object, or extended object type depending on what object is being loaded.
; Could be used as scratch RAM (except in ObjecTool and similar codes).
!RAM_SMW_Blocks_SizeOrType #= !Define_SMW_DirectPageLocation+$59
; Used in the level loading routine as the object number. Could be used as
; scratch RAM (except in ObjecTool and similar codes).
!RAM_SMW_Blocks_ObjectNumber #= !Define_SMW_DirectPageLocation+$5A
; Screen mode: CD----Vv. C = Collision with either Layer 2 or Layer 3. D =
; Disable collision with Layer 1. V = Vertical Layer 2. v = Vertical Layer
; 1. - = unused. For the most part, this address is managed by a table at
; $058417, which is indexed by the level mode setting. The only exception to
; this is that the C bit may also get set if Layer 3 tides are active.
!RAM_SMW_Misc_LevelLayoutFlags #= !Define_SMW_DirectPageLocation+$5B
;Empty $00005C
; Number of screens in level (equivalent to the "number of screens" setting
; in Lunar Magic). Note that there is no differentiation here between
; horizontal and vertical levels, so you will need to check that seperately
; before using this address to handle the maximum X or Y position of
; something. See $5E instead for specifically horizontal levels, or $5F for
; specifically vertical levels. Also set to FF in Ludwig and Reznor's boss
; rooms. Instead, those rooms used a fixed width of 1.5 screens.
!RAM_SMW_Misc_ScreensInLvl #= !Define_SMW_DirectPageLocation+$5D
; In horizontal levels, used as the level's width in screens, i.e. the
; screen number (plus 1) at which the camera should stop scrolling
; rightwards. Equivalent to the "number of screens" dropdown in Lunar
; Magic's "Change Properties in Header" dialogue. Not used in vertical
; levels, where it is always set to 01; see $5F instead. Also set to 00 in
; Ludwig and Reznor's boss rooms. Instead, those rooms used a fixed width of
; 1.5 screens.
!RAM_SMW_Camera_LastScreenHoriz #= !Define_SMW_DirectPageLocation+$5E
; In vertical levels, used as the level's height in screens, i.e. the screen
; number (plus 1) at which the camera should stop scrolling downwards.
; Equivalent to the "number of screens" dropdown in Lunar Magic's "Change
; Properties in Header" dialogue. Not used in horizontal levels, where it is
; always set to 01; see $5E instead.
!RAM_SMW_Camera_LastScreenVert #= !Define_SMW_DirectPageLocation+$5F
;Empty $000060-$000063
; Properties (YXPPCCCT) byte for most sprites inside levels - including the
; player. Exceptions to this include sprites that mess with sprite priority
; in a different way, such as Piranha Plants, items coming out of a box (and
; inside the item box) and Net Koopas behind the nets.
!RAM_SMW_Sprites_TilePriority #= !Define_SMW_DirectPageLocation+$64
; 24-bit pointer to layer 1 data - both level and overworld. Also used
; during the staff roll sequence of the credits to hold some data about the
; current line being uploaded to VRAM: - $65-$66 is used to hold the first
; two bytes of the stripe image header for the current line (in little
; endian), mainly for keeping track of the Y position. - $67 tracks the
; current line number being written, with a line defined as two consecutive
; 8x8 rows.
!RAM_SMW_Misc_ScratchRAM7E0065 #= !Define_SMW_DirectPageLocation+$65
	!RAM_SMW_Pointer_Layer1DataLo #= !RAM_SMW_Misc_ScratchRAM7E0065
	!RAM_SMW_Misc_CreditsStripeImageHeaderLo #= !RAM_SMW_Pointer_Layer1DataLo
	!RAM_SMW_Misc_CreditsBackgroundPageNumber #= !RAM_SMW_Pointer_Layer1DataLo
!RAM_SMW_Misc_ScratchRAM7E0066 #= !RAM_SMW_Misc_ScratchRAM7E0065+$01
	!RAM_SMW_Pointer_Layer1DataHi #= !RAM_SMW_Pointer_Layer1DataLo+$01
	!RAM_SMW_Misc_CreditsStripeImageHeaderHi #= 	!RAM_SMW_Misc_CreditsStripeImageHeaderLo+$01
!RAM_SMW_Misc_ScratchRAM7E0067 #= !RAM_SMW_Misc_ScratchRAM7E0065+$02
	!RAM_SMW_Pointer_Layer1DataBank #= !RAM_SMW_Pointer_Layer1DataLo+$02
	!RAM_SMW_Misc_CreditsStripeImageIndex #= !RAM_SMW_Pointer_Layer1DataBank
; 24-bit pointer to layer 2 data.
!RAM_SMW_Pointer_Layer2DataLo #= !Define_SMW_DirectPageLocation+$68
!RAM_SMW_Pointer_Layer2DataHi #= !RAM_SMW_Pointer_Layer2DataLo+$01
!RAM_SMW_Pointer_Layer2DataBank #= !RAM_SMW_Pointer_Layer2DataLo+$02
; 24-bit pointer to low byte of Map16 block data. Used during level load.
!RAM_SMW_Pointer_LoMap16BlockDataLo #= !Define_SMW_DirectPageLocation+$6B
!RAM_SMW_Pointer_LoMap16BlockDataHi #= !RAM_SMW_Pointer_LoMap16BlockDataLo+$01
!RAM_SMW_Pointer_LoMap16BlockDataBank #= !RAM_SMW_Pointer_LoMap16BlockDataLo+$02
; 24-bit pointer to high byte of Map16 block data. Used during level load.
!RAM_SMW_Pointer_HiMap16BlockDataLo #= !Define_SMW_DirectPageLocation+$6E
!RAM_SMW_Pointer_HiMap16BlockDataHi #= !RAM_SMW_Pointer_HiMap16BlockDataLo+$01
!RAM_SMW_Pointer_HiMap16BlockDataBank #= !RAM_SMW_Pointer_HiMap16BlockDataLo+$02
; Player animation trigger states. When nonzero, the player character is
; performing an action and cannot be controlled by the player. Often used
; for cutscenes.
!RAM_SMW_Player_CurrentState #= !Define_SMW_DirectPageLocation+$71
; Player is in the air flag, as well as the actual pose value to store to
; $13E0 while the player is in midair. This is set to a certain value
; depending on how the player got in the air in the first place, and in what
; state they are currently (rising or sinking). This address is not affected
; by phases such as climbing. It is, however, also used in swimming
; animation. Notable values: #$0B = Jumping/swimming upwards. #$0C =
; Shooting out of a slanted pipe, running at maximum speed. #$24 =
; Descending/sinking. NOTE: Hitting bottom-solid sprites like invisible
; solid block, message block etc. does NOT set $72 to this value as cape
; mario. The address in general is used in many instances. For example, the
; game checks if this address is #$0C. If not, the player cannot ascend
; properly with the cape. Furthermore, the Layer 3 smash won't hurt the
; player if they're not on the ground (any non-zero value) and this address
; prevents the player from locking in place when still airborne during the
; Morton/Roy/Ludwig battle.
!RAM_SMW_Player_InAirFlag #= !Define_SMW_DirectPageLocation+$72
; Player is ducking flag. #$00 = No; #$04 = Yes. However, any value that is
; not zero also counts as 'Yes', SMW just stores that specific value to it.
!RAM_SMW_Player_DuckingFlag #= !Define_SMW_DirectPageLocation+$73
; Player is climbing flag. When non-zero, also indicates which of the
; player's interaction points are touching a climbable tile. Format:
; n--shftb n - Flag for climbing either a net (1) or vine (0). Determines if
; the player can move diagonally. s - Side of body is touching a climbable
; tile (MarioSide). If clear, prevents player from moving horizontally. h -
; Side of head is touching a climbable tile (HeadInside). f - Bottom of
; Mario is touching a climbable tile (MarioAbove). t - Top of Mario is
; touching a climbable tile (MarioBelow). b - Center of Mario is touching a
; climbable tile (BodyInside).
!RAM_SMW_Player_ClimbingFlag #= !Define_SMW_DirectPageLocation+$74
; Player is in water flag. #$00 = No; #$01 = Yes.
!RAM_SMW_Player_SwimmingFlag #= !Define_SMW_DirectPageLocation+$75
; Player direction. #$00 = Left; #$01 = Right.
!RAM_SMW_Player_FacingDirection #= !Define_SMW_DirectPageLocation+$76
; Player blocked status. Used to check which sides of Mario are being
; blocked by solid tiles. Format: S--M^v<> M - Mario is inside of a tile
; (BodyInside). ^ - There is a tile above Mario (MarioBelow / HeadInside). v
; - There is a tile below Mario (MarioAbove). < - There is a tile to the
; left of Mario (MarioSide). > - There is a tile to the right of Mario
; (MarioSide / HeadInside). S - Special bit indicating Mario is touching the
; side of the screen in a level that has horizontal scrolling disabled.
; Intended for autoscrollers. The game kills Mario if the M, ^, and v bits
; are all set. If either the < or > bits are set, it will push Mario 1 pixel
; to the side per frame until he's out of the block. Note that tiles 11E
; (turnblock) and 152 (invisible solid block) are explicitly coded to never
; set the M bit.
!RAM_SMW_Player_BlockedFlags #= !Define_SMW_DirectPageLocation+$77
; Flags used to disable drawing parts of the player's sprite. Format:
; dFfcEebh d - used in conjunction with all other set bits in order to
; disable processes such as the star timer decrementing. h - hide head tile
; (upper 16x16). b - hide body tile (lower 16x16). e - hide extra tile #1. E
; - hide extra tile #2. c - hide regular cape tile. f - hide extra cape
; flight tile #1. F - hide extra cape flight tile #2. Note that if this byte
; is set to #$FF, yoshi will also be hidden.
!RAM_SMW_Player_HidePlayerTileFlags #= !Define_SMW_DirectPageLocation+$78
;Empty $000079
; Accumulating fraction bits for fixed point player X speed (fractions of
; 256, see code around $00D792, this handles horizontal movement with the
; player and when the player is on the slope). Not to be confused with
; $7E13DA, which handles X position.
!RAM_SMW_Player_SubXSpeed #= !Define_SMW_DirectPageLocation+$7A
; Player X speed (8-bit, signed), in 1/16s of a pixel per frame. Positive
; speeds (01-7F) are rightwards while negative speeds (80-FF) are leftwards.
!RAM_SMW_Player_XSpeed #= !RAM_SMW_Player_SubXSpeed+$01
; Empty. Cleared on reset, titlescreen load, overworld load and level load.
!RAM_SMW_Player_SubYSpeed #= !Define_SMW_DirectPageLocation+$7C					; RAM address used in SMASE
; Player Y speed (8-bit, signed), in 1/16s of a pixel per frame. Positive
; speeds (01-7F) are downwards while negative speeds (80-FF) are upwards.
; SMW generally restricts Mario's downwards speed to a maximum of #$40,
; although because the game applies gravity after capping the speed, the
; actual maximum downwards speed is either #$43 (holding A/B) or #$46 (not
; holding A/B).
!RAM_SMW_Player_YSpeed #= !RAM_SMW_Player_SubYSpeed+$01
; Player X position (16-bit), within the borders of the screen.
!RAM_SMW_Player_OnScreenPosXLo #= !Define_SMW_DirectPageLocation+$7E
!RAM_SMW_Player_OnScreenPosXHi #= !RAM_SMW_Player_OnScreenPosXLo+$01
; Player Y position (16-bit), within the borders of the screen. Note that
; this value may be displaced by $1888 (the screen shake), in addition to
; small one-pixel displacements based on Mario's powerup status and walking
; animation frame.
!RAM_SMW_Player_OnScreenPosYLo #= !Define_SMW_DirectPageLocation+$80
!RAM_SMW_Player_OnScreenPosYHi #= !RAM_SMW_Player_OnScreenPosYLo+$01
; Points to how steep the various slopes are and which parts of the slopes
; they represent. Points to $00:E5C8 in tilesets 0 and 7, and $00:E55E in
; others. The table this one points to has one byte per block, from tile 16E
; to tile 1D7. The value in these tables is then multiplied by 16, the
; lowest nibble of the sprite/player X position is added, and this is then
; used as an index to $00:E632 to tell how many pixels the sprite/player
; should move down from the nearest 16x16 tile.
!RAM_SMW_Pointer_SlopeSteepnessLo #= !Define_SMW_DirectPageLocation+$82
!RAM_SMW_Pointer_SlopeSteepnessHi #= !RAM_SMW_Pointer_SlopeSteepnessLo+$01
!RAM_SMW_Pointer_SlopeSteepnessBank #= !RAM_SMW_Pointer_SlopeSteepnessLo+$02
; Water level flag. #$00 = No; #$01 = Yes.
!RAM_SMW_Flag_UnderwaterLevel #= !Define_SMW_DirectPageLocation+$85
; Slippery level flag. #$00 = No; #$01 through #$7F = Half-slippery; #$80
; through #$FF = Yes. Possible values in the clean ROM are #$00 and #$80.
!RAM_SMW_Flag_IceLevel #= !Define_SMW_DirectPageLocation+$86
;Empty $000087
; How long the player goes into a pipe until they warp to another level.
; Also used as a timer in the castle destruction scenes for holding inputs.
!RAM_SMW_Player_TimerBeforeWarpingInPipe #= !Define_SMW_DirectPageLocation+$88
	!RAM_SMW_Player_CutsceneInputTimer1 #= !Define_SMW_DirectPageLocation+$88
; Action to take when the player enters or exits from a pipe (see valid
; values). It also serves as a timer for the No Yoshi cutscenes for each
; controller command (for the table at $00:C848).
!RAM_SMW_Player_PipeAction #= !Define_SMW_DirectPageLocation+$89
	!RAM_SMW_Player_CutsceneInputTimer2 #= !Define_SMW_DirectPageLocation+$89
; Used as scratch RAM by various routines; see details for more info.
!RAM_SMW_Misc_ScratchRAM8A #= !Define_SMW_DirectPageLocation+$8A
!RAM_SMW_Misc_ScratchRAM8B #= !Define_SMW_DirectPageLocation+$8B
!RAM_SMW_Misc_ScratchRAM8C #= !Define_SMW_DirectPageLocation+$8C
; Used as scratch RAM in multiple locations: During GFX file decompression,
; $8F is used for holding the current decompression operation and $8D/$8E
; are used for holding the 16-bit length of that operation. After
; decompressing GFX33, all three of these get used as a 24-bit pointer to
; its decompressed data for the purpose of converting it from 3BPP to 4BPP.
; During the player-object interaction routine, $8D is used as a backup of
; $13EF (player on ground flag), $8E is used as a backup of $5B (layer
; interaction and vertical flags), and $8F is used as a copy of $72 (player
; in air flag). $8D is used to detect if code for being on top of a tile
; should be run, $8E is used for handling whether tile interaction should
; occur and whether the player should move horizontally with the layer, and
; $8F is used to detect whether the player has just landed (for the purposes
; of ground stomps, cape smashes, and breaking turnblocks) or has not been
; on the ground for at least a frame (for entering doors and horizontal
; pipes).
!RAM_SMW_Misc_ScratchRAM8D #= !Define_SMW_DirectPageLocation+$8D
!RAM_SMW_Misc_ScratchRAM8E #= !Define_SMW_DirectPageLocation+$8E
!RAM_SMW_Misc_ScratchRAM8F #= !Define_SMW_DirectPageLocation+$8F
; Player Y position within a block. Calculated with $7E:0096 & #$0F.
; Indicates whether the player is touching the top or the bottom of the
; block.
!RAM_SMW_Player_YPosInBlock #= !Define_SMW_DirectPageLocation+$90
; Y position of the player's head and feet within a block. For the head
; interaction, this is calculated by taking the player's Y position, adding
; it with the interaction point offset of MarioAbove, and limiting it to the
; lowest four bits. For the feet interaction, this is handled by simply
; storing $7E0090 (the player's Y position within the block) to this
; address. This is used to calculate how far the interaction points are
; inside of a block (values of $00 - $07 denotes the top half while $08 -
; $0F denotes the bottom half) and to determine which direction the player
; should be pushed out if the block is solid.
!RAM_SMW_Player_VerticalDirectionToPushOutOfBlock #= !Define_SMW_DirectPageLocation+$91
; Player X position within a block. Calculated with $7E:0094 + #$08 & #$0F.
!RAM_SMW_Player_XPosInBlock #= !Define_SMW_DirectPageLocation+$92
; The side of a block the player is on. It's set to #$00 for the right side
; and #$01 for the left side. This address is relative to the block the
; player is currently inside.
!RAM_SMW_Player_HorizontalSideOfBlockBeingTouched #= !Define_SMW_DirectPageLocation+$93
; Player X position (16-bit) within the level, next frame (calculates player
; position one frame ahead, as opposed to $D1). It's also used as a player X
; position on-screen on the overworld border. NOTE: During player
; interaction with blocks on Layer 2, this value is modified to be relative
; to Layer 2's position rather than Layer 1. This can be checked via $1933,
; and can be offset back to Layer 1 by subtracting $26.
!RAM_SMW_Player_XPosLo #= !Define_SMW_DirectPageLocation+$94
!RAM_SMW_Player_XPosHi #= !RAM_SMW_Player_XPosLo+$01
; Player Y position (16-bit) within the level, next frame (calculates player
; position one frame ahead, as opposed to $D3). It's also used as a player Y
; position on-screen on the overworld border. NOTE: the player's Y position
; is not affected by their powerup, nor whether they are crouching; the
; point will always be 32 pixels above their feet. However, if riding on
; Yoshi, their Y position does get offset 16 pixels upwards. Additionally,
; during player interaction with blocks on Layer 2, this value is modified
; to be relative to Layer 2's position rather than Layer 1. This can be
; checked via $1933, and can be offset back to Layer 1 by subtracting $28.
!RAM_SMW_Player_YPosLo #= !Define_SMW_DirectPageLocation+$96
!RAM_SMW_Player_YPosHi #= !RAM_SMW_Player_YPosLo+$01
; Position (in pixels) of the collision point currently being processed for
; player interaction with blocks in the level. Also used in the creation of
; various sprite types/other blocks. $98-$99: 16-bit Y position $9A-$9B:
; 16-bit X position Note that this position is with respect to the top left
; of the layer being processed. Hence, if Layer 1 and Layer 2 are offset
; from each other, this value will differ between the two, even when Mario
; is at the same position with respect to the level. Also note that, in
; vertical levels, the X and Y position may be swapped after running certain
; block changing routines (e.g. $00BEB0 or the ChangeMap16 routine included
; with various tools).
!RAM_SMW_Blocks_YPosLo #= !Define_SMW_DirectPageLocation+$98
!RAM_SMW_Blocks_YPosHi #= !RAM_SMW_Blocks_YPosLo+$01
!RAM_SMW_Blocks_XPosLo #= !Define_SMW_DirectPageLocation+$9A
!RAM_SMW_Blocks_XPosHi #= !RAM_SMW_Blocks_XPosLo+$01
; Map16 tile to generate (used with $00BEB0).
!RAM_SMW_Blocks_Map16ToGenerate #= !Define_SMW_DirectPageLocation+$9C
; Lock animation and sprites flag. Most codes will still run if this is set,
; but almost nothing will move or animate. Set by a number of events such as
; screen scrolling, entering pipes, dying, and more. Notably, not set when
; the game is actually paused by $13D4, since most resource processing is
; skipped altogether by that flag. However, UberASM codes still run prior to
; that flag being checked, so in those you'll need to check both to prevent
; any unwanted code from running while the game is frozen.
!RAM_SMW_Flag_SpritesLocked #= !Define_SMW_DirectPageLocation+$9D
; Sprite number, or Acts Like setting for custom sprites. To check the
; actual sprite ID for custom sprites, see $7FAB9E instead.
if defined("Define_SMW_SprTable_009E") == 0
!Define_SMW_SprTable_009E #= !Define_SMW_DirectPageLocation+$9E
endif
!RAM_SMW_NorSpr_SpriteID #= !Define_SMW_SprTable_009E
; Sprite Y speed table.
if defined("Define_SMW_SprTable_00AA") == 0
!Define_SMW_SprTable_00AA #= !Define_SMW_DirectPageLocation+$AA
endif
!RAM_SMW_NorSpr_YSpeed #= !Define_SMW_SprTable_00AA
; Sprite X speed table.
if defined("Define_SMW_SprTable_00B6") == 0
!Define_SMW_SprTable_00B6 #= !Define_SMW_DirectPageLocation+$B6
endif
!RAM_SMW_NorSpr_XSpeed #= !Define_SMW_SprTable_00B6
; Miscellaneous sprite table. In SMW, it's commonly used as a pointer to
; different parts of a sprite.
if defined("Define_SMW_SprTable_00C2") == 0
!Define_SMW_SprTable_00C2 #= !Define_SMW_DirectPageLocation+$C2
endif
!RAM_SMW_NorSpr_Table7E00C2 #= !Define_SMW_SprTable_00C2
	!RAM_SMW_NorSprXXX_CurrentlyActiveBoss #= !RAM_SMW_NorSpr_Table7E00C2
; 24-bit pointer to level's sprite data.
!RAM_SMW_Pointer_SpriteListDataLo #= !Define_SMW_DirectPageLocation+$CE
!RAM_SMW_Pointer_SpriteListDataHi #= !RAM_SMW_Pointer_SpriteListDataLo+$01
!RAM_SMW_Pointer_SpriteListDataBank #= !RAM_SMW_Pointer_SpriteListDataLo+$02
; Player X position (16-bit) within the level, current frame (as opposed to
; $94).
!RAM_SMW_Player_CurrentXPosLo #= !RAM_SMW_Player_XPosLo+$3D				;$0000D1
!RAM_SMW_Player_CurrentXPosHi #= !RAM_SMW_Player_CurrentXPosLo+$01
; Player Y position (16-bit) within the level, current frame (as opposed to
; $96).
!RAM_SMW_Player_CurrentYPosLo #= !RAM_SMW_Player_YPosLo+$3D				;$0000D3
!RAM_SMW_Player_CurrentYPosHi #= !RAM_SMW_Player_CurrentYPosLo+$01
; Scratch RAM used by the Wiggler to hold a 24-bit pointer to its segment
; X/Y position table at $7F9A7B.
!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo #= !Define_SMW_DirectPageLocation+$D5
!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrHi #= !RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo+$01
!RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrBank #= !RAM_SMW_NorSpr086_Wiggler_SegmentPosPtrLo+$02
; Sprite Y position, low byte.
if defined("Define_SMW_SprTable_00D8") == 0
!Define_SMW_SprTable_00D8 #= !Define_SMW_DirectPageLocation+$D8
endif
!RAM_SMW_NorSpr_YPosLo #= !Define_SMW_SprTable_00D8
!RAM_SMW_NorSpr_XPosLo #= !RAM_SMW_NorSpr_YPosLo+(!Define_SMW_MaxNormalSpriteSlot+$01)
; Where the shipped cartridge keeps those two tables, for the seven sites
; that address one fixed slot's byte directly -- Bowser's bowling ball and
; Princess Peach in slot 8, and slot 0 in the level-load init. SA-1 Pack
; rewrites none of these because it replaces the code around them: a JML
; over each slot-8 spawn to code of its own, and the init routine whole.
; Dead on that base, and kept as the pack leaves them.
!RAM_SMW_NorSpr_YPosLo_AsShipped #= !Define_SMW_DirectPageLocation+$D8
!RAM_SMW_NorSpr_XPosLo_AsShipped #= !Define_SMW_DirectPageLocation+$E4
; How code reaches the current slot's byte of the sprite number and the two
; position low bytes -- the three tables the SA-1 base takes off the direct
; page. On the shipped cartridge the slot is X, so each of these expands to
; `!Table,x`; on that base the tables sit in I-RAM, out of reach of a
; two-byte instruction, and SA-1 Pack keeps a direct-page pointer to the
; current slot's byte of each, set wherever the slot changes, so the same
; line expands to `(!Pointer)`: the same length, over the same bytes. The
; mode lives in the define so that one line assembles both cartridges, and
; code never writes `!Table,x` for these three itself.
!RAM_SMW_NorSpr_SpriteID_x = "!RAM_SMW_NorSpr_SpriteID,x"
!RAM_SMW_NorSpr_YPosLo_x = "!RAM_SMW_NorSpr_YPosLo,x"
!RAM_SMW_NorSpr_XPosLo_x = "!RAM_SMW_NorSpr_XPosLo,x"
; LDX and LDY have no (dp) form, so where the sprite number is loaded into
; an index register the SA-1 base reads the copy the pack keeps beside its
; pointers, refreshed with them.
!RAM_SMW_NorSpr_SpriteID_x_Cached = "!RAM_SMW_NorSpr_SpriteID,x"
; Slot 0's byte named without an index -- the cluster sprites, Reznor's sign
; and the ending's Yoshi borrow slot 0 to run code written for a normal
; sprite. The pack points its pointers at slot 0 around each of those, so on
; the SA-1 base these are the same indirect access.
!RAM_SMW_NorSpr_SpriteID_Slot0 = "!RAM_SMW_NorSpr_SpriteID"
!RAM_SMW_NorSpr_YPosLo_Slot0 = "!RAM_SMW_NorSpr_YPosLo"
!RAM_SMW_NorSpr_XPosLo_Slot0 = "!RAM_SMW_NorSpr_XPosLo"
if defined("Define_SMW_SA1")
; SA-1 Pack's pointers to the current slot's byte of the three tables above,
; and its copy of the slot's sprite number, in bytes the 22-slot layout
; leaves free: the pointers after the two speed tables and where the X
; position's slots 10 and 11 were, the copy in $87, which nothing names on
; any cartridge.
!RAM_SMW_Misc_CurrentSpriteIDCopy #= !Define_SMW_DirectPageLocation+$87
!RAM_SMW_Pointer_SpriteIDTableLo #= !Define_SMW_DirectPageLocation+$B4
!RAM_SMW_Pointer_SpriteIDTableHi #= !RAM_SMW_Pointer_SpriteIDTableLo+$01
!RAM_SMW_Pointer_SpriteYPosTableLo #= !Define_SMW_DirectPageLocation+$CC
!RAM_SMW_Pointer_SpriteYPosTableHi #= !RAM_SMW_Pointer_SpriteYPosTableLo+$01
!RAM_SMW_Pointer_SpriteXPosTableLo #= !Define_SMW_DirectPageLocation+$EE
!RAM_SMW_Pointer_SpriteXPosTableHi #= !RAM_SMW_Pointer_SpriteXPosTableLo+$01
!RAM_SMW_NorSpr_SpriteID_x = "(!RAM_SMW_Pointer_SpriteIDTableLo)"
!RAM_SMW_NorSpr_YPosLo_x = "(!RAM_SMW_Pointer_SpriteYPosTableLo)"
!RAM_SMW_NorSpr_XPosLo_x = "(!RAM_SMW_Pointer_SpriteXPosTableLo)"
!RAM_SMW_NorSpr_SpriteID_x_Cached = "!RAM_SMW_Misc_CurrentSpriteIDCopy"
!RAM_SMW_NorSpr_SpriteID_Slot0 = "(!RAM_SMW_Pointer_SpriteIDTableLo)"
!RAM_SMW_NorSpr_YPosLo_Slot0 = "(!RAM_SMW_Pointer_SpriteYPosTableLo)"
!RAM_SMW_NorSpr_XPosLo_Slot0 = "(!RAM_SMW_Pointer_SpriteXPosTableLo)"
endif
;Empty $0000F0-$0000FF
