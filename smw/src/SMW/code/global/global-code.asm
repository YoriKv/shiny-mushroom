; Which of the global entry points the project wrote, as one define apiece
; naming the routine in global-code-data.asm beside this file:
;
;	!SMW_GlobalCode_Init   = <label>   once at boot
;	!SMW_GlobalCode_Main   = <label>   every frame
;	!SMW_GlobalCode_Status = <label>   when the status bar is drawn
;
; Defines only, and read with them rather than with the code: each hook in
; Banks/ asks whether its own entry point was named, and a hook nobody wants
; is not assembled at all.
;
; The editor regenerates this file and the routines beside it from the
; project's own global.asm and statusbar.asm. It is shipped empty because
; there are none, so the feature with an unedited fragment plants no hooks
; and the cartridge runs exactly what the stock one runs.
