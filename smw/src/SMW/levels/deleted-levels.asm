; The level streams the project has deleted: one define per stream,
; !SMW_LevelDeleted_<Label> = 1, naming the label %SMW_InsertLevelData
; emits it under -- LEVEL_L1_105, LEVEL_SP_105. Read at the start of every
; pass from Config/ManagedLevelMemory.asm; a named stream is inserted as the
; empty level under its label, so every pointer-table row naming it loads an
; empty level and the bytes it occupied are room for the streams after it.
;
; The editor regenerates this file from the project's deleted files.
; Shipped empty: the checkout deletes nothing.
