;-------------------------------------------------------------------------------
; Assembler for students 
;-------------------------------------------------------------------------------

	THUMB
;	AREA    |.text|, CODE, READONLY
	AREA  |.data|, CODE, READWRITE, ALIGN=4
        EXPORT  ledSend
		EXPORT  ledsRGB
			
resetTime	EQU	0			
NopTime		EQU 1
T0HTime		EQU 4;38
T0LTime		EQU 86
T1HTime		EQU 110;76
T1LTime		EQU 40;65
TRESTime 	EQU 5400
	
nBits 		EQU 24
	
nopLoop	RN r4

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
	push	{nopLoop,lr}
	bl		bitHigh
	mov 	nopLoop, #T1HTime		; reset the loop counter
whileT1H
	subs 	nopLoop, #NopTime		;decremente loop
	bne		whileT1H
	
	bl 		bitLow
	mov		nopLoop, #T1LTime		; reset the loop counter
whileT1L
	subs	nopLoop, #NopTime		;decremente loop
	bne		whileT1L
	pop     {nopLoop,pc}
		ENDP
;-------------------------------------------------------------------------------
zero	PROC
	push	{nopLoop,lr}
	bl		bitHigh
	mov 	nopLoop, #T0HTime		; reset the loop counter
whileT0H
	subs 	nopLoop, #NopTime		;decremente loop
	bne		whileT0H
	
	bl 		bitLow
	mov		nopLoop, #T0LTime		; reset the loop counter
whileT0L
	subs	nopLoop, #NopTime		;decremente loop
	bne		whileT0L
	pop     {nopLoop,pc}
		ENDP
;-------------------------------------------------------------------------------
ledSend	PROC
	push	{r9,lr}
	mov r9,r0
	mov	r2,#0x800000
while24bits	
	ands r0, r9, r2					;r0 AND 0x01 stored into r2
	beq zeroBit
	bl   one
	b nxtBit
zeroBit
	bl  zero
nxtBit
	lsrs  r2, r2, #1						;shift the parameter to the right
	bne while24bits
	pop		{r9,pc}
		ENDP
;-------------------------------------------------------------------------------
ledsRGB PROC
	push {r4, r5, r6, r7, r8, lr}
	mov r4, r0
	mov r5, r1
	mov r6, r2
	mov r7, r3
	ldr r8,[sp,#24]
	
	cmp r0,#1
	beq	LED1
	cmp r0,#2
	beq	LED2
	cmp r0,#3
	beq	LED3
	cmp r0,#4
	beq	LED4
	
	
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

endRGB
	
	
	pop {r4, r5, r6, r7, r8, pc}
	ENDP
		
	END