.segment "BSS"
    level: .res 1

    size_1_count: .res 1
    size_2_count: .res 1
    size_3_count: .res 1
    size_4_count: .res 1

    temp_rotation: .res 1
    size_list: .res 1


.segment "CODE"

; are all the asteroids on this level destroyed?
; if so, run the level up code
.proc check_level_up
    ldx #(ASTEROID_COUNT-1)

    asteroid_check_loop:
        lda asteroid_size, x
        bne asteroid_exists
        dex
    bpl asteroid_check_loop

    jsr level_up 

    asteroid_exists:
    rts
.endproc

; all the asteroids have been destroyed so level up
.proc level_up 
    lda player_status
    and #%00000010 ; check to see if the player is already invulnerable
    jmp_ne end_level_up ; if the player is already invulnerable, we don't want to run the level up


    jsr set_invulnerable
    inc level
    ; set ufo_spawn_wait
    jsr init_ufo_level_timer

    lda size_list
    clc 
    adc #3
    sta size_list

    tay
    and #%00000011
    bne size_1_not_0
        lda #1
    size_1_not_0:
    sta size_1_count

    tya
    lsr
    lsr
    tay
    and #%00000011
    bne size_2_not_0
        lda #1
    size_2_not_0:

    sta size_2_count

    tya
    lsr
    lsr
    tay
    and #%00000011
    bne size_3_not_0
        lda #1
    size_3_not_0:

    sta size_3_count

    tya
    lsr
    lsr
    and #%00000011
    sta size_4_count

    ldy size_1_count
    size_1_loop:
        sty temp_y_reg
        get_random_a
        asl
        sta temp_x_pos

        get_random_a
        asl
        sta temp_y_pos

        get_random_a
        lsr
        lsr
        lsr
        sta temp_rotation

;        create_asteroid temp_x_pos, temp_y_pos, temp_rotation, #1 ; xpos, ypos, rotation, size
        jsr call_create_asteroid_1

        ldy temp_y_reg
        dey
        jmp_ne size_1_loop

    ldy size_2_count
    size_2_loop:
        sty temp_y_reg
        get_random_a
        asl
        sta temp_x_pos

        get_random_a
        asl
        sta temp_y_pos

        get_random_a
        lsr
        lsr
        lsr
        sta temp_rotation

;        create_asteroid temp_x_pos, temp_y_pos, temp_rotation, #2 ; xpos, ypos, rotation, size
        jsr call_create_asteroid_2

        ldy temp_y_reg
        dey
        jmp_ne size_2_loop

    ldy size_3_count
    size_3_loop:
        sty temp_y_reg
        get_random_a
        asl
        sta temp_x_pos

        get_random_a
        asl
        sta temp_y_pos

        get_random_a
        lsr
        lsr
        lsr
        sta temp_rotation

;        create_asteroid temp_x_pos, temp_y_pos, temp_rotation, #3 ; xpos, ypos, rotation, size
        jsr call_create_asteroid_3


        ldy temp_y_reg
        dey
        jmp_ne size_3_loop


    ldy size_4_count
    beq end_size_4

    size_4_loop:
        sty temp_y_reg
        get_random_a
        asl
        and #%11111000
        sta temp_x_pos

        ldy temp_y_reg
        tya
        cmp #3
        beq third_large_asteroid

        cmp #2
        beq second_large_asteroid

        first_large_asteroid:
            lda #184
            jmp end_set_y

        second_large_asteroid:
            lda #64
            jmp end_set_y

        third_large_asteroid:
            lda #136
        end_set_y:

        sta temp_y_pos

        get_random_a
        lsr
        lsr
        lsr
        sta temp_rotation

;        create_asteroid temp_x_pos, temp_y_pos, temp_rotation, #4 ; xpos, ypos, rotation, size
        jsr call_create_asteroid_4

        ldy temp_y_reg
        dey
        jmp_ne size_4_loop

    end_size_4:
    end_level_up:
    rts
.endproc

; this procedure can be optimized out.  I made this a procedure to make it easier to debug
.proc call_create_asteroid_1
    floor temp_x_pos, #25
    ceil temp_x_pos, #225

    floor temp_y_pos, #25
    ceil temp_y_pos, #215

    create_asteroid temp_x_pos, temp_y_pos, temp_rotation, #1 ; xpos, ypos, rotation, size
    rts
.endproc

; this procedure can be optimized out.  I made this a procedure to make it easier to debug
.proc call_create_asteroid_2
    floor temp_x_pos, #25
    ceil temp_x_pos, #225

    floor temp_y_pos, #25
    ceil temp_y_pos, #215

    create_asteroid temp_x_pos, temp_y_pos, temp_rotation, #2 ; xpos, ypos, rotation, size
    rts
.endproc

; this procedure can be optimized out.  I made this a procedure to make it easier to debug
.proc call_create_asteroid_3
    floor temp_x_pos, #25
    ceil temp_x_pos, #225

    floor temp_y_pos, #25
    ceil temp_y_pos, #215

    create_asteroid temp_x_pos, temp_y_pos, temp_rotation, #3 ; xpos, ypos, rotation, size
    rts
.endproc

; this procedure can be optimized out.  I made this a procedure to make it easier to debug
.proc call_create_asteroid_4
    create_asteroid temp_x_pos, temp_y_pos, temp_rotation, #4 ; xpos, ypos, rotation, size
    rts
.endproc
