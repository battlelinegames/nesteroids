.segment "RODATA"
; * 1.5

; fb80 = -1152  ; FCA0 = -864
; fbe0 = -1056  ; FCE8 = -792
; fd00 = -768   ; FDC0 = -576
; fe80 = -384   ; FEE0 = -288

; 0000 = 0      ; 0000 = 0
; 0180 = 384    ; 0120 = 288
; 0300 = 768    ; 0240 = 576
; 0420 = 1056   ; 0318 = 792

; 0480 = 1152   ; 0360 = 864
; 0420 = 1056   ; 0318 = 792
; 0300 = 768    ; 0240 = 576
; 0180 = 384    ; 0120 = 288

; 0000 = 0      ; 0000 = 0
; fe80 = -384   ; FEE0 = -288
; fd00 = -768   ; FDC0 = -576
; fbe0 = -1056  ; FCE8 = -796

 x_shot_acc_table_hi:   .byte $FC, $FC, $FD, $FE ; finished row
                        .byte $00, $01, $02, $03 ; finished row
                        .byte $03, $03, $02, $01 ; finished row
                        .byte $00, $FE, $FD, $FC 

 x_shot_acc_table_lo:   .byte $A0, $E8, $C0, $E
                        .byte $00, $20, $40, $18
                        .byte $60, $18, $40, $20 
                        .byte $00, $E0, $C0, $E8 

; 0000 = 0      ; 0000 = 0
; 0180 = 384    ; 0120 = 288
; 0300 = 768    ; 0240 = 576
; 0420 = 1056   ; 0318 = 792

; 0480 = 1152   ; 0360 = 864
; 0420 = 1056   ; 0318 = 792
; 0300 = 768    ; 0240 = 576
; 0180 = 384    ; 0120 = 288

; 0000 = 0      ; 0000 = 0
; fe80 = -384   ; FEE0 = -288
; fd00 = -768   ; FDC0 = -576
; fbe0 = -1056  ; FCE8 = -796

; fb80 = -1152  ; FCA0 = -864
; fbe0 = -1056  ; FCE8 = -792
; fd00 = -768   ; FDC0 = -576
; fe80 = -384   ; FEE0 = -288
;===============================================================
; fb80 = -1152  ; FCA0 = -864
; fbe0 = -1056  ; FCE8 = -792
; fd00 = -768   ; FDC0 = -576
; fe80 = -384   ; FEE0 = -288

 y_shot_acc_table_hi:   .byte $00, $01, $02, $03
                        .byte $03, $03, $02, $01
                        .byte $00, $FE, $FD, $FC 
                        .byte $FC, $FC, $FD, $FE
                
 y_shot_acc_table_lo:   .byte $00, $20, $40, $18
                        .byte $60, $18, $40, $20 
                        .byte $00, $E0, $C0, $E8 
                        .byte $A0, $E8, $C0, $E0