# 设置为你的工作路径，即RV32I_X的目录
export RV_ROOT =  

# Allow tool override
IVERILOG = iverilog
GCC_PREFIX = riscv32-unknown-elf
GCC_TOOL_PATH = /opt/riscv/
GCC_VERSION =10.2.0
GCC_FLAGS = -march=rv32i -O3		# 题目基本要求是32位的整数和压缩指令

TEST_LIST = HelloWorld Fiboncci Bubble Printf

# Define the test program directory
ifeq ($(strip $(TEST_DIR)),)
	TEST_DIR = ${RV_ROOT}/software/benchmark
endif

# Define test name，must in TEST_LIST
ifeq ($(strip $(TEST)),)			# 如果TEST是空的，那么就定义TEST为以下的值。
	TEST = Bubble
endif

# CFLAGS for verilator generated Makefiles. Without -std=c++11 it complains for `auto` variables
CFLAGS += "-std=c++11 -DVL_DEBUG"
# Optimization for better performance; alternative is nothing for slower runtime (faster compiles)
VERILATOR_MAKE_FLAGS = OPT_FAST=""

src = $(wildcard $(TEST_DIR)/$(TEST)/*.c)		# 这个代表了测试函数文件夹下的所有.c文件
obj = $(patsubst %.c, %.o, $(src))				# 这个将文件名后缀从.c改为.o

# Targets
all: clean run 

clean:
	rm -rf $(TEST_DIR)/$(TEST)/*.o $(TEST_DIR)/sim_hex/*.hex $(TEST_DIR)/sim_hex/*.dump $(TEST_DIR)/sim_hex/*.elf $(TEST_DIR)/sim_hex/*.o 

%.o: %.c		# 这个规则有点没太看明白; #实际就是每个.o文件依赖相应的.c文件
	$(GCC_PREFIX)-gcc $(GCC_FLAGS) -I$(TEST_DIR)/include/ -c -o $@ $<
	
$(TEST_DIR)/sim_hex/main.elf: $(obj)			# 依赖的是.o文件 第一个命令是编译，第二个是链接
	$(GCC_PREFIX)-gcc $(GCC_FLAGS) -c $(TEST_DIR)/include/crt.s -o $(TEST_DIR)/sim_hex/crt.o 
	$(GCC_PREFIX)-ld -m elf32lriscv --discard-none -o $@ $(TEST_DIR)/sim_hex/crt.o $(obj) -L$(GCC_TOOL_PATH)/lib/gcc/$(GCC_PREFIX)/$(GCC_VERSION)/ \
		-L$(GCC_TOOL_PATH)/$(GCC_PREFIX)/lib/ -lm -lc -lgcc -lgcov -T$(TEST_DIR)/include/link.ld -static

$(TEST_DIR)/sim_hex/program.hex: $(TEST_DIR)/sim_hex/main.elf	# 依赖的是.elf文件 第一个命令是反汇编，生成.dump文件。第二、三个命令是将数据和指令部分抽出来形成.hex文件
	$(GCC_PREFIX)-objdump -D $(TEST_DIR)/sim_hex/main.elf -M no-aliases,numeric > $(TEST_DIR)/sim_hex/main.dump
	$(GCC_PREFIX)-objcopy -O verilog --only-section ".data*" --only-section ".rodata*" --only-section ".srodata*" $(TEST_DIR)/sim_hex/main.elf $(TEST_DIR)/sim_hex/data.hex
	$(GCC_PREFIX)-objcopy -O verilog --only-section ".text*" --set-start=0x0 $(TEST_DIR)/sim_hex/main.elf $(TEST_DIR)/sim_hex/program.hex
	python $(TEST_DIR)/sim_hex/transform_program.py
	python $(TEST_DIR)/sim_hex/transform_data.py

run: $(TEST_DIR)/sim_hex/program.hex		# 依赖程序的二进制文件，启动仿真
	@echo start compile
	$(IVERILOG) -o wave ${TEST_DIR}/../testbench/tb_top.sv -l ${RV_ROOT}/hardware/*.v ${RV_ROOT}/hardware/*/*.v
	vvp ./wave

help:
	@echo Make sure the environment variable RV_ROOT is set.
	@echo Make sure RISC-V toolchain has been installed.
	@echo Possible targets: help clean all run program.hex
