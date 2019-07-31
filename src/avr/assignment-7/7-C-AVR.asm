.include "m16def.inc"
.def temp=r16
.def mule=r17
.def clock_h=r18
.def clock_l=r19
.def leds=r20
.def first_time=r15
.org 0x00
jmp main ;; HANDLER RESET
.org 0x02
jmp ISR0
.org 0x10
jmp timer1_rout
main:
ldi temp,high(RAMEND)
out SPH,temp
ldi temp,low(RAMEND)
out SPL,temp ;; INITIALIZE STACK
ldi r24 ,( 1 << ISC01) | ( 1 << ISC00)
out MCUCR, r24
ldi r24 ,( 1 << INT0)
out GICR, r24
ldi temp,0x05 ;; DIVISOR OF FRQNC == 1024
out TCCR1B,temp
ldi temp,0x04 ;; TIMER1 ENABLING
out TIMSK,temp
sei
out DDRD,temp
ser temp
ser temp
out DDRA,temp
clr first_time
ldi clock_h,0xa4
;; 0xA472 = 0d42098 = 65536 - 3 * 7812.5
;; WITH 7812.5Hz = CYCLES/SEC = 8 MHz / 1024
ldi clock_l,0x72
ldi leds,0x80
loop:
in mule,PINB ;; PORTB INPUT
sbrs mule,0 ;; PB0 == 1 THEN EXIT
rjmp loop
cpi first_time,1
bne con
ldi temp,0xFF
out PORTA,temp
ldi r24,low(500)
ldi r25,high(500)
rcall wait_msec
con:
ldi first_time,1
out PORTA,leds ;; PB0 LED ON
out TCNT1H,clock_h;; 3 SECONDS
out TCNT1L,clock_l
rjmp loop
ISR0:
rcall protect
push r26
in r26, SREG
push r26
cpi first_time,1
bne con1
ldi temp,0xFF ;; LIGHT UP IN CASE OF REFRESH
out PORTA,temp
ldi r24,low(500)
ldi r25,high(500)
rcall wait_msec
con1:
ldi first_time,1
out PORTA,leds ;; TURN LED ON
out TCNT1H,clock_h ;; CLOCK RESETTING
out TCNT1L,clock_l
pop r26
out SREG, r26
pop r26
sei
reti
timer1_rout:
clr leds
out PORTA,leds ;; TURN LIGHTS OFF ON
;; OVERFLOW
ldi leds,0x80
ldi first_time,0
sei
reti
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
ldi r24 , 0xe6
ldi r25 , 0x03
rcall wait_usec
pop r25
pop r24
sbiw r24 , 1
brne wait_msec
ret
protect:
ldi temp,0x40
out GIFR,temp
ldi r24,0x05
ldi r25,0x00
rcall wait_msec
in temp,GIFR
sbrc temp,6
rjmp protect
ret
