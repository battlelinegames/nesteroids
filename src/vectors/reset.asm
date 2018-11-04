.segment "CODE"
reset:
	sei                 ; mask interrupts

	lda #0              ; clear the A register
	sta PPU_CTRL        ; $2000 ; disable NMI
	sta PPU_MASK        ; $2001 ; disable rendering
    sta PPU_SCROLL
    sta PPU_SCROLL
	sta $4015           ; disable APU sound
	sta $4010           ; disable DMC IRQ
	lda #$40
	sta $4017           ; disable APU IRQ
	cld                 ; disable decimal mode
	ldx #$FF
	txs                 ; initialize stack

    ; execute this code during first vblank after reset

    ; clear out all the ram by setting everything to 0
    clear_ram                   ; utils.asm

    ; move all the sprites in oam memory offscreen by setting y to #$ff
    clear_sprites               ; utils.asm


;    set player_status, #0 ; set the player status to alive
    jsr reset_explosion_frames ; reset the frame number
    ;=======================================

    ; wait for next vblank
    wait_for_vblank   ; utils.asm

    ; -----  SETUP FAMITONE  -----
	lda #1                  ; set to NTSC Mode
	jsr FamiToneInit		;init FamiTone

	ldx #<sounds		;set sound effects data location
	ldy #>sounds
	jsr FamiToneSfxInit
    ; -----  END SETUP FAMITONE  -----

    jsr reset_game
    ; I WOULD LIKE TO KNOW IF THE HELLO WORLD PRINTF WORKED
;    printf "hello world" ; testing out a printf macro
    jmp game_loop   ; start the wait loop


    .proc reset_game
        jsr clear_background_all

        ; set the default coordinates for the player
        set player_y_hi, #128
        set player_x_hi, #120

        ; clear the player's x and y velocity
        set player_y_velocity_hi, #0
        ; the set macro will have loaded #0 into the A register, so no need to do that again
        sta player_y_velocity_lo
        sta player_x_velocity_hi
        sta player_x_velocity_lo
        sta player_y_lo
        sta player_x_lo

        jsr clear_asteroids
        /*
        add_asteroid:
        create_asteroid #50, #50, #11, #1 ; xpos, ypos, rotation, size
        create_asteroid #23, #250, #7, #1 ; xpos, ypos, rotation, size
        create_asteroid #150, #25, #6, #2 ; xpos, ypos, rotation, size
        create_asteroid #200, #160, #2, #2 ; xpos, ypos, rotation, size
        create_asteroid #25, #60, #15, #3 ; xpos, ypos, rotation, size

        set size_list, #%01011010
        */
    ;    create_asteroid #128, #120, #0, #4 ; xpos, ypos, rotation, size
    ;   create_asteroid #98, #72, #15, #1 ; xpos, ypos, rotation, size
    done_add_asteroids:
        ;======================================================================================
        ; PPU CTRL FLAGS
        ; VPHB SINN
        ; 7654 3210
        ; |||| ||||
        ; |||| |||+----\
        ; |||| |||      |---> Nametable Select  (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
        ; |||| ||+-----/
        ; |||| |+----> Increment Mode (0: increment by 1, across; 1: increment by 32, down)
        ; |||| +-----> Sprite Tile Address Select (0: $0000; 1: $1000)
        ; ||||                              
        ; |||+-------> Background Tile Address Select (0: $0000; 1: $1000)
        ; ||+--------> Sprite Hight (0: 8x8; 1: 8x16)
        ; |+---------> PPU Master / Slave (not sure if this is used)
        ; +----------> NMI enable (0: off; 1: on)
        ;======================================================================================

        ; set the ppu control register to enable nmi and sprite tile rendering

        set palette_init, #0
        jsr load_open_screen
        jsr load_attribute

        ; ppu_hi, ppu_lo, data_hi, data_lo, run_len
    ;    
        add_background_clear #1, #$C6, #16

        add_background_write #0, #34, #>lives_status, #<lives_status, #8
        add_background_write #0, #98, #>score_status, #<score_status, #12

        add_background_write #0, #159, #>sprite0_background, #<sprite0_background, #1
/*
        add_background_write #1, #$88, #>logo_background_top, #<logo_background_top, #16
        add_background_write #1, #$A8, #>logo_background_bottom, #<logo_background_bottom, #16
        add_background_write #1, #$EA, #>press_start_text, #<press_start_text, #12
*/
        set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
        lda PPU_STATUS ; $2002
        set PPU_SCROLL, #0
        sta PPU_SCROLL

        set PPU_CTRL, PPU_CTRL_DEFAULT 

        lda #0
        
        sta lives

        jsr init_open_screen
        jsr clear_score

        rts 
    .endproc