# Simple blinker
# assemble: riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o
# compile: riscv64-unknown-elf-ld --gc-sections -S blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv -nostdlib --no-relax
# tohex: riscv64-unknown-elf-objcopy -O verilog blinker.bram.elf blinker.v

start:
	li a0, 0
loop:
	addi a0, a0, 1
	j loop


# .equ IO_BASE, 0x400000  
# .equ IO_LEDS, 4

# .section .text

# start:
#         li   gp,IO_BASE
# 	li   sp,0x1800
# .L0:
# 	li   t0, 5
# 	sw   t0, IO_LEDS(gp)
# 	call wait
# 	li   t0, 10
# 	sw   t0, IO_LEDS(gp)
# 	call wait
# 	j .L0

# wait:
#         li t0,1
# 	slli t0, t0, 17
# .L1:       
#         addi t0,t0,-1
# 	bnez t0, .L1
# 	ret
