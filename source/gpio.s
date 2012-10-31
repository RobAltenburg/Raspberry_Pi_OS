.globl GetGpioAddress
.globl SetGpioFunction
.globl SetGpio


GetGpioAddress:
		
	ldr r0,=0x20200000	/* put gpio address in r0 */
	mov pc,lr			/* return */


/**********************************************
 * SetGpioFunction
 * takes:
 *		r0 = GPIO pin number (0 - 53)
 *		r1 = GPIO pin function (0 - 7)
 **********************************************/


SetGpioFunction:
		
	
	cmp r0,#53			/* make sure pin is <= 53 */
	cmpls r1,#7			/* make sure function is <= 7 */
	movhi pc,lr  		/* return if parameters are out of rage*/

	push {lr}			/* preserve lr */
	mov r2,r0			/* move r0 to r2 to preserve it on call */
	bl GetGpioAddress


	functionLoop$:
	cmp r2,#9			/* is r2 higher than 9? */
	subhi r2,#10		/* if so, subtract 10 */
	addhi r0,#4			/* and add four to the gpio address */
	bhi functionLoop$
						/* r0 now points to the gpio address offset for the block
						   of 10 pins.  That address can hold a 32 bit value.
						   each pin is represented by 3 bits. (so eight functions
						   can be encoded for each pin.) */
	
						/* r2 is now the number of the pin (0-9) in the set of 10 */
	add r2, r2,lsl #1	/* same as (r2 * 3), but faster.  r2 is now the number of bits */
	lsl r1,r2			/* left shift the pin function r2 times */
	str r1,[r0]			/* store this in the gpio controller address */
	
	pop {pc}			/* return */
	

SetGpio:

	pinNum .req r0		/* set alias for r0 */
	pinVal .req r1		/* set alias for r1 */
	
	cmp pinNum,#53		/* make sure pin is <= 53 */
	movhi pc,lr			/* if not, return*/
	
	push {lr}		
	
	mov r2,pinNum		/* move pin to... */
	.unreq pinNum		/* forget old alias... */ 
	pinNum .req r2		/* and set new alias */
	
	bl GetGpioAddress	/* put gpio address in r0 */
	gpioAddr .req r0	/* set an alias */
	
	
	/* GPIO controllers have two set of four bytes each.
	   The first controls 32 pins, the second set controls
	   22 pins. */
			
	pinBank .req r3
	lsr pinBank,pinNum,#5	/* Which set?  pinBank >> (pinNum div 32) */
	lsl pinBank,#2			/* rs(pinBank * 4) */
							/* pinBank is now 0 or 4 */
	add gpioAddr,pinBank	/* add it to gpioAddr */
	
	.unreq pinBank			/* forget the alias */
	
 
	and pinNum,#31			/* look at the last 5 bits of pinNum */
	setBit .req r3			/* alias setBit... */
	mov setBit,#1			/* set it to one */
	lsl setBit,pinNum		/* move the bit into place */
	.unreq pinNum           /* forget the alias */
	
	teq pinVal,#0			/* is the pinval 0? */
	.unreq pinVal
	streq setBit,[gpioAddr,#40]	/* if so, turn pin off */
	strne setBit,[gpioAddr,#28] /* else, turn pin on */
	.unreq setBit
	.unreq gpioAddr
	pop {pc}				/* return */
		
