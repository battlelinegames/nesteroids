; this clobbers x register
.macro get_random_a 
    inc random_ptr
    lda random_ptr
    and #%01111111
    tax
    lda random_table, x
.endmacro

.macro advance_random_ptr
    lda random_ptr
    adc frame_counter ; I don't really care if the carry byte is set for random jump
    sta random_ptr
.endmacro