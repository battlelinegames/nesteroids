.segment "BSS"
clear_calls: .res 1
;.segment "ZEROPAGE"
palette_init: .res 1
.segment "CODE"

; this is the interrupt that is called during a vblank, when the crt beam
; moves from the bottom right to the top left of the television (back when CRTs were a thing)

nmi:
    pha
    lda nmi_ready
    beq nmi_go
        pla
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

    ; we need to figure out what screen we're on and run the nmi call for that screen
    jsr clear_background
    jsr update_background
    lda game_screen
    cmp OPEN_SCREEN
    beq open_screen_nmi

    cmp PLAY_SCREEN
    beq gameplay_nmi

    cmp PAUSE_SCREEN
    beq pause_nmi

    cmp GAME_OVER_SCREEN
    beq game_over_screen_nmi

    open_screen_nmi:
        jsr render_open_screen
        jmp end_screen_nmi
    gameplay_nmi:
        jsr render_gameplay
        jmp end_screen_nmi
    pause_nmi:
        jsr render_pause
        jmp end_screen_nmi
    game_over_screen_nmi:
        jsr render_game_over
    end_screen_nmi:

    set nmi_executed, #1
pla
rti