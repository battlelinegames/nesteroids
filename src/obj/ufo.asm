UFO_SPAWN_BASE_TIME = 20
UFO_START_FRAME = 6
UFO_SHOT_TIME = 30
UFO_FRAMES = 4

.segment "BSS"
ufo_y: .res 1
ufo_x: .res 1
ufo_move_horizontal: .res 1
ufo_shot_wait: .res 1
ufo_shot_countdown: .res 1
ufo_active: .res 1
ufo_spawn_wait: .res 1
ufo_spawn_countdown: .res 1
ufo_frame: .res 1
ufo_temp: .res 1

ufo_reg_x: .res 1
ufo_reg_y: .res 1

.segment "CODE"


.proc init_ufo_level_timer
    lda #UFO_SPAWN_BASE_TIME

    sec
    sbc level
    abs_a

    sta ufo_spawn_wait
    sta ufo_spawn_countdown

    set ufo_shot_wait, #UFO_SHOT_TIME
    rts
.endproc
; clobber the y register
.proc create_ufo
    lda frame_counter
    bne end ; if frame counter is not 0, we can not create a ufo

    dec ufo_spawn_countdown
    lda ufo_spawn_countdown
    bne end  ; if spawn countdown is not 0 we can not create a ufo

    lda ufo_spawn_wait
    sta ufo_spawn_countdown

    lda ufo_active ; check to see if ufo is active
    bne end     ; if the ufo is currently active don't create a ufo

    get_random_a
    asl             ; multiply random numbers by x2
    bmi vertical
    horizontal:
        sta ufo_x
        lda #0
        sta ufo_y
        lda #1
        sta ufo_move_horizontal
    
        jmp dir_end
    vertical: 
        sta ufo_y
        lda #0
        sta ufo_x
        sta ufo_move_horizontal
    dir_end:

    set ufo_active, #1

    end:
    rts
.endproc

.proc move_ufo
    lda ufo_active
    beq end
        lda ufo_move_horizontal
        beq vertical

        horizontal:
            inc ufo_y
            lda ufo_y
            bne dir_end
                sta ufo_active ; ufo is no longer active
                ;set ufo_spawn_countdown, ufo_spawn_wait

                jmp end
        vertical:
            inc ufo_x
            lda ufo_x
            bne dir_end
                sta ufo_active ; ufo is no longer active
                ;set ufo_spawn_countdown, ufo_spawn_wait

                jmp end
        dir_end:

        inc ufo_frame
        lda ufo_frame
        and #%00000011
        sta ufo_frame
        clc
        adc #UFO_START_FRAME
        sta ufo_temp
        render_sprite ufo_y, ufo_x, ufo_temp, #PLAYER_PALETTE

        dec ufo_shot_countdown
        lda ufo_shot_countdown
        bne no_shot
            set ufo_shot_countdown, ufo_shot_wait
            jsr ufo_shoot
        no_shot:
    end:

    rts
.endproc

.proc kill_ufo
    lda ufo_active
    bne ufo_alive
        rts ; can't be killed if already dead
    ufo_alive:

    lda #0
    sta ufo_active ; kill off ufo

    create_explosion ufo_y, ufo_x

    stx ufo_reg_x
    sty ufo_reg_y

    lda #50
    jsr add_score_base10 

    ldx ufo_reg_x
    ldy ufo_reg_y

    rts
.endproc