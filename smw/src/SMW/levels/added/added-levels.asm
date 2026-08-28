; The streams of the level files the project adds: one %SMW_InsertLevelData
; per stream, packed after the banks' own streams by
; %SMW_ManagedLevelMemory_Close under the labels the pointer-table fragments
; name -- ShinyLevel_L1_<name> and ShinyLevel_SP_<name>, unnamespaced
; deliberately, because those tables spell them bare. Only read under
; !Define_SMW_ManagedLevelMemory, whose runs are the room the streams take.
;
; The editor regenerates this file from the project's added containers.
; Shipped empty: the checkout adds no files, so there is nothing to insert.
