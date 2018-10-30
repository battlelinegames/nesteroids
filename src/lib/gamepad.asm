.segment "BSS"
    start_delay: .res 1
.segment "CODE"
    ;======================================================================================
    ; GAMEPAD DATA FLAGS
    ; 76543210
    ; ||||||||
    ; |||||||+--> A Button
    ; ||||||+---> B Button
    ; |||||+----> SELECT Button
    ; ||||+-----> START Button
    ; |||+------> UP Direction
    ; ||+-------> DOWN Direction
    ; |+--------> LEFT Direction
    ; +---------> RIGHT Direction
    ;======================================================================================

.define PRESS_A        #%00000001
.define PRESS_B        #%00000010
.define PRESS_SELECT   #%00000100
.define PRESS_START    #%00001000
.define PRESS_UP       #%00010000
.define PRESS_DOWN     #%00100000
.define PRESS_LEFT     #%01000000
.define PRESS_RIGHT    #%10000000

GAMEPAD_REGISTER = $4016

; because this should only be called once, duplicate labels should not be a problem
.macro gamepad_init
gamepad_init_begin:
    set gamepad_last_press, gamepad_press       ; save gamepad_press to gamepad_last_press

    ; Setup the gamepad register so we can start pulling gamepad data
    set  GAMEPAD_REGISTER, #1
    set  GAMEPAD_REGISTER, #0

    ; the prior set call set the A register to #0, so no need to load it again
    sta gamepad_press ; clear out our gamepad press byte
gamepad_init_end:
.endmacro

.macro button_press_check button
    .local @not_pressed
    lda GAMEPAD_REGISTER
    and #%00000001
    beq @not_pressed    ; beq key not pressed
        lda button
        ora gamepad_press
        sta gamepad_press
    @not_pressed:   ; key not pressed
.endmacro


.macro set_gamepad
    gamepad_init ; prepare the gamepad register to pull data serially

    ; ---> start A flag
;    ora gamepad_press ; set the A flag, no shift is necessary
;    m_load_bit_shift_or GAMEPAD_REGISTER, 0, gamepad_press ; set the A flag
gamepad_a:
    lda GAMEPAD_REGISTER
    and #%00000001
    sta gamepad_press
    ; ---> end A flag

    ; m_load_shift_or loads a with parameter 1, left shifts n times 
    ; (where n = parameter 2), and stores in parameter 3
    ; ---> start B flag
gamepad_b:
    button_press_check PRESS_B
    ; ---> end B flag
    ; ---> start SELECT flag
gamepad_select:
    button_press_check PRESS_SELECT
    ; ---> end SELECT flag
    ; ---> start START flag
gamepad_start:
    button_press_check PRESS_START

    ; ---> end START flag
    ; ---> start UP flag
gamepad_up:
    button_press_check PRESS_UP
    ; ---> end UP flag
    ; ---> start DOWN flag
gamepad_down:
    button_press_check PRESS_DOWN
    ; ---> end DOWN flag
    ; ---> start LEFT flag
gamepad_left:
    button_press_check PRESS_LEFT
    ; ---> end LEFT flag
    ; ---> start RIGHT flag
gamepad_right:
    button_press_check PRESS_RIGHT
    ; ---> end RIGHT flag
    
    ; to find out if this is a newly pressed button, load the last buttons pressed, and 
    ; flipp all the bits with an eor #$ff.  Then you can AND the results with current
    ; gamepad pressed.  This will give you what wasn't pressed previously, but what is
    ; pressed now.  Then store that value in the gamepad_new_press
    lda gamepad_last_press 
    eor #$ff
    and gamepad_press

    sta gamepad_new_press ; all these buttons are new presses and not existing presses

    ; in order to find what buttons were just released, we load and flip the buttons that
    ; are currently pressed  and and it with what was pressed the last time.
    ; that will give us a button that is not pressed now, but was pressed previously
    lda gamepad_press       ; reload original gamepad_press flags
    eor #$ff                ; flip the bits so we have 1 everywhere a button is released
    ; anding with last press shows buttons that were pressed previously and not pressed now
    and gamepad_last_press  
    ; then store the results in gamepad_release
    sta gamepad_release  ; a 1 flag in a button position means a button was just released
.endmacro

.proc press_a
    lda PRESS_A
    and gamepad_press
    beq skip_press_a
        ; THE A BUTTON IS PRESSED
        branch_player_dead dont_shoot
            jsr player_shoot ; shoot if a is pressed
        dont_shoot:
        jmp a_end
    skip_press_a:
        lda #0
        sta player_shot_wait

    a_end:
    
    rts
.endproc

.proc press_b
    lda PRESS_B
    and gamepad_press
    beq skip_press_b
        advance_random_ptr ; advance the random pointer based on the frame
        branch_player_dead dont_teleport
            jsr teleport_player    ; cause the player to teleport
        dont_teleport:
        ; THE B BUTTON IS PRESSED
        ; b button action
        jmp b_end
    skip_press_b:
        ; if the b is not pressed
    b_end:
    rts
.endproc

.proc press_select
    lda PRESS_SELECT
    and gamepad_press
    beq skip_press_select
        advance_random_ptr ; advance the random pointer based on the frame
        ; THE SELECT BUTTON IS PRESSED
        ; select button action
        jmp select_end
    skip_press_select:
        ; if the select is not pressed
    select_end:
    rts
.endproc

.proc press_start
    lda PRESS_START
    and gamepad_press
    beq skip_press_start
        advance_random_ptr ; advance the random pointer based on the frame

        lda start_delay
        bne skip_press_start
        
        lda open_screen_active
        beq dont_start
            lda #0
            sta open_screen_active
            jsr start_game

            lda #30
            sta start_delay

            jmp start_end
        dont_start:

        lda game_over_active
        beq dont_reset
            lda #100
            sta start_delay
;            lda #0
;            sta PPU_CTRL

;            set nmi_ready, #1
;            jsr hide_large_asteroid

            jsr reset_game
            rts
        dont_reset:
        ; THE START BUTTON IS PRESSED
        ; start button action
        jmp start_end
    skip_press_start:
        ; if the start is not pressed
    start_end:
    rts
.endproc

; should change these to use bit

.proc press_up
    lda PRESS_UP       ; load PRESS UP flag into A register
    and gamepad_press   ; and this with gamepad_press
    beq no_press_up     ; if the result is 0, the gamepad is not pressed
        ; right now I'm chosing not to advance the pointer
        ; advance_random_ptr ; advance the random pointer based on the frame

        ; accelerate x macro
        jsr accelerate_player
    no_press_up:
        jsr move_player   ; move the player without accelerating
    rts
.endproc

.proc press_down
    lda PRESS_DOWN
    and gamepad_press
    beq no_press_down     ; if the result is 0, the gamepad is not pressed
        advance_random_ptr ; advance the random pointer based on the frame
        ; press down on directional pad
        jmp press_down_end
    no_press_down:
        ; not pressing down on directional pad
    press_down_end:
    rts
.endproc

.proc press_left
    lda PRESS_LEFT
    and gamepad_press
    beq skip_press_left
        advance_random_ptr ; advance the random pointer based on the frame
        and gamepad_new_press
        beq not_new_left
            jsr frame_left
        jmp skip_press_left
    not_new_left:
        jsr turn_left
    skip_press_left:
    rts
.endproc

.proc press_right
    lda PRESS_RIGHT
    and gamepad_press
    beq skip_press_right
        advance_random_ptr ; advance the random pointer based on the frame
        and gamepad_new_press
        beq not_new_right
            jsr frame_right
        jmp skip_press_right
    not_new_right:
        jsr turn_right
    skip_press_right:
    rts
.endproc