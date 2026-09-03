; SA-1 Pack: the code placed at $028398, kept as a file of its own
; so that a build assembling this tree inside its own pass can emit it at
; the site (sa1_hijacks_external) and a run of the pack on its own can org
; it there as before (LOCAL MODIFICATION, shiny-mushroom).

candles:
    SEP #$20
    LDA #$09
    STA $620F,y
    LSR $788C
    BCC +
    LDA #$EA
    STA $620E,y
+   
    REP #$20
    JMP .back
    
.refresh
    LDA $14
    AND #$03
    BNE +
    JSL $01ACF9
    BRA ++
+
    LDA $788C
++  ASL #4
    TSB $788C

assert pc() <= $0283C4
