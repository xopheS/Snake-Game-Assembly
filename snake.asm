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
  addi sp, zero, LEDS ; stack pointer = LEDS address

  addi v0, zero, 2

game_loop:
  call wait
  addi t0, zero, 1 ; t0 = 1

  ldw t1, BUTTONS + 4 (zero)
  srli t1, t1, 4
  and t1, t1, t0 ; t1 = t1 & t0
  beq t1, zero, post_restart_check ; if button 4 is pressed restart game
  ldw zero, BUTTONS + 4 (zero)
  call restart_game
  call create_food
  call clear_leds
  call draw_array
  call display_score
  call wait
post_restart_check:
  call get_input
  call hit_test
  addi t0, zero, 2 ; t0 = 2
  beq v0, t0, game_loop
  call clear_leds
  addi t0, zero, 1 ; t0 = 1
  bne v0, t0, post_food_check
  ldw t0, SCORE (zero)
  addi t0, t0, 1 ; t0++
  stw t0, SCORE (zero)
  call create_food
post_food_check: 
  call move_snake
  add v0, zero, zero

  call draw_array
  call display_score

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
  slli t0, a0, 3 ; t0 = x * 8
  add t0, t0, a1 ; t0 = t0 + y
  addi t1, zero, 1 ; t1 = 1
  sll t1, t1, t0 ; t1 = t1 << t0

  add t4, zero, zero ; t4 = 0
  addi t3, zero, 4
  blt a0, t3, draw_pixel

  addi t4, zero, 4 ; t4 = 4
  addi t3, t3, 4
  blt a0, t3, draw_pixel

  addi t4, zero, 8 ; t4 = 8

draw_pixel:
  ldw t2, LEDS (t4)
  or t2, t2, t1
  stw t2, LEDS (t4)

  ret
; END:set_pixel

; BEGIN:get_input
get_input:
  ldw t0, HEAD_X (zero) ; t0 = head_x
  ldw t1, HEAD_Y (zero) ; t1 = head_y
  ldw t2, BUTTONS + 4 (zero) ; t2 = edge_capture

  beq t2, zero, end_get_input ; end loop

  slli t6, t0, 3 ; t6 = head_x * 8
  add t6, t6, t1 ; t6 = t6 + head_y
  slli t6, t6, 2 ; t6 = t6 * 4
  ldw t7, GSA (t6) ; t7 = GSA[t6]

  addi t5, zero, 1 ; t5 = 1
loop:
  and t3, t2, t5 ; t3 = edge_capture & mask

  bne t3, zero, end_loop
  
  slli t5, t5, 1 ; t5 = t5 << 1
  addi t3, zero, 1 ; t3 = 1
  slli t3, t3, 4 ; t3 = 0b10000
  bne t0, t3, loop
  jmpi end_get_input
end_loop:

  addi t0, zero, 1
  beq t5, t0, button_zero
  addi t0, zero, 2
  beq t5, t0, button_one
  addi t0, zero, 4
  beq t5, t0, button_two
  addi t0, zero, 8
  beq t5, t0, button_three

button_zero:
  addi t0, zero, 4
  beq t7, t0, end_get_input
  addi t0, zero, 1 
  stw t0, GSA (t6)
  jmpi end_get_input

button_one:
  addi t0, zero, 3
  beq t7, t0, end_get_input
  addi t0, zero, 2
  stw t0, GSA (t6)
  jmpi end_get_input 

button_two:
  addi t0, zero, 2
  beq t7, t0, end_get_input
  addi t0, zero, 3
  stw t0, GSA (t6) 
  jmpi end_get_input

button_three:
  addi t0, zero, 1
  beq t7, t0, end_get_input
  addi t0, zero, 4
  stw t0, GSA (t6)
  jmpi end_get_input  
  
end_get_input:
  addi t0, zero, 0b10000
  ldw t1, BUTTONS + 4 (zero)
  and t1, t1, t0
  stw t1, BUTTONS + 4 (zero)
  ret

; END:get_input

; ---------------------------------------move_snake
; BEGIN:move_snake
move_snake:
  ldw t0, HEAD_X (zero) ; t0 = head_x
  ldw t1, HEAD_Y (zero) ; t1 = head_y
  slli t3, t0, 3 ; t3 = x * 8
  add t3, t3, t1 ; t3 = t3 + head_y
  slli t3, t3, 2 ; t3 = t3 * 4
  ldw t4, GSA (t3) ; t4 = GSA[t3]
  
  addi t5, zero, 1
  beq t4, t5, update_left_head
  addi t5, zero, 2
  beq t4, t5, update_up_head
  addi t5, zero, 3
  beq t4, t5, update_down_head
  addi t5, zero, 4
  beq t4, t5, update_right_head

update_up_head:
  addi t1, t1, -1
  jmpi update_head 
update_down_head:
  addi t1, t1, 1
  jmpi update_head
update_left_head:
  addi t0, t0, -1
  jmpi update_head 
update_right_head:
  addi t0, t0, 1
  jmpi update_head

update_head:
  stw t0, HEAD_X (zero)
  stw t1, HEAD_Y (zero)
  slli t3, t0, 3 ; t3 = head_x * 8
  add t3, t3, t1 ; t3 = t3 + head_y
  slli t3, t3, 2 ; t3 = t3 * 4
  stw t4, GSA (t3)

  addi t0, zero, 1
  beq v0, t0, end_move_snake
  ; update tail
  ldw t0, TAIL_X (zero) ; t0 = tail_x
  ldw t1, TAIL_Y (zero) ; t1 = tail_y
  slli t3, t0, 3 ; t3 = tail_x * 8
  add t3, t3, t1 ; t3 = t3 + tail_y
  slli t3, t3, 2 ; t3 = t3 * 4
  ldw t4, GSA (t3) ; t4 = GSA[t3]
  stw zero, GSA (t3) ; GSA[t3] = 0

  addi t5, zero, 1
  beq t4, t5, update_left_tail
  addi t5, zero, 2
  beq t4, t5, update_up_tail 
  addi t5, zero, 3
  beq t4, t5, update_down_tail  
  addi t5, zero, 4
  beq t4, t5, update_right_tail
 
update_up_tail:
  addi t1, t1, -1
  jmpi update_tail
update_down_tail:
  addi t1, t1, 1
  jmpi update_tail
update_left_tail:
  addi t0, t0, -1
  jmpi update_tail
update_right_tail:
  addi t0, t0, 1
  jmpi update_tail

update_tail:
  stw t0, TAIL_X (zero) ; t0 = tail_x
  stw t1, TAIL_Y (zero) ; t1 = tail_y

end_move_snake:
  ret
; END:move_snake

; BEGIN:draw_array
draw_array:
  addi s0, zero, 0 ; x = 0
loopx:
  addi s1, zero, 0 ; y = 0
  loopy:
    add t0, s0, zero ; t0 = x
    add t1, s1, zero ; t1 = y
    slli t0, t0, 3 ; t0 = t0 * 8
    add t0, t0, t1 ; t0 = t0 + t1
    slli t0, t0, 2 ; t0 = t0 * 4
    ldw t1, GSA (t0)
    beq t1, zero, post_pixel
    addi sp, sp, -20
    stw a0, 0 (sp)
    stw a1, 4 (sp)
    stw s0, 8 (sp)
    stw s1, 12 (sp)
    stw ra, 16 (sp)
    addi a0, s0, 0 ; a0 = x
    addi a1, s1, 0 ; a1 = y
    call set_pixel
    ldw a0, 0 (sp)
    ldw a1, 4 (sp)
    ldw s0, 8 (sp)
    ldw s1, 12 (sp)
    ldw ra, 16 (sp)
    addi sp, sp, 20
  post_pixel:
  	addi s1, s1, 1
    addi t1, zero, 8 ; t1 = max_y + 1
 	bne s1, t1, loopy
  
  addi s0, s0, 1
  addi t0, zero, 12 ; t0 = max_x + 1
  bne s0, t0, loopx

end_draw_array:
  ret
; END:draw_array

; BEGIN:create_food
create_food:
  ldw t0, RANDOM_NUM (zero) ; t0 = random number
  nor t1, zero, zero ; t1 = not(0)
  srli t1, t1, 24 ; t1 = t1 >>> 24
  and t0, t0, t1
  blt t0, zero, create_food ; if (random < 0) return
  addi t1, zero, 96 ; t1 = 96, 95 is the end bound of game array
  bge t0, t1, create_food ; if (random > 95) return

  ;addi t0, zero, 11

  slli t0, t0, 2 ; t0 = 4 * t0
  ldw t3, GSA (t0) ; t3 = GSA[t0]
  bne t3, zero, end_create_food ; if (GSA[t0] != 0) return

  addi t4, zero, 5 ; t4 = 5
  stw t4, GSA (t0) ; GSA[t0] = 5

end_create_food:
  ret
; END:create_food

; BEGIN:hit_test
hit_test:
  ldw t0, HEAD_X (zero) ; t0 = head_x
  ldw t1, HEAD_Y (zero) ; t1 = head_y
  slli t3, t0, 3 ; t3 = t0 * 8
  add t3, t3, t1 ; t3 = t3 + head_y
  slli t3, t3, 2 ; t3 = t3 * 4
  ldw t4, GSA (t3) ; t4 = GSA[head_x][head_y]

  ;TODO update hit test names to predict move

  addi t5, zero, 1
  beq t4, t5, left_predict
  addi t5, zero, 2
  beq t4, t5, up_predict
  addi t5, zero, 3
  beq t4, t5, down_predict
  addi t5, zero, 4
  beq t4, t5, right_predict
left_predict:
  addi t0, t0, -1 ; head_x--
  jmpi test_end
up_predict:
  addi t1, t1, -1 ; head_y--
  jmpi test_end
down_predict:
  addi t1, t1, 1 ; head_y++
  jmpi test_end
right_predict:
  addi t0, t0, 1 ; head_x++
  jmpi test_end
test_end: 

  addi t3, zero, 0 ; t3 = 0
  slli t3, t0, 3 ; t3 = t0 * 8
  add t3, t3, t1 ; t3 = t3 + head_y
  slli t3, t3, 2
  ldw t4, GSA (t3) ; t4 = GSA[head_x][head_y] (predicted)

  blt t0, zero, screen_body_collide
  blt t1, zero, screen_body_collide
  addi t6, zero, 12
  addi t7, zero, 8
  bge t0, t6, screen_body_collide
  bge t1, t7, screen_body_collide

  beq t4, zero, end_hit_test
  addi t0, zero, 5
  beq t4, t0, food_collide
  addi t0, zero, 1
  beq t4, t0, screen_body_collide
  addi t0, zero, 2
  beq t4, t0, screen_body_collide
  addi t0, zero, 3
  beq t4, t0, screen_body_collide
  addi t0, zero, 4
  beq t4, t0, screen_body_collide

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

; ---------------------------------------display_score
; BEGIN:display_score
display_score:	 
  ldw t1, SCORE (zero) ; t1 = score
  
  ldw t0, font_data (zero) ; t0 = 0xFC
  stw t0, SEVEN_SEGS (zero) ; SEVEN_SEGS[0] = 0xFC
  stw t0, SEVEN_SEGS + 4 (zero) ; SEVEN_SEGS[1] = 0xFC

  addi t3, zero, 10 ; t3 = 10
  add t2, zero, zero ; t2 = 0
digit_loop:
  blt t1, t3, end_digit_loop
  addi t1, t1, -10 ; t1--
  addi t2, t2, 1 ; t2++
  jmpi digit_loop
end_digit_loop:

  slli t2, t2, 2 ; t2 = t2 * 4
  ldw t0, font_data (t2)
  stw t0, SEVEN_SEGS + 8 (zero)
  slli t1, t1, 2 ; t1 = t1 * 4
  ldw t0, font_data (t1)
  stw t0, SEVEN_SEGS + 12 (zero)
	
end_display_score:
	ret
; END:display_score

; BEGIN:restart_game
restart_game:
  add a0, zero, zero
  add a1, zero, zero
  add a2, zero, zero
  add a3, zero, zero
  add s0, zero, zero
  add s1, zero, zero
  add s2, zero, zero
  add s3, zero, zero
  add s4, zero, zero
  add s5, zero, zero
  add s6, zero, zero
  add s7, zero, zero
  add v0, zero, zero
  stw zero, TAIL_X (zero) ; tail_x = 0
  stw zero, TAIL_Y (zero) ; tail_y = 0
  stw zero, HEAD_X (zero) ; head_x = 0
  stw zero, HEAD_Y (zero) ; head_y = 0
  stw zero, SCORE (zero) ; score = 0
  stw zero, BUTTONS + 4 (zero)
  addi t0, zero, 4 ; t0 = 4
  stw t0, GSA (zero) ; GSA[0] = 4

  addi t2, zero, 384
  addi t0, zero, 4
gsa_loop:
  addi t0, t0, 4
  stw zero, GSA (t0)
  blt t0, t2, gsa_loop

  ret
; END:restart_game

; ---------------------------------------wait
; BEGIN:wait
wait:
  addi t1, zero, 1000
count_1:
  addi t0, zero, 10000
count_2:
  addi t0, t0, -1
  bne t0, zero, count_2
  addi t1, t1, -1
  bne t1, zero, count_1

  ret
; utility function

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













