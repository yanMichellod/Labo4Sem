;-------------------------------------------------------------------------------
; Assembler for students 
;-------------------------------------------------------------------------------

	THUMB
;	AREA    |.text|, CODE, READONLY
	AREA  |.data|, CODE, READWRITE, ALIGN=4
        EXPORT  ledSend
		EXPORT  ledsRGB
		EXPORT manyLedRGB
			
resetTime	EQU	0						
NopTime		EQU 1
T0HTime		EQU 4
T0LTime		EQU 86
T1HTime		EQU 110
T1LTime		EQU 40
TRESTime 	EQU 5400
	
nBits 		EQU 24			;one led needs 24 bits to work
	
nopLoop	RN r4				;used to wait some time

;-------------------------------------------------------------------------------
bitLow 	PROC
	push	{lr}
	ldr		r0,=0x40020014		; address of PA0 to LEDs
	mov		r1,#0				; value will be '0'
	str     r1,[r0]				; place data on leds
	pop     {pc}
		ENDP

;-------------------------------------------------------------------------------
bitHigh PROC
	push	{lr}
	ldr		r0,=0x40020014		; address of PA0 to LEDs
	mov		r1,#1				; value will be '1'
	str     r1,[r0]				; place data on leds
	pop     {pc}
		ENDP 
;-------------------------------------------------------------------------------
one		PROC
	push	{nopLoop,lr}			;save the register  we will use on the stack
	bl		bitHigh					;call the function to set a high state on the pin
	mov 	nopLoop, #T1HTime		;prepare the counter
whileT1H
	subs 	nopLoop, #NopTime		;decrement loop
	bne		whileT1H				;loop as long as it's not 0 
	
	bl 		bitLow					;call the function to set a low state on the pin
	mov		nopLoop, #T1LTime		;prepare the counter
whileT1L
	subs	nopLoop, #NopTime		;decrement loop
	bne		whileT1L				;loop as long as it's not 0
	pop     {nopLoop,pc}			;restore the register from the stack
		ENDP
;-------------------------------------------------------------------------------
zero	PROC
	push	{nopLoop,lr}			;save the register  we will use on the stack
	bl		bitHigh					;call the function to set a high state on the pin
	mov 	nopLoop, #T0HTime		;prepare the counter
whileT0H
	subs 	nopLoop, #NopTime		;decrement loop
	bne		whileT0H				;loop as long as it's not 0
	
	bl 		bitLow					;call the function to set a low state on the pin
	mov		nopLoop, #T0LTime		;prepare the counter
whileT0L
	subs	nopLoop, #NopTime		;decremente loop
	bne		whileT0L				;loop as long as it's not 0
	pop     {nopLoop,pc}			;restore the register from the stack
		ENDP
;-------------------------------------------------------------------------------
ledSend	PROC
	push	{r9,lr}					;save the register  we will use on the stack
	mov r9,r0						;save the 32 bits parameter inside r9, because r0 will be modified during the code execution
	mov	r2,#0x800000				;prepare the mask : 0x00800000, wich means that we start from the bit 23
while24bits	
	ands r0, r9, r2					;parameter AND mask -> r0, update flags
	beq zeroBit						;if it's equal to zero -> it sets a zero pn the pin
	bl   one						;if not, it sets a one
	b nxtBit						;when it comes back here, we must jump over the zero branch and go directly to nxtBit label
zeroBit
	bl  zero						;set a zero on the pin
nxtBit
	lsrs  r2, r2, #1				;shift the mask to the right until the mask is 0x00000000
	bne while24bits					;as long as it's not 0x00000000, start the comparison again
	pop		{r9,pc}					;restore the register from the stack
		ENDP
;-------------------------------------------------------------------------------
; work with 5 LEDs 
;------------------------------------------------------------------------------
ledsRGB PROC
	push {r4, r5, r6, r7, r8, r9, lr}	;save the register  we will use on the stack
	mov r4, r0						;save parameter 1
	mov r5, r1						;save parameter 2
	mov r6, r2						;save parameter 3
	mov r7, r3						;save parameter 4
	ldr r8,[sp,#28]					;save parameter 5 from the stack, with a 10*4 bytes offset, because of the registers we saved on the stack on line 91
	ldr r9,[sp,#32]					;save parameter 6 from the stack, with a 10*4 bytes offset, because of the registers we saved on the stack on line 91
	
	
	cmp r0,#1						;get the amount of leds to set and branch to the right label
	beq	LED1
	cmp r0,#2
	beq	LED2
	cmp r0,#3
	beq	LED3
	cmp r0,#4
	beq	LED4
	cmp r0,#5
	beq LED5
	
LED1
	mov r0, r5
	bl ledSend
	b endRGB
	
LED2
	mov r0, r5
	bl ledSend
	mov r0, r6
	bl ledSend
	b endRGB
	
LED3
	mov r0, r5
	bl ledSend
	mov r0, r6
	bl ledSend
	mov r0, r7
	bl ledSend
	b endRGB

LED4
	mov r0, r5
	bl ledSend
	mov r0, r6
	bl ledSend
	mov r0, r7
	bl ledSend
	mov r0, r8
	bl ledSend
	b endRGB
	
LED5
	mov r0, r5
	bl ledSend
	mov r0, r6
	bl ledSend
	mov r0, r7
	bl ledSend
	mov r0, r8
	bl ledSend
	mov r0, r9
	bl ledSend

endRGB
		
	pop {r4, r5, r6, r7, r8, r9, pc}			;restore the register from the stack
	ENDP
		
;-------------------------------------------------------------------------------
; work with 5 LEDs 
;------------------------------------------------------------------------------
manyLedRGB PROC
	push {r4, r5,r6, lr}	;save the register  we will use on the stack
	mov r4, r0						;save parameter 1
	mov r5, r1						;save parameter 2
	mov r6, #0

	cmp r4, #0
	beq endloop
loopLed
	ldr r0,[r5, r6]
	bl ledSend
	add r6, #4
	subs r4, #1
	bne loopLed

endloop
		
	pop {r4, r5, r6, pc}			;restore the register from the stack
	ENDP
		
	END