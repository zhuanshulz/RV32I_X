.file	"crt.s"

	.text
	
	.global _start
	
	.extern main

_start:
	li	sp, 0x00050000
	j _call_main

_finish:
    li x3, 0xd0580000
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish

_call_main:
	call main
	j _finish


