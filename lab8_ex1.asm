;=================================================
; Name: Benjamin Denzler
; Email: bdenz001@ucr.edu
;
; Lab: lab 8, ex1
; Lab section: 023
; TA: Dipan Shaw
;
;=================================================

.orig x3000

; Test harness
;-------------------------------------------------
LD R5, loadFillValuePtr			; R5 <- subroutine address
JSRR R5							; Execute subroutine

ADD R6, R6, #1				; Add 1 to R6

LD R5, outputAsDecimalPtr		; R5 <- subroutine address
JSRR R5							; Execute subroutine

HALT

; Test harness local data
;-------------------------------------------------
inputCharLoc		.FILL		x3100	; Address to store user input char
loadFillValuePtr	.FILL		x3200	; Address of subroutine LOAD_FILL_VALUE_3200
outputAsDecimalPtr	.FILL		x3400	; Address of subroutine OUTPUT_AS_DECIMAL_3400

; Subroutines
;=================================================
; Subroutine: LOAD_FILL_VALUE_3200
; Parameter: None
; Postcondition: Hardcoded .FILL value loaded into R6
; Return Value (R6): Binary representation of .FILL value
;=================================================
.END
.orig x3200

; (1) Backup the affected registers
ST R7, backup_r7_3200	; Backup R7 (used for RET)

; (2) Subroutine instructions
LD R6, testNumber

; (3) Restore backed up registers
LD R7, backup_r7_3200

; (4) Return
ret

; Local data for LOAD_FILL_VALUE_3200
;testNumber 			.FILL		#-21234
testNumber 			.FILL		#32767

;backup_r0_3200		.BLKW		#1
;backup_r1_3200		.BLKW		#1
;backup_r2_3200		.BLKW		#1
;backup_r3_3200		.BLKW		#1
;backup_r4_3200		.BLKW		#1
;backup_r5_3200		.BLKW		#1
;backup_r6_3200		.BLKW		#1
backup_r7_3200		.BLKW		#1

;=================================================
;				END SUBROUTINE
;=================================================

;=================================================
; Subroutine: OUTPUT_AS_DECIMAL_3400
; Parameter (R6): R6 contains some hard-coded binary value
; Postcondition: Binary value in R6 is outputted as
;	its decimal representation
; Return Value: None, only console output
;=================================================
.END
.orig x3400

; (1) Backup the affected registers
ST R1, backup_r1_3400
ST R2, backup_r2_3400
ST R3, backup_r3_3400
ST R3, backup_r3_3400
ST R4, backup_r4_3400
ST R5, backup_r5_3400
ST R6, backup_r6_3400
ST R7, backup_r7_3400

; (2) Subroutine instructions
AND R1, R1, x0 			; Clear R1, will count # of each digit
AND R4, R4, x0			; Clear R4, will store # of digits outputted
ADD R5, R6, #0			; R5 <- R6 (R5 gets copy of value)

; Do we need '-'?
ADD R5, R5, #0			; Make R5 (our binary #) LMR
BRzp TEN_K				; If value is positive, don't output '-'
LD R0, negative_sign	; R0 <- '-'
OUT						; Output negative sign
NOT R5, R5				; Negate R5 for 2's complement
ADD R5, R5, #1			; Add 1, which flips the sign of R5 (now positive)

;-------------------------------------------------

; How many 10,000's?
TEN_K
LD R2, ten_thousand		; R2 <- #-10,000
TEN_K_LOOP
	STI R5, temp_result		; Store current value at x3500 so we can recall it
	ADD R5, R5, R2			; R5 = R5 - #10,000
	BRn END_TEN_K_LOOP		; If result is negative, we're done counting
	ADD R1, R1, #1			; If result is zero or positive, increment digit counter
	BR TEN_K_LOOP			; Repeat until result is negative
END_TEN_K_LOOP

AND R3, R3, x0			; Clear R3, used to store digit to output
ADD R1, R1, #0			; Make R1 (digit counter) LMR
BRz MAYBE_ZERO_1		; If we have 0 of a digit, consider if leading or not

OUTPUT_TEN_K
; Digit count is at least 1 if we get here
ADD R3, R1, #0			; R3 <- R1 (copy R1 to R3)
LD R2, ascii_offset		; R2 <- ASCII offset x30
ADD R3, R3, R2			; Convert output digit to ASCII
ADD R0, R3, #0			; R0 <- output digit (gets copy)
OUT						; Output digit
ADD R4, R4, #1			; Increment # digits outputted
BR END_MAYBE_ZERO_1		; Skip to next place value

MAYBE_ZERO_1
	ADD R4, R4, #0			; Make R4 (# digits outputted) LMR
	BRz END_MAYBE_ZERO_1	; If nothing has been outputted, don't echo '0'
	LD R0, zero_ascii		; R0 <- x30 ('0')
	OUT						; Output '0'
END_MAYBE_ZERO_1
LDI R5, temp_result		; R5 <- value stored in temp_result
AND R1, R1, x0			; Clear R1 for next digit

;-------------------------------------------------

; How many 1,000's?
LD R2, one_thousand		; R2 <- #-1,000
ONE_K_LOOP
	STI R5, temp_result		; Store current value at x3500 so we can recall it
	ADD R5, R5, R2			; R5 = R5 - #1,000
	BRn END_ONE_K_LOOP		; If result is negative, we're done counting
	ADD R1, R1, #1			; If result is zero or positive, increment digit counter
	BR ONE_K_LOOP			; Repeat until result is negative
END_ONE_K_LOOP

AND R3, R3, x0			; Clear R3, used to store digit to output
ADD R1, R1, #0			; Make R1 (digit counter) LMR
BRz MAYBE_ZERO_2		; If we have 0 of a digit, consider if leading or not

OUTPUT_ONE_K
; Digit count is at least 1 if we get here
ADD R3, R1, #0			; R3 <- R1 (copy R1 to R3)
LD R2, ascii_offset		; R2 <- ASCII offset x30
ADD R3, R3, R2			; Convert output digit to ASCII
ADD R0, R3, #0			; R0 <- output digit (gets copy)
OUT						; Output digit
ADD R4, R4, #1			; Increment # digits outputted
BR END_MAYBE_ZERO_2		; Skip to next place value

MAYBE_ZERO_2
	ADD R4, R4, #0			; Make R4 (# digits outputted) LMR
	BRz END_MAYBE_ZERO_2	; If nothing has been outputted, don't echo '0'
	LD R0, zero_ascii		; R0 <- x30 ('0')
	OUT						; Output '0'
END_MAYBE_ZERO_2
LDI R5, temp_result		; R5 <- value stored in temp_result
AND R1, R1, x0			; Clear R1 for next digit

;-------------------------------------------------

; How many 100's?
LD R2, one_hundred		; R2 <- #-100
ONE_H_LOOP
	STI R5, temp_result		; Store current value at x3500 so we can recall it
	ADD R5, R5, R2			; R5 = R5 - #100
	BRn END_ONE_H_LOOP		; If result is negative, we're done counting
	ADD R1, R1, #1			; If result is zero or positive, increment digit counter
	BR ONE_H_LOOP			; Repeat until result is negative
END_ONE_H_LOOP

AND R3, R3, x0			; Clear R3, used to store digit to output
ADD R1, R1, #0			; Make R1 (digit counter) LMR
BRz MAYBE_ZERO_3		; If we have 0 of a digit, consider if leading or not

OUTPUT_ONE_H
; Digit count is at least 1 if we get here
ADD R3, R1, #0			; R3 <- R1 (copy R1 to R3)
LD R2, ascii_offset		; R2 <- ASCII offset x30
ADD R3, R3, R2			; Convert output digit to ASCII
ADD R0, R3, #0			; R0 <- output digit (gets copy)
OUT						; Output digit
ADD R4, R4, #1			; Increment # digits outputted
BR END_MAYBE_ZERO_3		; Skip to next place value

MAYBE_ZERO_3
	ADD R4, R4, #0			; Make R4 (# digits outputted) LMR
	BRz END_MAYBE_ZERO_3	; If nothing has been outputted, don't echo '0'
	LD R0, zero_ascii		; R0 <- x30 ('0')
	OUT						; Output '0'
END_MAYBE_ZERO_3
LDI R5, temp_result		; R5 <- value stored in temp_result
AND R1, R1, x0			; Clear R1 for next digit

;-------------------------------------------------

; How many 10's?
LD R2, ten				; R2 <- #-10
TEN_LOOP
	STI R5, temp_result		; Store current value at x3500 so we can recall it
	ADD R5, R5, R2			; R5 = R5 - #10
	BRn END_TEN_LOOP		; If result is negative, we're done counting
	ADD R1, R1, #1			; If result is zero or positive, increment digit counter
	BR TEN_LOOP			; Repeat until result is negative
END_TEN_LOOP

AND R3, R3, x0			; Clear R3, used to store digit to output
ADD R1, R1, #0			; Make R1 (digit counter) LMR
BRz MAYBE_ZERO_4		; If we have 0 of a digit, consider if leading or not

OUTPUT_TEN
; Digit count is at least 1 if we get here
ADD R3, R1, #0			; R3 <- R1 (copy R1 to R3)
LD R2, ascii_offset		; R2 <- ASCII offset x30
ADD R3, R3, R2			; Convert output digit to ASCII
ADD R0, R3, #0			; R0 <- output digit (gets copy)
OUT						; Output digit
ADD R4, R4, #1			; Increment # digits outputted
BR END_MAYBE_ZERO_4		; Skip to next place value

MAYBE_ZERO_4
	ADD R4, R4, #0			; Make R4 (# digits outputted) LMR
	BRz END_MAYBE_ZERO_4	; If nothing has been outputted, don't echo '0'
	LD R0, zero_ascii		; R0 <- x30 ('0')
	OUT						; Output '0'
END_MAYBE_ZERO_4
LDI R5, temp_result		; R5 <- value stored in temp_result
AND R1, R1, x0			; Clear R1 for next digit

;-------------------------------------------------

; Now we only have 1 digit (1's place), so just output it!
ADD R0, R5, #0			; R0 <- R5 (copy value into R0)
LD R2, ascii_offset		; R2 <- ASCII offset x30
ADD R0, R0, R2			; Convert R0's number to ASCII
OUT						; Output last digit

;-------------------------------------------------

LD R0, newline			; R0 <- newline char
OUT						; Output newline

; (3) Restore backed up registers
LD R0, backup_r0_3400
LD R1, backup_r1_3400
LD R2, backup_r2_3400
LD R3, backup_r3_3400
LD R4, backup_r4_3400
LD R5, backup_r5_3400
LD R6, backup_r6_3400
LD R7, backup_r7_3400

; (4) Return
ret

; Local data for OUTPUT_AS_DECIMAL_3400
temp_result			.FILL		x3500
ascii_offset		.FILL		x30
negative_sign		.FILL		x2D
zero_ascii			.FILL		x30
newline				.FILL		xA
ten_thousand		.FILL		#-10000
one_thousand		.FILL		#-1000
one_hundred			.FILL		#-100
ten 				.FILL		#-10
one					.FILL		#-1

backup_r0_3400		.BLKW		#1
backup_r1_3400		.BLKW		#1
backup_r2_3400		.BLKW		#1
backup_r3_3400		.BLKW		#1
backup_r4_3400		.BLKW		#1
backup_r5_3400		.BLKW		#1
backup_r6_3400		.BLKW		#1
backup_r7_3400		.BLKW		#1

;=================================================
;				END SUBROUTINE
;=================================================

.END