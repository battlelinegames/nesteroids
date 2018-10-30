.segment "CODE"

; PARAMETERS WILL BE (TILE_NUMBER, X, Y, XOFFSET, YOFFSET)
FLIP_SPRITE_V = %10000000 ; OAM BIT FLAG FOR FLIPPING THE SPRITE VERTICALLY
FLIP_SPRITE_H = %01000000 ; OAM BIT FLAG FOR FLIPPING THE SPRITE HORIZONTAL
PRIORITY_SPRITE = %00100000 ; OAM BIT FLAG PRIORITY


.proc oam_dma
    set PPU_CTRL, #%10010000; PPU_CTRL_NMI_ENABLE
;=============================================
; PPU_MASK_EMPH_BLUE          = %10000000
; PPU_MASK_EMPH_GREEN         = %01000000
; PPU_MASK_EMPH_RED           = %00100000
; PPU_MASK_SHOW_SPRITES       = %00010000
; PPU_MASK_SHOW_BACKGROUND    = %00001000
; PPU_MASK_SHOW_SPRITES_L8    = %00000100
; PPU_MASK_SHOW_BACKGROUND_L8 = %00000010
; PPU_MASK_GRAYSCALE          = %00000001
;=============================================

    lda #(PPU_MASK_SHOW_SPRITES|PPU_MASK_SHOW_BACKGROUND|PPU_MASK_SHOW_SPRITES_L8|PPU_MASK_SHOW_BACKGROUND_L8) ; PPU_MASK_SHOW_SPRITES
    sta PPU_MASK
    set OAM_ADDR, #0
    set OAM_DMA, #$02

    rts
.endproc

.proc clear_oam
  lda #$ff      ; setting y value in oam to #$ff will prevent it from rendering
  ldx #0
  stx oam_ptr

  oam_loop:
    inx
    inx
    inx
    inx
    sta oam, X
  bne oam_loop
  rts
.endproc

; calling this will render a specific sprite number at an x and y position
.macro render_sprite xpos, ypos, sprite_num, flags
    ldx oam_ptr

    ; set oam, X to xpos and increment X register
    setxinc oam, xpos

    ; set oam, X to sprite_num and increment X register
    setxinc oam, sprite_num

    ;=======================================================================================
    ; set oam, X to flags and increment X register
    ;  76543210
    ;  |||   ||
    ;  |||   ++- Color Palette of sprite.  Choose which set of 4 from the 16 colors to use
    ;  |||
    ;  ||+------ Priority (0: in front of background; 1: behind background)
    ;  |+------- Flip sprite horizontally
    ;  +-------- Flip sprite vertically
    ;=======================================================================================
    setxinc oam, flags

    ; set oam, X to ypos and increment X register
    setxinc oam, ypos

    stx oam_ptr ; this happens at the end
.endmacro

.define PLAYER_SPRITE_NUM   #1
PLAYER_PALETTE = 3
ASTEROID_PALETTE = 0

;=============================================================
; ASTEROID_COUNT = 16
; 
; asteroid_x_lo: .res ASTEROID_COUNT
; asteroid_x_hi: .res ASTEROID_COUNT
; asteroid_x_lo: .res ASTEROID_COUNT
; asteroid_x_hi: .res ASTEROID_COUNT
; 
; asteroid_vel_x_lo: .res ASTEROID_COUNT
; asteroid_vel_x_hi: .res ASTEROID_COUNT
; asteroid_vel_x_lo: .res ASTEROID_COUNT
; asteroid_vel_x_hi: .res ASTEROID_COUNT
; asteroid_rotation: .res ASTEROID_COUNT
; asteroid_size: .res ASTEROID_COUNT ; if the asteroid size is 0, the asteroid is destroyed
; 
; asteroid_count: .res 1
;=============================================================

SIZE_1_FRAMES = 32 ; starting frame position of smallest asteroid
SIZE_2_FRAMES = 36 ; starting frame position of medium sized asteroid
SIZE_3_FRAMES = 40 ; starting frame position of large sized asteroid
SIZE_4_FRAMES = 28 ; starting (background) frame position of HUGE asteroid

.define TILE_ROTATION_FLAG #%00000100 ; flag indicating the tile is rotated
TILE_ROT_SHIFT = 24         ; distance between the tiles and rotated tiles

SIZE_1_ROT_FRAMES = 56 ; starting rotated frame position of smallest asteroid
SIZE_2_ROT_FRAMES = 60 ; starting rotated frame position of smallest asteroid
SIZE_3_ROT_FRAMES = 64 ; starting rotated frame position of smallest asteroid

.define TEMP_FRAME var_5
.define TEMP_FLAGS var_4

;.macro palette_setup start 
;  LDA PPU_STATUS    ; $2002 read PPU status to reset the high/low latch to high
;  LDA #$3F
;  STA PPU_ADDR      ; $2006 write the high byte of $3F10 address
;  LDA start         ; this was the parameter passed in
;  STA PPU_ADDR      ; $2006 write the low byte of $3F10 address
;.endmacro

; this macro sets the full palette data on the ppu
;.macro set_palette
;  palette_setup #$00
;  write_data_to_register palette_background, PPU_DATA, 32 ; $2007 macro_utils.asm
;.endmacro
