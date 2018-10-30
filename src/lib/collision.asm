.segment "BSS"
collision_temp_x: .res 1
collision_temp_y: .res 1
temp_shot_x: .res 1
temp_shot_y: .res 1

.segment "CODE"


COLLISION_DIST = var_1

; check for collisions between ufo and player
.proc collision_check_up
    lda ufo_y
    sec
    sbc player_y_hi
    abs_a
    cmp #8
    bcs end ; if the x distance between player and ufo is >= 8 no hit

    lda ufo_x
    sec
    sbc player_x_hi
    abs_a
    cmp #6
    bcs end ; if the x distance between player and ufo is >= 8 no hit

    jsr kill_player

    end:
    rts
.endproc

; check for collision between ufo shot and player
.proc collision_check_usp
    ldx #UFO_SHOT_COUNT
    shot_loop:
        dex

        lda ufo_shot_y_hi, x
        sec
        sbc player_y_hi
        abs_a
        cmp #6
        bcs next ; if the x distance between player and ufo is >= 8 no hit

        lda ufo_shot_x_hi, x
        sec
        sbc player_x_hi
        abs_a
        cmp #6
        bcs next ; if the x distance between player and ufo is >= 8 no hit

        jsr kill_player
        jmp end
        next:
        cpx #0
    bne shot_loop

    end:
    rts
.endproc

; check for collision between player shot and ufo
.proc collision_check_spu
    ldx #MAX_PLAYER_SHOTS
    shot_loop:
        dex

        lda player_shot_y_hi, x
        sec
        sbc ufo_y
        abs_a
        cmp #6
        bcs next ; if the x distance between player and ufo is >= 8 no hit

        lda player_shot_x_hi, x
        sec
        sbc ufo_x
        abs_a
        cmp #6
        bcs next ; if the x distance between player and ufo is >= 8 no hit

        jsr kill_ufo
        jmp end
        next:
        cpx #0
    bne shot_loop

    end:
    rts
    rts
.endproc

; I'M GOING TO PUT THE COLLISION RESULTS INTO A REGISTER
.proc large_asteroid_collision_check ;  asteroid_x, asteroid_y
    lda temp_x_pos ; asteroid_x
    sec
    sbc scroll_x
    sta var_1

    lda player_x_hi
    sec
    sbc var_1 

    bpl player_right
    player_left:
        negate_a
        cmp #0
        bcs large_asteroid_collision_end ; distance >= 8
        jmp x_hit                        ; x distance is a hit

    player_right:
        cmp #40
        bcs large_asteroid_collision_end ; distance >= 32

    x_hit:

    lda player_y_hi
    sec
    sbc temp_y_pos ; asteroid_y

    bpl player_down
    ; the player is on the left side of the asteroid
    player_up:
        negate_a
        cmp #9
        bcs large_asteroid_collision_end ; distance >= 8

        jmp y_hit                        ; x distance is a hit

    ; the player is on the right side of the asteroid
    player_down:
        cmp #31
        bcs large_asteroid_collision_end ; distance >= 32

    y_hit:

    lda #0

    large_asteroid_collision_end:
    rts
.endproc

.macro large_asteroid_collision_ps asteroid_x, asteroid_y, shot_x, shot_y
    .local @shot_left
    .local @shot_right
    .local @x_hit
    .local @shot_up
    .local @shot_down
    .local @y_hit
    .local @large_asteroid_collision_end

    lda asteroid_x
    sec
    sbc scroll_x
    sta collision_temp_x

    lda shot_x
    sec
    sbc collision_temp_x

    bpl @shot_right
    @shot_left:
        negate_a
        cmp #0
        bcs @large_asteroid_collision_end ; distance >= 8
        jmp @x_hit                        ; x distance is a hit

    @shot_right:
        cmp #34
        bcs @large_asteroid_collision_end ; distance >= 32

    @x_hit:

    lda asteroid_y
    sec
    sbc shot_y 

    bpl @shot_down
    ; the player is on the left side of the asteroid
    @shot_up:
        negate_a
        cmp #4
        bcs @large_asteroid_collision_end ; distance >= 8

        jmp @y_hit                        ; x distance is a hit

    ; the player is on the right side of the asteroid
    @shot_down:
        cmp #30
        bcs @large_asteroid_collision_end ; distance >= 32

    @y_hit:

    lda #0

    @large_asteroid_collision_end:
.endmacro


; check for collisions between an asteroid and a player.  If a collision happens, kill the player
.proc collision_check_pa
    ldx #ASTEROID_COUNT ; how many asteroids in are we ===================
    inx ; we need to decrement through each loop.  Because I do this at the top of the loop, I 
        ; need to compensate for the first pass by incrementing x register here
    asteroid_loop:
        dex
        jmp_mi no_asteroid_hits

        lda asteroid_size, x
        beq asteroid_loop

        cmp #4
        bne not_large_asteroid
            the_large_asteroid:
            lda asteroid_y_hi, x
            sta temp_y_pos

            lda asteroid_x_hi, x
            sta temp_x_pos

;            large_asteroid_collision_check temp_y_pos, temp_x_pos
            jsr large_asteroid_collision_check
            cmp #0
            beq hit_player
            jmp asteroid_loop
        not_large_asteroid:

        asl
        asl
        sta COLLISION_DIST ; store this value off as the collision distance

        lda asteroid_y_hi, x
        sec
        sbc player_y_hi
        abs_a y ; take the absolute value of A register, this will clobber the contents of Y reg

        ; compare the absolute distance between the asteroid and player to the collision distance
        cmp COLLISION_DIST

        ; if the carry flag is set, the collision distance is greater than the actual distance 
        ; so we can move on to checking the next asteroid
        ; bcs asteroid_loop 
        jmp_cs asteroid_loop 
        ; CHANGE THIS BACK TO BCS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        ; the x distance was less than the collision distance, so no we need to check if
        ; the y distance was also less than the collision distance.
        lda asteroid_x_hi, x
        sec
        sbc player_x_hi
        abs_a y ; take the absolute value of A register, this will clobber the contents of Y reg

        ; compare the absolute distance between the asteroid and player to the collision distance
        cmp COLLISION_DIST

        ; if the carry flag is set, the collision distance is greater than the actual distance 
        ; so we can move on to checking the next asteroid
        jmp_cs asteroid_loop 

        hit_player:
        ; there was a collision with an asteroid.  kill the player and return
        jsr kill_player
    no_asteroid_hits:
    rts

.endproc

;SHOT_Y = var_2
;SHOT_X = var_3
TEMP_X_2 = var_5

; look for a collision between a shot and an asteroid.  If the two collide destroy both
.proc collision_check_sa
    ; loop over shots and loop over asteroids
    ldy #MAX_PLAYER_SHOTS; player_shot_count
    sty temp_y_reg
    shot_loop:
        ldx #ASTEROID_COUNT ; how many asteroids in are we ===================
        ; check to see if this shot is alive
        lda player_shot_alive_time, y
        jmp_eq no_asteroid_hits

        lda player_shot_y_hi, Y
        sta temp_shot_y
        lda player_shot_x_hi, Y
        sta temp_shot_x

        asteroid_loop:
            dex
            jmp_mi no_asteroid_hits

            lda asteroid_size, x
            beq asteroid_loop

            cmp #4
            bne not_large
                lda asteroid_x_hi, x
                sta temp_x_pos

                lda asteroid_y_hi, x
                sta temp_y_pos

                large_asteroid_collision_ps temp_x_pos, temp_y_pos, temp_shot_x, temp_shot_y
                bne asteroid_loop
                jsr kill_asteroid
                jmp asteroid_loop
            not_large:
            asl
            asl
            asl ; multiply the asteroid size by 4

            sta COLLISION_DIST ; store this value off as the collision distance

            lda asteroid_y_hi, x
            sec
            sbc temp_shot_y
            abs_a ; take the absolute value of A register, DON'T clobber the contents of Y reg

            ; compare the absolute distance between the asteroid and player to the collision distance
            cmp COLLISION_DIST

            ; if the carry flag is set, the collision distance is greater than the actual distance 
            ; so we can move on to checking the next asteroid
            jmp_cs asteroid_loop 

            ; the x distance was less than the collision distance, so no we need to check if
            ; the y distance was also less than the collision distance.
            lda asteroid_x_hi, x
            sec
            sbc temp_shot_x
            abs_a ; take the absolute value of A register, this DON'T clobber the contents of Y reg

            ; compare the absolute distance between the asteroid and player to the collision distance
            cmp COLLISION_DIST

            ; if the carry flag is set, the collision distance is greater than the actual distance 
            ; so we can move on to checking the next asteroid
            jmp_cs asteroid_loop 

            ; there was a collision with an asteroid.  kill the player and return
            jsr kill_asteroid ; x will hold the index of the asteroid, y the shot index
        no_asteroid_hits:
        ldy temp_y_reg
        dey ; if none of the asteroids hit the current shot, move on to the next shot
        sty temp_y_reg
        jmp_ne shot_loop
    rts
.endproc