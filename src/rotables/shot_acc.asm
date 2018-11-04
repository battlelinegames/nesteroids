.segment "CODE"
 x_shot_acc_table_hi:   .byte $FC, $FC, $FD, $FE 
                        .byte $00, $01, $02, $03 
                        .byte $03, $03, $02, $01 
                        .byte $00, $FE, $FD, $FC 

 x_shot_acc_table_lo:   .byte $A0, $E8, $C0, $E
                        .byte $00, $20, $40, $18
                        .byte $60, $18, $40, $20 
                        .byte $00, $E0, $C0, $E8 

 y_shot_acc_table_hi:   .byte $00, $01, $02, $03
                        .byte $03, $03, $02, $01
                        .byte $00, $FE, $FD, $FC 
                        .byte $FC, $FC, $FD, $FE
                
 y_shot_acc_table_lo:   .byte $00, $20, $40, $18
                        .byte $60, $18, $40, $20 
                        .byte $00, $E0, $C0, $E8 
                        .byte $A0, $E8, $C0, $E0
