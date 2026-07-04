all: 
	riscv64-linux-gnu-gcc -nostdlib -static hello.s -o hello
	qemu-riscv64 ./hello 

debug:
	riscv64-linux-gnu-gcc -nostdlib -static -g hello.s -o hello.elf 

first:
	qemu-riscv64 -g 1234 ./hello.elf 

start:
	riscv64-linux-gnu-gdb ./hello.elf 

disassemble: 
	riscv64-linux-gnu-gcc hello.c -o hello 
	riscv64-linux-gnu-objdump -d hello 
