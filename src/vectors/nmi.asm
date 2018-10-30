.segment "BSS"
clear_calls: .res 1
;.segment "ZEROPAGE"
palette_init: .res 1
.segment "CODE"

; this is the interrupt that is called during a vblank, when the crt beam
; moves from the bottom right to the top left of the television (back when CRTs were a thing)

nmi:
    lda nmi_ready
    beq nmi_go
        rti
    nmi_go:
    ; set the palette with a macro
    ;set_palette 

    inc frame_counter


    lda palette_init
    cmp #2
    bcs palette_loaded
        jsr load_palettes
        inc palette_init
    palette_loaded:



    ; set the player metasprite with a proc
    ; call the oam dma with a macro
    jsr oam_dma

    lda open_screen_active
    beq not_open_screen
        jsr render_open_screen
    not_open_screen:

    lda run_start_game
    beq not_start_game
        lda #0
        sta run_start_game
    not_start_game:

    jsr clear_background
    jsr update_background

    lda open_screen_active
    bne open_screen
    game_screen:
;       inc scroll_x
;       inc scroll_y
        set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
        lda PPU_STATUS ; $2002

        set PPU_SCROLL, #0 ; scroll_x
        sta PPU_SCROLL ; , #0
;        sta sprite0_run     ; reset sprite0_run
        jmp end_screens
    open_screen:
        set PPU_SCROLL, #0
        set PPU_SCROLL, scroll_y
    end_screens:


    set nmi_executed, #1

rti