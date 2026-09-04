; Lunar Magic's eighth secondary-header byte, one per level, RL-ooooo: R the
; entrance places the foreground and background relative to the player, L
; the player faces left, ooooo the background's height in rows less one, or
; its offset where the seventh byte's O bit is set. $1A is the stock 27-row
; background. The load's placement reads R and ooooo and the offset stub L
; (Config/LunarMagicLevels.asm). Only assembled under
; !Define_SMW_LunarMagicLevels, into the level bank.
Background:
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 000-00F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 010-01F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 020-02F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 030-03F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 040-04F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 050-05F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 060-06F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 070-07F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 080-08F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 090-09F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 0A0-0AF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 0B0-0BF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 0C0-0CF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 0D0-0DF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 0E0-0EF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 0F0-0FF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 100-10F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 110-11F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 120-12F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 130-13F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 140-14F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 150-15F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 160-16F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 170-17F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 180-18F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 190-19F
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 1A0-1AF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 1B0-1BF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 1C0-1CF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 1D0-1DF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 1E0-1EF
	db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A ; 1F0-1FF
