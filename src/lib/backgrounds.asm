.proc load_palettes

    lda PPU_STATUS             ; read PPU status to reset the high/low latch

    ; PPUADDR	$2006	aaaa aaaa	PPU read/write address (two writes: MSB, LSB)
    ;----------￾-------￾----------￾---------------------------------------------'
    ;| $2006   |  W2   | aaaaaaaa | PPU Memory Address                [PPUADDR] |
    ;|         |       |          |                                             |
    ;|         |       |          |  Specifies the address in VRAM in which     |
    ;|         |       |          |  data should be read from or written to.    |
    ;|         |       |          |  This is a double-write register. The high- |
    ;|         |       |          |  byte of the 16-bit address is written      |
    ;|         |       |          |  first, then the low-byte.                  |
    ;----------￾-------￾----------￾---------------------------------------------'
    lda #$3F
    sta PPU_ADDR             ; write the high byte of $3F00 address

    lda #$00
    sta PPU_ADDR             ; write the low byte of $3F00 address

    ldx #$00              ; start out at 0
    LoadPalettesLoop:
    lda palette_background, x        ; load data from address (palette + the value in x)
                            ; 1st time through loop it will load palette+0
                            ; 2nd time through loop it will load palette+1
                            ; 3rd time through loop it will load palette+2
                            ; etc

    ; PPUDATA	$2007	dddd dddd	PPU data read/write
    ;----------￾-------￾----------￾---------------------------------------------'
    ;| $2007   | RW    | dddddddd | PPU I/O Register                    [PPUIO] |
    ;|         |       |          |                                             |
    ;|         |       |          |  Used to read/write to the address spec-    |
    ;|         |       |          |  ified via $2006 in VRAM.                   |
    ;----------￾-------￾----------￾---------------------------------------------'
    sta PPU_DATA             ; write to PPU
    ;    WRITE_PPU_DATA

    inx                   ; X = X + 1
    cpx #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
    bne LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
    rts
.endproc

BACKGROUND_RENDER_COUNT = 32

.segment "BSS"
    nametable_reg_x: .res 1
    nametable_reg_y: .res 1

    tile_render_count: .res 1

    ; clear background data variables
    clear_ppu_hi: .res BACKGROUND_RENDER_COUNT
    clear_ppu_lo: .res BACKGROUND_RENDER_COUNT
    clear_run_len: .res BACKGROUND_RENDER_COUNT

    clear_read_ptr: .res 1
    clear_write_ptr: .res 1

    ; background data write variables
    bg_ppu_hi: .res BACKGROUND_RENDER_COUNT
    bg_ppu_lo: .res BACKGROUND_RENDER_COUNT

    bg_data_hi: .res BACKGROUND_RENDER_COUNT
    bg_data_lo: .res BACKGROUND_RENDER_COUNT
    bg_run_len: .res BACKGROUND_RENDER_COUNT

.segment "ZEROPAGE"
    bg_read_ptr: .res 1
    bg_write_ptr: .res 1

    bg_indirect_lo: .res 1
    bg_indirect_hi: .res 1
    bg_loop_run: .res 1
.segment "CODE"

MAX_TILE_RENDERS = 40

; clear background procedure runs during the nmi
; clobbering both x and y with this.  may need to save off those values if it's a problem
.proc clear_background
    set tile_render_count, #0
    
    clear_entry_loop:
        ldx clear_read_ptr
        cpx clear_write_ptr
        beq end_clear_background ; if clear_read_ptr == clear_write_ptr, we have rendere'd all the clears

        lda clear_run_len, x
        clc
        adc tile_render_count
        cmp #MAX_TILE_RENDERS
        bcs end_clear_background ; if rendering these tiles would cause us to go over our max

        ; because we are going to render this, store off the new tile count
        sta tile_render_count 

        lda PPU_STATUS        ; PPU_STATUS = $2002

        lda #$20
        clc
        adc clear_ppu_hi, x
        sta PPU_ADDR          ; PPU_ADDR = $2006

        lda clear_ppu_lo, x; #$00
        sta PPU_ADDR          ; PPU_ADDR = $2006

        lda #0
        ldy clear_run_len, x
        dey
        clear_bg_loop:
            sta PPU_DATA      
            dey
        bne clear_bg_loop

        inc clear_read_ptr ; we need to advance the clear read ptr
        lda clear_read_ptr
        cmp #BACKGROUND_RENDER_COUNT
        bcc no_reset
            lda #0
            sta clear_read_ptr
        no_reset:
    jmp clear_entry_loop

    end_clear_background:

    lda scroll_x
    sta PPU_SCROLL

    lda scroll_y
    sta PPU_SCROLL

    rts
.endproc

; update background procedure runs during the nmi
; clobbers all registers
.proc update_background
    update_entry_loop:
        lda bg_read_ptr
        and #%00011111
        tax

        cpx bg_write_ptr
        beq end_update_background ; if clear_read_ptr == clear_write_ptr, we have rendere'd all the clears

        lda bg_run_len, x
        clc
        adc tile_render_count
        clc
        adc #10
        cmp #MAX_TILE_RENDERS
        bcs end_update_background ; if rendering these tiles would cause us to go over our max

        ; because we are going to render this, store off the new tile count
        sta tile_render_count 

        lda PPU_STATUS        ; PPU_STATUS = $2002

        lda #$20
        clc
        adc bg_ppu_hi, x
        sta PPU_ADDR          ; PPU_ADDR = $2006

        lda bg_ppu_lo, x; #$00
        sta PPU_ADDR          ; PPU_ADDR = $2006

        lda bg_data_hi, x
        sta bg_indirect_hi

        lda bg_data_lo, x
        sta bg_indirect_lo

        lda bg_run_len, x
        sta bg_loop_run
        ldy #0
        update_bg_loop:
            lda (bg_indirect_lo),y
            sta PPU_DATA      
            iny
            cpy bg_loop_run
        bne update_bg_loop

        inc bg_read_ptr ; we need to advance the clear read ptr
    jmp update_entry_loop

    end_update_background:

    lda scroll_x
    sta PPU_SCROLL

    lda scroll_y
    sta PPU_SCROLL

    rts
.endproc

; during the game loop, this macro adds a request to clear
; part of the background to the background clear queue
.macro add_background_clear ppu_hi, ppu_lo, run_len
    
    ldx clear_write_ptr

    ; clear background data variables
    setx clear_ppu_hi, ppu_hi
    setx clear_ppu_lo, ppu_lo
    setx clear_run_len, run_len
    inc clear_run_len, x

    txa
    clc
    adc #1
    and #%00011111
    sta clear_write_ptr

.endmacro

; during the game loop, this macro adds a request to write to the bakcground
; part of the background to the background write queue
.macro add_background_write ppu_hi, ppu_lo, data_hi, data_lo, run_len
    ldx bg_write_ptr

    ; clear background data variables
    setx bg_ppu_hi, ppu_hi
    setx bg_ppu_lo, ppu_lo
    setx bg_data_hi, data_hi
    setx bg_data_lo, data_lo
    setx bg_run_len, run_len

    txa
    clc
    adc #1
    and #%00011111
    sta bg_write_ptr
.endmacro

; this loads up the background for the open screen
.proc load_open_screen
    ldx bg_write_ptr

    lda #>logo_background_top
    sta bg_data_hi, x

    lda #<logo_background_top
    sta bg_data_lo, x

    lda #$20
    sta bg_ppu_hi, x

    lda #$88
    sta bg_ppu_lo, x

    lda #16
    sta bg_run_len, x

    inx
    lda #>logo_background_bottom
    sta bg_data_hi, x

    lda #<logo_background_bottom
    sta bg_data_lo, x

    lda #$20
    sta bg_ppu_hi, x

    lda #$A8
    sta bg_ppu_lo, x

    lda #16
    sta bg_run_len, x
    inx

    txa
    and #%00011111
    sta bg_write_ptr
    rts
.endproc

; this loads up the background attribute table
.proc load_attribute 
    lda PPU_STATUS        ; read PPU status to reset the high/low latch
    lda #$23    ; 27 ; 2B ; 2F
    sta PPU_ADDR          ; write the high byte of $23C0 address

    lda #$C0
    sta PPU_ADDR          ; write the low byte of $23C0 address

    ldx #$00              ; start out at 0
    LoadAttributeLoop:
        lda #%00000000 ; attribute, x      ; load data from address (attribute + the value in x)
        sta PPU_DATA          ; write to PPU
        inx                   ; X = X + 1
        cpx #$40              ; Compare X to hex $08, decimal 8 - copying 8 bytes
    bne LoadAttributeLoop  ; Branch to LoadAttributeLoop if compare was Not Equal to zero


    lda PPU_STATUS        ; read PPU status to reset the high/low latch
    lda #$2B    ; 27 ; 2B ; 2F
    sta PPU_ADDR          ; write the high byte of $23C0 address

    lda #$C0
    sta PPU_ADDR          ; write the low byte of $23C0 address

    ldx #$00              ; start out at 0
    LoadAttributeLoop_2:
        lda #%00000000 ; attribute, x      ; load data from address (attribute + the value in x)
        sta PPU_DATA          ; write to PPU

        inx                   ; X = X + 1
        cpx #$40              ; Compare X to hex $08, decimal 8 - copying 8 bytes
    bne LoadAttributeLoop_2  ; Branch to LoadAttributeLoop if compare was Not Equal to zero

    rts
.endproc