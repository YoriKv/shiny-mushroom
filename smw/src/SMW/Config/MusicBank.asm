includeonce

;#############################################################################################################
;# The music banks: where a project's own songs and their samples live, taking
;# as many banks upward as the soundtrack needs.
;#
;# A song is big and a sample is bigger. Nine ported songs from the community's
;# own corpus, with the samples they do not share, measure 140 KB between them,
;# so a full soundtrack is a megabyte and more -- room no bank of the game's
;# own has, and more than the growable features' single run
;# (Config/ReservedBank.asm) was ever meant to hold. Like the managed graphics
;# (Config/GraphicsBank.asm), the appetite is whatever the project makes it, so
;# the storage is a run of whole banks and the count is a build setting the
;# editor raises with the soundtrack.
;#
;# Each bank is reserved whole behind a RATS tag of its own, for the reason the
;# other reservations give: asar's freespace search takes any long enough run
;# of $00, and a bank the packing has not reached is exactly that, so what
;# holds a bank is the tag over it and a bank boundary is the only line that
;# needs no tuning. SMW_MusicBankStart names the first bank's run and
;# SMW_MusicBankEnd the last bank's last byte, the pair the editor prices
;# against.
;#
;# **This run declares no address, and that is what lets it sit above the
;# graphics.** Config/GraphicsBank.asm says graphics is the last reservation
;# and nothing may reserve above it, because a run growing upward has no
;# ceiling to price against but the cartridge's end. Two growable runs cannot
;# both be last, so the rule is the sharper one it was always standing in for:
;# graphics keeps a *fixed, declarable head* -- its pointer table is at one
;# address on every cartridge, and the loader's hooks reach it there -- and is
;# the last reservation that declares one. Music needs no such thing. Every
;# byte of it is reached through the pointer tables at the run's own head, and
;# those are found by symbol rather than by address, so the run may start
;# wherever the graphics happen to end.
;#
;# Which bank that is therefore follows the graphics rather than being fixed:
;# one past the last of them, so raising Define_SMW_GraphicsBankCount moves
;# this run up and no combination of the two can collide. A build may still
;# name its own with --define Define_SMW_MusicBank, and the reservation
;# refuses one that would land on any bank below.
;#
;# The reservation needs a cartridge every bank of it exists in, and says so
;# rather than letting the image quietly double. The editor raises the count
;# with the soundtrack; the cartridge size that holds the last bank is still
;# the project's own setting.
;#############################################################################################################

; The first bank, and how many. The default sits one past the graphics banks,
; whether or not those are reserved: the graphics run is the last one that
; declares an address, so this one opens above where it would end.
if defined("Define_SMW_MusicBank") == 0
	!Define_SMW_MusicBank #= !Define_SMW_GraphicsBank+!Define_SMW_GraphicsBankCount
endif
if defined("Define_SMW_MusicBankCount") == 0
	!Define_SMW_MusicBankCount #= 1
endif
!Define_SMW_MusicBankBase #= (!Define_SMW_MusicBank<<$10)|$8000
!Define_SMW_MusicBankLast #= !Define_SMW_MusicBank+!Define_SMW_MusicBankCount-1

; Whether anything wants the banks at all. A build without the custom music
; reserves nothing, so a stock cartridge gains no RATS tag and no symbol.
!SMW_MusicBankWanted #= !FALSE
if !Define_SMW_CustomMusic == !TRUE
	!SMW_MusicBankWanted #= !TRUE
endif

!Loc_SMW_MusicBank_Tag		#= !Define_SMW_MusicBankBase+$0000	;> the first bank's RATS tag, 8 bytes
!Loc_SMW_MusicBank_Packed	#= !Define_SMW_MusicBankBase+$0008	;> the head, and SMW_MusicBankStart
!Loc_SMW_MusicBank_End		#= (!Define_SMW_MusicBankLast<<$10)|$FFFF	;> SMW_MusicBankEnd, the last bank's last byte

; The RATS tags over the banks, and the labels that bound the run. Called from
; each ROM map once every bank has emitted -- and once more below, from the
; initialize pass, which is the one that matters: asar chooses freespace
; against the file as it stands when a pass starts, so the tags have to be on
; disk before the pass that assembles a patch (Config/ReservedBank.asm has the
; measurement). The ROM map's call writes the same bytes again, which is where
; the end label the editor prices against comes from.
macro SMW_ReserveMusicBanks()
if !SMW_MusicBankWanted == !TRUE
	if !Define_SMW_MusicBankCount < 1
		error "The custom music needs at least one music bank. Check Define_SMW_MusicBankCount."
	endif
	if !Define_SMW_MusicBankLast > $7D
		error "The music banks run past bank $7D, where a LoROM cartridge ends. Fewer banks, or a lower Define_SMW_MusicBank."
	endif
	if !SMW_ReservedBankWanted == !TRUE
		if !Define_SMW_MusicBank <= !Define_SMW_ReservedBank
			error "The music banks must lie above the growable features' bank. Check the two bank defines."
		endif
	endif
	if !SMW_LevelBankWanted == !TRUE
		if !Define_SMW_MusicBank <= !Define_SMW_LevelBank
			error "The music banks must lie above the level bank. Check the two bank defines."
		endif
	endif
	if !SMW_GraphicsBankWanted == !TRUE
		if !Define_SMW_MusicBank <= !Define_SMW_GraphicsBankLast
			error "The music banks must lie above the graphics banks: graphics is the last reservation that declares an address, and this one is found by symbol instead. Check the two bank defines."
		endif
	endif
	pushpc
	; One reservation each, for the graphics banks' reason: a bank the packing
	; never reaches still has to read as taken.
	!SMW_MusicBankIndex #= 0
	while !SMW_MusicBankIndex < !Define_SMW_MusicBankCount
		%SMW_ReserveExpansionBank("The music banks", "Define_SMW_MusicBank", !Define_SMW_MusicBank+!SMW_MusicBankIndex, SMW_MusicBank!{SMW_MusicBankIndex}Start, SMW_MusicBank!{SMW_MusicBankIndex}End)
		!SMW_MusicBankIndex #= !SMW_MusicBankIndex+1
	endwhile
	; And the run's own two labels over the lot of them: the first bank's head
	; and the last bank's last byte, which is what the songs are priced
	; against. Placed rather than aliased so a symbol file carries both.
	org !Loc_SMW_MusicBank_Packed
SMW_MusicBankStart:
	org !Loc_SMW_MusicBank_End
SMW_MusicBankEnd:
	pullpc
	assert (SMW_MusicBankStart>>$10) == !Define_SMW_MusicBank, "The music banks' run is not in the bank the slot map says it is."
	assert SMW_MusicBankEnd == !Loc_SMW_MusicBank_End, "The music banks' end label is not where the layout says the last bank ends."
endif
endmacro

; The same reservation, laid down in the initialize pass -- see the macro.
if !SMW_MusicBankWanted == !TRUE
	if !FileType == !FileType_InitializeROM
		%SMW_ReserveMusicBanks()
	endif
endif

; The banks themselves, as one sequence: one org at the first bank's head,
; then the custom music's tables and blobs behind it. Nothing unless the
; feature is on, in which case nothing else shares the run.
;
; Called from the tail of each ROM map after the reservation, once every bank
; has emitted. Nothing after the ROM map reads the position this leaves.
macro SMW_PlaceMusicBanks()
if !SMW_MusicBankWanted == !TRUE
	org !Loc_SMW_MusicBank_Packed
	; One sequence across however many banks the count reserves, exactly as
	; the compressed graphics emit (Banks/Bank08.asm): crossing checks off
	; while the run emits, back to full after. asar carries a lorom emission
	; over the border itself -- $15FFFF steps to $168000 with every label
	; right -- so a blob larger than what is left of a bank simply continues.
	; The packing overwrites the RATS tags of every bank past the first,
	; which is fine on both counts a tag serves: the run it would guard is
	; now dense data no freespace search takes, and the reservation pass
	; already kept the banks out of every earlier search.
	check bankcross off
	%SMW_PlaceCustomMusic()
	check bankcross full
	; One byte conservative at the edge: a run that fills the last bank to
	; the byte leaves pc at the next bank's $8000 and reads as outgrown. A
	; soundtrack that exact pays one more bank rather than the assert a
	; blind spot.
	assert pc() <= !Loc_SMW_MusicBank_End, "The custom music has outgrown the banks reserved for it. Raise Define_SMW_MusicBankCount, and the cartridge size with it."
endif
endmacro
