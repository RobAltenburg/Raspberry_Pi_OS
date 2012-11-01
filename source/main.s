/******************************************************************************
*	main.s
******************************************************************************/

.section .init
.globl _start

_start:
b main

.section .text

main:

	mov sp, #0x80000

	pinNum .req r0
	pinFunc .req r1
	mov pinNum,#16
	mov pinFunc,#1
	bl SetGpioFunction
	.unreq pinNum
	.unreq pinFunc
	

loop$:

	/* turn pin on */
	pinNum .req r0
	pinVal .req r1
	mov pinNum,#16
	mov pinVal,#0
	bl SetGpio
	.unreq pinNum
	.unreq pinVal

	ldr r0,=500000
	bl delay

	/* turn pin off */
	pinNum .req r0
	pinVal .req r1
	mov pinNum,#16
	mov pinVal,#1
	bl SetGpio
	.unreq pinNum
	.unreq pinVal

	ldr r0,=500000
	bl delay

b loop$
