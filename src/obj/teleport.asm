.segment "ZEROPAGE"
teleport_y: .res 1
teleport_x: .res 1
teleport_frame: .res 1
teleport_delay: .res 1
temp_teleport_frame: .res 1

.define TELEPORT_FRAME_SHIFT 3
.define MAX_TELEPORT_FRAME #5
.define TELEPORT_DELAY_TIME #180
.define START_TELEPORT_FRAME #$1c
.define TELEPORT_PALETTE #2
TELEPORT_OUT_FLAG = %00000100
TELEPORT_IN_FLAG  = %00001000

.segment "CODE"

; teleport the player to a different location
.proc teleport_player
    lda teleport_delay
    bne dont_teleport  ; if teleport delay is != 0, we can't teleport
        set teleport_y, player_y_hi
        set teleport_x, player_x_hi
        set teleport_frame, #0
        set teleport_delay, TELEPORT_DELAY_TIME ; how many frames should we delay the next teleport
        set player_status, #TELEPORT_OUT_FLAG

    dont_teleport:
    rts
.endproc

; check to see if the player is allowed to teleport
.macro teleport_render_player_check skip_render_label
    .local @not_teleporting
    .local @not_hidden
    lda TELEPORT_OUT_FLAG
    bit player_status
    beq @not_teleporting

    lda #TELEPORT_IN_FLAG
    bit player_status
    beq @not_teleporting

    lda teleport_frame ; need to check to see if teleport frame is greater than 2 
    .repeat TELEPORT_FRAME_SHIFT
        lsr             ; shift to find actual frame
    .endrepeat
    cmp #2
    bcc @not_hidden
    jmp skip_render_label

    @not_hidden:
    @not_teleporting:
.endmacro

; run the teleport frame changes in the game loop
.proc move_teleport
    ; first thing we need to do is decrement the teleport delay
    ; this delay prevents the user from teleporting multiple times
    ; without a break
    lda teleport_delay
    beq delay_complete
        dec teleport_delay
    delay_complete:

    lda #(TELEPORT_IN_FLAG | TELEPORT_OUT_FLAG)  ; check to see if we are teleporting
    bit player_status
    bne we_are_teleporting
        rts  ; we're not teleporting so exit the proc
    we_are_teleporting:

    lda teleport_frame

    .repeat TELEPORT_FRAME_SHIFT
        lsr ; TELEPORT_FRAME_SHIFT is the number of insignificant bits on the right side
    .endrepeat

    cmp MAX_TELEPORT_FRAME
    bcs stage_complete ; if our frame is greater than our max frame we don't want to teleport
        inc teleport_frame ; if our frame is less we want to increment it and render
        clc
        adc START_TELEPORT_FRAME
        sta temp_teleport_frame

        render_sprite teleport_y, teleport_x, temp_teleport_frame, TELEPORT_PALETTE ; render the teleport sprite
        rts
    stage_complete:

    lda #TELEPORT_OUT_FLAG  ; check to see if we are teleporting
    bit player_status
    beq not_teleporting_in
        lda #( TELEPORT_IN_FLAG | 1 )  ; flip status to teleporting out
        sta player_status
        get_random_a ; get a random number a and store it in player_y_hi
        asl ; multiply random value by 2
        sta player_y_hi
        sta teleport_y
        get_random_a ; get a random number a and store it in player_x_hi
        asl ; multiply random value by 2
        sta player_x_hi
        sta teleport_x
        lda #0
        sta teleport_frame ; reset the teleport frame
        sta player_y_lo
        sta player_x_lo
        rts
    not_teleporting_in:
    lda #1
    sta player_status
    rts
.endproc

