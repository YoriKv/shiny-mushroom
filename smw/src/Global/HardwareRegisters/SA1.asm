includeonce
!ChipName = "SA-1"
!SRAMType = "SRAM"
!Firmware = "NULL"

; The SA-1 is a second 65c816 on the cartridge with its own memory controller.
; Registers below $2300 are written; registers from $2300 up are read. Which CPU
; may touch a register is part of its definition and is noted where it matters:
; the SNES CPU (S-CPU) owns $2200-$2208 and $2220-$2224, the SA-1 CPU (C-CPU)
; owns $2209-$220F and $2225-$22FF, and writing one from the wrong side does
; nothing on hardware even where an emulator allows it.

!REGISTER_SA1_SNESIRQControlWrite = $002200			; S-CPU write only.
	!SA1_SNESIRQControlWrite_MessageMask = $0F		; Bits 0-3 are read back by the SA-1 from $2301.
	!SA1_SNESIRQControlWrite_SNESNMItoSA1_Interrupt = $10
	!SA1_SNESIRQControlWrite_SNESResettoSA1_Reset = $20
	!SA1_SNESIRQControlWrite_SNESWaittoSA1_Wait = $40
	!SA1_SNESIRQControlWrite_SNESIRQtoSA1_Interrupt = $80
!REGISTER_SA1_EnableSNESIRQ = $002201
!REGISTER_SA1_ClearSNESIRQ = $002202
!REGISTER_SA1_SA1ResetVectorLo = $002203
!REGISTER_SA1_SA1ResetVectorHi = $002204
!REGISTER_SA1_SA1NMIVectorLo = $002205
!REGISTER_SA1_SA1NMIVectorHi = $002206
!REGISTER_SA1_SA1IRQVectorLo = $002207
!REGISTER_SA1_SA1IRQVectorHi = $002208
!REGISTER_SA1_SA1IRQControlWrite = $002209			; C-CPU write only. Sends to the SNES CPU, not to the SA-1.
	!SA1_SA1IRQControlWrite_MessageMask = $0F		; Bits 0-3 are read back by the SNES from $2300.
	!SA1_SA1IRQControlWrite_SNESNMIVector_Reg = $10		; Take the SNES NMI vector from $220C instead of the ROM header.
	!SA1_SA1IRQControlWrite_SNESIRQVector_Reg = $40		; Take the SNES IRQ vector from $220E instead of the ROM header.
	!SA1_SA1IRQControlWrite_SA1IRQtoSNES_Interrupt = $80
!REGISTER_SA1_EnableSA1IRQ = $00220A
!REGISTER_SA1_ClearSA1IRQ = $00220B
!REGISTER_SA1_SNESNMIVectorLo = $00220C				; C-CPU write only, even though the vector is the SNES CPU's.
!REGISTER_SA1_SNESNMIVectorHi = $00220D
!REGISTER_SA1_SNESIRQVectorLo = $00220E				; C-CPU write only, even though the vector is the SNES CPU's.
!REGISTER_SA1_SNESIRQVectorHi = $00220F
!REGISTER_SA1_SA1HVTimerControl = $002210
	!SA1_SA1HVTimerControl_EnableHIRQ = $01
	!SA1_SA1HVTimerControl_EnableVIRQ = $02
	!SA1_SA1HVTimerControl_HVTimerMode = $00
	!SA1_SA1HVTimerControl_LinearMode = $80
!REGISTER_SA1_SA1TimerReset = $002211
!REGISTER_SA1_HCounterLo = $002212
!REGISTER_SA1_HCounterHi = $002213
!REGISTER_SA1_VCounterLo = $002214
!REGISTER_SA1_VCounterHi = $002215
; Super MMC. Each register projects one megabyte of ROM into a block of banks:
; C is $00-$1F/$C0-$CF, D is $20-$3F/$D0-$DF, E is $80-$9F/$E0-$EF and
; F is $A0-$BF/$F0-$FF. The HiROM half always follows the register; the LoROM
; half only follows it when the projection bit is set, and otherwise keeps its
; fixed megabyte. So a ROM of 4 MB or less sets the bit on all four to mirror
; the whole image into both halves, and a larger one clears it so that the
; LoROM half stays on megabytes 0-3 while the HiROM half reaches 4-7.
!REGISTER_SA1_SuperMMCBankC = $002220
!REGISTER_SA1_SuperMMCBankD = $002221
!REGISTER_SA1_SuperMMCBankE = $002222
!REGISTER_SA1_SuperMMCBankF = $002223
	!SA1_SuperMMCBank_MegabyteMask = $07
	!SA1_SuperMMCBank_LoROMProjection_Fixed = $00
	!SA1_SuperMMCBank_LoROMProjection_Follow = $80
; Which 8 kB page of BW-RAM the $6000-$7FFF window of every LoROM bank shows.
; The two CPUs choose independently. Only the SA-1's side can point the window
; at the bitmap projection instead, through bit 7.
!REGISTER_SA1_SNESBWRAMAddressMapping = $002224
!REGISTER_SA1_SA1BWRAMAddressMapping = $002225
	!SA1_BWRAMAddressMapping_Source_Bank40 = $00
	!SA1_BWRAMAddressMapping_Source_Bank60 = $80
; BW-RAM write protection. A set bit 7 permits writes; a clear bit 7 protects
; the area described by $2228. $2226 is the SNES CPU's side and $2227 the SA-1's.
!REGISTER_SA1_SNESBWRAMWriteEnable = $002226
!REGISTER_SA1_SA1BWRAMWriteEnable = $002227
	!SA1_BWRAMWriteProtection_Enable = $00
	!SA1_BWRAMWriteProtection_Disable = $80
!REGISTER_SA1_BWRAMWriteProtectedArea = $002228
; I-RAM write protection. Each bit permits writes to one 256-byte block, so a
; set bit disables protection for that block and $FF unprotects all of I-RAM.
; $2229 is the SNES CPU's side and $222A the SA-1's.
!REGISTER_SA1_SNESIRAMWriteProtection = $002229
!REGISTER_SA1_SA1IRAMWriteProtection = $00222A
	!SA1_IRAMWriteEnable_None = $00
	!SA1_IRAMWriteEnable_3000_30FF = $01
	!SA1_IRAMWriteEnable_3100_31FF = $02
	!SA1_IRAMWriteEnable_3200_32FF = $04
	!SA1_IRAMWriteEnable_3300_33FF = $08
	!SA1_IRAMWriteEnable_3400_34FF = $10
	!SA1_IRAMWriteEnable_3500_35FF = $20
	!SA1_IRAMWriteEnable_3600_36FF = $40
	!SA1_IRAMWriteEnable_3700_37FF = $80
	!SA1_IRAMWriteEnable_All = $FF
!REGISTER_SA1_DMAControl = $002230
	!SA1_DMAControl_Source_ROM = $00
	!SA1_DMAControl_Source_BWRAM = $01
	!SA1_DMAControl_Source_IRAM = $02
	!SA1_DMAControl_Destination_IRAM = $00			; The transfer starts on the write to $2236.
	!SA1_DMAControl_Destination_BWRAM = $04			; The transfer starts on the write to $2237.
	!SA1_DMAControl_CharacterConversionType_SemiAuto = $00
	!SA1_DMAControl_CharacterConversionType_Auto = $10
	!SA1_DMAControl_DMAType_Regular = $00
	!SA1_DMAControl_DMAType_CharacterConversion = $20
	!SA1_DMAControl_Priority_SA1CPU = $00
	!SA1_DMAControl_Priority_DMA = $40
	!SA1_DMAControl_DisableDMA = $00
	!SA1_DMAControl_EnableDMA = $80
!REGISTER_SA1_CharacterConversionDMAParameters = $002231
	!SA1_CharacterConversionDMAParameters_ColorDepth_8bit = $00
	!SA1_CharacterConversionDMAParameters_ColorDepth_4bit = $01
	!SA1_CharacterConversionDMAParameters_ColorDepth_2bit = $02
	!SA1_CharacterConversionDMAParameters_CharactersPerLine_1 = $00
	!SA1_CharacterConversionDMAParameters_CharactersPerLine_2 = $04
	!SA1_CharacterConversionDMAParameters_CharactersPerLine_4 = $08
	!SA1_CharacterConversionDMAParameters_CharactersPerLine_8 = $0C
	!SA1_CharacterConversionDMAParameters_CharactersPerLine_16 = $10
	!SA1_CharacterConversionDMAParameters_CharactersPerLine_32 = $14
	!SA1_CharacterConversionDMAParameters_EndCharacterConversion = $80
!REGISTER_SA1_DMASourceLo = $002232
!REGISTER_SA1_DMASourceHi = $002233
!REGISTER_SA1_DMASourceBank = $002234
!REGISTER_SA1_DMADestinationLo = $002235
!REGISTER_SA1_DMAIRAMDestinationHi = $002236			; Writing here starts an I-RAM destined transfer.
!REGISTER_SA1_DMABWRAMDestinationHi = $002237			; Writing here starts a BW-RAM destined transfer.
!REGISTER_SA1_DMASizeLo = $002238
!REGISTER_SA1_DMASizeHi = $002239
; Format of the bitmap projection of BW-RAM into banks $60-$6F, where each byte
; written contributes only its low 2 or 4 bits to the underlying BW-RAM byte.
!REGISTER_SA1_BWRAMBitMapFormat = $00223F
	!SA1_BWRAMBitMapFormat_4bit = $00
	!SA1_BWRAMBitMapFormat_2bit = $80
!REGISTER_SA1_BitMapReg00 = $002240
!REGISTER_SA1_BitMapReg01 = $002241
!REGISTER_SA1_BitMapReg02 = $002242
!REGISTER_SA1_BitMapReg03 = $002243
!REGISTER_SA1_BitMapReg04 = $002244
!REGISTER_SA1_BitMapReg05 = $002245
!REGISTER_SA1_BitMapReg06 = $002246
!REGISTER_SA1_BitMapReg07 = $002247
!REGISTER_SA1_BitMapReg08 = $002248
!REGISTER_SA1_BitMapReg09 = $002249
!REGISTER_SA1_BitMapReg0A = $00224A
!REGISTER_SA1_BitMapReg0B = $00224B
!REGISTER_SA1_BitMapReg0C = $00224C
!REGISTER_SA1_BitMapReg0D = $00224D
!REGISTER_SA1_BitMapReg0E = $00224E
!REGISTER_SA1_BitMapReg0F = $00224F
; Arithmetic. Write both operands as 16-bit values to $2251 and $2253; five
; cycles later $2306 holds a 32-bit product, or a quotient with the remainder
; in $2308. Cumulative sum accumulates products into the 40-bit result and is
; the only mode that can reach $230A and set the overflow flag in $230B.
!REGISTER_SA1_ArithmeticType = $002250
	!SA1_ArithmeticType_Multiply = $00
	!SA1_ArithmeticType_Divide = $01
	!SA1_ArithmeticType_MultiplyAccumulate = $02
!REGISTER_SA1_MultiplicandOrDividendLo = $002251
!REGISTER_SA1_MultiplicandOrDividendHi = $002252
!REGISTER_SA1_MultiplierOrDivisorLo = $002253
!REGISTER_SA1_MultiplierOrDivisorHi = $002254
!REGISTER_SA1_VariableLengthBitProcessingSettings = $002258
	!SA1_VariableLengthBitProcessingSettings_FixedMode = $00
	!SA1_VariableLengthBitProcessingSettings_AutoIncrement = $80
!REGISTER_SA1_VariableLengthBitProcessingSourceLo = $002259
!REGISTER_SA1_VariableLengthBitProcessingSourceHi = $00225A
!REGISTER_SA1_VariableLengthBitProcessingSourceBank = $00225B
!REGISTER_SA1_SNESIRQControlRead = $002300			; Read by the SNES CPU. Reports what the SA-1 sent through $2209.
	!SA1_SNESIRQControlRead_MessageMask = $0F
	!SA1_SNESIRQControlRead_SNESNMIVector_Header = $00
	!SA1_SNESIRQControlRead_SNESNMIVector_Reg = $10
	!SA1_SNESIRQControlRead_IRQFromCharacterConversion_Interrupt = $20
	!SA1_SNESIRQControlRead_SNESIRQVector_Header = $00
	!SA1_SNESIRQControlRead_SNESIRQVector_Reg = $40
	!SA1_SNESIRQControlRead_SA1IRQtoSNES_Interrupt = $80
!REGISTER_SA1_SA1IRQControlRead = $002301			; Read by the SA-1 CPU. Reports what the SNES sent through $2200.
	!SA1_SA1IRQControlRead_MessageMask = $0F
	!SA1_SA1IRQControlRead_SNESNMItoSA1_Interrupt = $10
	!SA1_SA1IRQControlRead_DMAToSA1_Interrupt = $20
	!SA1_SA1IRQControlRead_TimerToSA1_Interrupt = $40
	!SA1_SA1IRQControlRead_SNESIRQtoSA1_Interrupt = $80
!REGISTER_SA1_HCounterReadLo = $002302
!REGISTER_SA1_HCounterReadHi = $002303
!REGISTER_SA1_VCounterReadLo = $002304
!REGISTER_SA1_VCounterReadHi = $002305
!REGISTER_SA1_ArithmeticResultLo = $002306
!REGISTER_SA1_ArithmeticResultMidLo = $002307
!REGISTER_SA1_ArithmeticResultMid = $002308
!REGISTER_SA1_ArithmeticResultMidHi = $002309
!REGISTER_SA1_ArithmeticResultHi = $00230A			; Cumulative sum only. The other two modes stop at $2309.
!REGISTER_SA1_ArithmeticOverflowFlag = $00230B
!REGISTER_SA1_VariableLengthBitProcessingDataReadLo = $00230C
!REGISTER_SA1_VariableLengthBitProcessingDataReadHi = $00230D
!REGISTER_SA1_VersionCode = $00230E				; Note: This will always return open bus if read from.
