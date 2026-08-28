; The managed graphics pointer table: one long pointer per file number,
; $100 rows, read by SMW_ManagedGraphics_Pointer with the file number
; times three. Rows $00-$33 name the game's own files wherever the packing
; put them; rows $34-$FE name an added file's label when
; graphics/added/added-graphics.asm lists that number and hold $000000
; otherwise -- derived from that list, never stored twice; row $FF is the
; terminator's neighbour and is never a file. Static: nothing regenerates
; this file. Read by Config/ManagedGraphicsMemory.asm.

	dl SMW_GFX00
	dl SMW_GFX01
	dl SMW_GFX02
	dl SMW_GFX03
	dl SMW_GFX04
	dl SMW_GFX05
	dl SMW_GFX06
	dl SMW_GFX07
	dl SMW_GFX08
	dl SMW_GFX09
	dl SMW_GFX0A
	dl SMW_GFX0B
	dl SMW_GFX0C
	dl SMW_GFX0D
	dl SMW_GFX0E
	dl SMW_GFX0F
	dl SMW_GFX10
	dl SMW_GFX11
	dl SMW_GFX12
	dl SMW_GFX13
	dl SMW_GFX14
	dl SMW_GFX15
	dl SMW_GFX16
	dl SMW_GFX17
	dl SMW_GFX18
	dl SMW_GFX19
	dl SMW_GFX1A
	dl SMW_GFX1B
	dl SMW_GFX1C
	dl SMW_GFX1D
	dl SMW_GFX1E
	dl SMW_GFX1F
	dl SMW_GFX20
	dl SMW_GFX21
	dl SMW_GFX22
	dl SMW_GFX23
	dl SMW_GFX24
	dl SMW_GFX25
	dl SMW_GFX26
	dl SMW_GFX27
	dl SMW_GFX28
	dl SMW_GFX29
	dl SMW_GFX2A
	dl SMW_GFX2B
	dl SMW_GFX2C
	dl SMW_GFX2D
	dl SMW_GFX2E
	dl SMW_GFX2F
	dl SMW_GFX30
	dl SMW_GFX31
	dl SMW_GFX32
	dl SMW_GFX33
	%SMW_ManagedGraphicsPointerRow(GFX34)
	%SMW_ManagedGraphicsPointerRow(GFX35)
	%SMW_ManagedGraphicsPointerRow(GFX36)
	%SMW_ManagedGraphicsPointerRow(GFX37)
	%SMW_ManagedGraphicsPointerRow(GFX38)
	%SMW_ManagedGraphicsPointerRow(GFX39)
	%SMW_ManagedGraphicsPointerRow(GFX3A)
	%SMW_ManagedGraphicsPointerRow(GFX3B)
	%SMW_ManagedGraphicsPointerRow(GFX3C)
	%SMW_ManagedGraphicsPointerRow(GFX3D)
	%SMW_ManagedGraphicsPointerRow(GFX3E)
	%SMW_ManagedGraphicsPointerRow(GFX3F)
	%SMW_ManagedGraphicsPointerRow(GFX40)
	%SMW_ManagedGraphicsPointerRow(GFX41)
	%SMW_ManagedGraphicsPointerRow(GFX42)
	%SMW_ManagedGraphicsPointerRow(GFX43)
	%SMW_ManagedGraphicsPointerRow(GFX44)
	%SMW_ManagedGraphicsPointerRow(GFX45)
	%SMW_ManagedGraphicsPointerRow(GFX46)
	%SMW_ManagedGraphicsPointerRow(GFX47)
	%SMW_ManagedGraphicsPointerRow(GFX48)
	%SMW_ManagedGraphicsPointerRow(GFX49)
	%SMW_ManagedGraphicsPointerRow(GFX4A)
	%SMW_ManagedGraphicsPointerRow(GFX4B)
	%SMW_ManagedGraphicsPointerRow(GFX4C)
	%SMW_ManagedGraphicsPointerRow(GFX4D)
	%SMW_ManagedGraphicsPointerRow(GFX4E)
	%SMW_ManagedGraphicsPointerRow(GFX4F)
	%SMW_ManagedGraphicsPointerRow(GFX50)
	%SMW_ManagedGraphicsPointerRow(GFX51)
	%SMW_ManagedGraphicsPointerRow(GFX52)
	%SMW_ManagedGraphicsPointerRow(GFX53)
	%SMW_ManagedGraphicsPointerRow(GFX54)
	%SMW_ManagedGraphicsPointerRow(GFX55)
	%SMW_ManagedGraphicsPointerRow(GFX56)
	%SMW_ManagedGraphicsPointerRow(GFX57)
	%SMW_ManagedGraphicsPointerRow(GFX58)
	%SMW_ManagedGraphicsPointerRow(GFX59)
	%SMW_ManagedGraphicsPointerRow(GFX5A)
	%SMW_ManagedGraphicsPointerRow(GFX5B)
	%SMW_ManagedGraphicsPointerRow(GFX5C)
	%SMW_ManagedGraphicsPointerRow(GFX5D)
	%SMW_ManagedGraphicsPointerRow(GFX5E)
	%SMW_ManagedGraphicsPointerRow(GFX5F)
	%SMW_ManagedGraphicsPointerRow(GFX60)
	%SMW_ManagedGraphicsPointerRow(GFX61)
	%SMW_ManagedGraphicsPointerRow(GFX62)
	%SMW_ManagedGraphicsPointerRow(GFX63)
	%SMW_ManagedGraphicsPointerRow(GFX64)
	%SMW_ManagedGraphicsPointerRow(GFX65)
	%SMW_ManagedGraphicsPointerRow(GFX66)
	%SMW_ManagedGraphicsPointerRow(GFX67)
	%SMW_ManagedGraphicsPointerRow(GFX68)
	%SMW_ManagedGraphicsPointerRow(GFX69)
	%SMW_ManagedGraphicsPointerRow(GFX6A)
	%SMW_ManagedGraphicsPointerRow(GFX6B)
	%SMW_ManagedGraphicsPointerRow(GFX6C)
	%SMW_ManagedGraphicsPointerRow(GFX6D)
	%SMW_ManagedGraphicsPointerRow(GFX6E)
	%SMW_ManagedGraphicsPointerRow(GFX6F)
	%SMW_ManagedGraphicsPointerRow(GFX70)
	%SMW_ManagedGraphicsPointerRow(GFX71)
	%SMW_ManagedGraphicsPointerRow(GFX72)
	%SMW_ManagedGraphicsPointerRow(GFX73)
	%SMW_ManagedGraphicsPointerRow(GFX74)
	%SMW_ManagedGraphicsPointerRow(GFX75)
	%SMW_ManagedGraphicsPointerRow(GFX76)
	%SMW_ManagedGraphicsPointerRow(GFX77)
	%SMW_ManagedGraphicsPointerRow(GFX78)
	%SMW_ManagedGraphicsPointerRow(GFX79)
	%SMW_ManagedGraphicsPointerRow(GFX7A)
	%SMW_ManagedGraphicsPointerRow(GFX7B)
	%SMW_ManagedGraphicsPointerRow(GFX7C)
	%SMW_ManagedGraphicsPointerRow(GFX7D)
	%SMW_ManagedGraphicsPointerRow(GFX7E)
	%SMW_ManagedGraphicsPointerRow(GFX7F)
	%SMW_ManagedGraphicsPointerRow(GFX80)
	%SMW_ManagedGraphicsPointerRow(GFX81)
	%SMW_ManagedGraphicsPointerRow(GFX82)
	%SMW_ManagedGraphicsPointerRow(GFX83)
	%SMW_ManagedGraphicsPointerRow(GFX84)
	%SMW_ManagedGraphicsPointerRow(GFX85)
	%SMW_ManagedGraphicsPointerRow(GFX86)
	%SMW_ManagedGraphicsPointerRow(GFX87)
	%SMW_ManagedGraphicsPointerRow(GFX88)
	%SMW_ManagedGraphicsPointerRow(GFX89)
	%SMW_ManagedGraphicsPointerRow(GFX8A)
	%SMW_ManagedGraphicsPointerRow(GFX8B)
	%SMW_ManagedGraphicsPointerRow(GFX8C)
	%SMW_ManagedGraphicsPointerRow(GFX8D)
	%SMW_ManagedGraphicsPointerRow(GFX8E)
	%SMW_ManagedGraphicsPointerRow(GFX8F)
	%SMW_ManagedGraphicsPointerRow(GFX90)
	%SMW_ManagedGraphicsPointerRow(GFX91)
	%SMW_ManagedGraphicsPointerRow(GFX92)
	%SMW_ManagedGraphicsPointerRow(GFX93)
	%SMW_ManagedGraphicsPointerRow(GFX94)
	%SMW_ManagedGraphicsPointerRow(GFX95)
	%SMW_ManagedGraphicsPointerRow(GFX96)
	%SMW_ManagedGraphicsPointerRow(GFX97)
	%SMW_ManagedGraphicsPointerRow(GFX98)
	%SMW_ManagedGraphicsPointerRow(GFX99)
	%SMW_ManagedGraphicsPointerRow(GFX9A)
	%SMW_ManagedGraphicsPointerRow(GFX9B)
	%SMW_ManagedGraphicsPointerRow(GFX9C)
	%SMW_ManagedGraphicsPointerRow(GFX9D)
	%SMW_ManagedGraphicsPointerRow(GFX9E)
	%SMW_ManagedGraphicsPointerRow(GFX9F)
	%SMW_ManagedGraphicsPointerRow(GFXA0)
	%SMW_ManagedGraphicsPointerRow(GFXA1)
	%SMW_ManagedGraphicsPointerRow(GFXA2)
	%SMW_ManagedGraphicsPointerRow(GFXA3)
	%SMW_ManagedGraphicsPointerRow(GFXA4)
	%SMW_ManagedGraphicsPointerRow(GFXA5)
	%SMW_ManagedGraphicsPointerRow(GFXA6)
	%SMW_ManagedGraphicsPointerRow(GFXA7)
	%SMW_ManagedGraphicsPointerRow(GFXA8)
	%SMW_ManagedGraphicsPointerRow(GFXA9)
	%SMW_ManagedGraphicsPointerRow(GFXAA)
	%SMW_ManagedGraphicsPointerRow(GFXAB)
	%SMW_ManagedGraphicsPointerRow(GFXAC)
	%SMW_ManagedGraphicsPointerRow(GFXAD)
	%SMW_ManagedGraphicsPointerRow(GFXAE)
	%SMW_ManagedGraphicsPointerRow(GFXAF)
	%SMW_ManagedGraphicsPointerRow(GFXB0)
	%SMW_ManagedGraphicsPointerRow(GFXB1)
	%SMW_ManagedGraphicsPointerRow(GFXB2)
	%SMW_ManagedGraphicsPointerRow(GFXB3)
	%SMW_ManagedGraphicsPointerRow(GFXB4)
	%SMW_ManagedGraphicsPointerRow(GFXB5)
	%SMW_ManagedGraphicsPointerRow(GFXB6)
	%SMW_ManagedGraphicsPointerRow(GFXB7)
	%SMW_ManagedGraphicsPointerRow(GFXB8)
	%SMW_ManagedGraphicsPointerRow(GFXB9)
	%SMW_ManagedGraphicsPointerRow(GFXBA)
	%SMW_ManagedGraphicsPointerRow(GFXBB)
	%SMW_ManagedGraphicsPointerRow(GFXBC)
	%SMW_ManagedGraphicsPointerRow(GFXBD)
	%SMW_ManagedGraphicsPointerRow(GFXBE)
	%SMW_ManagedGraphicsPointerRow(GFXBF)
	%SMW_ManagedGraphicsPointerRow(GFXC0)
	%SMW_ManagedGraphicsPointerRow(GFXC1)
	%SMW_ManagedGraphicsPointerRow(GFXC2)
	%SMW_ManagedGraphicsPointerRow(GFXC3)
	%SMW_ManagedGraphicsPointerRow(GFXC4)
	%SMW_ManagedGraphicsPointerRow(GFXC5)
	%SMW_ManagedGraphicsPointerRow(GFXC6)
	%SMW_ManagedGraphicsPointerRow(GFXC7)
	%SMW_ManagedGraphicsPointerRow(GFXC8)
	%SMW_ManagedGraphicsPointerRow(GFXC9)
	%SMW_ManagedGraphicsPointerRow(GFXCA)
	%SMW_ManagedGraphicsPointerRow(GFXCB)
	%SMW_ManagedGraphicsPointerRow(GFXCC)
	%SMW_ManagedGraphicsPointerRow(GFXCD)
	%SMW_ManagedGraphicsPointerRow(GFXCE)
	%SMW_ManagedGraphicsPointerRow(GFXCF)
	%SMW_ManagedGraphicsPointerRow(GFXD0)
	%SMW_ManagedGraphicsPointerRow(GFXD1)
	%SMW_ManagedGraphicsPointerRow(GFXD2)
	%SMW_ManagedGraphicsPointerRow(GFXD3)
	%SMW_ManagedGraphicsPointerRow(GFXD4)
	%SMW_ManagedGraphicsPointerRow(GFXD5)
	%SMW_ManagedGraphicsPointerRow(GFXD6)
	%SMW_ManagedGraphicsPointerRow(GFXD7)
	%SMW_ManagedGraphicsPointerRow(GFXD8)
	%SMW_ManagedGraphicsPointerRow(GFXD9)
	%SMW_ManagedGraphicsPointerRow(GFXDA)
	%SMW_ManagedGraphicsPointerRow(GFXDB)
	%SMW_ManagedGraphicsPointerRow(GFXDC)
	%SMW_ManagedGraphicsPointerRow(GFXDD)
	%SMW_ManagedGraphicsPointerRow(GFXDE)
	%SMW_ManagedGraphicsPointerRow(GFXDF)
	%SMW_ManagedGraphicsPointerRow(GFXE0)
	%SMW_ManagedGraphicsPointerRow(GFXE1)
	%SMW_ManagedGraphicsPointerRow(GFXE2)
	%SMW_ManagedGraphicsPointerRow(GFXE3)
	%SMW_ManagedGraphicsPointerRow(GFXE4)
	%SMW_ManagedGraphicsPointerRow(GFXE5)
	%SMW_ManagedGraphicsPointerRow(GFXE6)
	%SMW_ManagedGraphicsPointerRow(GFXE7)
	%SMW_ManagedGraphicsPointerRow(GFXE8)
	%SMW_ManagedGraphicsPointerRow(GFXE9)
	%SMW_ManagedGraphicsPointerRow(GFXEA)
	%SMW_ManagedGraphicsPointerRow(GFXEB)
	%SMW_ManagedGraphicsPointerRow(GFXEC)
	%SMW_ManagedGraphicsPointerRow(GFXED)
	%SMW_ManagedGraphicsPointerRow(GFXEE)
	%SMW_ManagedGraphicsPointerRow(GFXEF)
	%SMW_ManagedGraphicsPointerRow(GFXF0)
	%SMW_ManagedGraphicsPointerRow(GFXF1)
	%SMW_ManagedGraphicsPointerRow(GFXF2)
	%SMW_ManagedGraphicsPointerRow(GFXF3)
	%SMW_ManagedGraphicsPointerRow(GFXF4)
	%SMW_ManagedGraphicsPointerRow(GFXF5)
	%SMW_ManagedGraphicsPointerRow(GFXF6)
	%SMW_ManagedGraphicsPointerRow(GFXF7)
	%SMW_ManagedGraphicsPointerRow(GFXF8)
	%SMW_ManagedGraphicsPointerRow(GFXF9)
	%SMW_ManagedGraphicsPointerRow(GFXFA)
	%SMW_ManagedGraphicsPointerRow(GFXFB)
	%SMW_ManagedGraphicsPointerRow(GFXFC)
	%SMW_ManagedGraphicsPointerRow(GFXFD)
	%SMW_ManagedGraphicsPointerRow(GFXFE)
	dl $000000			;> $FF, never a file
