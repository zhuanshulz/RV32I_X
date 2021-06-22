	.text
	.align	2
	.globl	func1
func1:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a4,-20(s0)
	li	a5,1
	bne	a4,a5,.L2
	li	a5,1
	j	.L1
.L2:
	lw	a4,-20(s0)
	li	a5,1
	ble	a4,a5,.L4
	lw	a5,-20(s0)
	addi	a5,a5,-1
	mv	a0,a5
	call	func1
	mv	a4,a0
	lw	a5,-20(s0)
	mul	a5,a4,a5
	j	.L1
.L4:
.L1:
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.align	2
	.globl	func2
func2:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a4,-36(s0)
	li	a5,1
	beq	a4,a5,.L6
	lw	a4,-36(s0)
	li	a5,2
	bne	a4,a5,.L7
.L6:
	li	a5,1
	j	.L8
.L7:
	li	a5,2
	sw	a5,-20(s0)
	li	a5,1
	sw	a5,-24(s0)
	li	a5,1
	sw	a5,-28(s0)
	j	.L9
.L10:
	lw	a4,-28(s0)
	lw	a5,-24(s0)
	add	a5,a4,a5
	sw	a5,-28(s0)
	lw	a4,-28(s0)
	lw	a5,-24(s0)
	sub	a5,a4,a5
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L9:
	lw	a4,-20(s0)
	lw	a5,-36(s0)
	blt	a4,a5,.L10
	lw	a5,-28(s0)
.L8:
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.align	2
	.globl	main
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,10
	sw	a5,-20(s0)
	lw	a0,-20(s0)
	call	func1
	sw	a0,-24(s0)
	lw	a0,-20(s0)
	call	func2
	sw	a0,-28(s0)
	lw	a4,-24(s0)
	lw	a5,-28(s0)
	sw  a4,0(zero)
	sw  a5,4(zero)