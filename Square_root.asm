.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc			;library containing WriteString, ReadFloat, WriteFloat procedures
								;provided by Kip Irvine in his book 'Assembly Language for x86 processors'
		
;--------------------------------------------------------------
; Written by David Della Rossa 
; Simple 32-bit program written in assembly language for x86, 
; using MASM Assembler to calculate the square root of a real number
; using the Heron's Algorithm, as explained in the course
; Algorithms and Data Structures of the UoL BSc Computer Science degree.
;--------------------------------------------------------------

.data
	message1 BYTE "Please enter a real number: ", 0
	message2 BYTE "The square root is: ", 0

	precision REAL8 0.0001		;precision
	square REAL8 ?				;value we want to calculate the square root
	lowlimit REAL8 1.0			;lowlimit of the Heron's algorithm; initially 1
	highlimit REAL8 ?			;highlimit of the Heron's algorithm; initially set to the square value
	divisorByTwo REAL8 2.0		;just the value 2
	mean REAL8 ?				;placeholder for the mean of lowlimit and highlimit. Eventually it contains the wanted value
	bin REAL8 ?					;variable used only to extract unwanted value from the FPU Stack
.code
main proc
	finit						;initialize FPU

	mov edx, OFFSET message1	;move message in edx - needed by WriteString
	CALL WriteString			;procedure that writes a message on the console
	call ReadFloat				;read the number and add it to the FPU stack
	fst square					;save the read value in square
	fst highlimit				;save it in highlimit too

L1:	fadd lowlimit				;add lowlimit to highlimit;
	fdiv divisorByTwo			;divide the result by 2. 
	fst mean					;save the calculated value into mean in memory

	fsub lowlimit				;Calculate half the interval subtracting lowlimit from mean - used as error value
	fld precision				;load the precision value in the stack
	fcomip st(0), st(1)			; compare the error with the wanted precision
	jnb quit					; if the error is lower than precision jump to quit 

	fstp bin					;this is meant only to empty out the stack from the residual value
								
	fld square					;load square (the initial value) into the stack
	fdiv mean					;divide square by mean 
							
	fstp lowlimit				;save the new lowlimit

	fld mean					;load the mean value
	fst highlimit				;and assign the value to highlight

	jmp L1						;jump to L1
	
quit:
	fld mean					;retrieve mean from memory
	call WriteFloat				;write the result in the console

	invoke	ExitProcess, 0		;exit process
main endp

end main
