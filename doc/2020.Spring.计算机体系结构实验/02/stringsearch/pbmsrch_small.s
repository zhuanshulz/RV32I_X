	.file	"pbmsrch_small.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.local	table
	.comm	table,1024,4
	.local	len
	.comm	len,4,4
	.local	findme
	.comm	findme,4,4
	.align	2
	.globl	my_strlen
	.type	my_strlen, @function
my_strlen:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	j	.L2
.L3:
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a5,-36(s0)
	addi	a4,a5,1
	sw	a4,-36(s0)
	lbu	a5,0(a5)
	bne	a5,zero,.L3
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	my_strlen, .-my_strlen
	.align	2
	.globl	my_strncmp
	.type	my_strncmp, @function
my_strncmp:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	a2,-44(s0)
	sw	zero,-20(s0)
	j	.L6
.L11:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a4,0(a5)
	lw	a5,-20(s0)
	lw	a3,-40(s0)
	add	a5,a3,a5
	lbu	a5,0(a5)
	bleu	a4,a5,.L7
	li	a5,1
	j	.L8
.L7:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a4,0(a5)
	lw	a5,-20(s0)
	lw	a3,-40(s0)
	add	a5,a3,a5
	lbu	a5,0(a5)
	bgeu	a4,a5,.L9
	li	a5,-1
	j	.L8
.L9:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	beq	a5,zero,.L10
	lw	a5,-20(s0)
	lw	a4,-40(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	beq	a5,zero,.L10
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L6:
	lw	a4,-20(s0)
	lw	a5,-44(s0)
	blt	a4,a5,.L11
.L10:
	li	a5,0
.L8:
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	my_strncmp, .-my_strncmp
	.align	2
	.globl	init_search
	.type	init_search, @function
init_search:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a0,-36(s0)
	call	my_strlen
	mv	a4,a0
	lui	a5,%hi(len)
	sw	a4,%lo(len)(a5)
	sw	zero,-20(s0)
	j	.L13
.L14:
	lui	a5,%hi(len)
	lw	a4,%lo(len)(a5)
	lui	a5,%hi(table)
	addi	a3,a5,%lo(table)
	lw	a5,-20(s0)
	slli	a5,a5,2
	add	a5,a3,a5
	sw	a4,0(a5)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L13:
	lw	a4,-20(s0)
	li	a5,255
	bleu	a4,a5,.L14
	sw	zero,-20(s0)
	j	.L15
.L16:
	lui	a5,%hi(len)
	lw	a5,%lo(len)(a5)
	mv	a4,a5
	lw	a5,-20(s0)
	sub	a5,a4,a5
	addi	a3,a5,-1
	lw	a4,-36(s0)
	lw	a5,-20(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	mv	a2,a5
	lui	a5,%hi(table)
	addi	a4,a5,%lo(table)
	slli	a5,a2,2
	add	a5,a4,a5
	sw	a3,0(a5)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L15:
	lui	a5,%hi(len)
	lw	a5,%lo(len)(a5)
	mv	a4,a5
	lw	a5,-20(s0)
	bltu	a5,a4,.L16
	lui	a5,%hi(findme)
	lw	a4,-36(s0)
	sw	a4,%lo(findme)(a5)
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	init_search, .-init_search
	.align	2
	.globl	strsearch
	.type	strsearch, @function
strsearch:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	sw	s1,36(sp)
	sw	s2,32(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lui	a5,%hi(len)
	lw	a5,%lo(len)(a5)
	addi	a5,a5,-1
	mv	s1,a5
	lw	a0,-36(s0)
	call	my_strlen
	mv	a5,a0
	sw	a5,-20(s0)
	j	.L18
.L21:
	add	s1,s1,s2
.L19:
	lw	a5,-20(s0)
	bgeu	s1,a5,.L20
	lw	a5,-36(s0)
	add	a5,a5,s1
	lbu	a5,0(a5)
	mv	a3,a5
	lui	a5,%hi(table)
	addi	a4,a5,%lo(table)
	slli	a5,a3,2
	add	a5,a4,a5
	lw	a5,0(a5)
	mv	s2,a5
	bne	s2,zero,.L21
.L20:
	bne	s2,zero,.L18
	lui	a5,%hi(findme)
	lw	a3,%lo(findme)(a5)
	lui	a5,%hi(len)
	lw	a5,%lo(len)(a5)
	sub	a5,s1,a5
	addi	a5,a5,1
	lw	a4,-36(s0)
	add	a5,a4,a5
	sw	a5,-24(s0)
	lui	a5,%hi(len)
	lw	a5,%lo(len)(a5)
	mv	a2,a5
	lw	a1,-24(s0)
	mv	a0,a3
	call	my_strncmp
	mv	a5,a0
	bne	a5,zero,.L22
	lw	a5,-24(s0)
	j	.L23
.L22:
	addi	s1,s1,1
.L18:
	lw	a5,-20(s0)
	bltu	s1,a5,.L19
	li	a5,0
.L23:
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	addi	sp,sp,48
	jr	ra
	.size	strsearch, .-strsearch
	.section	.rodata
	.align	2
.LC0:
	.string	"abb"
	.align	2
.LC1:
	.string	"cabbie"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	lui	a5,%hi(.LC0)
	addi	a5,a5,%lo(.LC0)
	sw	a5,-40(s0)
	sw	zero,-36(s0)
	lui	a5,%hi(.LC1)
	addi	a5,a5,%lo(.LC1)
	sw	a5,-44(s0)
	sw	zero,-28(s0)
	sw	zero,-20(s0)
	j	.L26
.L28:
	lw	a5,-28(s0)
	addi	a5,a5,1
	sw	a5,-28(s0)
	lw	a5,-20(s0)
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-24(a5)
	mv	a0,a5
	call	init_search
	lw	a5,-20(s0)
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-28(a5)
	mv	a0,a5
	call	strsearch
	sw	a0,-32(s0)
	lw	a5,-32(s0)
	beq	a5,zero,.L27
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L27:
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L26:
	lw	a5,-20(s0)
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-24(a5)
	bne	a5,zero,.L28
	lw	a4,-24(s0)
	lw	a5,-28(s0)
	add	a5,a4,a5
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 9.2.0"
