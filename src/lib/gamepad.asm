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

.define START_WAIT #40
.define A_WAIT #40
.define B_WAIT #100

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


;.macro set_gamepad
.proc set_gamepad

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
    rts
.endproc
;.endmacro

