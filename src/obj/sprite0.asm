.segment "CODE"

.proc set_sprite0
    render_sprite #31, #248, #0, #0
    rts
.endproc

;==============================================================================
; PPU_STATUS $2002
; 7  bit  0
; ---- ----
; VSO. ....
; 7654 3210
; |||| ||||
; |||+-++++- Least significant bits previously written into a PPU register
; |||        (due to register not being updated for this address)
; |||
; ||+------- Sprite overflow. The intent was for this flag to be set
; ||         whenever more than eight sprites appear on a scanline, but a
; ||         hardware bug causes the actual behavior to be more complicated
; ||         and generate false positives as well as false negatives; see
; ||         PPU sprite evaluation. This flag is set during sprite
; ||         evaluation and cleared at dot 1 (the second dot) of the
; ||         pre-render line.
; |+-------- Sprite 0 Hit.  Set when a nonzero pixel of sprite 0 overlaps
; |          a nonzero background pixel; cleared at dot 1 of the pre-render
; |          line.  Used for raster timing.
; +--------- Vertical blank has started (0: not in vblank; 1: in vblank).
;            Set at dot 1 of line 241 (the line *after* the post-render
;            line); cleared after reading $2002 and at dot 1 of the
;            pre-render line.
;==============================================================================

.define SPRITE0_HIT #%01000000

;.segment "ZEROPAGE"
;    sprite0_run: .res 1
;.segment "CODE"
.proc sprite0_clear_wait
        sprite0_loop:
            lda PPU_STATUS
            and SPRITE0_HIT
        bne sprite0_loop

    rts
.endproc

.proc sprite0_wait
        sprite0_loop:
            lda PPU_STATUS
            and SPRITE0_HIT
        beq sprite0_loop

    rts
.endproc