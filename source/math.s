
/*
.global DivideU32
DivideU32:
	result .req r0
	remainder .req r1
	shift .req r2
	current .req r3
	
	clz shift, r1 		@ shift how often we can left shift r1
	clz current, r0		@ current how often we can left shift r0
	subs shift, r3		@ how many shifts needed
	
	lsl current,r1,shift 
	mov remainder,r0
	mov result, #0  @ set result = 0
	
	blt divide_return$	
	
divide_loop$:
	cmp remainder, current
	blt divide_continue$
	
	add result, #1
	subs remainder, current
	lsleq result, shift
	beq divide_return$
	
divide_continue$:	
	subs shift,#1
	lsrge current,#1
	lslge result,#1
	bge divide_loop$	
	
divide_return$:	
	.unreq current
	
	mov pc, lr
	
	.unreq remainder
	.unreq shift
	.unreq result
*/	
	/*
	function DivideU32(r0 is dividend, r1 is divisor)
	set shift to 31
	set result to 0
	while shift ≥ 0
	if dividend ≥ (divisor << shift) then
	set dividend to dividend - (divisor << shift)
	set result to result + 1
	end if
	set result to result << 1
	set shift to shift - 1
	loop
	return (result, dividend)
	end function
	*/
	
	/******************************************************************************
*	maths.s
*	 by Alex Chadwick
*
*	A sample assembly code implementation of the screen04 operating system.
*	See main.s for details.
*
*	maths.s contains the rountines for mathematics.
******************************************************************************/

/* NEW
* DivideU32 Divides one unsigned 32 bit number in r0 by another in r1 and 
* returns the result in r0 and the remainder in r1.
* C++ Signature: u32x2 DivideU32(u32 dividend, u32 divisor);
* This is implemented as binary long division.
*/
.globl DivideU32
DivideU32:
	result .req r0
	remainder .req r1
	shift .req r2
	current .req r3

	clz shift,r1
	clz r3,r0
	subs shift,r3
	lsl current,r1,shift
	mov remainder,r0
	mov result,#0
	blt divideU32Return$
	
	divideU32Loop$:
		cmp remainder,current
		blt divideU32LoopContinue$

		add result,result,#1
		subs remainder,current
		lsleq result,shift 
		beq divideU32Return$

	divideU32LoopContinue$:
		subs shift,#1
		lsrge current,#1
		lslge result,#1
		bge divideU32Loop$
	
divideU32Return$:
	.unreq current
	mov pc,lr
	
	.unreq result
	.unreq remainder
	.unreq shift
