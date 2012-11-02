.global lightOn
lightOn:
	push {lr}
	mov r0,#16
	mov r1,#1
	bl SetGpioFunction

	mov r0,#16
	mov r1,#0
	bl SetGpio
	pop	{pc}

	
lightOn$:				/* local version, when we know the GPIO Function is set */
	push {lr}
	mov r0,#16
	mov r1,#0
	bl SetGpio
	pop {pc}

.global lightOff
lightOff:
	push {lr}
	mov r0,#16	/* shouldn't need this.  but just to make sure */
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

.global flash
flash:
	push {lr}

repeat$:
	bl lightOn
	ldr r0,=250000
	bl Wait			
	
	bl lightOff$
	ldr r0,=250000
	bl Wait

	bl lightOn$
	ldr r0,=500000
	bl Wait			
	
	bl lightOff$
	ldr r0,=500000
	bl Wait

	pop {pc}
	
	