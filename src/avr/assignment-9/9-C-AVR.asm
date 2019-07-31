#define __SFR_OFFSET 0
#include <avr/io.h>
#include <avr/interrupt.h>

.include "m16def.inc"

.DSEG

.def input = r18
.def sign = r21
.def tempo = r20
.def hunds = r22
.def tens = r23
.def unts = r19
.def quantum = r24
.def temp1 = r24
.def temp2 = r25

.CSEG

main:
    ldi r24,lo8(RAMEND)      ;; INITIALIZE STACK POINTER
    out SPL,r24
    ldi r24,hi8(RAMEND)
    out SPH,r24
    clr r25
    out DDRB,r25             ;; INITIALIZE PORTB FOR INPUT
    ser r25
    out DDRD,r25             ;; INITIALIZE PORTD FOR OUTPUT
    rcall lcd_init           ;; INITIALIZE DISPLAY
start:
    in input,PINB            ;; GET INPUT
    mov tempo,input          ;; SAVE THE GIVEN INPUT
    lsl tempo                ;; LOGICALY SHIFT LEFT BY ONE PLACE
                             ;; 0-THE BIT IS CLEARED && 7-TH BIT LOADED INTO C FLAG OF SREG
    brcc positive             ;; IF CARRY == 0 THEN BRANCH TO POSITIVE
                             ;; ELSE INPUT IS NEGATIVE
negative:                     ;; WE GOT A NEGATIVE NUM
                             ;; SO SET THE MINUS SYMBOL '-' IN THE FROND
    ldi sign,'-'
    neg input                 ;; REPLACE THE CONTENT OF INPUT WITH TWO' COMPLEMENT
    rjmp calculation         ;; NOW GO TO CALCULATE
positive:                    ;; THE NUM IS POSITIVE
    ldi sign,'+'             ;; SO SET THE PLUS SYMBOL '+' IN THE FROND
calculation:
    clr hunds                ;; CLEAR HUNDREDS UP
    clr tens                 ;; CLEAR DECADES UP
    clr unts                 ;; CLEAR UNITS UP
    cpi input,0x64           ;; COMPARE INPUT WITH HEX 100
    brlo count_tens           ;; IF LESS THAN 100 THEN THERE ARE NO HUNREDS TO COUNT
                             ;; IF NOT THEN WE DO HAVE A FEW HUNDREDS TO COUNT
count_hunds:
    ldi hunds,1               ;; MAXIMUM NUMBER OF HUNDREDS IS 1
    subi input,0x64           ;; SUBRTRACT A VALUE OF 100 FROM INPUT
count_tens:                  ;; TIME TO COUNT THE TENTHS
    cpi input,10             ;; COMPARE WITH A VALUE OF 10
    brlo count_unts           ;; IF LESS THAN 10 THEN THERE ARE NO TENTHS TO COUNT
                             ;; IF NOT THEN WE DO HAVE A FEW TENTHS TO COUNT
    subi input,10             ;; SUBTRACT A VALUE OF 10 FROM INPUT
    inc tens                 ;; INCREMENT THE COUNTER OF TENTHS
    rjmp count_tens          ;; CONTINUE COUNTING UNTIL THERE ARE NO MORE LEFT
                             ;; NOW WE ARE LEFT ONLY WITH UNITS
count_unts:
    mov unts,input
    rjmp print_to_lcd

print_to_lcd:
                             ;; PRINT THE SIGN
lcd_clear:
    ldi r24,0x01             ;; CLEAR THE DISPLAY
    rcall lcd_command
    ldi r24,lo8(1530)
    ldi r25,hi8(1530)
    rcall wait_usec           ;; END OF CLEARING OF THE DISPAY
    mov quantum,sign
    rcall lcd_data           ;; SEND OUT THE SIGN
                             ;; CHECK FOR THE HUNDRED
    cpi hunds,1
    brlo check_tens           ;; IF LESS THAN 100 CHECK IF TENTHS ARE ALOS == O
    subi hunds,-48           ;; GET THE ASCII OF HUNDREDS
    mov quantum,hunds
    rcall lcd_data           ;; SEND OUT THE HUNDREDS ASCII`
check_tens:
    cpi tens,0
    breq check_unts           ;; NO TENTHS SO GO TO UNITS
    subi tens,-48             ;; ELSE GET THE ASCII OF TENTHS
    mov quantum,tens
    rcall lcd_data           ;; SET OUT THE ASCII OF TENTHS
check_unts:
    subi unts,-48             ;; GET THE ASCII OF UNITS
    mov quantum,unts           ;; SEND UNITS ASCII OUT AS IT IS SINCE THEY ARE ALREADY
                             ;; COMPLEMENTED BY TWO
                             ;; 0 WILL BE PRESENTED AS +0
    rcall lcd_data           ;; SEND OUT THE ASCII OF UNITS

    ldi r24,0xAA
    ldi r25,0x00
    rcall wait_msec

  rjmp start


;; A LINE BELOW THE DARK SIDE OF ROUTINES BEGINS
lcd_init:
    ldi r24,40
    ldi r25,0
    rcall wait_msec

    ldi r24,0x30
    out PORTD,r24
    sbi PORTD,PD3
    cbi PORTD,PD3
    ldi r24,39
    ldi r25,0
    rcall wait_usec

    ldi r24,0x30
    out PORTD,r24
    sbi PORTD,PD3
    cbi PORTD,PD3
    ldi r24,39
    ldi r25,0
    rcall wait_usec

    ldi r24,0x20
    out PORTD,r24
    sbi PORTD,PD3
    cbi PORTD,PD3
    ldi r24,39
    ldi r25,0
    rcall wait_usec

    ldi r24,0x28
    rcall lcd_command

    ldi r24,0x0c
    rcall lcd_command

    ldi r24,0x01
    rcall lcd_command
    ldi r24,lo8(1530)
    ldi r25,hi8(1530)
    rcall wait_usec

    ldi r24,0x06
    rcall lcd_command

    ret

lcd_data:
    sbi PORTD,PD2
    rcall write_2_nibbles
    ldi r24,43
    ldi r25,0
    rcall wait_usec
    ret

lcd_command:
    cbi PORTD,PD2
    rcall write_2_nibbles
    ldi r24,39
    ldi r25,0
    rcall wait_usec
    ret

write_2_nibbles:
    push r24
    in r25,PIND
    andi r25,0x0f
    andi r24,0xf0
    add r24,r25
    out PORTD,r24
    sbi PORTD,PD3
    cbi PORTD,PD3
    pop r24
    swap r24
    andi r24,0xf0
    add r24,r25
    out PORTD,r24
    sbi PORTD,PD3
    cbi PORTD,PD3
    ret

wait_msec:
    push temp1
    push temp2
    ldi temp1, lo8(998)
    ldi temp2, hi8(998)
    rcall wait_usec
    pop temp2
    pop temp1
    sbiw temp1, 1
    brne wait_msec

    ret

wait_usec:
    sbiw temp1,1
    nop
    nop
    nop
    nop
    brne wait_usec

    ret
