.segment "ZEROPAGE"
ft_temp: .res 7 ; THIS IS USED BY THE FAMITONE
nmi_executed: .res 1
nmi_ready: .res 1

;  this is a block of general use variables for procedures
var_1: .res 1
var_2: .res 1
var_3: .res 1
var_4: .res 1
var_5: .res 1


oam_ptr: .res 1                 ; pointer to where we are in oam memory

; gamepad variables
gamepad_press: .res 1           ; current keys pressed on the gamepad
gamepad_last_press: .res 1      ; last frame cycle what keys were pressed
gamepad_new_press: .res 1       ; newly pressed keys that were not pressed in the previous frame
gamepad_release: .res 1        ; just released keys

; variables for specific uses
random_ptr: .res 1
frame_counter: .res 1          ; this number will cycle from 0 - 255 incrementing each frame

temp_x_reg: .res 1
temp_y_reg: .res 1
; countdown_timer: .res 1        ; when set this counter will decrement every frame

.segment "CODE"
