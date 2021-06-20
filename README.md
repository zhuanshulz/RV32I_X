# 仿真工具可以选择iverilog
可以参考该文档进行安装和使用https://blog.csdn.net/whik1194/article/details/103377834 

# 使用Makefile进行仿真所需要的软件支持
	倘若没有修改.c文件，则需要安装iverilog，并使用make run命令进行。
	倘若修改了.c文件，则需要riscv32 gcc、objdump、copy的支持，并使用make all命令进行。
	
