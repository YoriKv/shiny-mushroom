LevelMsg01:
if !Define_Global_ROMToAssemble == !ROM_SMW_ARCADE
	db "- SWITCH PALACE ", $1C|$80
	db "\"
	db "The  power  of th", $44|$80
	db "switch  you   hav", $44|$80
	db "pushed  will  tur", $4D|$80
	db "\"
	db "      into     ", $1B|$80
	db "\"

else
	db "- SWITCH PALACE ", $1C|$80	;!!
	db "The  power  of th", $44|$80
	db "switch  you   hav", $44|$80	;!!
	db "pushed  will  tur", $4D|$80
	db "\"
	db "      into     ", $1B|$80
	db "Your progress wil", $4B|$80
	db "also   be   saved", $1B|$80
endif
