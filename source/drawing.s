
.section .data
.align 1
foreColour:
.hword 0xFFFF

.align 2
graphicsAddress:
.int 0

.section .text

.globl SetForeColour
SetForeColour:
    cmp r0,#0x10000
    movhs pc,lr
    ldr r1,=foreColour
    strh r0,[r1]
    mov pc,lr

.globl SetGraphicsAddress
SetGraphicsAddress:
    ldr r1,=graphicsAddress
    str r0,[r1]
    mov pc,lr


.globl DrawPixel
DrawPixel:
	px .req r0
	py .req r1
	addr .req r2
	
	ldr addr,=graphicsAddress   /* get the graphics address */
	ldr addr,[addr]
	
	height .req r3				
	ldr height,[addr,#4]	/* height is at offset 4 in frame buffer */
	sub height,#1
	
	cmp py,height			/* exit if height > py */
	movhi pc,lr
	.unreq height

	width .req r3
	ldr width,[addr,#0]		/* width is at offset 0 in frame buffer */
	sub width,#1
	
	cmp px,width 			/* exit if width > px */
	movhi pc,lr
	
	/* compute the address -- specific to hi color */
	ldr addr,[addr,#32]		/* load GPU pointer */
	add width,#1
	mla px,py,width,px		
	.unreq width
	.unreq py
	add addr, px,lsl #1
	.unreq px
	
	/* get the color -- specific to hi color */
	fore .req r3
	ldr fore,=foreColour
	ldrh fore,[fore]
	
	/* set the address to a color -- specific to hi color */	
	strh fore,[addr]
	.unreq fore
	.unreq addr
	mov pc,lr			/* return */

/* Bresenham's Algorithm for drawing lines  */

.globl DrawLine	
DrawLine:
	
	push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}  /* preserve high registers */
	x0 .req r9
	x1 .req r10
	y0 .req r11
	y1 .req r12

	mov x0,r0
	mov x1,r2
	mov y0,r1
	mov y1,r3
	
	dx .req r4
	dyn .req r5 /* Note that we only ever use -deltay, so I store its negative for speed. (hence dyn) */
	sx .req r6
	sy .req r7
	err .req r8
	
	/* if x1 > x0 then */
	cmp x1, x0			/* test x1 - xo */
	subgt dx, x1, x0	/* set deltax to x1 - x0 */
	movgt sx, #1		/* set stepx to +1 */

	/* otherwise */
	suble dx, x0, x1	/* set deltax to x0 - x1 */
	movle sx, #-1		/* set stepx to -1 */
	/* end if */

	/* if y1 > y0 then */
	cmp y1, y0			/* test y1 - yo */
	subgt dyn, y0, y1	/* set deltay(neg) to y1 - y0 */
	movgt sy, #1		/* set stepy to +1 */

	/* otherwise */
	suble dyn, y0, y1	/* set deltay to y0 - y1 */
	movle sy, #-1		/* set stepy to -1 */
	/* end if */

	add err, dx, dyn		/* set error to deltax - deltay */


	add x1, sx	/* until x0 = x1 + stepx or y0 = y1 + stepy */
	add y1, sy

pixelloop$:	
	teq x0, x1
	teqne y0, y1
	popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}  /* if so, return */
	
	mov r0, x0  	/* setPixel(x0, y0) */
	mov r1, y0
	bl DrawPixel
	
	cmp dyn, err, lsl #1 	/* if error × 2 ≥ -deltay then */
	addle x0, sx			/* set x0 to x0 + stepx */
	addle err, dyn			/* set error to error - deltay */
							/* end if */
	
	cmp dx, err, lsl #1		/* if error × 2 ≤ deltax then */ 
	addge y0, sy			/* set y0 to y0 + stepy */
	addge err, dx			/* set error to error + deltax */
							/* end if */
	b pixelloop$

	.unreq x0
	.unreq x1
	.unreq y0
	.unreq y1
	.unreq dx
	.unreq dyn
	.unreq sx
	.unreq sy
	.unreq err
