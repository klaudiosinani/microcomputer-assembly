.include "m16def.inc"
.def counter=r18
.def icounter=r19
.def bcounter=r17
.cseg
.org 0x0
rjmp reset
.org 0x2
rjmp ISRO
.org 0x4
rjmp ISR1
reset:
ldi r16,high(RAMEND)
out SPH,r16
ldi r16,low(RAMEND)
out SPL,r16
clr r16
out DDRD,r16
ser r16
out PORTD,r16
out DDRA,r16
out DDRB,r16
out DDRC ,r16
clr r16
out PORTB,r16
;; INTERRUPTS SECTION
ldi r24,(1<<ISC01)|(1<<ISC00)|(1<<ISC10)|(1<< ISC11)
out MCUCR,r24
ldi r24,( 1 << INT0) | (1 << INT1)
out GIMSK,r24
sei
clr counter
clr icounter
start:
out PORTA,counter
ldi r24,low(100)
ldi r25,high(100)
rcall wait_msec
inc counter
rjmp start
ISRO:
rcall check
cli
in r16,PIND
inc icounter
sbrc r16,0
rjmp ex0
out PORTB,icounter
ex0:
sei
reti
ISR1:
clr r16
out DDRB,r16
ser r16
out PORTB, r16
rcall check1
cli
clr bcounter
in r18, PINB
ldi r19,8
again:
sbrc r18,0
inc bcounter
ror r18
dec r19
brne again
out PORTC,bcounter
ser r16
out DDRB,r16
out PORTB,icounter ;; WHENEVER CHANGE OF
;; OUTPUT TAKES PLACE
;; WE LOSE OUT INT COUNTER
sei
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
ldi r24 , 0xe6
ldi r25 , 0x03
rcall wait_usec
pop r25
pop r24
sbiw r24 , 1
brne wait_msec
ret
check:
ldi r16, (1 << INTF0)
out GIFR,r16
ldi r24,low(5)
ldi r25,high(5)
rcall wait_msec
in r16,GIFR
sbrc r16,6
rjmp check
ret
check1:
ldi r16, (1 << INTF1)
out GIFR,r16
ldi r24,low(5)
ldi r25,high(5)
rcall wait_msec ;; WAIT 5 msec
in r16,GIFR ;; CHECK IF INTF0 === 1
sbrc r16,7
rjmp check ;; IF INTF0 == 1 LOOP ON
ret ;; IF INTF0 == 0 THEN RETURN
