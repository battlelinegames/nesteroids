.segment "ZEROPAGE"
    add_next_digit: .res 1
.segment "BSS"
    score_base10: .res 6 ; .byte 0, 0, 0, 0, 0, 0
    score_display_change: .res 6 ;.byte "      "
.segment "CODE"

SCORE_DIGIT_COUNT = 6

.proc clear_score
    lda #0
    ldx #SCORE_DIGIT_COUNT
    clear_score_loop:
        dex
        sta score_base10, x
    bne clear_score_loop

    lda #1
    jsr add_score_base10
    
    rts
.endproc

; make sure register A is loaded with value you want to add
; this procedure clobbers x, y register
; adding more than 245 will break this
.proc add_score_base10
    ldx #(SCORE_DIGIT_COUNT-1)
    add_loop:
        tay
        lda #0
        sta add_next_digit ; this is to figure out the number we need to add to the next 10s place
        tya 

        clc
        adc score_base10, x
        sta score_base10, x
        cmp #10
        bcc done_adding
        sub10_loop:
            lda score_base10, x
            sec 
            sbc #10
            sta score_base10, x
            inc add_next_digit
            cmp #10
        bcs sub10_loop ; loop until value in A is less than 10

        lda add_next_digit
        dex
        jmp add_loop
    done_adding:

    jsr change_score_display
    rts
.endproc

.proc change_score_display
    ; first clear display change
    lda #' '
    ldx #(SCORE_DIGIT_COUNT-1)
    clear_loop:
        sta score_display_change, x
        dex
    bne clear_loop
    sta score_display_change, x

    ldx #0
    zero_loop:
        lda score_base10, x
        bne non_zero

        inx
        cpx #SCORE_DIGIT_COUNT
        bne zero_loop
    non_zero:

    ldy #0

    change_loop:
        lda score_base10, x
        clc
        adc #$30
        sta score_display_change, y
        iny
        inx
        cpx #SCORE_DIGIT_COUNT
    bcc change_loop

    add_background_write #0, #104, #>score_display_change, #<score_display_change, #6

    rts
.endproc
