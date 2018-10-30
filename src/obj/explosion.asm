.segment "BSS"
.define FRAME_SHIFT 2
MAX_EXPLOSION_FRAME = 4
EXPLOSION_COUNT = 8
STARTING_EXPLOSION_FRAME = $0C

explosion_y: .res EXPLOSION_COUNT
explosion_x: .res EXPLOSION_COUNT
explosion_frame: .res EXPLOSION_COUNT

explosion_ptr: .res 1

.segment "CODE"
.proc reset_explosion_frames 
    ldx #EXPLOSION_COUNT
    lda #$ff ; #(MAX_EXPLOSION_FRAME <<FRAME_SHIFT)
    dex
    frame_loop:
;        php ; save off the dex status so I can branch on not equal

        sta explosion_frame, x
        sta explosion_x, x

;        plp
        dex
    bpl frame_loop
    rts
.endproc

.macro create_explosion x_pos, y_pos
    .local @no_reset_y
    play_sfx EXPLODE_SOUND, PRIORITY_1

    ldx explosion_ptr
    lda x_pos
    sta explosion_y, x
    lda y_pos
    sta explosion_x, x
    lda #0  ; reset the explosion frame to 0
    sta explosion_frame, x

    dex
    bpl @no_reset_y
        ldx #(EXPLOSION_COUNT-1)
    @no_reset_y:
    stx explosion_ptr
.endmacro

; SAVE_X_REG = var_5 

.proc move_explosions
    ldx #(EXPLOSION_COUNT-1)

    explosion_loop:
        lda explosion_frame, x
        .repeat FRAME_SHIFT
            lsr
        .endrepeat
        cmp #MAX_EXPLOSION_FRAME
        jmp_cs end_loop ; our frame can not be rendered
        inc explosion_frame, x

        asl
        asl ; multiply by 4
        clc
        adc #STARTING_EXPLOSION_FRAME

        sta TEMP_FRAME
        lda explosion_y, x 
        sta temp_y_pos
        lda explosion_x, x 
        sta temp_x_pos

        txa ; make sure you don't clobber the x register
        tay

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

        tya ; make sure you don't clobber the x register
        tax

        end_loop:
        dex
    jmp_pl explosion_loop

    end:
rts
.endproc