includefrom sa1.asm
; This patch optimizes the SMW's circle routine.
namespace Circle
pushpc

if !sa1_hijacks_external == 0
org $00CA88
	JSL SwitchCPU
	RTS

org $00CC14
incsrc "../inline/00CC14.asm"
endif
	
pullpc

Jump:
	NOP				;
	LDA $2307			;
	STA $03				;
	LDA ($04),y			;
	STA $2253			;
	STZ $2254			;
	NOP				;
	JML Back			;

SwitchCPU:
	STA $3100
	TSC
	XBA
	CMP #$37
	BEQ SA1
	LDA.b #SA1
	STA $3180
	LDA.b #SA1>>8
	STA $3181
	LDA.b #SA1>>16
	STA $3182
	JSR $1E80
	RTL
	
SA1:	PHP
	PHB
	LDA #$00
	PHA
	PLB
	LDA $3100
	REP #$30
	AND #$00FF
	PHK
	PEA.w .jslrtsreturn-1
	PEA.w $0084CF-1
	JML $00CA8D
.jslrtsreturn
	PLB
	PLP
	RTL
	
	

namespace off
