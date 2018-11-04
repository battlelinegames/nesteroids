; initialize gameplay screen
.proc gameplay_init
    jsr set_sprite0
    rts 
.endproc

; input buttons used by the gameplay screen
.proc gameplay_input
    jsr gameplay_press_left
    jsr gameplay_press_right
    jsr gameplay_press_up
    ; jsr gameplay_press_down
    jsr gameplay_press_a
    jsr gameplay_press_b
    jsr gameplay_press_start
    ; jsr gameplay_press_select

    rts
.endproc

; press the a button on the gameplay screen
.proc gameplay_press_a
    lda PRESS_A
    and gamepad_press
    beq skip_press_a
        ; THE A BUTTON IS PRESSED
        branch_player_dead dont_shoot
            jsr player_shoot ; shoot if a is pressed
        dont_shoot:
        jmp a_end
    skip_press_a:
        lda #0
        sta player_shot_wait

    a_end:
    
    rts
.endproc

; press the b button on the gameplay screen
.proc gameplay_press_b
    lda PRESS_B
    and gamepad_press
    beq skip_press_b
        advance_random_ptr ; advance the random pointer based on the frame
        branch_player_dead dont_teleport
            jsr teleport_player    ; cause the player to teleport
        dont_teleport:
        ; THE B BUTTON IS PRESSED
        ; b button action
        jmp b_end
    skip_press_b:
        ; if the b is not pressed
    b_end:
    rts
.endproc

; press the start button on the gameplay screen
.proc gameplay_press_start
    lda start_delay
    bne decrement_delay

    lda PRESS_START
    and gamepad_press
    beq start_end
        advance_random_ptr ; advance the random pointer based on the frame

        set game_screen, PAUSE_SCREEN

        lda #100
        sta start_delay
        play_sfx PAUSE_SOUND, PRIORITY_1
        ; AT THIS POINT I'M ASSUMING THE GAME IS PLAYING
        
        ; THE START BUTTON IS PRESSED
        ; start button action
        jmp start_end
    decrement_delay:
        dec start_delay

        ; if the start is not pressed
    start_end:
    rts
.endproc

; press the up button on the gameplay screen
.proc gameplay_press_up
    lda PRESS_UP       ; load PRESS UP flag into A register
    and gamepad_press   ; and this with gamepad_press
    beq no_press_up     ; if the result is 0, the gamepad is not pressed
        ; right now I'm chosing not to advance the pointer
        ; advance_random_ptr ; advance the random pointer based on the frame

        ; accelerate x macro
        jsr accelerate_player
    no_press_up:
        jsr move_player   ; move the player without accelerating
    rts
.endproc

; press the left button on the gameplay screen
.proc gameplay_press_left
    lda PRESS_LEFT
    and gamepad_press
    beq skip_press_left
        advance_random_ptr ; advance the random pointer based on the frame
        and gamepad_new_press
        beq not_new_left
            jsr frame_left
        jmp skip_press_left
    not_new_left:
        jsr turn_left
    skip_press_left:
    rts
.endproc

; press the right button on the gameplay screen
.proc gameplay_press_right
    lda PRESS_RIGHT
    and gamepad_press
    beq skip_press_right
        advance_random_ptr ; advance the random pointer based on the frame
        and gamepad_new_press
        beq not_new_right
            jsr frame_right
        jmp skip_press_right
    not_new_right:
        jsr turn_right
    skip_press_right:
    rts
.endproc

; gameloop code for gameplay screen
.proc gameplay_gameloop
    bne no_sprite0_clear
        jsr sprite0_clear_wait
    no_sprite0_clear:

    jsr sprite0_wait

    set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
    lda PPU_STATUS ; $2002
    set PPU_SCROLL, scroll_x
    set PPU_SCROLL, #0

    jsr gameplay_input

    jsr set_sprite0

    jsr move_asteroids ; move the asteroids

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
    dec scroll_x

    jsr move_explosions
    jsr move_teleport
    jsr move_player_shots
    jsr player_metasprite


    ; check for collisions between the asteroids and the player
    jsr collision_check_pa
    ; check for collisions between the asteroids and the player's shots
    jsr collision_check_sa
    jsr collision_check_up
    jsr collision_check_usp
    jsr collision_check_spu

    jsr player_respawn_check

    jsr create_ufo
    jsr move_ufo
    jsr move_ufo_shots

    jsr check_level_up

    rts
.endproc

; code called on the gameplay screen during the nmi
.proc render_gameplay
    lda PPU_STATUS ; $2002

    set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
    lda PPU_STATUS ; $2002

    set PPU_SCROLL, #0 ; scroll_x
    sta PPU_SCROLL ; , #0

    rts
.endproc