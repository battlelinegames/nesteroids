.segment "BSS"
open_screen_active: .res 1
scroll_y: .res 1
scroll_x: .res 1
;logo_clear: .res 1
;run_clear: .res 1
run_start_game: .res 1

open_screen_nametable:
.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f
.byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f


.segment "CODE"

.proc init_open_screen
    lda #1
    sta open_screen_active
    set scroll_y, #$A0

    rts
.endproc

.proc start_game
    lda run_start_game
    jmp_ne end
        lda #1
        sta run_start_game

;        add_background_clear #0, #34, #8
;        add_background_clear #0, #98, #12

        add_background_clear #1, #$88, #16
        add_background_clear #1, #$A8, #16
        add_background_clear #1, #$EA, #12

        ; create_asteroid #108, #56, #0, #4

    end:

    lda #1
    sta player_status
    jsr set_invulnerable
    lda #0
    sta open_screen_active
    sta scroll_y

    jsr init_ufo_level_timer

    lda #2
    sta lives
    jsr increment_lives

    rts
.endproc

.proc clear_logo
    clear_loop:

    lda PPU_STATUS        ; PPU_STATUS = $2002
    lda #$21
    sta PPU_ADDR          ; PPU_ADDR = $2006
    lda #$06
    sta PPU_ADDR          ; PPU_ADDR = $2006

    ; opening padding
    ldx #111              ; start out at 0
    lda #0

    clear_logo_loop:
        sta PPU_DATA      
        dex
    bpl clear_logo_loop

    rts
.endproc

.proc render_open_screen
    lda scroll_y
    cmp #32
    bne not_complete
        lda #32
        sta PPU_SCROLL
        lda scroll_y
        sta PPU_SCROLL
        rts
    not_complete:
    dec scroll_y

    lda scroll_x
    sta PPU_SCROLL

    lda scroll_y
    sta PPU_SCROLL

    rts
.endproc