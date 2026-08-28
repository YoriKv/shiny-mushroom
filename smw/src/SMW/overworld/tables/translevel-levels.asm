; Which level number each translevel loads, one word per translevel -- the
; table that replaces SMW_SpecifySublevelToLoad's arithmetic when
; !Define_SMW_TranslevelRemap is on. Only assembled under that define, at the
; head of the run the growable features share (Config/ReservedBank.asm); the
; stock game computes the number instead (subtract $24 past the main map's
; range, add $100 on a submap) and holds no such table.
;
; These rows reproduce that arithmetic for the shipped tilemap, whose scan
; hands out $01-$24 on the main map and $25-$5C on the submaps -- so an
; unedited table loads exactly what the computation loads. Rows $5D-$5F
; continue the submap pattern for tiles the shipped map does not have, and
; row $00 is zero: the scan starts at 1, so no tile carries translevel zero.
LevelNumbers:
	dw $0000,$0001,$0002,$0003,$0004,$0005,$0006,$0007						;> $00-$07
	dw $0008,$0009,$000A,$000B,$000C,$000D,$000E,$000F						;> $08-$0F
	dw $0010,$0011,$0012,$0013,$0014,$0015,$0016,$0017						;> $10-$17
	dw $0018,$0019,$001A,$001B,$001C,$001D,$001E,$001F						;> $18-$1F
	dw $0020,$0021,$0022,$0023,$0024,$0101,$0102,$0103						;> $20-$27
	dw $0104,$0105,$0106,$0107,$0108,$0109,$010A,$010B						;> $28-$2F
	dw $010C,$010D,$010E,$010F,$0110,$0111,$0112,$0113						;> $30-$37
	dw $0114,$0115,$0116,$0117,$0118,$0119,$011A,$011B						;> $38-$3F
	dw $011C,$011D,$011E,$011F,$0120,$0121,$0122,$0123						;> $40-$47
	dw $0124,$0125,$0126,$0127,$0128,$0129,$012A,$012B						;> $48-$4F
	dw $012C,$012D,$012E,$012F,$0130,$0131,$0132,$0133						;> $50-$57
	dw $0134,$0135,$0136,$0137,$0138,$0139,$013A,$013B						;> $58-$5F
