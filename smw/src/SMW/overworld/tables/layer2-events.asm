TileEntries:
base $000000
.Event00
.Event01
	; A table used by layer 2 events. It contains 0x173 four byte entries. The
	; first two bytes in each entry are for the source offset ($0C8000) (also
	; decides size), the last two are for the target offset ($7F4000).
	dw $0900,$23CC
	dw $0904,$238C
	dw $0908,$234E
	dw $090C,$230E
	dw $0910,$22D0
	dw $0914,$2290
	dw $018C,$2202
	dw $01B0,$2202
	dw $01D4,$2202
	dw $0A44,$21C6
	dw $0A48,$2044
	dw $0A4C,$2186
	dw $0A48,$2004
.Event02
.Event03
	dw $0900,$23E4
	dw $0938,$23A4
	dw $0928,$2324
.Event04
	dw $0918,$2326
	dw $091C,$2328
	dw $0920,$22EC
	dw $0924,$22AC
	dw $0B0C,$222C
.Event05
	dw $0B10,$21EC
	dw $0930,$216C
	dw $0934,$2168
.Event06
	dw $0938,$20E4
	dw $0938,$20A4
.Event07
	dw $093C,$1090
	dw $0940,$104C
	dw $0944,$100C
	dw $0938,$078C
	dw $0938,$070C
	dw $0928,$068C
.Event08
	dw $0948,$1014
	dw $094C,$0794
	dw $0950,$0754
.Event09
	dw $0938,$060C
	dw $0904,$058C
	dw $0954,$050E
.Event0A
	dw $09E8,$0648
	dw $09E8,$06C8
	dw $0998,$0688
.Event0B
	dw $09EC,$0512
	dw $09F0,$04D2
	dw $09F4,$0492
.Event0C
	dw $0000,$04D8
	dw $0024,$0498
	dw $0048,$03D8
	dw $006C,$0356
	dw $0090,$0356
	dw $00B4,$0356
	dw $0510,$0518
	dw $0928,$0524
	dw $0B38,$0714
.Event0D
	dw $0960,$0528
	dw $0964,$056A
	dw $0968,$05AC
	dw $096C,$062C
.Event0E
	dw $0970,$0630
.Event0F
	dw $0974,$05B2
	dw $0978,$0532
	dw $0168,$07FC
	dw $0A50,$0FC0
	dw $00D8,$077C
	dw $00FC,$077C
	dw $0120,$077C
	dw $0144,$077C
.Event10
	dw $0950,$06D4
	dw $094C,$0694
	dw $097C,$0614
	dw $0980,$0594
.Event11
	dw $0984,$0718
	dw $0988,$071A
	dw $0948,$079C
	dw $098C,$101C
.Event12
	dw $0990,$1060
	dw $0994,$1064
.Event13
	dw $0938,$10DC
.Event14
	dw $0998,$2884
.Event15
	dw $09A4,$3118
	dw $0984,$311C
	dw $09A8,$30E0
	dw $094C,$3060
.Event16
	dw $09A0,$30CA
	dw $09A0,$310E
	dw $09B0,$3110
	dw $09B4,$30CC
	dw $09B8,$308C
	dw $09BC,$300C
	dw $09BC,$278C
.Event17
	dw $09BC,$27A0
	dw $09BC,$2720
	dw $09AC,$26A0
	dw $0928,$2620
.Event18
	dw $0A00,$3064
	dw $0A04,$30A8
	dw $0A08,$3128
.Event19
	dw $0918,$2622
	dw $0998,$2626
	dw $09C0,$262A
	dw $09C4,$266C
	dw $09C8,$2670
	dw $09CC,$26B0
	dw $0928,$2730
.Event1A
	dw $09D0,$2770
	dw $0938,$27B0
	dw $0928,$3030
.Event1B
	dw $0938,$30B0
	dw $0938,$30F0
.Event1C
	dw $09D4,$31B0
	dw $09D8,$322E
	dw $0998,$322A
.Event1D
	dw $09E0,$26CC
	dw $09BC,$268C
	dw $09E4,$260C
.Event1E
	dw $09DC,$2704
	dw $09DC,$26C0
	dw $09DC,$2740
.Event1F
	dw $0998,$01B4
	dw $0B0C,$01B8
.Event20
.Event21
	dw $0B30,$0988
	dw $0B34,$09A0
	dw $0A10,$098A
	dw $0A10,$099E
	dw $0A0C,$098C
	dw $0A0C,$099C
	dw $0A10,$098E
	dw $0A10,$099A
	dw $0A0C,$0990
	dw $0A0C,$0998
	dw $0A10,$0992
	dw $0A10,$0996
.Event22
.Event23
	dw $0A14,$09A4
.Event24
	dw $03A8,$0830
	dw $0A18,$09AC
	dw $0A1C,$09F0
	dw $099C,$0A70
	dw $0A20,$0AF0
	dw $0A20,$0B70
	dw $0A20,$0BF0
	dw $0A24,$0C70
	dw $0938,$0CF0
	dw $0A28,$0D30
.Event25
	dw $0A2C,$0A98
	dw $0A30,$0A9C
.Event26
	dw $0B14,$0B10
	dw $0B18,$0B90
.Event27
	dw $0A34,$0B1C
	dw $0A38,$0B5E
	dw $0A3C,$0B62
	dw $0A40,$0B66
	dw $0A20,$0AE8
	dw $099C,$0A68
.Event28
.Event29
.Event2A
	dw $0A7C,$33A4
	dw $0A7C,$33E8
	dw $0A7C,$3468
	dw $0918,$33A2
	dw $09C0,$33A4
	dw $0930,$33E8
	dw $0A54,$3428
	dw $0938,$34A8
.Event2B
	dw $0A7C,$3398
	dw $0A7C,$339C
	dw $0A58,$339E
	dw $0998,$339C
	dw $0928,$3398
.Event2C
	dw $0A7C,$3626
	dw $0A7C,$3620
	dw $0A5C,$3568
	dw $0914,$35A8
	dw $09D8,$3626
	dw $091C,$3624
	dw $0928,$3620
.Event2D
	dw $0A7C,$352C
	dw $0A7C,$3530
	dw $0A60,$352A
	dw $0998,$352C
	dw $0998,$352E
	dw $0998,$3530
.Event2E
	dw $0A7C,$35DA
	dw $0A7C,$3498
	dw $0A7C,$3418
	dw $0A58,$361E
	dw $093C,$361C
	dw $0A64,$35D8
	dw $0944,$3598
	dw $0928,$3518
	dw $0938,$3498
	dw $0938,$3418
	dw $0928,$3398
.Event2F
	dw $0A7C,$36A0
	dw $0A7C,$3760
	dw $09D0,$3660
	dw $0938,$36E0
	dw $0938,$3760
.Event30
	dw $0A7C,$339C
	dw $0918,$339A
	dw $0998,$339C
.Event31
	dw $0A7C,$3510
	dw $0A58,$3396
	dw $0A6C,$3392
	dw $0A70,$33D0
	dw $0A74,$3410
	dw $0938,$3490
	dw $0928,$3510
.Event32
	dw $0A7C,$351C
	dw $0A7C,$3522
	dw $0998,$3514
	dw $0928,$3518
	dw $0998,$351C
	dw $0998,$3520
	dw $0998,$3524
.Event33
	dw $0A7C,$3610
	dw $09D0,$3550
	dw $0938,$3590
	dw $0928,$3610
.Event34
	dw $0A7C,$3690
	dw $0A7C,$370E
	dw $0A7C,$370A
	dw $0A7C,$3702
	dw $09D0,$3650
	dw $0A78,$36D0
	dw $091C,$370C
	dw $0998,$3708
	dw $0998,$3704
	dw $0998,$3700
.Event35
	dw $0A90,$1812
.Event36
.Event37
.Event38
	dw $0A94,$2BAA
	dw $0A98,$2BA8
	dw $0A9C,$2BA4
.Event39
	dw $0A94,$2BA2
	dw $0A98,$2BA0
.Event3A
	dw $0AA0,$2B64
.Event3B
	dw $0AA4,$2B9A
	dw $0A98,$2B98
	dw $0A98,$2B96
	dw $0A98,$2B94
	dw $0A9C,$2B90
.Event3C
	dw $0AA0,$2B5C
.Event3D
	dw $0AA0,$2B50
	dw $0AA8,$2B10
	dw $0A9C,$2A90
.Event3E
	dw $0AAC,$2A92
	dw $0A98,$2A94
	dw $0A98,$2A96
	dw $0A98,$2A98
.Event3F
	dw $0AA0,$2A50
	dw $0AA8,$2A10
	dw $0B3C,$2990
	dw $0B40,$2994
	dw $0B40,$2998
.Event40
	dw $0AA0,$2A5C
	dw $0AA8,$2A1C
	dw $0AA8,$29DC
.Event41
	dw $0AA0,$2A64
	dw $0AA8,$2A24
	dw $0AA8,$29E4
.Event42
.Event43
.Event44
.Event45
.Event46
	dw $0AB0,$1D90
	dw $09A0,$1D8C
.Event47
	dw $0AB0,$1E56
	dw $0AB4,$1E5A
	dw $0AB8,$1D5C
	dw $09A0,$1D18
	dw $0ABC,$1C90
	dw $0ABC,$1C0C
.Event48
	dw $09A0,$1E0C
	dw $0AC0,$1E8A
	dw $0AC0,$1E86
	dw $0ABC,$1E04
	dw $09A0,$1D84
	dw $0AB8,$1CC6
	dw $0AB0,$1D0C
.Event49
	dw $09A0,$1D88
	dw $09A0,$1D84
	dw $0AB4,$1D80
.Event4A
	dw $09A0,$163C
	dw $09A0,$16BC
.Event4B
	dw $09A0,$16B8
	dw $09A0,$16B4
.Event4C
	dw $09A0,$1630
.Event4D
	dw $0AA8,$1570
	dw $0AC4,$1530
	dw $0AD8,$13B8
	dw $094C,$14B0
	dw $0AC8,$1432
	dw $0ACC,$13F4
	dw $0AD0,$13B8
.Event4E
	dw $0AD4,$12B8
	dw $01F8,$11F4
	dw $021C,$11F4
	dw $0240,$11F4
	dw $0264,$11F4
	dw $0288,$11F4
	dw $02AC,$11F4
	dw $02D0,$11F4
	dw $02F4,$11F4
	dw $0318,$11F4
	dw $033C,$11B4
	dw $0360,$11B4
	dw $033C,$11B4
.Event4F
.Event50
.Event51
.Event52
	dw $0ADC,$3D10
	dw $0AE0,$3CCE
	dw $0AE4,$3C8C
	dw $0AE8,$3C48
.Event53
.Event54
.Event55
	dw $0AEC,$3C14
	dw $0AF0,$3BD6
	dw $0AF4,$3B98
	dw $0AF8,$3B5A
.Event56
.Event57
.Event58
	dw $0918,$3C26
	dw $0998,$3C28
	dw $0998,$3C2A
	dw $0998,$3C2C
.Event59
.Event5A
.Event5B
	dw $096C,$3D28
	dw $0AFC,$3D68
	dw $0B00,$3DAA
	dw $0AE4,$3DEC
	dw $0AE4,$3E2E
	dw $0ADC,$3EB0
	dw $0B3C,$2990
	dw $0B40,$2994
	dw $0B40,$2998
.Event5C
.Event5D
	dw $0B04,$3D9C
	dw $0B08,$3DD8
	dw $0B08,$3E14
	dw $0B08,$3E50
	dw $0B08,$3E8C
	dw $096C,$3E88
.Event5E
.Event5F
.Event60
	dw $0144,$077C
.Event61
	dw $0938,$19E0
	dw $0B1C,$1A20
	dw $03CC,$1ADC
	dw $03F0,$1ADC
	dw $0414,$1ADC
	dw $0438,$1B9C
	dw $045C,$1B9C
	dw $0480,$1B5C
	dw $04A4,$1B1C
	dw $04C8,$1ADC
	dw $04EC,$1A9C
.Event62
	dw $0A58,$1B1E
	dw $0B20,$1B1C
	dw $0B24,$1B1A
	dw $0B28,$1B18
.Event63
	dw $09A0,$1B94
	dw $09A0,$1C14
	dw $09A0,$1C94
	dw $0AC0,$1D14
	dw $0B2C,$1D56
	dw $09A0,$1DD4
.Event64
.Event65
	dw $0998,$3990
	dw $0998,$3994
	dw $0928,$3998
.Event66
	dw $0998,$399C
	dw $0998,$39A0
	dw $0928,$39A4
.Event67
	dw $0998,$39A8
	dw $0998,$39AC
	dw $0928,$39B0
.Event68
	dw $0998,$39B4
	dw $0998,$38B4
	dw $0928,$38B0
.Event69
	dw $0998,$38AC
	dw $0998,$38A8
	dw $0928,$38A4
.Event6A
	dw $0998,$38A0
	dw $0998,$389C
	dw $0928,$3898
.Event6B
	dw $0998,$3894
	dw $0998,$3890
	dw $0928,$388C
.Event6C
	dw $0998,$3888
	dw $0928,$3884
.Event6D
.Event6E
.Event6F
.Event70
.Event71
.Event72
.Event73
.Event74
.Event75
.Event76
.Event77
.Event78
base off
