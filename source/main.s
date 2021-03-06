/******************************************************************************
*	main.s
*	 based on the original by Alex Chadwick
*    modifications by Robert Altenburg
*
*	Raspbery Pi operating system workbench
*
*	main.s contains the main operating system, and IVT code.
******************************************************************************/

.equ SCREEN_HEIGHT, 768
.equ SCREEN_WIDTH, 1360
.equ COLOR_DEPTH, 16

/*
* .globl is a directive to our assembler, that tells it to export this symbol
* to the elf file. Convention dictates that the symbol _start is used for the 
* entry point, so this all has the net effect of setting the entry point here.
* Ultimately, this is useless as the elf itself is not used in the final 
* result, and so the entry point really doesn't matter, but it aids clarity,
* allows simulators to run the elf, and also stops us getting a linker warning
* about having no entry point. 
*/
.section .init
.globl _start
_start:

/*
* According to the design of the RaspberryPi, addresses 0x00 through 0x20 
* actually have a special meaning. This is the location of the interrupt 
* vector table. Thus, we shouldn't make the code for our operating systems in 
* this area, as we will need it in the future. In fact the first address we are
* really safe to use is 0x8000.
*/
b main

/*
* This command tells the assembler to put this code at 0x8000.
*/
.section .text

/*
* main is what we shall call our main operating system method. It never 
* returns, and takes no parameters.
* C++ Signature: void main()
*/
main:

/*
* Set the stack point to 0x8000.
*/
	mov sp,#0x8000

	bl flashQuick
	bl flashQuick
	bl flashQuick	
	ldr r0,=1000000
	bl Wait
		
		
		
/* 
* Setup the screen.
*/
	mov r0,#SCREEN_WIDTH /* was 1024 */
	mov r1,#SCREEN_HEIGHT
	mov r2,#COLOR_DEPTH
	bl InitialiseFrameBuffer

/* 
* Check for a failed frame buffer.
*/
	teq r0,#0
	bne noError$
		
	bl lightOn

error$:
		b error$

noError$:

	fbInfoAddr .req r4
	mov fbInfoAddr,r0

/* NEW
* Let our drawing method know where we are drawing to.
*/


	bl SetGraphicsAddress

/*
	ldr r0, =format
	mov r1, #11
	ldr r2, =buffer
	ldr r3,[fbInfoAddr]
	bl FormatString
	
	mov r1, r0
	ldr r0, =buffer
	bl stdio_write
*/

	mov r1, #200
	ldr r0, =format
	bl stdio_write

loop$:
	b loop$

.section .data
format:
.rept 20
	.ascii "---------|"
.endr
formatEnd:
	
buffer:
	.space 256
	
