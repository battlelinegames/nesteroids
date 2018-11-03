UFO_SHOT_PALETTE = 2
UFO_SHOT_COUNT = 3
UFO_SHOT_ALIVE_FRAMES = 30 

.segment "BSS"
ufo_shot_y_lo: .res UFO_SHOT_COUNT
ufo_shot_y_hi: .res UFO_SHOT_COUNT
ufo_shot_x_lo: .res UFO_SHOT_COUNT
ufo_shot_x_hi: .res UFO_SHOT_COUNT

ufo_shot_vel_y_lo: .res UFO_SHOT_COUNT
ufo_shot_vel_y_hi: .res UFO_SHOT_COUNT
ufo_shot_vel_x_lo: .res UFO_SHOT_COUNT
ufo_shot_vel_x_hi: .res UFO_SHOT_COUNT

ufo_shot_direction: .res UFO_SHOT_COUNT
ufo_shot_alive_time: .res UFO_SHOT_COUNT

;ufo_shot_temp: .res 1
ufo_shot_x_reg_save: .res 1
ufo_shot_y_reg_save: .res 1
ufo_shot_var_1: .res 1
ufo_shot_var_2: .res 1

.segment "CODE"


;; !!! THIS IS NOT WORKING!!!!!!!!
.macro find_ufo_shot_x no_shot_label
    .local @shot_loop
    .local @found_shot
    ldx #UFO_SHOT_COUNT

    @shot_loop:
        dex
        bmi no_shot_label   
        lda ufo_shot_alive_time,x
        beq @found_shot
    bpl @shot_loop

    @found_shot:
.endmacro

.proc ufo_shoot 
    play_sfx PLAYER_SHOT_SOUND, PRIORITY_2

    stx ufo_shot_x_reg_save
    sty ufo_shot_x_reg_save
    find_ufo_shot_x no_ufo_shot
    txa
    tay ; move the x value to y

    lda #UFO_SHOT_ALIVE_FRAMES
    sta ufo_shot_alive_time,y
    get_random_a            ; get_random_a clobbers x
    and #%00001111
    sta ufo_shot_direction,y
    tax                      ; we need to use direction as an index into acceleration table
    ;===============================================================

    lda x_shot_acc_table_hi, x
    sta ufo_shot_vel_y_hi, y 

    lda x_shot_acc_table_lo, x
    sta ufo_shot_vel_y_lo, y 

    lda y_shot_acc_table_hi, x
    sta ufo_shot_vel_x_hi, y 

    lda y_shot_acc_table_lo, x
    sta ufo_shot_vel_x_lo, y 

    ;===============================================================
    lda ufo_y
    sta ufo_shot_y_hi, y
    lda ufo_x
    sta ufo_shot_x_hi, y

    lda #0
    sta ufo_shot_y_lo, y
    sta ufo_shot_x_lo, y

    no_ufo_shot:
    ldx ufo_shot_x_reg_save
    ldy ufo_shot_x_reg_save
    rts
.endproc

.proc move_ufo_shots
    ldx #0
    shot_loop: ; ===>>> SHOT LOOP
        lda ufo_shot_alive_time, x
        jmp_eq skip_shot       ; first see if the shot is still active
            ; move the shot
            dec ufo_shot_alive_time, x
            ;=== MOVE THE SHOT ON THE X AXIS ===
            xadd_16 ufo_shot_y_hi, ufo_shot_y_lo, \
                    ufo_shot_vel_y_hi, ufo_shot_vel_y_lo, \
                    ufo_shot_y_hi, ufo_shot_y_lo

            sta ufo_shot_var_1

            ;=== MOVE THE SHOT ON THE Y AXIS ===
            xadd_16 ufo_shot_x_hi, ufo_shot_x_lo, \
                    ufo_shot_vel_x_hi, ufo_shot_vel_x_lo, \
                    ufo_shot_x_hi, ufo_shot_x_lo

            sta ufo_shot_var_2

            ; p_x, p_y, p_sprite_num, p_flags
            stx ufo_shot_x_reg_save ; render sprite changes the value of x register. We need to save that
            render_sprite ufo_shot_var_1, ufo_shot_var_2, #$0A, #UFO_SHOT_PALETTE 
            ldx ufo_shot_x_reg_save ; restore the old value in x register
            jmp loop_continue
        skip_shot:

        lda #0
        sta ufo_shot_vel_y_hi, x
        sta ufo_shot_vel_x_hi, x
        sta ufo_shot_vel_y_lo, x
        sta ufo_shot_vel_x_lo, x

        sta ufo_shot_y_hi, x
        sta ufo_shot_x_hi, x
        sta ufo_shot_y_lo, x
        sta ufo_shot_x_lo, x

    loop_continue:
    inx
    cpx #UFO_SHOT_COUNT
    jmp_cc shot_loop
    rts
.endproc
