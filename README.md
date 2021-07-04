# 仿真工具可以选择iverilog
可以参考该文档进行安装和使用https://blog.csdn.net/whik1194/article/details/103377834 

# 使用Makefile进行仿真所需要的软件支持
	倘若没有修改.c文件，则需要安装iverilog，并使用make run命令进行。
	倘若修改了.c文件，则需要riscv32 gcc、objdump、copy的支持，并使用make all命令进行。
	
# 要求：
	1、不少于五级流水线的RISCV。
	2、测试程序中至少包含一条printf()，输出程序的执行结果。
	3、cache和动态分支预测不做要求。
	4、第四次课进行阶段检查。
	5、报告做了要求。

本周要求：
	1、列出加入printf后需要的所有指令
	2、实现除浮点、压缩指令外的所有指令

