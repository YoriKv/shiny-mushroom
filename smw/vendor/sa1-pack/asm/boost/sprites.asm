includefrom sa1.asm

!Wiggers = $418800			; Don't touch!

pushpc

if !sa1_hijacks_external == 0
org $0CAB8A
	JSL window_stuff
	BRA +
	NOP #2
+	

org $03C575	; Make the light windowing gets updated every frame
	db $00

org $03CA39
incsrc "../inline/03CA39.asm"

org $03CB08
incsrc "../inline/03CB08.asm"

ORG $03D7AB
	JML ReznorFix
ReznorFix_Return:
	RTS

ORG $00BFC5
	JML CheckForSA1

ORG $01808C
	JML SpriteMain
	NOP #2

ORG $01CC28
incsrc "../inline/01CC28.asm"

ORG $01C804
incsrc "../inline/01C804.asm"
	
ORG $03DEDF
	JML Mode7Stuff
	NOP #2
Mode7Continue:

ORG $03DD7D
	JML MoreMode7
Mode7MoreContinue:

ORG $03DDE3
	NOP
	
ORG $03995E
incsrc "../inline/03995E.asm"
	
ORG $02D870
incsrc "../inline/02D870.asm"

ORG $02F015
	LDA.B #!Wiggers
ORG $02F01D
	LDA.B #!Wiggers/256
ORG $02F024
	LDA.B #!Wiggers/65536
ORG $02F0F0
	MVP !Wiggers/65536,!Wiggers/65536
	
ORG $02D689
incsrc "../inline/02D689.asm"
	
ORG $02FB33
incsrc "../inline/02FB33.asm"

ORG $01F43E
incsrc "../inline/01F43E.asm"
else
ReznorFix_Return = $03D7AF
Mode7Continue = $03DEE5
Mode7MoreContinue = $03DD81
endif
	
;=======================================;
; Macros				;
;=======================================;

macro Switch()
	LDA.B #.SNES
	STA $0183
	LDA.B #.SNES/256
	STA $0184
	LDA.B #.SNES/65536
	STA $0185
endmacro
	
pullpc

ReznorFix:
	%Switch()
	LDA #$D0
	STA $2209
	SEP #$10
-	LDA $018A
	BEQ -
	STZ $018A
	JML .Return
ReznorFix_SNES:
	REP #$31
	LDA.L $7F837B             
	TAX                       
	LDA.W #$C05A              
	ADC $00                   
	STA.L $7F837D,X           
	ORA.W #$2000              
	STA.L $7F8383,X           
	LDA.W #$0240              
	STA.L $7F837F,X           
	STA.L $7F8385,X           
	LDA.W #$38FC              
	STA.L $7F8381,X           
	STA.L $7F8387,X           
	LDA.W #$00FF              
	STA.L $7F8389,X           
	TXA                       
	CLC                       
	ADC.W #$000C              
	STA.L $7F837B             
	SEP #$30
	RTL

CheckForSA1:				; CPU: ???
	PHA				; Preserve A
	TSC				;\ You're SA-1?
	XBA				; |
	CMP #$37			; |
	BEQ .SwitchCPU			;/
	PLA				; Restore A
	JML $0086DF			; If SNES, just return.

.SwitchCPU				; CPU: SA-1
	%Switch()			;\ Call SNES and run the need.
	LDA #$D0			; |
	STA $2209			;/
	PLA				;\ Put all information need by
	STA $0100			; | SNES in XScratch RAM
	PLA				; |
	STA $0101			; |
	PLA				; |
	STA $0102			; |
	PLA				; |
	STA $0103			;/
					;
	PHA				;\ While SNES is busy,
	LDA $02,S			; | fix the return address
	STA $01,S			; | (appears to end with RTS D:)
	LDA $03,S			; |
	STA $02,S			; |
	LDA #$00			; |
	STA $03,S			;/
					;
	REP #$10			; Also another fix.
					;
-	LDA $018A			;\ Wait for SNES
	BEQ -				; |
	STZ $018A			;/
	RTL
.SNES					; CPU: SNES
	PEA.w $84CF-1			; Make the RTS return like a RTL.
	LDA $3103 : PHA			;\ Get the required information to Stack
	LDA $3102 : PHA			; | and A
	LDA $3101 : PHA			; |
	LDA $3100			;/
	JML $0086DF			; Jump to routine.

MultiplyFix3:
	STZ $2254
	NOP
	BRA $00
	ASL $2306
	LDA $2307
	ADC #$00
	JML Return_MultiplyFix3

MoreMultiplyFix:
	ASL $0E
	ROL
	ASL $0E
	ROL
	ASL $0E
	ROL
	ASL $0E
	ROL
	JML Tralalal

MultiplyFix:
	STA $2253
	STZ $2254
	NOP
	BRA $00
	ASL $2306
	LDA $2307
	ADC #$00
	JML CODE_02D6C6

Continue_03995E:
	STA $2253
	STZ $2254
	ASL $2306
	JML Return_03995E

MoreMode7:
	%Switch()
	LDA #$D0
	STA $2209
	STX $0100
-	LDA $018A
	BEQ -
	STZ $018A
	RTL
.SNES
	PHB
	LDA #$03
	PHA
	PLB
	LDX $3100
	JML Mode7MoreContinue
	
Mode7Stuff:
	%Switch()
	LDA #$D0
	STA $2209
	STX $0100
-	LDA $018A
	BEQ -
	STZ $018A
	RTL	
.SNES
	PHB
	LDA #$03
	PHA
	PLB
	LDX $3100
	LDA $326E,X
	JML Mode7Continue

Continue_01C804:
	LDA $2306
	STA $04
	STA $08
	LDA $2307
	STA $05
	STA $09
	RTL
	
fireworks_fix:
	STA $2251
	STZ $2252
	LDA $06
	STA $2253
	STZ $2254
	JML .back
fireworks_fix2:
	STA $2251
	STZ $2252
	LDA $06
	STA $2253
	STZ $2254
	JML .back

SA1_Sprites:
	PHB
	LDA #$01
	PHA
	PLB
	LDA $748F
	JML $018092

SpriteMain:
	LDA.B #SA1_Sprites
	STA $3180
	LDA.B #SA1_Sprites/256
	STA $3181
	LDA.B #SA1_Sprites/65536
	STA $3182
	JSR $1E80
	RTL

window_stuff:
	TSC
	XBA
	CMP #$37
	BNE .snes
	
	LDA.b #.snes
	STA $0183
	LDA.b #.snes>>8
	STA $0184
	LDA.b #.snes>>16
	STA $0185
	LDA #$D0
	STA $2209
-	LDA $018A
	BEQ -
	STZ $018A
	RTL
.snes
	LDA #$13
	STA $212E
	STA $212F
	RTL
