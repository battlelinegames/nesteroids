.segment "BSS"
    lives: .res 1
    lives_display_change: .res 2
    lives_temp: .res 1
.segment "CODE"

; decrement the number of lives then change the status board
.proc decrement_lives
    dec lives
    jsr reset_lives_label
    rts
.endproc

; increment the number of lives then change the status board
.proc increment_lives
    inc lives
    jsr reset_lives_label
    rts
.endproc

; add A register to lives
.proc add_lives
    clc
    adc lives
    sta lives
    jsr reset_lives_label
    rts
.endproc

; changes the background tiles in the status bar to represent the lives the player has
.proc reset_lives_label
    lda #0
    sta lives_temp

    lda lives
    lives_loop:
    cmp #10
    bcc tens_done
        inc lives_temp
        sec
        sbc #10
        jmp lives_loop
    tens_done:
    clc
    adc #$30
    sta lives_display_change+1

    lda lives_temp
    clc
    adc #$30
    sta lives_display_change

    add_background_write #0, #40, #>lives_display_change, #<lives_display_change, #2

    rts
.endproc
