.segment "BSS"
;    game_over_active: .res 1
    game_over_wait: .res 1
    game_over_x_reg_save: .res 1
.segment "CODE"

.proc game_over_screen_init
    play_sfx GAME_OVER_SOUND, PRIORITY_1

    ldx #(ASTEROID_COUNT-1)
    asteroid_loop:
        lda asteroid_size, x
        cmp #4
        beq large_size
            dex 
            bpl asteroid_loop
            jmp end_asteroid_loop
        large_size:
            stx game_over_x_reg_save
            jsr hide_large_asteroid
            ldx game_over_x_reg_save
            dex 
            bpl asteroid_loop
    end_asteroid_loop:
    
    set game_screen, GAME_OVER_SCREEN
    set game_over_wait, #100

    ; stop scroll
    lda PPU_STATUS ; $2002
    set PPU_SCROLL, #0
    sta PPU_SCROLL

    jsr clear_player_stats

    ; display game over on background
    add_background_write #1, #$CB, #>game_over_text, #<game_over_text, #9
    add_background_write #1, #$EA, #>press_start_text, #<press_start_text, #11

    ; game_over_text

    rts
.endproc

.proc gameover_input
    jsr gameover_press_start
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

.proc gameover_press_start
    lda start_delay
    bne decrement_delay

    lda PRESS_START
    and gamepad_press
    beq start_end
        advance_random_ptr ; advance the random pointer based on the frame

        set start_delay, START_WAIT
        set game_screen, OPEN_SCREEN

        jsr reset_game
        rts
    decrement_delay:
        dec start_delay

        ; if the start is not pressed
    start_end:

    rts
.endproc

.proc render_game_over
    lda PPU_STATUS ; $2002

    set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
    lda PPU_STATUS ; $2002

    set PPU_SCROLL, #0 ; scroll_x
    sta PPU_SCROLL ; , #0
    rts
.endproc

.proc game_over_gameloop
    jsr gameover_input
    rts
.endproc