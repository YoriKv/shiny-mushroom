; The managed graphics format table: one byte per file number, $100 rows,
; read by SMW_ManagedGraphics_Upload with the file number, and by
; SMW_ManagedGraphics_Pointer to say where the file decompresses to. 0 is
; 3bpp, the stock upload path; 1 is 4bpp, $1000 decompressed bytes copied
; to VRAM as they are; 2 is the animated tiles' shape and 3 the player's,
; the two too large for the decompression buffer, which decompress to the
; staging area at $7E2000 instead. Rows $00-$33 are the game's own files:
; 0 for every file a slot loads, since what each of those is its slot path
; decides, and their own for $32 and $33, which no slot loads and a
; feature may ask the decompressor for. Rows $34-$FE carry what
; graphics/added/formats.asm declares for an added file, 0 where it
; declares nothing; row $FF is never a file. Static: nothing regenerates
; this file. Read by Config/ManagedGraphicsMemory.asm.

	db $00				;> GFX00, a stock file
	db $00				;> GFX01, a stock file
	db $00				;> GFX02, a stock file
	db $00				;> GFX03, a stock file
	db $00				;> GFX04, a stock file
	db $00				;> GFX05, a stock file
	db $00				;> GFX06, a stock file
	db $00				;> GFX07, a stock file
	db $00				;> GFX08, a stock file
	db $00				;> GFX09, a stock file
	db $00				;> GFX0A, a stock file
	db $00				;> GFX0B, a stock file
	db $00				;> GFX0C, a stock file
	db $00				;> GFX0D, a stock file
	db $00				;> GFX0E, a stock file
	db $00				;> GFX0F, a stock file
	db $00				;> GFX10, a stock file
	db $00				;> GFX11, a stock file
	db $00				;> GFX12, a stock file
	db $00				;> GFX13, a stock file
	db $00				;> GFX14, a stock file
	db $00				;> GFX15, a stock file
	db $00				;> GFX16, a stock file
	db $00				;> GFX17, a stock file
	db $00				;> GFX18, a stock file
	db $00				;> GFX19, a stock file
	db $00				;> GFX1A, a stock file
	db $00				;> GFX1B, a stock file
	db $00				;> GFX1C, a stock file
	db $00				;> GFX1D, a stock file
	db $00				;> GFX1E, a stock file
	db $00				;> GFX1F, a stock file
	db $00				;> GFX20, a stock file
	db $00				;> GFX21, a stock file
	db $00				;> GFX22, a stock file
	db $00				;> GFX23, a stock file
	db $00				;> GFX24, a stock file
	db $00				;> GFX25, a stock file
	db $00				;> GFX26, a stock file
	db $00				;> GFX27, a stock file
	db $00				;> GFX28, a stock file
	db $00				;> GFX29, a stock file
	db $00				;> GFX2A, a stock file
	db $00				;> GFX2B, a stock file
	db $00				;> GFX2C, a stock file
	db $00				;> GFX2D, a stock file
	db $00				;> GFX2E, a stock file
	db $00				;> GFX2F, a stock file
	db $00				;> GFX30, a stock file
	db $00				;> GFX31, a stock file
	db $03				;> GFX32, the player, 4bpp already
	db $02				;> GFX33, the animated tiles, 384 tiles of 3bpp
	%SMW_ManagedGraphicsFormatRow(GFX34)
	%SMW_ManagedGraphicsFormatRow(GFX35)
	%SMW_ManagedGraphicsFormatRow(GFX36)
	%SMW_ManagedGraphicsFormatRow(GFX37)
	%SMW_ManagedGraphicsFormatRow(GFX38)
	%SMW_ManagedGraphicsFormatRow(GFX39)
	%SMW_ManagedGraphicsFormatRow(GFX3A)
	%SMW_ManagedGraphicsFormatRow(GFX3B)
	%SMW_ManagedGraphicsFormatRow(GFX3C)
	%SMW_ManagedGraphicsFormatRow(GFX3D)
	%SMW_ManagedGraphicsFormatRow(GFX3E)
	%SMW_ManagedGraphicsFormatRow(GFX3F)
	%SMW_ManagedGraphicsFormatRow(GFX40)
	%SMW_ManagedGraphicsFormatRow(GFX41)
	%SMW_ManagedGraphicsFormatRow(GFX42)
	%SMW_ManagedGraphicsFormatRow(GFX43)
	%SMW_ManagedGraphicsFormatRow(GFX44)
	%SMW_ManagedGraphicsFormatRow(GFX45)
	%SMW_ManagedGraphicsFormatRow(GFX46)
	%SMW_ManagedGraphicsFormatRow(GFX47)
	%SMW_ManagedGraphicsFormatRow(GFX48)
	%SMW_ManagedGraphicsFormatRow(GFX49)
	%SMW_ManagedGraphicsFormatRow(GFX4A)
	%SMW_ManagedGraphicsFormatRow(GFX4B)
	%SMW_ManagedGraphicsFormatRow(GFX4C)
	%SMW_ManagedGraphicsFormatRow(GFX4D)
	%SMW_ManagedGraphicsFormatRow(GFX4E)
	%SMW_ManagedGraphicsFormatRow(GFX4F)
	%SMW_ManagedGraphicsFormatRow(GFX50)
	%SMW_ManagedGraphicsFormatRow(GFX51)
	%SMW_ManagedGraphicsFormatRow(GFX52)
	%SMW_ManagedGraphicsFormatRow(GFX53)
	%SMW_ManagedGraphicsFormatRow(GFX54)
	%SMW_ManagedGraphicsFormatRow(GFX55)
	%SMW_ManagedGraphicsFormatRow(GFX56)
	%SMW_ManagedGraphicsFormatRow(GFX57)
	%SMW_ManagedGraphicsFormatRow(GFX58)
	%SMW_ManagedGraphicsFormatRow(GFX59)
	%SMW_ManagedGraphicsFormatRow(GFX5A)
	%SMW_ManagedGraphicsFormatRow(GFX5B)
	%SMW_ManagedGraphicsFormatRow(GFX5C)
	%SMW_ManagedGraphicsFormatRow(GFX5D)
	%SMW_ManagedGraphicsFormatRow(GFX5E)
	%SMW_ManagedGraphicsFormatRow(GFX5F)
	%SMW_ManagedGraphicsFormatRow(GFX60)
	%SMW_ManagedGraphicsFormatRow(GFX61)
	%SMW_ManagedGraphicsFormatRow(GFX62)
	%SMW_ManagedGraphicsFormatRow(GFX63)
	%SMW_ManagedGraphicsFormatRow(GFX64)
	%SMW_ManagedGraphicsFormatRow(GFX65)
	%SMW_ManagedGraphicsFormatRow(GFX66)
	%SMW_ManagedGraphicsFormatRow(GFX67)
	%SMW_ManagedGraphicsFormatRow(GFX68)
	%SMW_ManagedGraphicsFormatRow(GFX69)
	%SMW_ManagedGraphicsFormatRow(GFX6A)
	%SMW_ManagedGraphicsFormatRow(GFX6B)
	%SMW_ManagedGraphicsFormatRow(GFX6C)
	%SMW_ManagedGraphicsFormatRow(GFX6D)
	%SMW_ManagedGraphicsFormatRow(GFX6E)
	%SMW_ManagedGraphicsFormatRow(GFX6F)
	%SMW_ManagedGraphicsFormatRow(GFX70)
	%SMW_ManagedGraphicsFormatRow(GFX71)
	%SMW_ManagedGraphicsFormatRow(GFX72)
	%SMW_ManagedGraphicsFormatRow(GFX73)
	%SMW_ManagedGraphicsFormatRow(GFX74)
	%SMW_ManagedGraphicsFormatRow(GFX75)
	%SMW_ManagedGraphicsFormatRow(GFX76)
	%SMW_ManagedGraphicsFormatRow(GFX77)
	%SMW_ManagedGraphicsFormatRow(GFX78)
	%SMW_ManagedGraphicsFormatRow(GFX79)
	%SMW_ManagedGraphicsFormatRow(GFX7A)
	%SMW_ManagedGraphicsFormatRow(GFX7B)
	%SMW_ManagedGraphicsFormatRow(GFX7C)
	%SMW_ManagedGraphicsFormatRow(GFX7D)
	%SMW_ManagedGraphicsFormatRow(GFX7E)
	%SMW_ManagedGraphicsFormatRow(GFX7F)
	%SMW_ManagedGraphicsFormatRow(GFX80)
	%SMW_ManagedGraphicsFormatRow(GFX81)
	%SMW_ManagedGraphicsFormatRow(GFX82)
	%SMW_ManagedGraphicsFormatRow(GFX83)
	%SMW_ManagedGraphicsFormatRow(GFX84)
	%SMW_ManagedGraphicsFormatRow(GFX85)
	%SMW_ManagedGraphicsFormatRow(GFX86)
	%SMW_ManagedGraphicsFormatRow(GFX87)
	%SMW_ManagedGraphicsFormatRow(GFX88)
	%SMW_ManagedGraphicsFormatRow(GFX89)
	%SMW_ManagedGraphicsFormatRow(GFX8A)
	%SMW_ManagedGraphicsFormatRow(GFX8B)
	%SMW_ManagedGraphicsFormatRow(GFX8C)
	%SMW_ManagedGraphicsFormatRow(GFX8D)
	%SMW_ManagedGraphicsFormatRow(GFX8E)
	%SMW_ManagedGraphicsFormatRow(GFX8F)
	%SMW_ManagedGraphicsFormatRow(GFX90)
	%SMW_ManagedGraphicsFormatRow(GFX91)
	%SMW_ManagedGraphicsFormatRow(GFX92)
	%SMW_ManagedGraphicsFormatRow(GFX93)
	%SMW_ManagedGraphicsFormatRow(GFX94)
	%SMW_ManagedGraphicsFormatRow(GFX95)
	%SMW_ManagedGraphicsFormatRow(GFX96)
	%SMW_ManagedGraphicsFormatRow(GFX97)
	%SMW_ManagedGraphicsFormatRow(GFX98)
	%SMW_ManagedGraphicsFormatRow(GFX99)
	%SMW_ManagedGraphicsFormatRow(GFX9A)
	%SMW_ManagedGraphicsFormatRow(GFX9B)
	%SMW_ManagedGraphicsFormatRow(GFX9C)
	%SMW_ManagedGraphicsFormatRow(GFX9D)
	%SMW_ManagedGraphicsFormatRow(GFX9E)
	%SMW_ManagedGraphicsFormatRow(GFX9F)
	%SMW_ManagedGraphicsFormatRow(GFXA0)
	%SMW_ManagedGraphicsFormatRow(GFXA1)
	%SMW_ManagedGraphicsFormatRow(GFXA2)
	%SMW_ManagedGraphicsFormatRow(GFXA3)
	%SMW_ManagedGraphicsFormatRow(GFXA4)
	%SMW_ManagedGraphicsFormatRow(GFXA5)
	%SMW_ManagedGraphicsFormatRow(GFXA6)
	%SMW_ManagedGraphicsFormatRow(GFXA7)
	%SMW_ManagedGraphicsFormatRow(GFXA8)
	%SMW_ManagedGraphicsFormatRow(GFXA9)
	%SMW_ManagedGraphicsFormatRow(GFXAA)
	%SMW_ManagedGraphicsFormatRow(GFXAB)
	%SMW_ManagedGraphicsFormatRow(GFXAC)
	%SMW_ManagedGraphicsFormatRow(GFXAD)
	%SMW_ManagedGraphicsFormatRow(GFXAE)
	%SMW_ManagedGraphicsFormatRow(GFXAF)
	%SMW_ManagedGraphicsFormatRow(GFXB0)
	%SMW_ManagedGraphicsFormatRow(GFXB1)
	%SMW_ManagedGraphicsFormatRow(GFXB2)
	%SMW_ManagedGraphicsFormatRow(GFXB3)
	%SMW_ManagedGraphicsFormatRow(GFXB4)
	%SMW_ManagedGraphicsFormatRow(GFXB5)
	%SMW_ManagedGraphicsFormatRow(GFXB6)
	%SMW_ManagedGraphicsFormatRow(GFXB7)
	%SMW_ManagedGraphicsFormatRow(GFXB8)
	%SMW_ManagedGraphicsFormatRow(GFXB9)
	%SMW_ManagedGraphicsFormatRow(GFXBA)
	%SMW_ManagedGraphicsFormatRow(GFXBB)
	%SMW_ManagedGraphicsFormatRow(GFXBC)
	%SMW_ManagedGraphicsFormatRow(GFXBD)
	%SMW_ManagedGraphicsFormatRow(GFXBE)
	%SMW_ManagedGraphicsFormatRow(GFXBF)
	%SMW_ManagedGraphicsFormatRow(GFXC0)
	%SMW_ManagedGraphicsFormatRow(GFXC1)
	%SMW_ManagedGraphicsFormatRow(GFXC2)
	%SMW_ManagedGraphicsFormatRow(GFXC3)
	%SMW_ManagedGraphicsFormatRow(GFXC4)
	%SMW_ManagedGraphicsFormatRow(GFXC5)
	%SMW_ManagedGraphicsFormatRow(GFXC6)
	%SMW_ManagedGraphicsFormatRow(GFXC7)
	%SMW_ManagedGraphicsFormatRow(GFXC8)
	%SMW_ManagedGraphicsFormatRow(GFXC9)
	%SMW_ManagedGraphicsFormatRow(GFXCA)
	%SMW_ManagedGraphicsFormatRow(GFXCB)
	%SMW_ManagedGraphicsFormatRow(GFXCC)
	%SMW_ManagedGraphicsFormatRow(GFXCD)
	%SMW_ManagedGraphicsFormatRow(GFXCE)
	%SMW_ManagedGraphicsFormatRow(GFXCF)
	%SMW_ManagedGraphicsFormatRow(GFXD0)
	%SMW_ManagedGraphicsFormatRow(GFXD1)
	%SMW_ManagedGraphicsFormatRow(GFXD2)
	%SMW_ManagedGraphicsFormatRow(GFXD3)
	%SMW_ManagedGraphicsFormatRow(GFXD4)
	%SMW_ManagedGraphicsFormatRow(GFXD5)
	%SMW_ManagedGraphicsFormatRow(GFXD6)
	%SMW_ManagedGraphicsFormatRow(GFXD7)
	%SMW_ManagedGraphicsFormatRow(GFXD8)
	%SMW_ManagedGraphicsFormatRow(GFXD9)
	%SMW_ManagedGraphicsFormatRow(GFXDA)
	%SMW_ManagedGraphicsFormatRow(GFXDB)
	%SMW_ManagedGraphicsFormatRow(GFXDC)
	%SMW_ManagedGraphicsFormatRow(GFXDD)
	%SMW_ManagedGraphicsFormatRow(GFXDE)
	%SMW_ManagedGraphicsFormatRow(GFXDF)
	%SMW_ManagedGraphicsFormatRow(GFXE0)
	%SMW_ManagedGraphicsFormatRow(GFXE1)
	%SMW_ManagedGraphicsFormatRow(GFXE2)
	%SMW_ManagedGraphicsFormatRow(GFXE3)
	%SMW_ManagedGraphicsFormatRow(GFXE4)
	%SMW_ManagedGraphicsFormatRow(GFXE5)
	%SMW_ManagedGraphicsFormatRow(GFXE6)
	%SMW_ManagedGraphicsFormatRow(GFXE7)
	%SMW_ManagedGraphicsFormatRow(GFXE8)
	%SMW_ManagedGraphicsFormatRow(GFXE9)
	%SMW_ManagedGraphicsFormatRow(GFXEA)
	%SMW_ManagedGraphicsFormatRow(GFXEB)
	%SMW_ManagedGraphicsFormatRow(GFXEC)
	%SMW_ManagedGraphicsFormatRow(GFXED)
	%SMW_ManagedGraphicsFormatRow(GFXEE)
	%SMW_ManagedGraphicsFormatRow(GFXEF)
	%SMW_ManagedGraphicsFormatRow(GFXF0)
	%SMW_ManagedGraphicsFormatRow(GFXF1)
	%SMW_ManagedGraphicsFormatRow(GFXF2)
	%SMW_ManagedGraphicsFormatRow(GFXF3)
	%SMW_ManagedGraphicsFormatRow(GFXF4)
	%SMW_ManagedGraphicsFormatRow(GFXF5)
	%SMW_ManagedGraphicsFormatRow(GFXF6)
	%SMW_ManagedGraphicsFormatRow(GFXF7)
	%SMW_ManagedGraphicsFormatRow(GFXF8)
	%SMW_ManagedGraphicsFormatRow(GFXF9)
	%SMW_ManagedGraphicsFormatRow(GFXFA)
	%SMW_ManagedGraphicsFormatRow(GFXFB)
	%SMW_ManagedGraphicsFormatRow(GFXFC)
	%SMW_ManagedGraphicsFormatRow(GFXFD)
	%SMW_ManagedGraphicsFormatRow(GFXFE)
	db $00				;> $FF, never a file
