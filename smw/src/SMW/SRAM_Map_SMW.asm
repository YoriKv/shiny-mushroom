incsrc "Config/Versions.asm"

if ver_is_smasw(!Define_Global_ROMToAssemble)
else
; Where the three save files and their backups live. The cartridge's SRAM
; on every shipped release; a base that keeps them elsewhere sets the define
; on the command line -- SA-1 Pack keeps them in BW-RAM at $41C000, which
; is where the sa1 base puts them. Everything that reads a file names it
; through these, and the one place that carries a file's position as a
; 16-bit offset spells it as the difference of two of them.
if defined("Define_SMW_SaveDataLocation") == 0
!Define_SMW_SaveDataLocation = !SRAMBankBaseAddress
endif
!SRAM_SMW_MarioA_StartLocation = !Define_SMW_SaveDataLocation
!SRAM_SMW_MarioB_StartLocation = !SRAM_SMW_MarioA_StartLocation+(!Define_SMW_Misc_SaveFileSize*$01)
!SRAM_SMW_MarioC_StartLocation = !SRAM_SMW_MarioA_StartLocation+(!Define_SMW_Misc_SaveFileSize*$02)
!SRAM_SMW_MarioA_Backup = !SRAM_SMW_MarioA_StartLocation+(!Define_SMW_Misc_SaveFileSize*$03)
!SRAM_SMW_MarioB_Backup = !SRAM_SMW_MarioA_StartLocation+(!Define_SMW_Misc_SaveFileSize*$04)
!SRAM_SMW_MarioC_Backup = !SRAM_SMW_MarioA_StartLocation+(!Define_SMW_Misc_SaveFileSize*$05)
endif