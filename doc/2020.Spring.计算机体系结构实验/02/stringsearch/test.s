	.file	"test.c"
	.option nopic
	.attribute arch, "rv32i2p0_m2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.section	.rodata
	.align	2
.LC0:
	.string	"abb"
	.align	2
.LC1:
	.string	"acc"
	.text
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
	.globl	boyermoore_horspool_memmem
	.type	boyermoore_horspool_memmem, @function
boyermoore_horspool_memmem:
	addi	sp,sp,-1072
	sw	s0,1068(sp)
	addi	s0,sp,1072
	sw	a0,-1060(s0)
	sw	a1,-1064(s0)
	sw	a2,-1068(s0)
	sw	a3,-1072(s0)
	sw	zero,-20(s0)
	lw	a5,-1072(s0)
	beq	a5,zero,.L6
	lw	a5,-1060(s0)
	beq	a5,zero,.L6
	lw	a5,-1068(s0)
	bne	a5,zero,.L7
.L6:
	li	a5,0
	j	.L18
.L7:
	sw	zero,-20(s0)
	j	.L9
.L10:
	lw	a5,-20(s0)
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a4,-1072(s0)
	sw	a4,-1032(a5)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L9:
	lw	a4,-20(s0)
	li	a5,255
	bleu	a4,a5,.L10
	lw	a5,-1072(s0)
	addi	a5,a5,-1
	sw	a5,-24(s0)
	sw	zero,-20(s0)
	j	.L11
.L12:
	lw	a4,-1068(s0)
	lw	a5,-20(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	mv	a3,a5
	lw	a4,-24(s0)
	lw	a5,-20(s0)
	sub	a4,a4,a5
	slli	a5,a3,2
	addi	a3,s0,-16
	add	a5,a3,a5
	sw	a4,-1032(a5)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L11:
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	bltu	a4,a5,.L12
	j	.L13
.L17:
	lw	a5,-24(s0)
	sw	a5,-20(s0)
	j	.L14
.L16:
	lw	a5,-20(s0)
	bne	a5,zero,.L15
	li	a5,1
	j	.L18
.L15:
	lw	a5,-20(s0)
	addi	a5,a5,-1
	sw	a5,-20(s0)
.L14:
	lw	a4,-1060(s0)
	lw	a5,-20(s0)
	add	a5,a4,a5
	lbu	a4,0(a5)
	lw	a3,-1068(s0)
	lw	a5,-20(s0)
	add	a5,a3,a5
	lbu	a5,0(a5)
	beq	a4,a5,.L16
	lw	a4,-1060(s0)
	lw	a5,-24(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-1032(a5)
	lw	a4,-1064(s0)
	sub	a5,a4,a5
	sw	a5,-1064(s0)
	lw	a4,-1060(s0)
	lw	a5,-24(s0)
	add	a5,a4,a5
	lbu	a5,0(a5)
	slli	a5,a5,2
	addi	a4,s0,-16
	add	a5,a4,a5
	lw	a5,-1032(a5)
	lw	a4,-1060(s0)
	add	a5,a4,a5
	sw	a5,-1060(s0)
.L13:
	lw	a4,-1064(s0)
	lw	a5,-1072(s0)
	bgeu	a4,a5,.L17
	li	a5,0
.L18:
	mv	a0,a5
	lw	s0,1068(sp)
	addi	sp,sp,1072
	jr	ra
	.size	boyermoore_horspool_memmem, .-boyermoore_horspool_memmem
	.section	.rodata
	.align	2
.LC4:
	.string	"cabbie"
	.align	2
.LC5:
	.string	"accelerator"
	.align	2
.LC6:
	.string	"abaaaac"
	.align	2
.LC3:
	.word	.LC0
	.word	.LC1
	.word	.LC1
	.word	0
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-80
	sw	ra,76(sp)
	sw	s0,72(sp)
	sw	s1,68(sp)
	sw	s2,64(sp)
	sw	s3,60(sp)
	addi	s0,sp,80
	lui	a5,%hi(.LC3)
	addi	a5,a5,%lo(.LC3)
	lw	a2,0(a5)
	lw	a3,4(a5)
	lw	a4,8(a5)
	lw	a5,12(a5)
	sw	a2,-64(s0)
	sw	a3,-60(s0)
	sw	a4,-56(s0)
	sw	a5,-52(s0)
	lui	a5,%hi(.LC4)
	addi	a5,a5,%lo(.LC4)
	sw	a5,-76(s0)
	lui	a5,%hi(.LC5)
	addi	a5,a5,%lo(.LC5)
	sw	a5,-72(s0)
	lui	a5,%hi(.LC6)
	addi	a5,a5,%lo(.LC6)
	sw	a5,-68(s0)
	sw	zero,-40(s0)
	sw	zero,-44(s0)
	sw	zero,-36(s0)
	j	.L20
.L22:
	lw	a5,-44(s0)
	addi	a5,a5,1
	sw	a5,-44(s0)
	lw	a5,-36(s0)
	slli	a5,a5,2
	addi	a4,s0,-32
	add	a5,a4,a5
	lw	s1,-44(a5)
	lw	a5,-36(s0)
	slli	a5,a5,2
	addi	a4,s0,-32
	add	a5,a4,a5
	lw	a5,-44(a5)
	mv	a0,a5
	call	my_strlen
	mv	a5,a0
	mv	s3,a5
	lw	a5,-36(s0)
	slli	a5,a5,2
	addi	a4,s0,-32
	add	a5,a4,a5
	lw	s2,-32(a5)
	lw	a5,-36(s0)
	slli	a5,a5,2
	addi	a4,s0,-32
	add	a5,a4,a5
	lw	a5,-32(a5)
	mv	a0,a5
	call	my_strlen
	mv	a5,a0
	mv	a3,a5
	mv	a2,s2
	mv	a1,s3
	mv	a0,s1
	call	boyermoore_horspool_memmem
	sw	a0,-48(s0)
	lw	a5,-48(s0)
	beq	a5,zero,.L21
	lw	a5,-40(s0)
	addi	a5,a5,1
	sw	a5,-40(s0)
.L21:
	lw	a5,-36(s0)
	addi	a5,a5,1
	sw	a5,-36(s0)
.L20:
	lw	a5,-36(s0)
	slli	a5,a5,2
	addi	a4,s0,-32
	add	a5,a4,a5
	lw	a5,-32(a5)
	bne	a5,zero,.L22
	lw	a4,-40(s0)
	lw	a5,-44(s0)
	add	a5,a4,a5
	mv	a0,a5
	lw	ra,76(sp)
	lw	s0,72(sp)
	lw	s1,68(sp)
	lw	s2,64(sp)
	lw	s3,60(sp)
	addi	sp,sp,80
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 9.2.0"
