.linecont       +               ; Allow line continuations
.feature        c_comments

.segment "TILES"
.incbin "../img/Asteroids.chr"
.segment "CODE"

.include "./lib/random.asm"  ; used for generating random numbers

; include the rom table data
.include "./rotables/acceleration.asm"
.include "./rotables/shot_acc.asm"
.include "./rotables/random.asm"

.include "./def/header.asm"         ; set up the iNES headers 
.include "./def/ppu.asm"        ; values used when calling the ppu

.include "./def/zeropage.asm"   ; define the variables on the zeropage
.include "./def/bss.asm"        ; less frequently used memory

.include "./lib/utils.asm"          ; load up some utilitiy macros and procedures

.include "./sound/famitone.asm"
.include "./sound/sfx.asm"

.include "./lib/draw.asm"       ; load up the gamepad library file

.include "./lib/backgrounds.asm"
.include "./obj/score.asm"
.include "./obj/lives.asm"
.include "./obj/explosion.asm"
.include "./obj/ufo.asm"
.include "./obj/ufo_shot.asm"
.include "./obj/teleport.asm"   ; teleport object data
.include "./screens/screens.asm"
.include "./obj/player.asm"     ; player object macros and procs
.include "./lib/gamepad.asm"    ; load up the gamepad library file
.include "./obj/player_shot.asm"      
.include "./obj/asteroid.asm"      
.include "./lib/collision.asm"
.include "./def/tables.asm"     ; palettes, sprite and background tables

.include "./screens/open_screen.asm"
.include "./screens/game_over.asm"
.include "./screens/pause.asm"
.include "./screens/game_play.asm"

.include "./obj/sprite0.asm"
.include "./lib/levels.asm"

.include "./vectors/irq.asm"              ; not currently using irq code, but it must be defined
.include "./vectors/reset.asm"            ; code and macros related to pressing the reset button
.include "./vectors/nmi.asm"

.segment "ZEROPAGE"
game_loop_y_reg_save: .res 1

.segment "CODE"

game_loop: ; this is a macro for the game_loop

    lda nmi_executed ; wait until the nmi has executed
    beq game_loop

    set nmi_ready, #1

    jsr set_gamepad     ; set the gamepad flags

    jsr clear_oam      ; clear out the oam ram
    lda #0
    sta oam_ptr

    lda game_screen
    cmp OPEN_SCREEN
    jmp_eq open_screen_loop

    cmp PLAY_SCREEN
    jmp_eq gameplay_loop

    cmp PAUSE_SCREEN
    jmp_eq pause_loop

    cmp GAME_OVER_SCREEN
    jmp_eq game_over_loop

    open_screen_loop:
        jsr open_screen_gameloop
        jmp end_screen
    gameplay_loop:
        jsr gameplay_gameloop
        jmp end_screen
    pause_loop:
        jsr pause_gameloop
        jmp end_screen
    game_over_loop:
        jsr game_over_gameloop

    end_screen:

    jsr FamiToneUpdate		;update sound

    lda #0

    sta nmi_executed    ; clear the nmi_executed flag so we wait for the next vblank
    set nmi_ready, #0

    jmp game_loop
