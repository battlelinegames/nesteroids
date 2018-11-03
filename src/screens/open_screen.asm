.segment "BSS"
;open_screen_active: .res 1
scroll_y: .res 1
scroll_x: .res 1
;logo_clear: .res 1
;run_clear: .res 1
;run_start_game: .res 1

.segment "CODE"

open_screen_nametable:
.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f
.byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f



.proc open_screen_gameloop
    jsr set_sprite0

    jsr open_input
    jsr render_open_screen
    rts
.endproc

.proc init_open_screen
    add_background_write #1, #$88, #>logo_background_top, #<logo_background_top, #16
    add_background_write #1, #$A8, #>logo_background_bottom, #<logo_background_bottom, #16
    add_background_write #1, #$EA, #>press_start_text, #<press_start_text, #12

    set game_screen, OPEN_SCREEN
    set scroll_y, #$A0

    rts
.endproc

.proc start_game

    add_background_clear #1, #$88, #16
    add_background_clear #1, #$A8, #16
    add_background_clear #1, #$EA, #12

    add_asteroid:
    
    create_asteroid #50, #50, #11, #1 ; xpos, ypos, rotation, size
    create_asteroid #23, #250, #7, #1 ; xpos, ypos, rotation, size
    create_asteroid #150, #25, #6, #2 ; xpos, ypos, rotation, size
    create_asteroid #200, #160, #2, #2 ; xpos, ypos, rotation, size
    create_asteroid #25, #60, #15, #3 ; xpos, ypos, rotation, size

    jsr init_ufo_level_timer
    
    set size_list, #%00011010

    lda #1
    sta player_status
    jsr set_invulnerable

    set game_screen, PLAY_SCREEN

    sta scroll_y

    jsr init_ufo_level_timer

    lda #2
    sta lives
    jsr increment_lives
    jsr gameplay_init

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
        lda #0 ; scroll_x
        sta PPU_SCROLL
        lda scroll_y
        sta PPU_SCROLL
        rts
    not_complete:
    dec scroll_y

    lda #0 ;scroll_x
    sta PPU_SCROLL

    lda scroll_y
    sta PPU_SCROLL

    rts
.endproc


.proc open_input
    jsr open_press_start
    /*
    jsr gameover_press_left
    jsr gameover_press_right
    jsr gameover_press_up
    jsr gameover_press_down
    jsr gameover_press_a
    jsr gameover_press_b
    jsr gameover_press_select
    */
    rts
.endproc
/*
.proc open_press_start
    lda PRESS_START
    and gamepad_press
    beq start_end
        advance_random_ptr ; advance the random pointer based on the frame

        set game_screen, PLAY_SCREEN
        jsr start_game

        lda #30
        sta start_delay

        jmp start_end

        ; if the start is not pressed
    start_end:
    rts
.endproc
*/

.proc open_press_start
    lda start_delay
    bne decrement_delay

    lda PRESS_START
    and gamepad_press
    beq start_end
        advance_random_ptr ; advance the random pointer based on the frame

        set game_screen, PLAY_SCREEN
        jsr start_game
        set start_delay, START_WAIT

        jmp start_end
        ; if the start is not pressed
    decrement_delay:
        dec start_delay

    start_end:
    rts
.endproc
