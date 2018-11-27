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
  
  addi sp, sp, LEDS ; stack pointer = LEDS address

game_loop:
  addi t0, zero, 1 ; t0 = 1
  ldw t1, BUTTONS + 4 (zero)
  slli t1, t1, 4
  and t1, t1, t0
  bne 
  jmpi game_loop

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
  ; t2 edge capture
  ; t7 value at GSA
  ; t6 current address in GSA

  ldw t0, HEAD_X (zero)
  ldw t1, HEAD_Y (zero)
  ldw t2, BUTTONS + 4 (zero)

  slli t6, t0, 3
  add t6, t6, t1
  ldw t7, GSA (t6)

  addi t5, zero, 1 ; mask initialization at 1
loop:
  and t2, t2, t5 ; edge_capture & mask
  slli t5, t5, 1 ; mask << 1
  beq t2, zero, end_get_input ; end loop

  beq t2, zero, end_get_input ;if equal to 0
  addi t3, zero, 1
  beq t2, t3, first_button ;if equal to 1
  addi t3, zero, 2
  beq t2, t3, second_button ;if equal to 2
  addi t3, zero, 4
  beq t2, t3, third_button ;if equal to 4
  addi t3, zero, 8
  beq t2, t3, fourth_button ;if equal to 8

first_button:
  addi t4, zero, 4
  beq t7, t4, end_get_input
  stw t2, GSA (t6)
  jmpi end_get_input

second_button:
  addi t4, zero, 3
  beq t7, t4, end_get_input
  stw t2, GSA (t6)
  jmpi end_get_input 

third_button:
  addi t4, zero, 2
  beq t7, t4, end_get_input
  stw t2, GSA (t6) 
  jmpi end_get_input

fourth_button:
  addi t4, zero, 1
  beq t7, t4, end_get_input
  stw t2, GSA (t6)
  jmpi end_get_input  
  
end_get_input:
  stw zero, BUTTONS + 4 (zero) 
  ret

; END:get_input


; ---------------------------------------move_snake
; BEGIN:move_snake
move_snake:
;HEAD
update_head:
  ldw t0, HEAD_X (zero)
  ldw t1, HEAD_Y (zero)
  ;HEAD position in GSA
  slli t3, t0, 3
  add t3, t3, t1
  ldw t4, GSA (t3)
  
  beq t4, zero, update_tail
  addi t5, zero, 1
  beq t4, t5, update_left_head
  addi t5, zero, 2
  beq t4, t5, update_up_head
  addi t5, zero, 3
  beq t4, t5, update_down_head
  addi t5, zero, 4
  beq t4, t5, update_right_head

;TAIL
update_tail:
  ldw t0, TAIL_X (zero)
  ldw t1, TAIL_Y (zero)
  ;TAIL position in GSA
  slli t3, t0, 3
  add t3, t3, t1
  ldw t4, GSA (t3)

  beq t4, zero, end_move_snake
  addi t5, zero, 1
  beq t4, t5, update_left_tail
  addi t5, zero, 2
  beq t4, t5, update_up_tail 
  addi t5, zero, 3
  beq t4, t5, update_down_tail  
  addi t5, zero, 4
  beq t4, t5, update_right_tail

update_up_head:
  addi t1, t1, -1
  stw t1, HEAD_Y (zero)
  jmpi update_tail 
update_down_head:
  addi t1, t1, 1
  stw t1, HEAD_Y (zero)
  jmpi update_tail 
update_left_head:
  addi t0, t0, -1
  stw t0, HEAD_X (zero)
  jmpi update_tail 
update_right_head:
  addi t0, t0, 1
  stw t0, HEAD_X (zero)
  jmpi update_tail 
update_up_tail:
  addi t1, t1, -1
  stw t1, TAIL_Y (zero)
  jmpi end_move_snake 
update_down_tail:
  addi t1, t1, 1
  stw t1, TAIL_Y (zero)
  jmpi end_move_snake 
update_left_tail:
  addi t0, t0, -1
  stw t0, TAIL_X (zero)
  jmpi end_move_snake 
update_right_tail:
  addi t0, t0, 1
  stw t0, TAIL_X (zero)
  jmpi end_move_snake 

end_move_snake:
  ret

; END:move_snake

; ---------------------------------------draw_array
; BEGIN:draw_array
draw_array:
  addi t2, zero, 0 ;x
  addi t3, zero, 0 ;y
  addi t0, zero, 11 ;xlim
  addi t1, zero, 7 ;ylim
loopx:
  addi t3, zero, 0
  loopy:
    addi sp, sp, -8
    stw a0, 4 (sp)
    stw a1, 0 (sp)
    addi a0, t2, 0
    addi a1, t3, 0
    call set_pixel
    ;restore and reset stack
  	addi t3, t3, 1
 	bne t3, t1, loopy
  
  addi t2, t2, 1
  bne t2, t0, loopx

end_draw_array:
  ret
; END:draw_array

; BEGIN:create_food
create_food:
  ldw t0, RANDOM_NUM (zero) ; t0 = random number
  srli t0, t0, 24 ; t0 = least significant byte
  blt t0, zero, end_create_food ; if (random < 0) return
  addi t1, zero, 96 ; t1 = 96, 95 is the end bound of game array
  bge t0, t1, end_create_food ; if (random > 95) return

  slli t2, t0, 2 ; t2 = 4 * t0
  ldw t3, 0 (t2) ; t3 = GSA[t0]
  bne t3, zero, end_create_food ; if (GSA[t0] != 0) return

  addi t4, zero, 5 ; t4 = 5
  stw t4, 0 (t2) ; GSA[t0] = 5

end_create_food:
  ret
; END:create_food

; BEGIN:hit_test
hit_test:
  ldw t0, HEAD_X (zero) ; t0 = head_x
  ldw t1, HEAD_Y (zero) ; t1 = head_y
  slli t3, t0, 3 ; t3 = t0 * 8
  add t3, t3, t1 ; t3 = t3 + head_y
  ldw t4, GSA (t3) ; t4 = GSA[head_x][head_y]

  ;TODO update hit test names to predict move

  addi t5, zero, 1
  bne t4, t5, left_hit_test
  addi t5, zero, 2
  bne t4, t5, up_hit_test
  addi t5, zero, 3
  bne t4, t5, down_hit_test
  addi t5, zero, 4
  bne t4, t5, right_hit_test
left_hit_test:
  addi t0, t0, -1 ; head_x--
up_hit_test:
  addi t1, t1, -1 ; head_y--
down_hit_test:
  addi t1, t1, 1 ; head_y++
right_hit_test:
  addi t0, t0, 1 ; head_x++

  addi t3, zero, 0 ; t3 = 0
  slli t3, t0, 3 ; t3 = t0 * 8
  add t3, t3, t1 ; t3 = t3 + head_y
  ldw t4, GSA (t3) ; t4 = GSA[head_x][head_y] (predicted)

  blt t0, zero, screen_body_collide
  blt t1, zero, screen_body_collide
  addi t6, zero, 12
  addi t7, zero, 8
  bge t0, t6, screen_body_collide
  bge t1, t7, screen_body_collide

  ;collision with food
  addi t0, zero, 5
  bne t4, t0, food_collide
  addi t0, zero, 1
  bne t4, t0, screen_body_collide
  addi t0, zero, 2
  bne t4, t0, screen_body_collide
  addi t0, zero, 3
  bne t4, t0, screen_body_collide
  addi t0, zero, 4
  bne t4, t0, screen_body_collide

food_collide:
  addi v0, zero, 1
  jmpi end_hit_test
screen_body_collide:
  addi v0, zero, 2
  jmpi end_hit_test

  addi v0, zero, 0

end_hit_test:
  ret
; END:hit_test

; BEGIN:display_score
display_score:

  ret
; END:

; BEGIN:restart_game
restart_game:
  stw zero, TAIL_X (zero) ; tail_x = 0
  stw zero, TAIL_Y (zero) ; tail_y = 0
  stw zero, HEAD_X (zero) ; head_x = 0
  stw zero, HEAD_Y (zero) ; head_y = 0
  addi t0, zero, 4 ; t0 = 4
  stw t0, GSA (zero) ; GSA[0] = 4

  ret
; END:restart_game

; ---------------------------------------wait
; BEGIN:wait
wait:
 ;addi t0, zero, 100000
 ;addi t0, t0, -1
 ;bne t0, r0, wait
 ;ret
; utility function



; ---------------------------------------END
end:
 break

font_data:
  .word 0xFC ; 0
  .word 0x60 ; 1
  .word 0xDA ; 2
  .word 0xF2 ; 3
  .word 0x66 ; 4
  .word 0xB6 ; 5
  .word 0xBE ; 6
  .word 0xE0 ; 7
  .word 0xFE ; 8
  .word 0xF6 ; 9













