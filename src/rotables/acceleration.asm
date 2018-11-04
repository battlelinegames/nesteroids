.rodata

 x_acceleration_table_hi: .byte $ff, $ff, $ff, $ff
                          .byte $00, $00, $00, $00
                          .byte $00, $00, $00, $00 
                          .byte $00, $ff, $ff, $ff 

 x_acceleration_table_lo: .byte $f4, $f5, $f8, $fc
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
