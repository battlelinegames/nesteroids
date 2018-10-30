.segment "BSS"
    game_over_active: .res 1
    game_over_wait: .res 1
    game_over_x_reg_save: .res 1
.segment "CODE"

.proc game_over_screen_init
    ldx #(ASTEROID_COUNT-1)
    asteroid_loop:
        lda asteroid_size, x
        cmp #4
        beq large_size
            dex 
            bpl asteroid_loop
            jmp end_asteroid_loop
        large_size:
            stx game_over_x_reg_save
            jsr hide_large_asteroid
            ldx game_over_x_reg_save
            dex 
            bpl asteroid_loop
    end_asteroid_loop:
    
    set game_over_active, #1
    set game_over_wait, #100

    ; stop scroll
    lda PPU_STATUS ; $2002
    set PPU_SCROLL, #0
    sta PPU_SCROLL

    jsr clear_player_stats

    ; display game over on background
    add_background_write #1, #$CB, #>game_over_text, #<game_over_text, #10
    add_background_write #1, #$EA, #>press_start_text, #<press_start_text, #12

    ; game_over_text

    rts
.endproc