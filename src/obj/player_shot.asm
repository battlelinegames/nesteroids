; defined values
PLAYER_BULLET_FRAME = $0A
MAX_PLAYER_SHOTS = 5
.define SHOT_ALIVE_FRAMES   #30 


.segment "BSS"

player_shot_y_hi: .res MAX_PLAYER_SHOTS
player_shot_x_hi: .res MAX_PLAYER_SHOTS
player_shot_y_lo: .res MAX_PLAYER_SHOTS
player_shot_x_lo: .res MAX_PLAYER_SHOTS

player_shot_vel_y_hi: .res MAX_PLAYER_SHOTS
player_shot_vel_x_hi: .res MAX_PLAYER_SHOTS
player_shot_vel_y_lo: .res MAX_PLAYER_SHOTS
player_shot_vel_x_lo: .res MAX_PLAYER_SHOTS

player_shot_alive_time: .res MAX_PLAYER_SHOTS

player_shot_count: .res 1
player_shot_index: .res 1

.segment "CODE"

.proc player_shoot 
    lda player_shot_wait        ; ===> BEGINNING OF PLAYER SHOOT
    beq can_shoot              ; we can shoot if the player_shot wait is 0
        dec player_shot_wait    ; if the player_shot_wait is not 0, decrement
        rts
    can_shoot:

    play_sfx PLAYER_SHOT_SOUND, PRIORITY_3

    lda SHOT_ALIVE_FRAMES        ; reset the shot clock
    sta player_shot_wait        ; store the shot wait time

    lda player_rotation
    lsr
    lsr
    lsr
    lsr
    tax

    ldy player_shot_count
    iny
    cpy #MAX_PLAYER_SHOTS
    bcc no_shot_reset      ; branch if shot count >= MAX_PLAYER_SHOTS
    ldy #0
    no_shot_reset:    
    sty player_shot_count          ; we're going to keep shot count in the y register
    lda #0
    sta player_shot_y_lo
    sta player_shot_x_lo

    ; FIND THE X ACCELERATION AND STORE IT INTO THE SHOT LIST
    lda x_shot_acc_table_hi, x
    sta player_shot_vel_y_hi, y 

    lda x_shot_acc_table_lo, x
    sta player_shot_vel_y_lo, y 

    lda y_shot_acc_table_hi, x
    sta player_shot_vel_x_hi, y 

    lda y_shot_acc_table_lo, x
    sta player_shot_vel_x_lo, y 

    lda player_y_hi
    sta player_shot_y_hi, y ; the x shot plus the current shot count

    ; FIND THE Y ACCELERATION AND STORE IT INTO THE SHOT LIST
    lda player_x_hi
    sta player_shot_x_hi, y ; the x shot plus the current shot count

    ; SAVE OFF THE TIME ALIVE
    lda SHOT_ALIVE_FRAMES
    sta player_shot_alive_time, y

    rts
.endproc


PLAYER_SHOT_PALETTE = 1

.proc move_player_shots
    ldx #0
    @shot_loop: ; ===>>> SHOT LOOP
        lda player_shot_alive_time, x
        jmp_eq @skip_shot       ; first see if the shot is still active
            ; move the shot
            dec player_shot_alive_time, x
            ;=== MOVE THE SHOT ON THE X AXIS ===
            xadd_16 player_shot_y_hi, player_shot_y_lo, \
                    player_shot_vel_y_hi, player_shot_vel_y_lo, \
                    player_shot_y_hi, player_shot_y_lo

            sta var_1

            ;=== MOVE THE SHOT ON THE Y AXIS ===
            xadd_16 player_shot_x_hi, player_shot_x_lo, \
                    player_shot_vel_x_hi, player_shot_vel_x_lo, \
                    player_shot_x_hi, player_shot_x_lo

            sta var_2

            ; p_x, p_y, p_sprite_num, p_flags
            stx temp_reg_x ; render sprite changes the value of x register. We need to save that
            render_sprite var_1, var_2, #$0A, #PLAYER_SHOT_PALETTE 
            ldx temp_reg_x ; restore the old value in x register
            jmp @loop_continue
        @skip_shot:
        lda #0
        sta player_shot_vel_y_hi, x
        sta player_shot_vel_x_hi, x
        sta player_shot_vel_y_lo, x
        sta player_shot_vel_x_lo, x

        sta player_shot_y_hi, x
        sta player_shot_x_hi, x
        sta player_shot_y_lo, x
        sta player_shot_x_lo, x

    @loop_continue:
    inx
    cpx #MAX_PLAYER_SHOTS
    jmp_cc @shot_loop
    rts
.endproc

