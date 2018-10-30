.rodata
; x_acceleration_table_hi: .byte $0,  $0,  $1,  $1
;                          .byte $2,  $1,  $1,  $0
;                          .byte $0,  $ff, $ff, $fe ;  0, -1, -2, -3
;                          .byte $fe, $fd, $fe, $ff ; -4, -3, -2, -1 

; x_acceleration_table_lo: .byte $0, $40, $0, $40
;                          .byte $0, $40, $0, $40
;                          .byte $0, $c0, $0, $c0 ;  0, -1, -2, -3
;                          .byte $0, $c0, $0, $c0 ; -4, -3, -2, -1 

; y_acceleration_table_hi: .byte $fe, $fd, $fe, $ff ; -4, -3, -2, -1
;                          .byte $0,  $0,  $1,  $1 
;                          .byte $2,  $1,  $1,  $0
;                          .byte $0,  $ff, $ff, $fe ;  0, -1, -2, -3
                
; y_acceleration_table_lo: .byte $0, $c0, $0, $c0 ; -4, -3, -2, -1
;                          .byte $0, $40, $0, $40 
;                          .byte $0, $40, $0, $40
;                          .byte $0, $c0, $0, $c0 ;  0, -1, -2, -3


 z_acceleration_table_hi: .byte $ff, $ff, $ff, $ff
                          .byte $00, $00, $00, $00
                          .byte $00, $00, $00, $00 
                          .byte $00, $ff, $ff, $ff 

 z_acceleration_table_lo: .byte $f4, $f5, $f8, $fc
                          .byte $00, $04, $08, $0b
                          .byte $0c, $0b, $08, $04 
                          .byte $00, $fc, $f8, $f5 

 y_acceleration_table_hi: .byte $00, $00, $00, $00 
                          .byte $00, $00, $00, $00 
                          .byte $00, $ff, $ff, $ff
                          .byte $ff, $ff, $ff, $ff 
                
 y_acceleration_table_lo: .byte $00, $04, $08, $0b 
                          .byte $0c, $0b, $08, $04 
                          .byte $00, $fc, $f8, $f5
                          .byte $f4, $f5, $f8, $fc 
