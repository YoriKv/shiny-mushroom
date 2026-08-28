; RAM Define tags:
; "Player" = RAM address associated with the player sprite in levels.
; "NorSpr" = RAM address associated with normal sprites.
; "NorSprZZ_Y" = RAM address associated with normal sprite Y of ID ZZ. Can also refer to a group of sprites if ZZ is XX.
; "GenSpr" = RAM address associated with a generator sprite.
; "ExtSpr" = RAM address associated with an extended sprite.
; "MExtSpr" = RAM address associated with a minor extended sprite.
; "ClusterSpr" = RAM address associated with a cluster sprite.
; "ScrollSpr" = RAM address associated with a scroll sprite.
; "BounceSpr" = RAM address associated with a bounce sprite.
; "ScoreSpr" = RAM address associated with a Score sprite.
; "CoinSpr" = RAM address associated with a spinning coin sprite.
; "SmokeSpr" = RAM address associated with a smoke sprite.
; "Ending" = RAM address associated with the ending.
; "Level" = RAM address associated with a level function
; "Overworld" = RAM address associated with an overworld function.
; "CastleDestruction" = RAM address associated with a castle destruction cutscene
; "Global" = Used anywhere or close to everywhere.

; Dependency:
; $7E0000-$7E00FF/$7E0200-$7E1FFF = ROUTINE_InitializeFirst8KBOfRAM
; $7E0071-$7E0093 = InitializeLevelRAM
; $7E13DA-$7E1410 = InitializeLevelRAM
; $7E001A-$7E00D7 = ClearOverworldAndCutsceneRAM
; $7E13D3-$7E1BA1 = ClearOverworldAndCutsceneRAM

org $7E8000
base $7E0000

;--- Split into semantic regions. Order is significant.

incsrc "Memory/WRAM_DirectPage.asm"
incsrc "Memory/WRAM_Stack.asm"
incsrc "Memory/WRAM_VideoTables.asm"
incsrc "Memory/WRAM_CutsceneSprites.asm"
incsrc "Memory/WRAM_System.asm"
incsrc "Memory/WRAM_OverworldSprites.asm"
incsrc "Memory/WRAM_GameState.asm"
incsrc "Memory/WRAM_LevelState.asm"
incsrc "Memory/WRAM_SpriteSlots.asm"
incsrc "Memory/WRAM_LevelSettings.asm"
incsrc "Memory/WRAM_Overworld.asm"
incsrc "Memory/WRAM_Extended.asm"
