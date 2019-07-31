include "m16def.inc"
.cseg
.org 0

.def temp = r16
.def temp2 = r17
.def temp3 = r18
.def temp4 = r19

.def res0 = r20
.def res1 = r21
.def res2 = r22
.def res3 = r23

.def result = r24


reset:
  ldi temp,low(RAMEND)    ;initialize stack pointer
  out SPL,temp
  ldi temp,high(RAMEND)
  out SPH,temp

  ldi temp,0x0F
  out DDRC,temp        ;PORTC is output (only PC3-PC0)

  clr temp
  out DDRB,temp        ;PORTB as input
  out PORTC,temp        ;initially, PORTC LEDs are off
  ldi temp, 0xF0
  out DDRA,temp         ;PORTA as input (only PA3-PA0)

  clr temp

start:
  in temp, PINB

check01:                                      ;check01 is used for the OR operator
  mov temp2, temp
  andi temp2,0x03        ;isolate PB0,PB1
  cpi temp2,0          ;if both 0, PC0 will turn off, else light up
  breq c0_off
  rjmp c0_on
c0_off:
  ldi res0,0
  rjmp check23
c0_on:
  ldi res0,1

check23:                                         ; check23 is used for the AND operator
  mov temp2, temp
  andi temp2,0x0C        ;isolate PB2,PB3
  cpi temp2,0x0C        ;if both 1, PC1 will light up, else turn off
  breq c1_on
  rjmp c1_off
c1_on:
  ldi res1,2
  rjmp check45
c1_off:
  ldi res1,0

check45:                ; check45 is used for the XOR operator
  mov temp2, temp
  andi temp2, 0x30      ;isolate PB4,PB5
  cpi temp2,0          ;if both 0, PC2 will turn off, else check if both 1
  breq c2_off
  cpi temp2,0x30        ;if both 1, PC2 will turn off, else light up
  breq c2_off
  rjmp c2_on
c2_off:
  ldi res2,0
  rjmp check67
c2_on:
  ldi res2,4

check67:            ;create temp3 in our minds
  mov temp2, temp
  andi temp2, 0xC0      ;isolate PB6,PB7
  cpi temp2,0          ;if both 0, temp3 will turn off, else check if both 1
  breq temp3_off
  cpi temp2,0xC0        ;if both 1, temp3 will turn off, else light up
  breq temp3_off
  rjmp temp3_on
temp3_off:
  ldi temp3,0
  rjmp check67_fin
temp3_on:
  ldi temp3,1

check67_fin:
  mov temp4, temp3
  or temp4, res2        ;get temp3 and c2 in one register (in bit0 and bit2)
  cpi temp4, 0          ;if both 0, PC3 will turn off, else check if both 1
  breq c3_off
  cpi temp4, 0x05        ;if both 1(here 0101), PC3 will turn off, else light up
  breq c3_off
  rjmp c3_on
c3_off:
  ldi res3,0
  rjmp concl
c3_on:
  ldi res3,8

concl:
  clr result

;--------------------------------------------
  in temp, PINA        ;now we'll check for PA buttons that are pushed, and inverse the corresponding output
  cpi temp,0          ;if no button is pushed, just proceed to result merging
  breq resultado
rev_0:
  mov temp3,temp
  andi temp3,0x01        ;isolate PA0
  cpi temp3, 0
  breq rev_1
  com res0          ;if PA0=1 inverse PC0
  andi res0,0x01        ;by taking its complement and keeping only corresponding bit

rev_1:
  mov temp3, temp
  andi temp3, 0x02      ;isolate PA1
  cpi temp3, 0
  breq rev_2
  com res1          ;if PA1=1 inverse PC1
  andi res1,0x02

rev_2:
  mov temp3, temp
  andi temp3, 0x04      ;isolate PA2
  cpi temp3, 0
  breq rev_3
  com res2          ;if PA2=1 inverse PC2
  andi res2,0x04

rev_3:
  mov temp3, temp
  andi temp3, 0x08      ;isolate PA3
  cpi temp3, 0
  breq resultado
  com res3          ;if PA3=1 inverse PC3
  andi res3,0x08

;--------------------------------------------
resultado:
  mov result, res0      ;PC0
  or result, res1        ;PC1
  or result, res2        ;PC2
  or result, res3        ;PC3

  andi result,0x0F      ;make sure PC4-PC7 don't light up
output:
  out PORTC,result      ;output result in PORTC

  rjmp start
