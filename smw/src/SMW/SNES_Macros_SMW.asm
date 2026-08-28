
;---------------------------------------------------------------------------

; Which bytes of a container one stream is: !ReadFileDataOffset and
; !ReadFileSize become the incbin's bounds, and !TEMP the container's name
; for the release being assembled. Shared by the two insertion macros below.
macro SMW_ResolveLevelData(LevelName, VerDif, Data)
if stringsequal("<Data>", "LAYER_1")
	!ReadFileDataOffset = $0048
	!ReadFileSize = $004C
elseif stringsequal("<Data>", "LAYER_2")
	!ReadFileDataOffset = $0050
	!ReadFileSize = $0054
elseif stringsequal("<Data>", "SPRITES")
	!ReadFileDataOffset = $0058
	!ReadFileSize = $005C
else
	error "<Data> is not a valid level data type"
endif

if !ROM_<VerDif> != !ROM_SMW_U
	if !Define_Global_ROMToAssemble&(!ROM_<VerDif>) != $00
		!TEMP = <LevelName>_<VerDif>
	else
		!TEMP = <LevelName>
	endif
else
	!TEMP = <LevelName>
endif

!ReadFileDataOffset #= ((readfile2("levels/!TEMP.mwl", !ReadFileDataOffset))+$08)
!ReadFileSize #= (!ReadFileDataOffset+((readfile2("levels/!TEMP.mwl", !ReadFileSize))-$08))
endmacro

; One stream of a container, inserted where the assembler has got to. The
; form the roll-call screens in bank $0C and the added level files use: the
; label a pointer table names is the line above the call.
macro SMW_InsertOriginalLevelData(LevelName, VerDif, Data)
%SMW_ResolveLevelData(<LevelName>, <VerDif>, <Data>)
incbin "levels/!TEMP.mwl":(!ReadFileDataOffset)-(!ReadFileSize)
endmacro

; The same insertion with its label as an argument, which is the form every
; insertion in banks $06 and $07 takes. The label is emitted here rather than
; on the line above because, while the level banks are managed, a stream
; that does not fit the run being packed is placed at the start of the next
; one -- and that decision has to be made before the label is placed, or the
; pointer table would name the run the stream left. On a stock build the
; label lands exactly where the line above would have put it.
;
; A stream the project has deleted -- !SMW_LevelDeleted_<Label> set, from
; levels/deleted-levels.asm -- is inserted as the empty level instead: a
; zeroed header and a bare $FF terminator for a layer, a zero header byte and
; the terminator for a sprite list. The label keeps its place, so every
; pointer-table row naming it loads an empty level, and the bytes the stream
; occupied are room for the streams after it -- on a stock build as well,
; where the fitted padding behind the macro grows by what was deleted.
macro SMW_InsertLevelData(Label, LevelName, VerDif, Data)
if defined("SMW_LevelDeleted_<Label>")
	if stringsequal("<Data>", "SPRITES")
		!SMW_LevelStreamSize #= $02
	else
		!SMW_LevelStreamSize #= $06
	endif
	if !SMW_ManagedLevelPacking == !TRUE
		%SMW_ManagedLevelFit(!SMW_LevelStreamSize)
	endif
<Label>:
	if stringsequal("<Data>", "SPRITES")
		db $00,$FF
	else
		db $00,$00,$00,$00,$00,$FF
	endif
else
%SMW_ResolveLevelData(<LevelName>, <VerDif>, <Data>)
if !SMW_ManagedLevelPacking == !TRUE
	!SMW_LevelStreamSize #= !ReadFileSize-!ReadFileDataOffset
	%SMW_ManagedLevelFit(!SMW_LevelStreamSize)
endif
<Label>:
incbin "levels/!TEMP.mwl":(!ReadFileDataOffset)-(!ReadFileSize)
endif
endmacro

;---------------------------------------------------------------------------

macro SMW_AnimationTileset(Num)
	db ((SMW_LevelTileAnimations_FrameData_Local<Num>-SMW_LevelTileAnimations_FrameData_Local0)/(SMW_LevelTileAnimations_FrameData_Local1-SMW_LevelTileAnimations_FrameData_Local0)*$05)
endmacro

;---------------------------------------------------------------------------

macro SMW_LMStyleAnimationFrames(Frame1, Frame2, Frame3, Frame4)
if $<Frame1> < $0600
	!Frame1 = !RAM_SMW_Graphics_DecompressedGFX33
elseif $<Frame1> <= $087F
	!Frame1 = (($<Frame1>-$0600)*$20)+!RAM_SMW_Graphics_DecompressedGFX33
elseif $<Frame1> <= $08FF
	!Frame1 = !RAM_SMW_Graphics_DecompressedGFX32
elseif $<Frame1> <= $0BE4
	!Frame1 = (($<Frame1>-$0900)*$20)+!RAM_SMW_Graphics_DecompressedGFX32
else
	!Frame1 = !RAM_SMW_Graphics_DecompressedGFX33
endif
if $<Frame2> < $0600
	!Frame2 = !RAM_SMW_Graphics_DecompressedGFX33
elseif $<Frame2> <= $087F
	!Frame2 = (($<Frame2>-$0600)*$20)+!RAM_SMW_Graphics_DecompressedGFX33
elseif $<Frame2> <= $08FF
	!Frame2 = !RAM_SMW_Graphics_DecompressedGFX32
elseif $<Frame2> <= $0BE4
	!Frame2 = (($<Frame2>-$0900)*$20)+!RAM_SMW_Graphics_DecompressedGFX32
else
	!Frame2 = !RAM_SMW_Graphics_DecompressedGFX33
endif
if $<Frame3> < $0600
	!Frame3 = !RAM_SMW_Graphics_DecompressedGFX33
elseif $<Frame3> <= $087F
	!Frame3 = (($<Frame3>-$0600)*$20)+!RAM_SMW_Graphics_DecompressedGFX33
elseif $<Frame3> <= $08FF
	!Frame3 = !RAM_SMW_Graphics_DecompressedGFX32
elseif $<Frame3> <= $0BE4
	!Frame3 = (($<Frame3>-$0900)*$20)+!RAM_SMW_Graphics_DecompressedGFX32
else
	!Frame3 = !RAM_SMW_Graphics_DecompressedGFX33
endif
if $<Frame4> < $0600
	!Frame4 = !RAM_SMW_Graphics_DecompressedGFX33
elseif $<Frame4> <= $087F
	!Frame4 = (($<Frame4>-$0600)*$20)+!RAM_SMW_Graphics_DecompressedGFX33
elseif $<Frame4> <= $08FF
	!Frame4 = !RAM_SMW_Graphics_DecompressedGFX32
elseif $<Frame4> <= $0BE4
	!Frame4 = (($<Frame4>-$0900)*$20)+!RAM_SMW_Graphics_DecompressedGFX32
else
	!Frame4 = !RAM_SMW_Graphics_DecompressedGFX33
endif
	dw !Frame1
	dw !Frame2
	dw !Frame3
	dw !Frame4
endmacro

;---------------------------------------------------------------------------

!UP = $03
!DOWN = $02
!LEFT = $01
!RIGHT = $00
!END = $FF

macro SMW_CreateEatBlockPath(Direction, Blocks)
if !<Direction> != $FF
	if <Blocks> < $000F
		db ((<Blocks>&$01FF)<<4)+(!<Direction>&$03)
	else
		!LoopCounter = ((<Blocks>&$01FF)/$0F)
		assert <Blocks> < $0200,"512 tiles is more than enough distance for the Create/Eat Block to travel in one direction."
		assert <Blocks> > $0000,"You can't set the Create/Eat Block to move 0 tiles!"
		while !LoopCounter > 0
			db $F0+(!<Direction>&$03)
			!LoopCounter #= !LoopCounter-$01
		endif
		if (((<Blocks>&$01FF)/$0F)*$0F) != (<Blocks>&$01FF)
			db (((<Blocks>&$01FF)-(((<Blocks>&$01FF)/$0F)*$0F))<<4)+(!<Direction>&$03)
		endif
	endif
else
	db $FF
endif
endmacro

;---------------------------------------------------------------------------

; One compressed graphics file, from the set the release reads. The label
; is emitted by the macro rather than on the line above because, while the
; graphics are managed, a file that does not fit the run being packed is
; placed at the start of the next one -- and that decision has to be made
; before the label is placed, or the pointer table would name the run the
; file left. On a stock build the label lands exactly where the line above
; would have put it. GFX33 has to end in the bank GFX32 starts in: the
; boot-time decompression of the pair reads GFX32 with GFX33's ending bank,
; so the managed build asserts it where the stock layout guarantees it.
macro SMW_INCGFX(graphic)
if ver_is_japanese(!Define_Global_ROMToAssemble)
	!SMW_GraphicsFile = GFX/SMW_J/<graphic>.lz1
elseif ver_is_pal_rev1(!Define_Global_ROMToAssemble)
	!SMW_GraphicsFile = GFX/SMW_E2/<graphic>.lz1
else
	!SMW_GraphicsFile = GFX/SMW_U/<graphic>.lz2
endif
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	%SMW_ManagedGraphicsFit(filesize("!SMW_GraphicsFile"))
endif
SMW_<graphic>:
	incbin "!SMW_GraphicsFile"
<graphic>End:
if !Define_SMW_ManagedGraphicsMemory == !TRUE
	if stringsequal("<graphic>", "GFX33")
		assert (pc()-$01)>>$10 == SMW_GFX32>>$10, "GFX33 must end in the bank GFX32 starts in: the boot-time decompression reads GFX32 with the bank GFX33 ended in. Take bytes out of GFX32 or GFX33."
	endif
endif
endmacro

;---------------------------------------------------------------------------

macro SMW_InsertOriginalFreespace(ROMID, RtNum)
;print "!<ROMID>Bytes bytes of freespace located at: !<ROMID>OrgLoc"
if !Define_Global_ROMToAssemble&(!ROM_SMW_E1|!ROM_SMW_E2|!ROM_SMW_ARCADE) != $00
	%InsertVersionExclusiveFile(incbin, Misc/GarbageData<RtNum>_, !ROMID.bin, )
else
	fillbyte $FF : fill !<ROMID>Bytes
endif
endmacro

;---------------------------------------------------------------------------

; The cartridge's own padding, fitted to what is left of its run rather than
; placed at the front of it.
;
; <Address> is where the run starts and !<ROMID>Bytes how long it was on the
; shipped cartridge, so between them they name where it ends. What goes in is
; whatever is left of it from wherever the assembler has got to -- and on a
; build nobody has edited that is the whole of it, because the position is
; <Address> exactly and every byte goes in as it always did. A table in front
; of it that has grown takes its bytes out of the front of the run instead,
; and the padding gives way rather than the build refusing.
;
; The bytes that remain keep the addresses they had, which is what decides
; where a version whose padding is shipped garbage takes them from: the *tail*
; of the garbage file, so every garbage byte still in the ROM is still where
; the cartridge had it. A version padded with $FF has nothing to choose.
;
; **Only for a run that is nothing but padding.** Three of them carry bytes of
; their own at the front, so their run is longer than the count declares and
; nothing inside it may move; those stay placed, on
; %SMW_InsertOriginalFreespace and its org.
macro SMW_FitOriginalFreespace(Address, ROMID, RtNum)
!SMW_FreespaceShipped #= !<ROMID>Bytes
!SMW_FreespaceEnd #= (<Address>)+!SMW_FreespaceShipped
assert pc() <= !SMW_FreespaceEnd, "Something in front of freespace region <RtNum> has grown past the end of it."
!SMW_FreespaceKept #= !SMW_FreespaceEnd-pc()
!SMW_FreespaceFrom #= !SMW_FreespaceShipped-!SMW_FreespaceKept
if !Define_Global_ROMToAssemble&(!ROM_SMW_E1|!ROM_SMW_E2|!ROM_SMW_ARCADE) != $00
	%InsertVersionExclusiveFile(incbin, Misc/GarbageData<RtNum>_, !ROMID.bin, :!SMW_FreespaceFrom..!SMW_FreespaceShipped)
else
	fillbyte $FF : fill !SMW_FreespaceKept
endif
endmacro

;---------------------------------------------------------------------------