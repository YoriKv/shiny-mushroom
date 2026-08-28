; The star and pipe warps: 27 entries across four parallel tables, searched
; from the last entry down. A warp is keyed on where the player STANDS, not
; on the tile -- the star/pipe tile is only what makes the game look here --
; and each direction of a two-way pair is its own entry.
;
; The trigger is a grid cell: the low byte of TriggerColumnAndMap is the
; 16x16 column, the high byte the submap ($00 main map through $06 Star
; World), and TriggerRow the grid row. The landing is a map pixel:
; LandingXAndMap carries the pixel X in its low 9 bits and the destination
; submap in bits 9-12, LandingY the pixel Y; the landing grid position is
; derived from both at warp time.
TriggerColumnAndMap:
	dw $0011,$000A,$0009,$000B,$0012,$000A,$0007,$020A
	dw $0203,$0410,$0412,$041C,$0414,$0612,$0200,$0612
	dw $0010,$0617,$0014,$061C,$0014,$061C,$0617,$0511
	dw $0511,$0414,$0106

TriggerRow:
	dw $0007,$0003,$0010,$000E,$0017,$0018,$0012,$0014
	dw $000B,$0003,$0001,$0009,$0009,$001D,$000E,$0018
	dw $000F,$0016,$0010,$0018,$0002,$001D,$0018,$0013
	dw $0011,$0003,$0007

LandingXAndMap:
	dw $04A8,$0438,$0908,$0928,$09C8,$0948,$0D28,$0118
	dw $00A8,$0098,$00B8,$0128,$00A8,$0078,$0D28,$0408
	dw $0D78,$0108,$0DC8,$0148,$0DC8,$0948,$0B18,$0D78
	dw $0268,$0DC8,$0D28

LandingY:
	dw $0148,$00B8,$0038,$0018,$0098,$0098,$01D8,$0078
	dw $0038,$0108,$00E8,$0178,$0188,$0128,$0188,$00E8
	dw $0168,$00F8,$0188,$0108,$01D8,$0038,$0138,$0188
	dw $0078,$01D8,$01D8
