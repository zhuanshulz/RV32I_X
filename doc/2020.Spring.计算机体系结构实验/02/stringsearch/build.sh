riscv32-unknown-elf-as -march=rv32im crt.s -o crt.o
riscv32-unknown-elf-gcc -march=rv32im -fno-stack-protector -fno-zero-initialized-in-bss -ffreestanding -fno-builtin -nostdlib -nodefaultlibs -nostartfiles -mstrict-align -c main.c
riscv32-unknown-elf-ld -m elf32lriscv --discard-none -o main.elf crt.o main.o -L/opt/riscv32/bin/../lib/gcc/riscv32-unknown-elf/9.2.0 -lgcc -lgcov -L/opt/riscv32/bin/../riscv32-unknown-elf/lib -lm -lc -T/mnt/f/RV64G_SWD/testbench/link.ld -static
riscv32-unknown-elf-objdump -D main.elf > main.dump
riscv32-unknown-elf-objcopy -O verilog --only-section ".data*" --only-section ".rodata*" --only-section ".srodata*" main.elf data.hex
riscv32-unknown-elf-objcopy -O verilog --only-section ".text*" --set-start=0x0 main.elf program.hex
python transform_data.py
python transform_program.py
