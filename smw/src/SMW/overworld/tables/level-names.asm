; XX|Y|Z

Main:
	; How to put level names together. Format: 16 bits/entry. First byte
	; contains the offsets to the second and third parts (lowest four bits
	; there is third part, upper four bits there is second), while the second
	; byte (except the highest bit, which is unused) contains the offset to the
	; first part. Note that those offsets aren't direct, they point to $049C91,
	; $049CCF, or $049CED (note: those offsets are 16bit), which contains the
	; real offsets to $049AC5.
	dw $0000 ;00
	dw $0D72 ;01
	dw $0D73 ;02
	dw $0C00 ;03
	dw $0A60 ;04
	dw $0A53 ;05
	dw $0A54 ;06
	dw $0440 ;07
	dw $0B30 ;08
	dw $0A52 ;09
	dw $0A71 ;0A
	dw $0D90 ;0B
	dw $1101 ;0C
	dw $1102 ;0D
	dw $0640 ;0E
	dw $1207 ;0F
	dw $1400 ;10
	dw $1300 ;11
	dw $02C0 ;12
	dw $0A7C ;13
	dw $0E33 ;14
	dw $0A51 ;15
	dw $02C0 ;16
	dw $0453 ;17
	dw $1800 ;18
	dw $0453 ;19
	dw $0840 ;1A
	dw $1690 ;1B
	dw $1625 ;1C
	dw $1624 ;1D
	dw $02C0 ;1E
	dw $1590 ;1F
	dw $0740 ;20
	dw $1700 ;21
	dw $1621 ;22
	dw $1623 ;23
	dw $1622 ;24
	dw $0340 ;101
	dw $0124 ;102
	dw $0123 ;103
	dw $0110 ;104
	dw $0121 ;105
	dw $0122 ;106
	dw $0D60 ;107
	dw $02C0 ;108
	dw $0D71 ;109
	dw $0D83 ;10A
	dw $0A72 ;10B
	dw $02C0 ;10C
	dw $1B00 ;10D
	dw $1A00 ;10E
	dw $19B4 ;10F
	dw $0940 ;110
	dw $1990 ;111
	dw $0000 ;112
	dw $19B3 ;113
	dw $1960 ;114
	dw $19B2 ;115
	dw $19B1 ;116
	dw $1670 ;117
	dw $0D82 ;118
	dw $0D84 ;119
	dw $0D81 ;11A
	dw $0F30 ;11B
	dw $0540 ;11C
	dw $1560 ;11D
	dw $15A1 ;11E
	dw $15A4 ;11F
	dw $15A2 ;120
	dw $1030 ;121
	dw $1577 ;122
	dw $15A3 ;123
	dw $02C0 ;124
	dw $000B ;125
	dw $000A ;126
	dw $0009 ;127
	dw $0008 ;128
	dw $02C0 ;129
	dw $1C00 ;12A
	dw $1D00 ;12B
	dw $1E00 ;12C
	dw $00E0 ;12D
	dw $02C0 ;12E
	dw $02C0 ;12F
	dw $02D2 ;130
	dw $02C0 ;131
	dw $02D3 ;132
	dw $02C0 ;133
	dw $02D1 ;134
	dw $02D4 ;135
	dw $02D5 ;136
	dw $02C0 ;137
	dw $02C0 ;138
