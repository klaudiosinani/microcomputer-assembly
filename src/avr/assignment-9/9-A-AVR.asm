.DSEG
_tmp_: .byte 2

.CSEG

start:
    ldi r24,low(RAMEND)     ;; STACK POINTER INITIALIZATION
    out SPL,r24
    ldi r24,high(RAMEND)
    out SPH,r24
    ser r26                 ;; SET R26
    out DDRD, r26           ;; INITIALIZE PORTD FOR OUTPUT
    ldi r26,0xF0
    out DDRC,r26            ;; INITIALIZE PORC FOR OUTPUT
    clr r26                 ;; CLEAR R26
    sts _tmp_,r26           ;; WRITE BACK TO TEMP
    rcall lcd_init          ;; INITIALIZE DISPLAY
    ldi r24, 'N'            ;; PRINT 'NONE'
    rcall lcd_data
    ldi r24, 'O'
    rcall lcd_data
    ldi r24, 'N'
    rcall lcd_data
    ldi r24, 'E'
    rcall lcd_data
main:
    ldi r24, 30             ;; READ
    call scan_keypad_rising_edge
    call keypad_to_ascii
    cpi r24, 0
    breq main               ;; RE-READ IF NOTHING WAS READ
    push r24
    ldi r24, 0x01           ;; CLEAR LCD DISPLAY
    rcall lcd_command
    ldi r24, low(1530)
    ldi r25, high(1530)
    rcall wait_usec
    pop r24
    rcall lcd_data
    jmp main

.include "routines.inc"
