.include "m16def.inc"
.def temp=r16
.cseg
.org 0x0
  ldi temp,HIGH(RAMEND)
  out SPH,temp
  ldi temp,LOW(RAMEND)
  out SPL,temp
reset:
  ser r26
  out DDRA,r26  ;PORTA output
  clr r26
  out DDRB,r26  ;PORTB input
  ser r26
  out PORTB,r26   ;pull-up resistors
  ldi r26,1  ;r26 in charge of the LED

down:
  out PORTA,r26  ;Light it up
  ldi r24,0xf4  ; Proper time for wait
  ldi r25,0x01
  rcall wait_msec
  jmp button_down
bpd:
  rol r26          ;check whether we must change direction
  brcc down
  ror r26
  ror r26
up:
  out PORTA, r26
  ldi r24,0xf4
  ldi r25,0x01
  rcall wait_msec
  jmp button_up
bpu:
  ror r26
  brcc up
  rol r26
  rol r26
  jmp down

button_up:
  in  r23,PINB
  bst r23, 0
  brtc exit_up
pressed_up:
  in  r23, PINB
  bst r23,0
  brts pressed_up
exit_up:
  jmp bpu

button_down:
  in  r23, PINB
  bst r23, 0
  brtc exit_down
pressed_down:
  in  r23, PINB
  bst r23,0
  brts pressed_down
exit_down:
  jmp bpd




wait_msec:
 push r24
 push r25
ldi r24 , low(998)
 ldi r25 , high(998)
 rcall wait_usec
 pop r25
 pop r24
 sbiw r24 ,1
 brne wait_msec
 ret

wait_usec:
sbiw r24 ,1
nop
nop
nop
nop
brne wait_usec
 ret
