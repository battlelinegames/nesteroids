; DEBUG = 1 ; if DEBUG flag exists debug is on.  comment this line out to turn it off
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
;game_paused: .res 1
.segment "CODE"

game_loop: ; this is a macro for the game_loop
;    lda oam_ptr
;    beq game_loop

    lda nmi_executed ; wait until the nmi has executed
    beq game_loop

    set nmi_ready, #1

    jsr set_gamepad     ; set the gamepad flags

/*
    lda game_over_active
    ora game_paused
    bne no_sprite0_clear
        jsr sprite0_clear_wait
    no_sprite0_clear:
*/
/*
    lda open_screen_active
    ora game_paused
    bne not_open_screen_active
        jsr sprite0_wait

        set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
        lda PPU_STATUS ; $2002
        set PPU_SCROLL, scroll_x
        set PPU_SCROLL, #0

    not_open_screen_active:
*/
;        set PPU_SCROLL, scroll_x


    ; should change this to use bit
    /*
    jsr press_left
    jsr press_right
    jsr press_up
    jsr press_down
    jsr press_a
    jsr press_b
    jsr press_start
    jsr press_select

    lda game_paused ; wait until the nmi has executed
    jmp_ne game_loop
    */

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

;    jsr set_sprite0

;    jsr move_asteroids ; move the asteroids
/*
    ldx #ASTEROID_COUNT
    asteroid_loop:
        dex
        bmi asteroid_loop_end
        lda asteroid_size, x
        beq asteroid_loop
        stx game_loop_y_reg_save
        jsr asteroid_metasprite
        ldx game_loop_y_reg_save
        jmp asteroid_loop ; if I don't have at least one asteroid, this is going to break

    asteroid_loop_end:
    dec scroll_x

    jsr move_explosions
    jsr move_teleport
    jsr move_player_shots
    jsr player_metasprite


    ; check for collisions between the asteroids and the player
    jsr collision_check_pa
    ; check for collisions between the asteroids and the player's shots
    jsr collision_check_sa
    jsr collision_check_up
    jsr collision_check_usp
    jsr collision_check_spu

    jsr player_respawn_check

    jsr create_ufo
    jsr move_ufo
    jsr move_ufo_shots

    jsr check_level_up

    jsr FamiToneUpdate		;update sound
*/
    jsr FamiToneUpdate		;update sound


    lda #0
;    sta PPU_SCROLL
;    sta PPU_SCROLL
    sta nmi_executed    ; clear the nmi_executed flag so we wait for the next vblank
    set nmi_ready, #0

    jmp game_loop
