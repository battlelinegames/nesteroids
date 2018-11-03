

.proc pause_init

    rts
.endproc

.proc pause_gameloop
    bne no_sprite0_clear
        jsr sprite0_clear_wait
    no_sprite0_clear:

    jsr sprite0_wait

    set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
    lda PPU_STATUS ; $2002
    set PPU_SCROLL, scroll_x
    set PPU_SCROLL, #0

    jsr pause_input

    jsr set_sprite0

    ldx #ASTEROID_COUNT
    asteroid_loop:
        dex
        bmi asteroid_loop_end
        lda asteroid_size, x
        beq asteroid_loop
        stx game_loop_y_reg_save
        jsr asteroid_metasprite
        ldx game_loop_y_reg_save
        jmp asteroid_loop ; if I don't have at least one asteroid, this is going to break
    asteroid_loop_end:

    jsr player_metasprite

    rts
.endproc

.proc pause_input
    jsr pause_press_start
    rts
.endproc

.proc pause_press_start
    lda start_delay
    bne decrement_delay

    lda PRESS_START
    and gamepad_press
    beq start_end
        advance_random_ptr ; advance the random pointer based on the frame

        set game_screen, PLAY_SCREEN

        set start_delay, START_WAIT
        play_sfx PAUSE_SOUND, PRIORITY_1

        jmp start_end
    decrement_delay:
        dec start_delay

        ; if the start is not pressed
    start_end:

    rts
.endproc

.proc render_pause
    jsr render_gameplay
    rts
.endproc
