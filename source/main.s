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

    /* set up the frame buffer */
    mov r0,#1024
    mov r1,#768
    mov r2,#16
    bl InitialiseFrameBuffer

    teq r0,#0       /* check if the above returned zero */
    bne noError$

error$:             /* if there is an error, flash the ok light */
    mov r0,#16
	mov r1,#0
	bl SetGpioFunction
    ldr r0,=250000
    bl wait
    mov r0,#16
    mov r1,#1
    bl SetGpioFunction
    ldr r0,=250000
    bl wait
    b error$

noError$:

    fbInfoAddr .req r4  /* mov and name our info register */
    mov fbInfoAddr,r0

render$:
    fbAddr .req r3
    ldr fbAddr,[fbInfoAddr,#32]

    colour .req r0
    y .req r1
    mov y,#768
    drawRow$:
    x .req r2
    mov x,#1024

drawPixel$:
    strh colour,[fbAddr]
    add fbAddr,#2
    sub x,#1
    teq x,#0
    bne drawPixel$

    sub y,#1
    add colour,#1
    teq y,#0
    bne drawRow$

    b render$

    .unreq fbAddr
    .unreq fbInfoAddr
