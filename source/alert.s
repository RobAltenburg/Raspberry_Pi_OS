/******************************************************************************
*	alert.s
*	 by Robert Altenburg
*
*	Some routines for manipulating the LED and flashing out numbers
*
******************************************************************************/

.globl lightOn
lightOn:
	push {lr}
	mov r0,#16
	mov r1,#1
	bl SetGpioFunction

	mov r0,#16
	mov r1,#0
	bl SetGpio
	pop	{pc}

	
lightOn$:			/* local version, when we know the GPIO Function is set */
	push {lr}
	mov r0,#16
	mov r1,#0
	bl SetGpio
	pop {pc}

.globl lightOff
lightOff:
	push {lr}
	mov r0,#16		/* shouldn't need this.  but just to make sure */
	mov r1,#1
	bl SetGpioFunction

	mov r0,#16
	mov r1,#1
	bl SetGpio
	pop	{pc}
	
lightOff$:
	push {lr}
	mov r0,#16
	mov r1,#1
	bl SetGpio
	pop {pc}


.globl flashQuick
flashQuick:
	push {lr}
	bl lightOn
	ldr r0,=250000
	bl Wait			

	bl lightOff$
	ldr r0,=250000
	bl Wait
	pop {pc}

.globl flashShort
flashShort:
	push {lr}
	bl lightOn
	ldr r0,=100000
	bl Wait			

	bl lightOff$
	ldr r0,=1000000
	bl Wait
	pop {pc}

.globl flashLong	
flashLong:
	push {lr}
	bl lightOn
	ldr r0,=1000000
	bl Wait			

	bl lightOff$
	ldr r0,=1000000
	bl Wait
	pop {pc}	
	
.globl flashInt
flashInt:
	push {r4, r5, lr}
	test .req r4
	count .req r5
	mov count, #32
	mov test, r0
next$:	
	tst test, #0x01
	bleq flashShort
	tst test, #0x01
	blne flashLong
	lsr test, #1
	subs count, count, #1
	bne next$
	pop {r4, r5, pc}

	
	