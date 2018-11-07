.equ HEAD_X,      0x1000 ; snake head's position on x-axis
.equ HEAD_Y,      0x1004 ; snake head's position on y-axis
.equ TAIL_X,      0x1008 ; snake tail's position on x-axis
.equ TAIL_Y,      0x100C ; snake tail's position on y-axis
.equ SCORE,       0x1010 ; score address
.equ GSA,         0x1014 ; game state array
.equ LEDS,        0x2000 ; LED addresses
.equ SEVEN_SEGS,  0x1198 ; 7-segment display addresses
.equ RANDOM_NUM,  0x2010 ; Random number generator address
.equ BUTTONS,     0x2030 ; Button addresses

main:
  call clear_leds
  addi a0, zero, 1
  addi a1, zero, 3
  call set_pixel
  addi a0, zero, 5
  addi a1, zero, 15
  jmpi end

; ---------------------------------------clear_leds
; BEGIN:clear_leds
clear_leds:
  stw zero, LEDS (zero)
  stw zero, LEDS + 4 (zero)
  stw zero, LEDS + 8 (zero)
  ret
; END:clear_leds


; ---------------------------------------set_pixel
; BEGIN:set_pixel
set_pixel:
  addi t0, zero, 4
  blt a0, t0, led1
  addi t0, t0, 4
  blt a0, t0, led2
  addi t0, t0, 4
  blt a0, t0, led3
  ret

; utility functions
led1:
  slli t0, a0, 3
  add t0, t0, a1
  addi t1, zero, 1
  sll t1, t1, t0
  ldw t2, LEDS (zero)
  or t1, t2, t1 
  stw t1, LEDS (zero)
  jmpi fin
led2:
  slli t0, a0, 3
  add t0, a1, t0
  addi t1, zero, 1
  sll t1, t1, t0
  ldw t2, LEDS + 4 (zero)
  or t1, t2, t1 
  stw t1, LEDS + 4 (zero)
  jmpi fin
led3:
  slli t0, a0, 3
  add t0, a1, t0
  addi t1, zero, 1
  sll t1, t1, t0
  ldw t2, LEDS + 8 (zero)
  or t1, t2, t1 
  stw t1, LEDS + 8 (zero)
  jmpi fin

fin:  
  ret
; END:set_pixel



; ---------------------------------------get_input
; BEGIN:get_input
get_input:
  ; getting head coordinates
  ldw t0, HEAD_X (zero)
  ldw t1, HEAD_Y (zero)
  slli t0, t0, 3
  add t0, t1, t0

  ldw t1, GSA(t0)
    


; END:set_pixel



; ---------------------------------------END
end:
 break













