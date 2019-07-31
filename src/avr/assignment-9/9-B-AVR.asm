.include "m16def.inc"

.DSEG

_tmp_: .byte 2

.CSEG

.org 0x0
rjmp start
.org 0x10
rjmp ISR_TIMER1_OVF          ;; TIMER OVERFLOW INTERRUPT ROUTINE


start:
    ldi r24 , (1 << TOIE1)   ;; ENABLE OVERFLOW INTERRUPT OF TCNT1 COUNTER FOR TIMER1
    out TIMSK ,r24           ;; ACTIVE TIMER1
    ldi r24 , (1 << CS12) | (0 << CS11) | (1 << CS10)
    out TCCR1B,r24
    ldi r24,low(RAMEND)      ;; INITIALIZE STACK POINTER
    out SPL,r24
    ldi r24,high(RAMEND)
    out SPH,r24
    ldi r24,0
    st X,r24                 ;; INITIALIZE TEMP
    st -X,r24
    ldi r24 , (1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)
    out DDRC ,r24            ;; INITIALIZE PORTC FOR KEYBOARD READING
    ldi r24,(1 << PD7) | (1 << PD6) | (1 << PD5) | (1 << PD4) | (1 << PD3) | (1 << PD2)
    out DDRD,r24             ;; INITIALIZE PORTD FOR SCREEN
    clr r24
    out DDRA,r24             ;; INITIALIZE PORTA FOR INPUT
    ser r24
    out DDRB,r24             ;; INITIALIZE PORTB FOR OUTPUT
    rcall lcd_init           ;; INITIALIZE SCREEN
    sei                      ;; ENABLE INTERRUPTS
buttoncheck:
    in r24,PINA              ;; CHECK IF BUTTON WAS PRESSED
    cpi r24,0                ;; IF NOT THEN RE-CHECK
    breq buttoncheck         ;; RE-CHECK
    ldi r24,0x85             ;; INITIALIZE TCNT1
    out TCNT1H,r24
    ldi r24,0xEE             ;; OVERFLOW IT AFTER 4 SECONDS
    out TCNT1L,r24
check:
    rcall lcd_init           ;; INITIALIZE SCREEN

check1:                      ;; CHECK FIRST INPUT
    ldi r24,10               ;; GET FIRST INPUT
    rcall scan_keypad_rising_edge
    rcall keypad_to_ascii
    cpi r24,0                ;; NOTHING WAS GIVEN SO RE-CHECK
    breq check1              ;; RE-CHECK
    mov r19,r24              ;; SAVE FIRST INPUT CONTENT IN R19
    rcall lcd_data           ;; PRINT DATA
check2:                      ;; CHECK SECOND INPUT
    ldi r24,10               ;; GET SECOND INPUT
    rcall scan_keypad_rising_edge
    rcall keypad_to_ascii
    cpi r24,0                ;; NOTHING WAS GIVEN SO RE-CHECK
    breq check2
    mov r21,r24              ;; SAVE SECOND INPUT CONTENT IN R21
    rcall lcd_data
check3:                      ;; CHECK THIRD INPUT
    ldi r24,10               ;; GET THRID INPUT
    rcall scan_keypad_rising_edge
    rcall keypad_to_ascii
    cpi r24,0                ;; NOTHING WAS GIVEN SO RE-CHECK
    breq check3
    mov r20,r24              ;; SAVE THIRD INPUT CONTENT INTO R20
    rcall lcd_data
                             ;; CROSS-CHECK TIME
    cpi r19,69               ;; CROSS-CHECK IF FIRST INPUT IS ACTUALLY ASCII CHARACTER 'E'
    brne failed              ;; HELL IT WAS NOT - AUTHENTICATION FAILED
                             ;; SUCCESSFULL INPUT STATUS 1/3
    cpi r21,49               ;; CROSS-CHECK IF SECOND INPUT IS ACTUALLY ASCII CHARACTER '1'
    brne failed              ;; HELL IT WAS NOT - AUTHENTICATION FAILED
                             ;; SUCCESSFULL INPUT STATUS: 2/3
    cpi r20,49               ;; CROSS-CHECK IF THRID INPUT IS ACTUALLY ASCII CHARACTER '1'
    brne failed              ;; HELL IT WAS NOT - AUTHENTICATION FAILED
                             ;; SUCCESSFULL INPUT STATUS: 3/3
    rjmp skip
failed:
    rcall ISR_TIMER1_OVF     ;; INPUT AUTHENTICATION FAILED
                             ;; SEND OUT ALARM ON && TURN LEDS ON
skip:                        ;; <!-- THAT MIGHT NOT BE ACTUALLY NEEDED -->
terminate:                   ;; TERMINATE ALARM
    ldi r24 , (0 << CS12) | (0 << CS11) | (0 << CS10)
    out TCCR1B,r24           ;; DISABLE TIMER
    rcall lcd_init
    ldi r24,0b01000001       ;; SEND OUT A 'A'
    rcall lcd_data
    ldi r24,0b01001100       ;; SEND OUT A 'L'
    rcall lcd_data
    ldi r24,0b01000001       ;; SEND OUT A 'A'
    rcall lcd_data
    ldi r24,0b01010010       ;; SEND OUT A 'R'
    rcall lcd_data
    ldi r24,0b01001101       ;; SEND OUT A 'M'
    rcall lcd_data
    ldi r24,0b00100000       ;; SEND OUT A SPACE
    rcall lcd_data
    ldi r24,0b01001111       ;; SEND OUT A 'O'
    rcall lcd_data
    ldi r24,0b01000110       ;; SEND OUT A 'F'
    rcall lcd_data
    ldi r24,0b01000110       ;; RE-SEND OUT A 'F'
    rcall lcd_data
    rjmp endit               ;; 'ALARM OFF' SHOULD HAVE BEEN DISPLAYED BY NOW
endit:
    rjmp endit

;; A LINE BELOW THE DARK SIDE OF ROUTINES BEGINS
lcd_init:
  ldi r24 ,40
  ldi r25 ,0
  rcall wait_msec
  ldi r24 ,0x30
  out PORTD ,r24
  sbi PORTD ,PD3
  cbi PORTD ,PD3
  ldi r24 ,39
  ldi r25 ,0
  rcall wait_usec
  ldi r24 ,0x30
  out PORTD ,r24
  sbi PORTD ,PD3
  cbi PORTD ,PD3
  ldi r24 ,39
  ldi r25 ,0
  rcall wait_usec
  ldi r24 ,0x20
  out PORTD ,r24
  sbi PORTD ,PD3
  cbi PORTD ,PD3
  ldi r24 ,39
  ldi r25 ,0
  rcall wait_usec
  ldi r24 ,0x28
  rcall lcd_command
  ldi r24 ,0x0c
  rcall lcd_command
  ldi r24 ,0x01
  rcall lcd_command
  ldi r24 ,low(1530)
  ldi r25 ,high(1530)
  rcall wait_usec
  ldi r24 ,0x06
  rcall lcd_command
ret

lcd_data:
  sbi PORTD ,PD2
  rcall write_2_nibbles
  ldi r24 ,43
  ldi r25 ,0
  rcall wait_usec
ret

lcd_command:
  cbi PORTD ,PD2
  rcall write_2_nibbles
  ldi r24 ,39
  ldi r25 ,0
  rcall wait_usec
ret

write_2_nibbles:
  push r24
  in r25 ,PIND
  andi r25 ,0x0f
  andi r24 ,0xf0
  add r24 ,r25
  out PORTD ,r24
  sbi PORTD ,PD3
  cbi PORTD ,PD3
  pop r24
  swap r24
  andi r24 ,0xf0
  add r24 ,r25
  out PORTD ,r24
  sbi PORTD ,PD3
  cbi PORTD ,PD3
ret

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
  swap r24
  mov r27 ,r24
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
  back_: lsl r25
    dec r24
  brne back_
  out PORTC ,r25
  nop
  nop
  in r24 ,PINC
  andi r24 ,0x0f
ret

keypad_to_ascii:
  movw r26 ,r24
  ldi r24 ,'*'
  sbrc r26 ,0
  ret
  ldi r24 ,'0'
  sbrc r26 ,1
  ret
  ldi r24 ,'#'
  sbrc r26 ,2
  ret
  ldi r24 ,'D'
  sbrc r26 ,3
  ret
  ldi r24 ,'7'
  sbrc r26 ,4
  ret
  ldi r24 ,'8'
  sbrc r26 ,5
  ret
  ldi r24 ,'9'
  sbrc r26 ,6
  ret
  ldi r24 ,'C'
  sbrc r26 ,7
  ret
  ldi r24 ,'4'
  sbrc r27 ,0
  ret
  ldi r24 ,'5'
  sbrc r27 ,1
  ret
  ldi r24 ,'6'
  sbrc r27 ,2
  ret
  ldi r24 ,'B'
  sbrc r27 ,3
  ret
  ldi r24 ,'1'
  sbrc r27 ,4
  ret
  ldi r24 ,'2'
  sbrc r27 ,5
  ret
  ldi r24 ,'3'
  sbrc r27 ,6
  ret
  ldi r24 ,'A'
  sbrc r27 ,7
  ret
  clr r24
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


ISR_TIMER1_OVF:
      rcall lcd_init
     ldi r24,0b01000001       ;; SEND OUT A 'A'
     rcall lcd_data
     ldi r24,0b01001100      ;; SEND OUT A 'L'
     rcall lcd_data
     ldi r24,0b01000001       ;; SEND OUT A 'A'
     rcall lcd_data
     ldi r24,0b01010010       ;; SEND OUT A 'R'
     rcall lcd_data
     ldi r24,0b01001101       ;; SEND OUT A 'M'
     rcall lcd_data
     ldi r24,0b00100000       ;; SEND OUT A SPACE
     rcall lcd_data
     ldi r24,0b01001111       ;; SEND OUT A 'O'
     rcall lcd_data
     ldi r24,0b01001110       ;; SEND OUT A 'N'
     rcall lcd_data
 leds_on:
    ser r24
    out PORTB,r24             ;; TURN LEDS ON
    ldi r24,low(200)
    ldi r25,high(200)
    rcall wait_msec           ;; SET A 200 MS DELAY WHILE ON
    clr r24
    out PORTB,r24             ;; TURN LEDS OFF
    ldi r24,low(200)
    ldi r25,high(200)
    rcall wait_msec           ;; SET A 200 MS DELAY WHILE OFF
    rjmp leds_on             ;; REPEAT
    reti
