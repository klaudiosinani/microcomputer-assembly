MVI L,FFH ;; Initialise L
;; our counter
LXI B,03E8H ;; Will cause 1 sec
;; delay with DELB
MVI E,00H ;; Flag whether we
;; want to
;; count forward or
;; backward
LOAD:
LDA 2000H ;; Input
MOV D,A ;; save the input
ANI 80H
JZ LOAD ;; Check the MSB
;; If we are ok
;; go on
MOV A,D
ANI 0FH ;; Our fracture
;; is decribed
;; in the 4 LSBs
MOV D,A ;; save our fracture
MOV A,E ;; Save to A the
;; current direction
ANA A
JNZ BACK ;; Which direction?
FORWARD:
MOV A,L ;; L is our counter
ORI F0H ;; Only the 4 LSB to
;; be displayed
STA 3000H ;; Display
CALL DELB
DCR L ;; Increase the counter
;; using negative logic
MOV A,L
CMA
CMP D ;; Check if have s
;; urpassed our fracture
JZ CHANGEDOWN ;; if we have its time
;; to count backward
JMP LOAD ;; Check again if
;; 4 MSB are fine
BACK:
MOV A,L ;; L is our counter
ORI F0H ;; We want the 4 LSB to
;; be displayed. Negative
;; logic: we put 1 to
;; the 4 MSBs
STA 3000H
CALL DELB ;; Display output
INR L ;; Decrease the counter
;; using negative logic
MOV A,L
CMA
CPI 00H ;; Our fracture is 0
JZ CHANGEUP
JMP LOAD
CHANGEDOWN:
MVI E,01H ;; We will count down
;; in the next loop
JMP LOAD
CHANGEUP:
MVI E,00H ;; We will count up
;; in the next loop
JMP LOAD
END
