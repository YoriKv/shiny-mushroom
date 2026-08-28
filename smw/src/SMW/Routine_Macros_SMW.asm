;Info:
; "Note:" = Something important to note.
; "Glitch:" = Something weird SMW does that should be fixed in the optimized code.
; "Crash:" = Something that causes a crash.
; "Todo:" = Something I should look at later.
; "Optimization:" = A bit of code that could be sped up, shortened or not hardcoded.
; "Info:" = Some interesting tidit
; "LM:" = Something Lunar Magic related
; "Dependency" = List of labels and defines in a parent macro that are used by child macros.
; "Credit:" Someone how helped me with the thing pointed out.

;Credit: Shoutouts to Thomas on SMWCentral for his detailed sprite RAM usage spreadsheet and Lunar Magic hijack information
;Note: If you're making a hack with this disassembly, it's a good idea to put your changes in "Asar_Patches_SMW.asm" rather than modifying anything in this disassembly.
;Note: I have no way of verifying if the PAL V1.0/V1.1, the SMAS+W Pal and Arcade versions of SMW are 100% clean dumps. I've disassembled the ones I was able to find.

;#############################################################################################################
;#############################################################################################################

;--- Split into per-bank files for navigability. asar inlines incsrc, so
;--- this is a pure structural change; the ROM map still decides layout.
;--- Inline helpers come first: they are called from inside other bodies.

incsrc "Routines/Inline.asm"

incsrc "Banks/Bank00.asm"
incsrc "Banks/Bank01.asm"
incsrc "Banks/Bank02.asm"
incsrc "Banks/Bank03.asm"
incsrc "Banks/Bank04.asm"
incsrc "Banks/Bank05.asm"
incsrc "Banks/Bank06.asm"
incsrc "Banks/Bank07.asm"
incsrc "Banks/Bank08.asm"
incsrc "Banks/Bank0C.asm"
incsrc "Banks/Bank0D.asm"
incsrc "Banks/Bank0E.asm"
incsrc "Banks/Bank0F.asm"
