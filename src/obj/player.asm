.segment "ZEROPAGE"

; player variables
player_rotation: .res 1        ; higher order 4 bits correspond to one of 16 rotation meta-sprites

player_y_hi: .res 1               ; player's x coordinates
player_y_lo: .res 1               ; player's x coordinates

player_x_hi: .res 1               ; player's y coordinates
player_x_lo: .res 1               ; player's y coordinates

player_y_velocity_lo: .res 1      
player_x_velocity_lo: .res 1      

player_y_velocity_hi: .res 1      
player_x_velocity_hi: .res 1      

player_y_acceleration_hi: .res 1
player_x_acceleration_hi: .res 1

player_y_acceleration_lo: .res 1
player_x_acceleration_lo: .res 1

player_palette: .res 1
player_shot_wait: .res 1       ; if the value is greater than 0, do not look for press a button

player_respawn_countdown: .res 1

;======================================================================================
; PLAYER STATUS FLAGS
; 76543210
; ||||||||
; |||||||+--> Alive
; ||||||+---> Invulnerable
; |||||+----> Teleporting out
; ||||+-----> Teleport in
; |||+------> NOT USED
; ||+-------> NOT USED
; |+--------> NOT USED
; +---------> NOT USED
;======================================================================================
player_status: .res 1 
player_invulnerable_countdown: .res 1

.segment "CODE"

; add this when you refactor
.macro branch_player_alive label
    ; player_alive check
    lda #1
    bit player_status
    bne label
.endmacro

.macro branch_player_dead label
    ; player_alive check
    lda #1
    bit player_status
    beq label
.endmacro

.proc set_invulnerable

    lda player_status
    ora #%00000010
    sta player_status
    set player_invulnerable_countdown, #250

    rts
.endproc

.proc move_player
    add_16 player_y_hi, player_y_lo, \
            player_y_velocity_hi, player_y_velocity_lo, \
            player_y_hi, player_y_lo

    add_16 player_x_hi, player_x_lo, \
            player_x_velocity_hi, player_x_velocity_lo, \
            player_x_hi, player_x_lo
    rts
.endproc


.proc player_metasprite

  lda #%00000001        ; bit 0 in status flag is alive
  bit player_status     ; test the alive bit and don't render if the player is dead
  
  jmp_eq endrotation

  lda #%00000010        ; bit 0 in status flag is alive
  bit player_status     ; test the alive bit and don't render if the player is dead
  beq not_invulnerable
    lda player_invulnerable_countdown
    beq set_vulnerable
    dec player_invulnerable_countdown
    lsr
    lsr
    and #%00000011
    jmp set_palette
  set_vulnerable:
    lda #%1111101
    and player_status
    sta player_status
  not_invulnerable:
    lda #PLAYER_PALETTE
  set_palette:
  sta player_palette

  lda player_rotation
  lsr                   ; the higher order bits (bit 7-4) are the only significant bits
  lsr                   ; the other bits are used to slow the rotation
  lsr
  lsr                   ; the lower 4 bits of player_rotation do not affect sprites

  ; compare A to 5.  Set carry flag if rotation >= 5
  jmp_on_less_than #5, degrees0to90 ; branch if A < 5

  ; compare A to 9.  Set carry flag if rotation >= 9
  jmp_on_less_than #9, degrees90to180 ; branch if A < 9

  ; compare A to 13.  Set carry flag if rotation >= 13
  jmp_on_less_than #13, degrees180to270 ; jump if A < 13

  jmp degrees270to360   ; if it's >= 13 jump to final rotation label

; 0-90 degrees
degrees0to90:
    clc
    adc PLAYER_SPRITE_NUM
    sta temp_tile
   
    teleport_render_player_check skip_render_1
        render_sprite player_y_hi, player_x_hi, temp_tile, player_palette
    skip_render_1:
    jmp endrotation

; >90-180 degrees
degrees90to180:
;FLIP_SPRITE_V = %10000000 ; OAM BIT FLAG FOR FLIPPING THE SPRITE VERTICALLY
;FLIP_SPRITE_H = %01000000 ; OAM BIT FLAG FOR FLIPPING THE SPRITE HORIZONTAL
;PRIORITY_SPRITE = %00100000 ; OAM BIT FLAG PRIORITY
    sta var_5
    lda #8
    sec
    sbc var_5
    clc
    adc PLAYER_SPRITE_NUM
    sta temp_tile

    teleport_render_player_check skip_render_2
        lda player_palette
        ora #FLIP_SPRITE_V
        sta player_palette
        render_sprite player_y_hi, player_x_hi, temp_tile, player_palette
    skip_render_2:

    jmp endrotation     

; >180-270 degrees
degrees180to270:
; possible numbers are 9, 10, 11, 12.  the tile number should be rotation - 9
    sec
    sbc #8     ; subtract 9 from the value in A.  

    clc
    adc PLAYER_SPRITE_NUM
    sta temp_tile

  ; flip the x and y values and pass the flip x and y flag
  ; draw top left tile
;  m_draw_tile temp_tile, player_y, player_x, #8, #8, player_palette, #1, #1, #1
    teleport_render_player_check skip_render_3
        lda player_palette
        ora #(FLIP_SPRITE_H | FLIP_SPRITE_V)
        sta player_palette

        render_sprite player_y_hi, player_x_hi, temp_tile, player_palette
    skip_render_3:

  ; ready to jump
  jmp endrotation ; jump to end     

; >270-<360 degrees
degrees270to360:
; possible numbers are 13, 14, 15, 16.  the tile number should be 16 - rotation
; a value of 13 would result in displaying sprite number 3
; a value of 14 would result in sprite number 2
; a value of 15 would result in a sprite number 1
; a value of 16 would result in a sprite number 0
    sta var_5
    lda #16
    sec
    sbc var_5     ; subtract old value in A from 8.  
;  I'm not bothering to set the carry flag because the value in temp_tile should be less than 8

    clc
    adc PLAYER_SPRITE_NUM
    sta temp_tile

  ; flip the y values and pass the flip y flag
  ; draw top left tile

    teleport_render_player_check skip_render_4
        lda player_palette
        ora #FLIP_SPRITE_H
        sta player_palette

        render_sprite player_y_hi, player_x_hi, temp_tile, player_palette
    skip_render_4:


    endrotation:
;  tya    ; set A back to what it was
; .endmacro
    rts
.endproc


.proc frame_left
; advance the player rotation by one frame to the left
    pha ; we don't want to clobber Accumulator so push it on to the stack
    lda player_rotation
    and #%11110000 ; we only care about the upper 4 bits
    sta player_rotation
    dec player_rotation
    dec player_rotation
    pla ; pull the Accumulator back from the stack
    rts
.endproc

.proc frame_right
; advance the player rotation by one frame to the left
    pha ; we don't want to clobber Accumulator so push it on to the stack
    lda player_rotation
    and #%11110000 ; we only care about the upper 4 bits
    clc
    adc #%00010011 ; add 1 to the upper 4 bits
    sta player_rotation
    pla ; pull the Accumulator back from the stack
    rts
.endproc

.proc turn_left
    dec player_rotation
    dec player_rotation
    rts
.endproc
  
.proc turn_right
    inc player_rotation
    inc player_rotation
    rts
.endproc

.proc kill_player
;======================================================================================
; PLAYER STATUS FLAGS
; 76543210
;      |||
;      ||+--> Alive
;      |+---> Invulnerable
;      +----> Teleporting
;======================================================================================
    lda #%00000010
    bit player_status 
    beq not_invulnerable
        rts ; can't be killed if invulnerable
    not_invulnerable:

    lda #%00000001
    bit player_status 

    bne player_is_alive ;=======>>>> NOT RETURNING FROM HERE!!!!!!!!!!
        rts ; can't be killed if invulnerable
    player_is_alive:

    lda #0
    sta player_status ; setting the player status flags to 0 means the player is dead

    create_explosion player_y_hi, player_x_hi
    lda #100
    sta player_respawn_countdown

    rts
.endproc

.proc player_respawn_check 
    ; if we're on the open screen don't respawn
    lda open_screen_active 
    bne player_is_alive

    lda #%00000001
    bit player_status 

    bne player_is_alive
        dec player_respawn_countdown
        lda player_respawn_countdown
        bne player_not_ready_for_respawn
        
        lda lives
        beq game_over

            lda #1
            sta player_status
            jsr clear_player_stats
            jsr set_invulnerable
            jsr decrement_lives

        rts ; can't be killed if invulnerable
        game_over:
        jsr game_over_screen_init
    
    player_not_ready_for_respawn:
    player_is_alive:

    rts
.endproc

.proc clear_player_stats
    lda #0
    sta player_rotation
    
    sta player_y_lo
    sta player_x_lo

    sta player_y_velocity_lo
    sta player_x_velocity_lo

    sta player_y_velocity_hi
    sta player_x_velocity_hi

    sta player_y_acceleration_hi
    sta player_x_acceleration_hi

    sta player_y_acceleration_lo
    sta player_x_acceleration_lo

    lda #120
    sta player_y_hi

    lda #128
    sta player_x_hi
    rts
.endproc

.proc accelerate_player
    ; player velocity x and y should be less than $10 or greater than $F0
    lda player_rotation ; load player rotation
    ; the hight 4 bits of the rotation
    ; are the only ones that matter
    lsr
    lsr
    lsr
    lsr 

    tax ; move this value to x to retrieve the x acceleration

    lda z_acceleration_table_lo, X
    sta player_y_acceleration_lo

    lda z_acceleration_table_hi, X
    sta player_y_acceleration_hi

    lda y_acceleration_table_lo, X
    sta player_x_acceleration_lo

    lda y_acceleration_table_hi, X
    sta player_x_acceleration_hi

    add_16 player_y_velocity_hi, player_y_velocity_lo, \
        player_y_acceleration_hi, player_y_acceleration_lo, \
        player_y_velocity_hi, player_y_velocity_lo

    ldy player_y_velocity_hi
    bpl positive_y_velocity
        floor player_y_velocity_hi, #$fd
        jmp positive_y_end
    positive_y_velocity:
        ceil player_y_velocity_hi, #$03
    positive_y_end:

    add_16 player_x_velocity_hi, player_x_velocity_lo, \
        player_x_acceleration_hi, player_x_acceleration_lo, \
        player_x_velocity_hi, player_x_velocity_lo

    ldy player_x_velocity_hi
    bpl positive_x_velocity
        floor player_x_velocity_hi, #$fd
        jmp positive_x_end
    positive_x_velocity:
        ceil player_x_velocity_hi, #$03
    positive_x_end:

    rts
.endproc

