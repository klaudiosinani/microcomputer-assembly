start:.DSEG
_tmp_: .byte 2

.CSEG

    ldi r24,low(RAMEND)       ;; INITIALIZE STACK
    out SPL,r24
    ldi r24,high(RAMEND)
    out SPH,r24
    ser r26
    out DDRD,r26              ;; INITIALIZE PORTD AS OUTPURT
    clr r26
    out DDRA,r26              ;; INITIALIZE PORTA AS INPUT
    sts _tmp_,r26             ;; WRITE BACK TO TEMP
clear:
    clr r20                   ;; CLEAR SECONDS UP
    clr r21                   ;; CLEAR MINUTES UP
    clr r19                   ;; CLEAR TENS OF MINUTES UP
    clr r18                   ;; CLEAR TENS OF SECONDS UP
    rcall print               ;; PRINT TO DISPLAY
main:
    in r24,PINA               ;; CHECK FOR PRESSED KEY
    mov r25,r24               ;; SAVE CONTENT
    andi r24,0x80
    cpi r24,0x80              ;; IF A7 WAS PRESSED
    breq clear                ;; CLEAR
    mov r24,r25               ;; RESTORE CONTENT
    andi r24,0x01
    cpi r24,0x00              ;; CHECK IF A0 WAS PRESSED
    breq main
counter:
    push r20
    push r21
    ldi r24,10
    clr r19
    clr r18
find_minutes:
    cpi r21,10                ;; CHECK MINUTES
    brlo minutes_found        ;; IF NO MORE TENTHS OF MINUTES EXIST
                              ;; WE ARE DONE WITH THEM
    sub r21,r24               ;; DECREASE BY A 10TH
    inc r19                   ;; INCREASE TENTHS OF MINUTES BY 1
    jmp find_minutes
minutes_found:
    cpi r20,10                ;; CHECK SECONDS
    brlo wait                 ;; IF NO MORE TENTHS OF SECONDS EXIST
                              ;; WE ARE DONE WITH THEM
    sub r20,r24               ;; DECREASE BY A TENTH
    inc r18                   ;; INCREMENT TENTHS OF SECONDS
    jmp minutes_found
wait:
    rcall print               ;; PRINT DATA
    ldi r24,low(1000)
    ldi r25,high(1000)
    rcall wait_msec
    pop r21
    pop r20
    inc r20                   ;; INCREMENT UNITS OF SECONDS
    cpi r20,60                ;; CHECK IF THEY ADD UP A MINUTE AS TOTAL
    breq add_minute           ;; ADD IT TO MINUTES UNITS ELSE JUMP TO MAIN
    jmp main
add_minute:
    clr r20                   ;; UNITS OF SECONDS REACHED 60 SO RESET THEM TO Z
    inc r21                   ;; ADD THE UNIT OF MINUTE TO UNITS OF MINUTES
    cpi r21,60                ;; HAVE YOU REACHED THE LIMIT OF UNITS OF MINUTES
    breq reset                ;; IF SO CLEAR UNITS OF MINUTES && GO TO MAIN
    jmp main
reset:
    clr r21
    jmp main
print:
;; INPUT DATA:
;;             r19 - TENTHS OF MINUTES | r21 - SINGLES OF MINUTES
;;		         r18 - TENTHS OF SECONDS | r20 - SINGLES OF SECONDS
    ldi r24,0x01              ;; CLEAR LCD SCREEN
    rcall lcd_command
    ldi r24,low(1530)
    ldi r25,high(1530)
    rcall wait_usec
    mov r24,r19               ;; TENTHS OF MINUTES
    rcall bin_to_ascii        ;; TO ASCII
    rcall lcd_data
    mov r24,r21               ;; SINGLES OF MINUTES
    rcall bin_to_ascii        ;; TO ASCII
    rcall lcd_data
    ldi r24,' '               ;; SPACE
    rcall lcd_data
    ldi r24,'M'               ;; 'MIN'
    rcall lcd_data
    ldi r24,'I'
    rcall lcd_data
    ldi r24,'N'
    rcall lcd_data
    ldi r24,0b00111010        ;; ':'
    rcall lcd_data
    mov r24,r18               ;; TENTHS OF SECONDS
    rcall bin_to_ascii        ;; TO ASCII
    rcall lcd_data
    mov r24,r20               ;; SINGLES OF SECONDS
    rcall bin_to_ascii        ;; TO ASCII
    rcall lcd_data
    ldi r24,' '               ;; SPACE
    rcall lcd_data
    ldi r24,'S'               ;; 'SEC'
    rcall lcd_data
    ldi r24,'E'
    rcall lcd_data
    ldi r24,'C'
    rcall lcd_data
    ret
bin_to_ascii:
;; INPUT: r24 - HOLDS THE BINARY VALUE OF THE DIGIT
;; OUTPUT: r24 - HOLDS THE ASCII VALUE OF THE DIGIT
    push r25
    mov r25,r24
    ldi r24,'0'
    cpi r25,0
    breq end
    ldi r24,'1'
    cpi r25,1
    breq end
    ldi r24,'2'
    cpi r25,2
    breq end
    ldi r24,'3'
    cpi r25,3
    breq end
    ldi r24,'4'
    cpi r25,4
    breq end
    ldi r24,'5'
    cpi r25,5
    breq end
    ldi r24,'6'
    cpi r25,6
    breq end
    ldi r24,'7'
    cpi r25,7
    breq end
    ldi r24,'8'
    cpi r25,8
    breq end
    ldi r24,'9'
    cpi r25,9
    breq end
end:
    pop r25
    ret

.include "routines.inc"
