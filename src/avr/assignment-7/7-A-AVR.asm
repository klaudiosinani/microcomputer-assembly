.include "m16def.inc"
.def counter=r18
.def icounter=r19
.cseg
.org 0x0
rjmp reset
.org 0x2
rjmp ISRO
reset:
ldi r16,high(RAMEND)
out SPH,r16
ldi r16,low(RAMEND)
out SPL,r16 ;; STACK SET
clr r16
out DDRD,r16
ser r16
out PORTD,r16 ;; PORTD INPUT
out DDRA,r16 ;; PORTA OUTPUT
out DDRB,r16 ;; PORTB OUTPUT
clr r16
out PORTB,r16
;; interrupt section
ldi r24,(1 << ISC01) | (1 << ISC00) ;; SLEEP ENABLE
out MCUCR,r24 ;; RISING EDGE TRIGGER
ldi r24,( 1 << INT0)
out GIMSK,r24 ;; INT MASK SET
sei
clr counter
clr icounter
start:
out PORTA,counter ;; PRINT LOOP COUNTER
ldi r24,low(100)
ldi r25,high(100) ;; DELAY IT
rcall wait_msec
inc counter ;; INCREASE COUNTER
rjmp start ;; LOOP ON
ISRO:
rcall check
in r16,PIND ;; PORTD INPUT
inc icounter ;; INCREMEANT I-COUNTER
sbrc r16,0
reti
out PORTB,icounter ;; PRINT
reti
wait_usec:
sbiw r24,1
nop
nop
nop
nop
brne wait_usec
ret
wait_msec:
push r24
push r25
ldi r24,0xe6
ldi r25,0x03
rcall wait_usec
pop r25
pop r24
sbiw r24,1
brne wait_msec
ret
check:
ldi r16, (1 << INTF0)
out GIFR,r16
ldi r24,low(5)
ldi r25,high(5)
rcall wait_msec ;; 5 MSEC WAITING
in r16,GIFR ;; CHECK IF INTF0 === 1
sbrc r16,6
rjmp check ;; IF INTF0 == 1 LOOP ON
ret ;; IF INTF0==0 THEN RETURN
