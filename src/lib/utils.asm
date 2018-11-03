.segment "CODE"

; this is like a x = y call where x is set to the value of y
.macro set set_var, from
    lda from
    sta set_var
.endmacro

; this is like the set, but uses the x register as an offset
.macro setxinc var, from
    setx var, from
    inx
.endmacro

.macro setx var, from
    lda from
    sta var, X
.endmacro

; this macro will loop until the next vblank
.macro wait_for_vblank
    .local @vblank_wait
	bit PPU_STATUS      ; $2002
    @vblank_wait:
		bit PPU_STATUS  ; $2002
		bpl @vblank_wait
.endmacro

; clear out all the ram on the reset press
.macro clear_ram
    .local @loop
	lda #0
	ldx #0
	@loop:
		sta $0000, X
		sta $0100, X
		sta $0200, X
		sta $0300, X
		sta $0400, X
		sta $0500, X
		sta $0600, X
		sta $0700, X
		inx
		bne @loop
.endmacro


; this moves all the sprites in oam memory offscreen by setting y to 255
.macro clear_sprites
    .local @loop
	lda #255
	ldx #0
	@loop:
		sta oam, X
		inx
		inx
		inx
		inx
        bne @loop
.endmacro

.macro abs_a clobber
	.local @negative
	.local @positive
	.local @end
	.ifblank clobber
		sty temp_reg_y
	.endif 
	tay
	and #%10000000
	beq @positive ; if the sign bit is not set, the number is positive
	@negative:
		tya
		negate_a
		jmp @end
	@positive:
		tya
	@end:
	.ifblank clobber 
		ldy temp_reg_y
	.endif
.endmacro

; this macro lets you jump a longer distance than a branch would
.macro jmp_eq jump_to_label
	.local @skip_jump
	bne @skip_jump
    jmp jump_to_label
@skip_jump:
.endmacro

.macro jmp_cc jump_to_label
	.local @skip_jump
	bcs @skip_jump
    jmp jump_to_label
@skip_jump:
.endmacro

.macro jmp_cs jump_to_label
	.local @skip_jump
	bcc @skip_jump
    jmp jump_to_label
@skip_jump:
.endmacro

.macro jmp_ne jump_to_label
	.local @skip_jump
	beq @skip_jump
    jmp jump_to_label
@skip_jump:
.endmacro

.macro jmp_mi jump_to_label
	.local @skip_jump
	bpl @skip_jump
    jmp jump_to_label
@skip_jump:
.endmacro

.macro jmp_pl jump_to_label
	.local @skip_jump
	bmi @skip_jump
    jmp jump_to_label
@skip_jump:
.endmacro

; turns a number in the A register to it's negative value (e.g. 3 becomes -3)
.macro negate_a
	eor #%11111111 ; flip all the bits
	clc
	adc #1
.endmacro

.macro add val_1, val_2, result
    lda val_1
    clc
    adc val_2
    sta result
.endmacro

.macro add_16 high1, low1, high2, low2, resulthi, resultlow
	.local @no_carry
	clc
	lda low1
	adc low2
	sta resultlow
	lda high1
    adc high2
	sta resulthi
.endmacro

.macro xadd_16 high1, low1, high2, low2, resulthi, resultlow
	.local @no_carry
	clc
	lda low1, x
	adc low2, x
	sta resultlow, x
	lda high1, x
    adc high2, x
	sta resulthi, x
.endmacro


.macro sub_16 high1, low1, high2, low2, resulthi, resultlow
	.local @carry_set
	lda low1
	sec
	sbc low2
	sta resultlow

	lda high1
    sbc high2
	sta resulthi
.endmacro

; carry is clear if we're over the ceiling
.macro ceil value, max
    .local @below_cap
	lda value

    cmp max ; carry is set if value >= max
    bcc @below_cap  ; branch if value < max
		lda max
        sta value
    @below_cap:
.endmacro

; carry is set if we hit the floor
.macro floor value, min
    .local @over_floor
	/*
	lda min
    cmp value
    bcc @over_floor
        sta value
    @over_floor:
	*/
	lda value
    cmp min ; carry set if value >= min
    bcs @over_floor
		; if carry flag is clear, value < min
		lda min
        sta value
    @over_floor:

.endmacro

/*
.macro ceil_16_hi hi, lo, max_hi
    .local @below_cap

	lda max_hi

    cmp hi
    bcs @below_cap
        sta hi
;		lda #0
;		sta lo
    @below_cap:
.endmacro

.macro floor_16_hi hi, lo, min_hi
    .local @over_floor

	lda min_hi

    cmp hi
    bcc @over_floor
        sta hi
		lda #0
		sta lo
    @over_floor:
.endmacro
*/


.macro jmp_on_less_than compare_value, jump_to_label
; .macro jmp_on_less_than compare_value, jump_to_label
    .local @skip_jump
    cmp compare_value
    bcs @skip_jump
    jmp jump_to_label
@skip_jump:
; .endmacro
.endmacro

.macro write_data_to_register label_from, register_to, byte_count 
; .macro m_write_data_to_register label_from, register_to, byte_count 
    .local @loop
    ldx #0

    @loop:
        lda label_from, X
        sta register_to
        inx
        cpx #byte_count
        bne @loop
; .endmacro
.endmacro


.proc clear_background_all
		wait_for_vblank

        ldy #$20
		outer_background_clear_loop:
	        lda PPU_STATUS        ; PPU_STATUS = $2002
			sty PPU_ADDR

			lda #0
			tax
			sta PPU_ADDR
			inner_background_clear_loop:
	            sta PPU_DATA
				inx
				bne inner_background_clear_loop
			iny
			cpy #$24
		bne outer_background_clear_loop

        ldy #$28
		outer_background_clear_loop2:
	        lda PPU_STATUS        ; PPU_STATUS = $2002
			sty PPU_ADDR

			lda #0
			tax
			sta PPU_ADDR
			inner_background_clear_loop2:
	            sta PPU_DATA
				inx
				bne inner_background_clear_loop2
			iny
			cpy #$2C
		bne outer_background_clear_loop2

	rts
.endproc