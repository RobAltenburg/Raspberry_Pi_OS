
.globl getSysTimer
.globl getTime
.globl delay

getSysTimer:
	ldr r0,=0x20003000
	mov pc, lr	
	
getTime:
	push {lr}
	bl getSysTimer
	ldrd r0, r1, [r0, #4]
	pop {pc}
	
delay:
	push {lr}
	waitTime .req r2
	mov waitTime, r0
	
	bl getTime
	start .req r3
	mov start, r0
	
loop$:
	bl getTime
	split .req r1
	sub split, r0, start
	cmp split, waitTime
	.unreq split
	bls loop$
	
	.unreq waitTime
	.unreq start
	
	pop {pc}
	