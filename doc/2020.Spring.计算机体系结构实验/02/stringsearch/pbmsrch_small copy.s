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
	addi	sp,sp,-48 074
	sw	s0,44(sp) 078
	addi	s0,sp,48 07c
	sw	a0,-36(s0) 080
	sw	zero,-20(s0) 084
	j	.L2 088
.L3:
	lw	a5,-20(s0) 08c
	addi	a5,a5,1 090
	sw	a5,-20(s0) 094
.L2:
	lw	a5,-36(s0) 098
	addi	a4,a5,1 09c
	sw	a4,-36(s0) 0a0
	lbu	a5,0(a5) 0a4
	bne	a5,zero,.L3 0a8
	lw	a5,-20(s0) 0ac
	mv	a0,a5 0b0
	lw	s0,44(sp) 0b4
	addi	sp,sp,48 0b8
	jr	ra 0bc
	.size	my_strlen, .-my_strlen
	.align	2
	.globl	my_strncmp
	.type	my_strncmp, @function
my_strncmp:
	addi	sp,sp,-48 0c0
	sw	s0,44(sp) 0c4
	addi	s0,sp,48 0c8
	sw	a0,-36(s0) 0cc
	sw	a1,-40(s0) 0d0
	sw	a2,-44(s0) 0d4
	sw	zero,-20(s0) 0d8
	j	.L6 0dc
.L11:
	lw	a5,-20(s0) 0e0
	lw	a4,-36(s0) 0e4
	add	a5,a4,a5 0e8
	lbu	a4,0(a5) 0ec
	lw	a5,-20(s0) 0f0
	lw	a3,-40(s0) 0f4
	add	a5,a3,a5 0f8
	lbu	a5,0(a5) 0fc
	bleu	a4,a5,.L7 100
	li	a5,1 104
	j	.L8 108
.L7:
	lw	a5,-20(s0) 10c
	lw	a4,-36(s0) 110
	add	a5,a4,a5 114
	lbu	a4,0(a5) 118
	lw	a5,-20(s0) 11c
	lw	a3,-40(s0) 120
	add	a5,a3,a5 124
	lbu	a5,0(a5) 128
	bgeu	a4,a5,.L9 12c
	li	a5,-1 130
	j	.L8 134
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
	lw	a4,-20(s0) 16c
	lw	a5,-44(s0) 170
	blt	a4,a5,.L11 174
.L10:
	li	a5,0 178
.L8:
	mv	a0,a5 17c
	lw	s0,44(sp) 180
	addi	sp,sp,48 184
	jr	ra 188
	.size	my_strncmp, .-my_strncmp
	.align	2
	.globl	init_search
	.type	init_search, @function
init_search:
	addi	sp,sp,-48 18c
	sw	ra,44(sp) 190
	sw	s0,40(sp) 194
	addi	s0,sp,48 198
	sw	a0,-36(s0) 19c
	lw	a0,-36(s0) 1a0
	call	my_strlen 1a4
	mv	a5,a0 1a8
	mv	a4,a5 1ac
	lui	a5,%hi(len) 1b0
	sw	a4,%lo(len)(a5) 1b0
	sw	zero,-20(s0) 1b4
	j	.L13 1b8
.L14:
	lui	a5,%hi(len)
	lw	a4,%lo(len)(a5)
	lui	a5,%hi(table) 1c0
	addi	a3,a5,%lo(table) 1c4
	lw	a5,-20(s0) 1c8
	slli	a5,a5,2 1cc
	add	a5,a3,a5 1d0
	sw	a4,0(a5) 1d4
	lw	a5,-20(s0) 1d8
	addi	a5,a5,1 1dc
	sw	a5,-20(s0) 1e0
.L13:
	lw	a4,-20(s0) 1e4
	li	a5,255 1e8
	bleu	a4,a5,.L14 1ec
	sw	zero,-20(s0)  1f0
	j	.L15 1f4
.L16:
	lui	a5,%hi(len)  1f8
	lw	a4,%lo(len)(a5) 1f8
	lw	a5,-20(s0) 1fc
	sub	a5,a4,a5 200
	lw	a3,-36(s0) 204
	lw	a4,-20(s0) 208
	add	a4,a3,a4 20c
	lbu	a4,0(a4) 210
	mv	a2,a4 214
	addi	a4,a5,-1 218
	lui	a5,%hi(table) 21c
	addi	a3,a5,%lo(table) 220
	slli	a5,a2,2 224
	add	a5,a3,a5 228
	sw	a4,0(a5) 22c
	lw	a5,-20(s0) 230
	addi	a5,a5,1 234
	sw	a5,-20(s0) 238
.L15:
	lui	a5,%hi(len) 23c
	lw	a5,%lo(len)(a5) 23c
	lw	a4,-20(s0) 240
	bltu	a4,a5,.L16 244
	lui	a5,%hi(findme) 248
	lw	a4,-36(s0) 24c
	sw	a4,%lo(findme)(a5) 250
	nop 250
	lw	ra,44(sp) 254
	lw	s0,40(sp) 258
	addi	sp,sp,48 25c
	jr	ra 260
	.size	init_search, .-init_search
	.align	2
	.globl	strsearch
	.type	strsearch, @function
strsearch:
	addi	sp,sp,-48 264
	sw	ra,44(sp) 268
	sw	s0,40(sp) 26c
	sw	s1,36(sp) 270
	sw	s2,32(sp) 274
	addi	s0,sp,48 278
	sw	a0,-36(s0) 27c
	lui	a5,%hi(len) 280
	lw	a5,%lo(len)(a5) 280
	addi	s1,a5,-1 284
	lw	a0,-36(s0) 288
	call	my_strlen 28c
	mv	a5,a0 290
	sw	a5,-20(s0) 294
	j	.L18 298
.L21:
	add	s1,s1,s2 29c
.L19:
	lw	a5,-20(s0) 2a0
	bgeu	s1,a5,.L20 2a4
	lw	a5,-36(s0) 2a8
	add	a5,a5,s1 2ac
	lbu	a5,0(a5) 2b0
	mv	a3,a5 2b4
	lui	a5,%hi(table) 2b8
	addi	a4,a5,%lo(table) 2bc
	slli	a5,a3,2 2c0
	add	a5,a4,a5 2c4
	lw	s2,0(a5) 2c8
	bne	s2,zero,.L21 2cc
.L20:
	bne	s2,zero,.L18 2d0
	lui	a5,%hi(findme) 2d4
	lw	a3,%lo(findme)(a5) 2d4
	lui	a5,%hi(len) 2d8
	lw	a5,%lo(len)(a5) 2d8
	sub	a5,s1,a5 2dc
	addi	a5,a5,1 2e0
	lw	a4,-36(s0) 2e4
	add	a5,a4,a5 2e8
	sw	a5,-24(s0) 2ec
	lui	a5,%hi(len) 2f0
	lw	a5,%lo(len)(a5) 2f0
	mv	a2,a5 2f4
	lw	a1,-24(s0) 2f8
	mv	a0,a3 2fc
	call	my_strncmp 300
	mv	a5,a0 304
	bne	a5,zero,.L22 308
	lw	a5,-24(s0) 30c
	j	.L23 310
.L22:
	addi	s1,s1,1 314
.L18:
	lw	a5,-20(s0) 318
	bltu	s1,a5,.L19 31c
	li	a5,0 320
.L23:
	mv	a0,a5 324
	lw	ra,44(sp) 328
	lw	s0,40(sp) 32c
	lw	s1,36(sp) 330
	lw	s2,32(sp) 334
	addi	sp,sp,48 338
	jr	ra 33c
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
	addi	sp,sp,-48  340
	sw	ra,44(sp) 344
	sw	s0,40(sp) 348
	addi	s0,sp,48 34c
	lui	a5,%hi(.LC0) 350
	addi	a5,a5,%lo(.LC0) 354
	sw	a5,-40(s0) 358
	sw	zero,-36(s0) 35c
	lui	a5,%hi(.LC1) 360
	addi	a5,a5,%lo(.LC1) 364
	sw	a5,-44(s0) 368
	sw	zero,-28(s0) 36c
	sw	zero,-20(s0) 370
	j	.L26 374
.L28:
	lw	a5,-28(s0) 378
	addi	a5,a5,1 37c
	sw	a5,-28(s0) 380
	lw	a5,-20(s0) 384
	slli	a5,a5,2 388
	addi	a4,s0,-16 38c
	add	a5,a4,a5 390
	lw	a5,-24(a5) 394
	mv	a0,a5 398
	call	init_search 39c
	lw	a5,-20(s0) 3a0
	slli	a5,a5,2 3a4
	addi	a4,s0,-16 3a8
	add	a5,a4,a5 3ac
	lw	a5,-28(a5) 3b0
	mv	a0,a5 3b4
	call	strsearch 3b8
	sw	a0,-32(s0) 3bc
	lw	a5,-32(s0) 3c0
	beq	a5,zero,.L27 3c4
	lw	a5,-24(s0) 3c8
	addi	a5,a5,1 3cc
	sw	a5,-24(s0) 3d0
.L27:
	lw	a5,-20(s0) 3d4
	addi	a5,a5,1 3d8
	sw	a5,-20(s0) 3dc
.L26:
	lw	a5,-20(s0) 3e0
	slli	a5,a5,2 3e4
	addi	a4,s0,-16 3e8
	add	a5,a4,a5 3ec
	lw	a5,-24(a5) 3f0
	bne	a5,zero,.L28 3f4
	lw	a4,-24(s0) 3f8
	lw	a5,-28(s0) 3fc
	add	a5,a4,a5 400
	mv	a0,a5 404
	lw	ra,44(sp) 408
	lw	s0,40(sp) 40c
	addi	sp,sp,48 410
	jr	ra 414
	.size	main, .-main
	.ident	"GCC: (GNU) 9.2.0"
