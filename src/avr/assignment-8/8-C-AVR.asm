.include "m16def.inc"

.DSEG
_tmp_: .byte 2

.CSEG

.LIST
.def temp = r16
.def counter = r17
.def flag = r18

.org 0x00
rjmp reset

reset:
  ldi temp,low(RAMEND)    ;Initialize stack pointer
  out SPL,temp
  ldi temp,high(RAMEND)
  out SPH,temp

  ser temp
  out DDRA,temp        ;PORTA is output

  ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)
  out DDRC ,r24

  clr temp
  sts _tmp_,temp          ;Initialize variable to 0

digit1:
  ldi r24,10
  rcall scan_keypad_rising_edge
  mov temp,r25
  sbrs temp,5          ;we check the fifth bit that equals to no.1
  rjmp digit1

digit2:
  ldi r24,10
  rcall scan_keypad_rising_edge
  mov temp,r25
  cpi temp,16
  breq blink         ;we check the fifth bit that equals to no.1 ==> 00010000=16
  mov temp, r24
  cpi temp,0
  brne digit1
  mov temp,r25
  cpi temp,0
  brne digit1
  rjmp digit2

  clr counter
blink:
  ldi r24,low(250)
  ldi r25,high(250)

  ser temp
  out PORTA,temp
  rcall wait_msec

  ldi r24,low(250)
  ldi r25,high(250)

  clr temp
  out PORTA,temp
  rcall wait_msec

  inc counter
  cpi counter,10
  brne blink
  rjmp reset


;----------------------------------------Routines Section----------------------------------------------------------------

scan_keypad_rising_edge:
  mov r22 ,r24
  rcall scan_keypad
  push r24
  push r25
  mov r24 ,r22
  ldi r25 ,0
  rcall wait_msec
  rcall scan_keypad
  pop r23
  pop r22
  and r24 ,r22
  and r25 ,r23
  ldi r26 ,low(_tmp_)
  ldi r27 ,high(_tmp_)
  ld r23 ,X+
  ld r22 ,X
  st X ,r24
  st -X ,r25
  com r23
  com r22
  and r24 ,r22
  and r25 ,r23
  ret

scan_keypad:
  ldi r24 ,0x01
  rcall scan_row
  mov r27 ,r24
  swap r24
  ldi r24 ,0x02
  rcall scan_row
  add r27 ,r24
  ldi r24 ,0x03
  rcall scan_row
  swap r24
  mov r26 ,r24
  ldi r24 ,0x04
  rcall scan_row
  add r26 ,r24
  movw r24 ,r26
  ret

scan_row:
  ldi r25 ,0x08
back_:
  lsl r25
  dec r24
  brne back_
  out PORTC ,r25
  nop
  nop
  in r24 ,PINC
  andi r24 ,0x0f
  ret

wait_usec:
  sbiw r24 ,1
  nop
  nop
  nop
  nop
  brne wait_usec
  ret

wait_msec:
  push r24
  push r25
  ldi r24 , low(998)
  ldi r25 , high(998)
  rcall wait_usec
  pop r25
  pop r24
  sbiw r24 , 1
  brne wait_msec
  ret
