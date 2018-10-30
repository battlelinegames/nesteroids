.segment "ZEROPAGE"
	sound_save_reg_x: .res 1
	sound_save_reg_y: .res 1
;	play_sound_delay: .res 1

.segment "CODE"

.macro play_sfx sound, priority
;	pha
;	lda play_sound_delay
;	bne @dont_play
;		stx sound_save_reg_x
;		sty sound_save_reg_y

		lda sound			;play effect 0 on channel 0
		ldx priority
		jsr FamiToneSfxStart

;		lda #80
;		sta play_sound_delay

;		ldx sound_save_reg_x
;		ldy sound_save_reg_y

;	@dont_play:
;	pla
.endmacro

.define PLAYER_SHOT_SOUND #0
.define EXPLODE_SOUND #1
.define START_CLICK_SOUND #2
.define PLAYER_READY_SOUND #3

sounds:
	.word player_shot
	.word explode
	.word start_click 
	.word player_ready

player_shot:
	.byte $00,$3d
	.byte $01,$38
	.byte $02,$00
	.byte $10
	.byte $00,$3c
	.byte $10
	.byte $00,$3b
	.byte $10
	.byte $00,$3a
	.byte $10
	.byte $00,$39
	.byte $10
	.byte $00,$38
	.byte $10
	.byte $00,$37
	.byte $01,$47
	.byte $10
	.byte $00,$36
	.byte $01,$56
	.byte $10
	.byte $00,$34
	.byte $01,$65
	.byte $10
	.byte $00,$33
	.byte $01,$74
	.byte $10
	.byte $00,$32
	.byte $01,$83
	.byte $10
	.byte $00,$31
	.byte $01,$92
	.byte $10
	.byte $01,$a1
	.byte $10
	.byte $00,$30
	.byte $80
	.byte $01,$4f
	.byte $02,$07
	.byte $10
	.byte $01,$5e
	.byte $10
	.byte $01,$6d
	.byte $10
	.byte $01,$7c
	.byte $ff

explode:
	.byte $09,$3e
	.byte $0a,$0e
	.byte $11
	.byte $09,$3d
	.byte $11
	.byte $09,$3c
	.byte $11
	.byte $09,$3b
	.byte $11
	.byte $09,$3a
	.byte $11
	.byte $09,$39
	.byte $11
	.byte $09,$38
	.byte $11
	.byte $09,$37
	.byte $11
	.byte $09,$36
	.byte $11
	.byte $09,$35
	.byte $11
	.byte $09,$34
	.byte $11
	.byte $09,$33
	.byte $11
	.byte $09,$32
	.byte $11
	.byte $09,$31
	.byte $12
	.byte $09,$30
	.byte $ff

start_click:
	.byte $03,$f4
	.byte $04,$ca
	.byte $05,$00
	.byte $10
	.byte $03,$bd
	.byte $04,$c9
	.byte $10
	.byte $03,$fa
	.byte $10
	.byte $03,$b8
	.byte $04,$b7
	.byte $10
	.byte $03,$f6
	.byte $04,$8d
	.byte $10
	.byte $03,$b5
	.byte $04,$4f
	.byte $10
	.byte $03,$b4
	.byte $04,$00
	.byte $10
	.byte $03,$30
	.byte $10
	.byte $03,$b2
	.byte $10
	.byte $03,$b7
	.byte $10
	.byte $03,$b5
	.byte $10
	.byte $03,$b4
	.byte $10
	.byte $03,$b3
	.byte $10
	.byte $03,$b2
	.byte $10
	.byte $03,$b1
	.byte $10
	.byte $03,$30
	.byte $10
	.byte $03,$b1
	.byte $14
	.byte $03,$30
	.byte $ff

player_ready:
	.byte $03,$33
	.byte $04,$a1
	.byte $05,$02
	.byte $10
	.byte $03,$3f
	.byte $04,$9b
	.byte $10
	.byte $03,$3c
	.byte $04,$95
	.byte $10
	.byte $04,$93
	.byte $10
	.byte $03,$3b
	.byte $04,$90
	.byte $10
	.byte $04,$8e
	.byte $10
	.byte $04,$8c
	.byte $10
	.byte $04,$89
	.byte $10
	.byte $04,$84
	.byte $10
	.byte $04,$00
	.byte $05,$05
	.byte $10
	.byte $04,$fe
	.byte $05,$04
	.byte $10
	.byte $04,$fd
	.byte $10
	.byte $04,$fb
	.byte $10
	.byte $04,$f8
	.byte $10
	.byte $04,$f6
	.byte $10
	.byte $04,$f4
	.byte $11
	.byte $04,$f3
	.byte $10
	.byte $04,$73
	.byte $05,$02
	.byte $11
	.byte $04,$71
	.byte $10
	.byte $04,$6c
	.byte $11
	.byte $04,$6a
	.byte $11
	.byte $04,$65
	.byte $10
	.byte $04,$64
	.byte $10
	.byte $04,$e2
	.byte $05,$04
	.byte $10
	.byte $04,$e0
	.byte $10
	.byte $04,$dd
	.byte $10
	.byte $04,$d9
	.byte $10
	.byte $04,$db
	.byte $10
	.byte $04,$d9
	.byte $10
	.byte $04,$d8
	.byte $12
	.byte $04,$56
	.byte $05,$02
	.byte $11
	.byte $04,$55
	.byte $10
	.byte $04,$51
	.byte $11
	.byte $04,$4f
	.byte $10
	.byte $04,$4e
	.byte $10
	.byte $04,$4c
	.byte $10
	.byte $04,$4a
	.byte $10
	.byte $04,$c7
	.byte $05,$04
	.byte $11
	.byte $04,$c5
	.byte $10
	.byte $04,$c3
	.byte $10
	.byte $04,$c0
	.byte $12
	.byte $04,$be
	.byte $10
	.byte $04,$bd
	.byte $10
	.byte $03,$3a
	.byte $04,$3d
	.byte $05,$02
	.byte $10
	.byte $03,$39
	.byte $04,$3b
	.byte $10
	.byte $03,$37
	.byte $10
	.byte $03,$36
	.byte $04,$3a
	.byte $10
	.byte $03,$35
	.byte $04,$39
	.byte $10
	.byte $03,$30
	.byte $ff
