; add this when you refactor
.segment "BSS"

    ASTEROID_COUNT = 32
    LARGE_ASTEROID_SPRITE_START = $80

    asteroid_y_lo: .res ASTEROID_COUNT
    asteroid_y_hi: .res ASTEROID_COUNT
    asteroid_x_lo: .res ASTEROID_COUNT
    asteroid_x_hi: .res ASTEROID_COUNT

    asteroid_vel_y_lo: .res ASTEROID_COUNT
    asteroid_vel_y_hi: .res ASTEROID_COUNT
    asteroid_vel_x_lo: .res ASTEROID_COUNT
    asteroid_vel_x_hi: .res ASTEROID_COUNT
    asteroid_rotation: .res ASTEROID_COUNT
    asteroid_size: .res ASTEROID_COUNT ; if the asteroid size is 0, the asteroid is destroyed

    ;asteroid_count: .res 1
    asteroid_ptr: .res 1

    large_asteroid_1_lo: .res 1
    large_asteroid_1_hi: .res 1
    large_asteroid_1_index: .res 1

    large_asteroid_2_lo: .res 1
    large_asteroid_2_hi: .res 1
    large_asteroid_2_index: .res 1

    large_asteroid_3_lo: .res 1
    large_asteroid_3_hi: .res 1
    large_asteroid_3_index: .res 1

    large_asteroid_4_lo: .res 1
    large_asteroid_4_hi: .res 1
    large_asteroid_4_index: .res 1

    lo_temp: .res 1
    hi_temp: .res 1
    tile_temp_lo: .res 1
    tile_temp_hi: .res 1
    asteroid_temp_y: .res 1
    cell_total: .res 1
    asteroid_index: .res 1

    kill_asteroid_size: .res 1
    kill_asteroid_y: .res 1
    kill_asteroid_x: .res 1
    kill_asteroid_rotation: .res 1
    kill_asteroid_reg_x: .res 1
    kill_asteroid_reg_y: .res 1

;asteroid_temp_y: .res 1
.segment "CODE"

;===============================================
; asteroid_x_lo: .res ASTEROID_COUNT
; asteroid_x_hi: .res ASTEROID_COUNT
; asteroid_x_lo: .res ASTEROID_COUNT
; asteroid_x_hi: .res ASTEROID_COUNT
; 
; asteroid_vel_x_lo: .res ASTEROID_COUNT
; asteroid_vel_x_hi: .res ASTEROID_COUNT
; asteroid_vel_x_lo: .res ASTEROID_COUNT
; asteroid_vel_x_hi: .res ASTEROID_COUNT
;===============================================

.proc move_asteroids
    ldx #ASTEROID_COUNT
    asteroid_loop: 
        dex
        bmi end

        lda asteroid_size, x
        beq asteroid_loop


        xadd_16 asteroid_y_hi, asteroid_y_lo, \
                asteroid_vel_y_hi, asteroid_vel_y_lo, \
                asteroid_y_hi, asteroid_y_lo

        xadd_16 asteroid_x_hi, asteroid_x_lo, \
                asteroid_vel_x_hi, asteroid_vel_x_lo, \
                asteroid_x_hi, asteroid_x_lo

        jmp asteroid_loop
    end:
    rts
.endproc


.proc find_open_asteroid_x
    ldx #0

    asteroid_search_loop:
        lda asteroid_size, x
        beq end ; if ths asteroid size is 0, jump to end
        inx
        cpx #ASTEROID_COUNT  ; is this the maximum asteroid
    bne asteroid_search_loop ; continue looping if we aren't finished searching

    end:
    rts
.endproc

.macro largest_asteroid_setup lo, hi, index
    .local @no_carry
    .local @no_carry_2
    ; the x register should have the current asteroid number
    stx index
    lda asteroid_x_hi, x
    lsr 
    lsr
    lsr ; we need to divide the x position by 8
    sta cell_total
    set hi, #0

    lda asteroid_y_hi, x
    and #%11111100
    rol
    bcc @no_carry
        inc hi
        asl hi
    @no_carry: 
    rol
    bcc @no_carry_2
        inc hi
    @no_carry_2: 

    clc
    adc cell_total
    bcc @no_carry_3
        inc hi
    @no_carry_3: 

    sta lo ; store the tile position in temp_y

    add_background_write hi, lo, #>asteroid_background_r1, #<asteroid_background_r1, #4

    add_16 hi, lo, #$00, #$20, tile_temp_hi, tile_temp_lo

    add_background_write tile_temp_hi, tile_temp_lo, \
                        #>asteroid_background_r2, #<asteroid_background_r2, #4

    add_16 tile_temp_hi, tile_temp_lo, #$00, #$20, tile_temp_hi, tile_temp_lo

    add_background_write tile_temp_hi, tile_temp_lo, \
                        #>asteroid_background_r3, #<asteroid_background_r3, #4

    add_16 tile_temp_hi, tile_temp_lo, #$00, #$20, tile_temp_hi, tile_temp_lo

    add_background_write tile_temp_hi, tile_temp_lo, \
                        #>asteroid_background_r4, #<asteroid_background_r4, #4

    ; THIS WON'T WORK BECAUSE THE VALUE WILL BE GREATER THAN 256
.endmacro

.macro clear_large_asteroid lo, hi
;        add_background_clear ppu_hi, ppu_lo, run_len

        add_background_clear hi, lo, #4

        add_16 hi, lo, #$00, #$20, tile_temp_hi, tile_temp_lo

        add_background_clear tile_temp_hi, tile_temp_lo, #4

        add_16 tile_temp_hi, tile_temp_lo, #$00, #$20, tile_temp_hi, tile_temp_lo

        add_background_clear tile_temp_hi, tile_temp_lo, #4

        add_16 tile_temp_hi, tile_temp_lo, #$00, #$20, tile_temp_hi, tile_temp_lo

        add_background_clear tile_temp_hi, tile_temp_lo, #4

.endmacro

.proc hide_large_asteroid
    cpx large_asteroid_1_index
    beq asteroid_slot_1
    cpx large_asteroid_2_index
    jmp_eq asteroid_slot_2
    cpx large_asteroid_3_index
    jmp_eq asteroid_slot_3
    cpx large_asteroid_4_index
    jmp_eq asteroid_slot_4
    jmp end

    asteroid_slot_1:
        clear_large_asteroid large_asteroid_1_lo, large_asteroid_1_hi
        jmp end
    asteroid_slot_2:
        clear_large_asteroid large_asteroid_2_lo, large_asteroid_2_hi
        jmp end
    asteroid_slot_3:
        clear_large_asteroid large_asteroid_3_lo, large_asteroid_3_hi
        jmp end
    asteroid_slot_4:
        clear_large_asteroid large_asteroid_4_lo, large_asteroid_4_hi
        jmp end

    end:
    rts
.endproc

.proc create_largest_asteroid
    ; make sure the x register is pointed at the right asteroid
    lda large_asteroid_1_lo
    ora large_asteroid_1_hi

    jmp_ne asteroid_1_not_available
        largest_asteroid_setup large_asteroid_1_lo, large_asteroid_1_hi, large_asteroid_1_index
        rts
    asteroid_1_not_available:

    lda large_asteroid_2_lo
    ora large_asteroid_2_hi

    jmp_ne asteroid_2_not_available
        largest_asteroid_setup large_asteroid_2_lo, large_asteroid_2_hi, large_asteroid_2_index
        rts
    asteroid_2_not_available:


    lda large_asteroid_3_lo
    ora large_asteroid_3_hi

    jmp_ne asteroid_3_not_available
        largest_asteroid_setup large_asteroid_3_lo, large_asteroid_3_hi, large_asteroid_3_index
        rts
    asteroid_3_not_available:

    lda large_asteroid_4_lo
    ora large_asteroid_4_hi

    jmp_ne asteroid_4_not_available
        largest_asteroid_setup large_asteroid_4_lo, large_asteroid_4_hi, large_asteroid_4_index
        rts
    asteroid_4_not_available:

    rts
.endproc

.macro create_asteroid ypos, xpos, rotation, size
 ;   .local @skip_reset_count
    .local @shift_loop
    .local @end_create_asteroid
    .local @not_largest_asteroid

; create_asteroid macro
;    ldx asteroid_count ; how many asteroids in are we ===================
    jsr find_open_asteroid_x ; this will set the x register
    cpx #ASTEROID_COUNT
    beq @end_create_asteroid

    lda #0
    sta asteroid_y_lo, x
    sta asteroid_x_lo, x

    ; setx macro sets the first value offset by the x register to the second value
    setx asteroid_y_hi, ypos
    setx asteroid_x_hi, xpos
    setx asteroid_rotation, rotation
    setx asteroid_size, size

    cmp #4
    bne @not_largest_asteroid
        ; x register must be set to current asteroid
        setx asteroid_y_hi, xpos
        setx asteroid_x_hi, ypos
        jsr create_largest_asteroid
        lda #0
        sta asteroid_vel_y_hi, x
        sta asteroid_vel_y_lo, x
        sta asteroid_vel_x_hi, x
        sta asteroid_vel_x_lo, x
        beq @end_create_asteroid
    @not_largest_asteroid:

    ; rotation will be 0-15
    ldy rotation

    ; get x velocity from acceleration table based on rotation
    lda z_acceleration_table_hi, y
    sta asteroid_vel_y_hi, x
    lda z_acceleration_table_lo, y
    sta asteroid_vel_y_lo, x

    lda y_acceleration_table_hi, y
    sta asteroid_vel_x_hi, x
    lda y_acceleration_table_lo, y
    sta asteroid_vel_x_lo, x

    ; I want to shift left (multiply by 2) the velocity values 5-size times.
    ; this will make the smaller asteroids go faster
    lda #5
    sec 
    sbc size
    tay

    @shift_loop:
        ; double the asteroid's x velocity
        asl asteroid_vel_y_lo, x
        rol asteroid_vel_y_hi, x

        ; double the asteroid's y velocity
        asl asteroid_vel_x_lo, x
        rol asteroid_vel_x_hi, x
        dey
    bne @shift_loop ; perform loop 5-size number of times

    @end_create_asteroid:
;    inx
;    cpx #ASTEROID_COUNT
;    bne @skip_reset_count
;        ldx #0
;    @skip_reset_count:
;    stx asteroid_count

; end create_asteroid macro
.endmacro

; asteroid_metasprite uses the x register to render an asteroid metasprite
.proc asteroid_metasprite ; the x value must be set to the appropriate asteroid

    lda asteroid_y_hi, x
    sta temp_y_pos

    lda asteroid_x_hi, x
    sta temp_x_pos
    
    ; using the asteroid rotation we can figure out how to flip the render and/or 
    ; rotate through the animation
    lda asteroid_rotation, x
    ; only the top 4 bits of the rotation are significant so shift those off
    ; now reduce the number of possibilities to 0-7 (lowest 3 bits)
    lsr 

    ; I need to subtract one so that I get  -1 - +6 
    sta var_1
    inc var_1
    lda var_1

    ; this and will put us back to 0-7, but we will change what was 0 to 7
    and #%00000111
    ; now shift off another bit so we have 4 possible directions (0-3)

    lsr

    cmp #3
    beq dir_3
    cmp #2
    beq dir_2
    cmp #1
    beq dir_1

    ;=======================================================================================
    ; set oam, X to flags and increment X register
    ;  76543210
    ;  |||   ||
    ;  |||   ++- Color Palette of sprite.  Choose which set of 4 from the 16 colors to use
    ;  |||
    ;  ||+------ Priority (0: in front of background; 1: behind background)
    ;  |+------- Flip sprite horizontally
    ;  +-------- Flip sprite vertically
    ;=======================================================================================

    dir_0: ; negative y axis
        lda asteroid_x_hi, x
        lsr
        lsr
        and #%00000011 ; only the last 2 bits matter
        ; we want to subtract this value from 3, but instead we'll negate and add to 3
        ; for the same effect
        negate_a
        clc
        adc #3
        sta TEMP_FRAME
        lda #FLIP_SPRITE_V
        sta TEMP_FLAGS
        jmp end_dir

    dir_1: ; positive x axis
        lda asteroid_y_hi, x
        lsr
        lsr
        and #%00000011 ; only the last 2 bits matter
        ora TILE_ROTATION_FLAG
        sta TEMP_FRAME
        lda #FLIP_SPRITE_H
        sta TEMP_FLAGS
        jmp end_dir

    dir_2: ; positive y axis
        lda asteroid_x_hi, x
        lsr
        lsr
        and #%00000011 ; only the last 2 bits matter
        ; we want to subtract this value from 3, but instead we'll negate and add to 3
        ; for the same effect
        sta TEMP_FRAME
        lda #0
        sta TEMP_FLAGS
        jmp end_dir

    dir_3: ; negative x axis

        lda asteroid_y_hi, x
        lsr
        lsr
        and #%00000011 ; only the last 2 bits matter
        negate_a
        clc
        adc #3
        ora TILE_ROTATION_FLAG
        sta TEMP_FRAME
        lda #FLIP_SPRITE_H
        sta TEMP_FLAGS


    end_dir:
    ; figure out what size it is and pick that for rendering purposes    

    ldy asteroid_size, x

    cpy #4
    jmp_eq size_4
    cpy #3
    beq size_3
    cpy #2
    beq size_2
    cpy #1
    beq size_1

    size_0:
        jmp end
    size_1:
        lda TILE_ROTATION_FLAG
        bit TEMP_FRAME 
        beq not_rotated_1
            rotated_1:
                lda TEMP_FRAME
                and #%00000011
                clc
                adc #SIZE_1_ROT_FRAMES
                jmp end_rot_1

            not_rotated_1:
                lda TEMP_FRAME
                and #%00000011
                clc
                adc #SIZE_1_FRAMES
            end_rot_1:
            sta TEMP_FRAME
            render_sprite temp_y_pos, temp_x_pos, TEMP_FRAME, #ASTEROID_PALETTE 
            jmp end
    size_2:
        lda TILE_ROTATION_FLAG
        bit TEMP_FRAME
        beq not_rotated_2
            rotated_2:
                lda TEMP_FRAME
                and #%00000011
                clc
                adc #SIZE_2_ROT_FRAMES
                jmp end_rot_2

            not_rotated_2:
                lda TEMP_FRAME
                and #%00000011
                clc
                adc #SIZE_2_FRAMES
        end_rot_2:
        sta TEMP_FRAME
        render_sprite temp_y_pos, temp_x_pos, TEMP_FRAME, #ASTEROID_PALETTE 
        jmp end
    size_3:
        lda TILE_ROTATION_FLAG
        bit TEMP_FRAME
        beq not_rotated_3
            rotated_3:
                lda TEMP_FRAME
                and #%00000011
                asl
                asl
                clc
                adc #SIZE_3_ROT_FRAMES
                jmp end_rot_3

            not_rotated_3:
                lda TEMP_FRAME
                and #%00000011
                asl
                asl
                clc
                adc #SIZE_3_FRAMES
        end_rot_3:
        sta TEMP_FRAME
        render_sprite temp_y_pos, temp_x_pos, TEMP_FRAME, #ASTEROID_PALETTE 
        lda temp_x_pos
        clc
        adc #8
        sta temp_x_pos
        inc TEMP_FRAME
        render_sprite temp_y_pos, temp_x_pos, TEMP_FRAME, #ASTEROID_PALETTE
        lda temp_y_pos
        clc
        adc #8
        sta temp_y_pos
        lda temp_x_pos
        sec
        sbc #8
        sta temp_x_pos
        inc TEMP_FRAME
        render_sprite temp_y_pos, temp_x_pos, TEMP_FRAME, #ASTEROID_PALETTE 
        lda temp_x_pos
        clc
        adc #8
        sta temp_x_pos
        inc TEMP_FRAME
        render_sprite temp_y_pos, temp_x_pos, TEMP_FRAME, #ASTEROID_PALETTE 

        jmp end
    size_4:
        ; I will add the largest asteroid later. It will use background tiles
    end:
    rts
.endproc


; X register index of killed asteroid, Y register index of killed bullet
.proc kill_asteroid
    ; save off x and y registers
    lda player_shot_alive_time, y ; kill the player shot
    bne shot_is_alive
        rts
    shot_is_alive:

    stx kill_asteroid_reg_x
    sty kill_asteroid_reg_y

    lda asteroid_y_hi, x 
    sta kill_asteroid_y
    lda asteroid_x_hi, x 
    sta kill_asteroid_x

    lda asteroid_size, x
    cmp #1
    jmp_eq size_1 ; size 1 is the smallest asteroid size
    cmp #2
    jmp_eq size_2
    cmp #3
    jmp_eq size_3

    size_4:
        ; NEED TO ERASE THE BACKGROUND TILE +++++++++++++++++++++++++++++++++++++++
        jsr hide_large_asteroid

        lda kill_asteroid_x
        clc
        adc scroll_x
        sta kill_asteroid_x

        get_random_a
        and #%00001111 ; only the lowest 4 bits are significant
        sta kill_asteroid_rotation
        create_asteroid kill_asteroid_y, kill_asteroid_x, kill_asteroid_rotation, #3 ; create asteroids clobbers X and Y

        get_random_a
        and #%00001111 ; only the lowest 4 bits are significant
        sta kill_asteroid_rotation

        lda kill_asteroid_y
        clc
        adc #16
        sta kill_asteroid_y

        lda kill_asteroid_x
        clc
        adc #16
        sta kill_asteroid_x

        create_asteroid kill_asteroid_y, kill_asteroid_x, kill_asteroid_rotation, #3 ; create asteroids clobbers X and Y

        lda #1
        jsr add_score_base10 

        jmp size_end
    size_3:
        get_random_a
        and #%00001111 ; only the lowest 4 bits are significant
        sta kill_asteroid_rotation
        create_asteroid kill_asteroid_y, kill_asteroid_x, kill_asteroid_rotation, #2 ; create asteroids clobbers X and Y

        get_random_a
        and #%00001111 ; only the lowest 4 bits are significant
        sta kill_asteroid_rotation
        create_asteroid kill_asteroid_y, kill_asteroid_x, kill_asteroid_rotation, #2 ; create asteroids clobbers X and Y

        lda #2
        jsr add_score_base10 

        jmp size_end
    size_2:
        get_random_a
        and #%00001111 ; only the lowest 4 bits are significant
        sta kill_asteroid_rotation
        create_asteroid kill_asteroid_y, kill_asteroid_x, kill_asteroid_rotation, #1 ; create asteroids clobbers X and Y

        get_random_a
        and #%00001111 ; only the lowest 4 bits are significant
        sta kill_asteroid_rotation
        create_asteroid kill_asteroid_y, kill_asteroid_x, kill_asteroid_rotation, #1 ; create asteroids clobbers X and Y

        lda #5
        jsr add_score_base10 
        jmp size_end
    size_1:
        lda #10
        jsr add_score_base10 
    size_end:

    ; restores x and y registers
    ldx kill_asteroid_reg_x
    ldy kill_asteroid_reg_y

    lda #0
    sta asteroid_size, x ; kill the asteroid
    sta player_shot_alive_time, y ; kill the player shot

    create_explosion kill_asteroid_y, kill_asteroid_x


    rts
.endproc

.proc clear_asteroids
    ldx #ASTEROID_COUNT
    lda #0

    clear_loop:
        dex
        sta asteroid_size, x
    bne clear_loop
    
    rts
.endproc
