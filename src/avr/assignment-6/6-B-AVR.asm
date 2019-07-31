.include "m16def.inc"
.def temp=r16
.cseg
.org 0x0
  ldi temp,HIGH(RAMEND)
  out SPH,temp
  ldi temp,LOW(RAMEND)
  out SPL,temp
  ser r26
  out DDRA, r26
  clr r26
  out DDRB, r26
  ser r26
  out PORTB, r26

flash:
  in r23, PINB    ; input
  mov r22, r23
  rcall on   ; light it up
  andi r23, 0x0f
  ;inc r23
wait_on:
  ldi r24, 0x64
  ldi r25, 0x00
  rcall wait_msec ;repeat x times
  ;dec r23
  brne wait_on

  rcall off
  swap r22
  andi r22, 0x0f
  ;inc r22
wait_off:
  ldi r24, 0x64
  ldi r25, 0x00
  rcall wait_msec
  ;dec r22
  brne wait_off
  rjmp flash

on:
  ser r26
  out PORTA , r26
  ret

off:
  clr r26
  out PORTA , r26
  ret





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
