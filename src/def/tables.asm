.segment "TABLES"

palette_background:
.byte $0F,$38,$17,$07 ; logo
.byte $0F,$09,$19,$29 ; bg1 green
.byte $0F,$01,$11,$21 ; bg2 blue
.byte $0F,$00,$10,$30 ; bg3 greyscale
;.byte $0F,$18,$28,$38 ; sp0 yellow

palette_sprites:
.byte $0F,$38,$27,$17 ; asteroid colors
.byte $0F,$14,$24,$34 ; player shot palette
.byte $0F,$1B,$2B,$3B ; sp2 teal
.byte $0F,$12,$22,$32 ; player palette

sprites:
     ;vert tile attr horiz
.byte $80, $32, $00, $80   ;sprite 0
.byte $80, $33, $00, $88   ;sprite 1
.byte $88, $34, $00, $80   ;sprite 2
.byte $88, $35, $00, $88   ;sprite 3

sprite0_background:
.byte $10

score_status:
.byte "SCORE 000000"

lives_status:
.byte "LIVES 00"

press_start_text:
; start at tile position $EA (234)
 .byte "PRESS START!"  ; 12 bytes

game_over_text:
; start at tile position $EA (234)
 .byte "GAME OVER!"  ; 12 bytes

logo_background_top:
; start at tile position $88 (136)
 .byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f ; 16 bytes

logo_background_bottom:
; start at tile position $A8 (168)
 .byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f ; 16 bytes



asteroid_background_r1:
 .byte $80,$81,$82,$83 
 
asteroid_background_r2:
 .byte $84,$85,$86,$87

asteroid_background_r3:
 .byte $88,$89,$8a,$8b

asteroid_background_r4:
 .byte $8c,$8d,$8e,$8f

attribute:
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

  .byte $24,$24,$24,$24, \
        $47,$47,$24,$24, \
        $47,$47,$47,$47, \
        $47,$47,$24,$24, \
        $24,$24,$24,$24, \
        $24,$24,$24,$24, \
        $24,$24,$24,$24, \
        $55,$56,$24,$24  ;;brick bottoms
