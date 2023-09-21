# riscv32-unknown-elf
# assemble: riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o
# link: riscv32-unknown-elf-ld blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv --no-relax --print-memory-usage
# tohex: riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
# dump: riscv32-unknown-elf-objdump -S blinker.o


# toolchain prefix for windows
# RV = C:\riscv64-unknown-elf-gcc-2018.07.0-x86_64-w64-mingw32\bin\riscv64-unknown-elf

# toolchain prefix path for linux
RV = riscv32-unknown-elf

gcc = $(RV)-gcc
# as = $(RV)-as
ld = $(RV)-ld
elf2hex = $(RV)-elf2hex
objdump = $(RV)-objdump
objcopy = $(RV)-objcopy


ARCH = rv32i
ABI = ilp32
EMU = elf32lriscv
LSCRIPT = bram.ld
LIBC = /opt/riscv32i/riscv32-unknown-elf/lib/libm_nano.a

GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion

# # make start.o from start.s
# start.o: start.s
# 	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -mno-relax -o $@ $<

# # make putchar.o from putchar.s
# putchar.o: putchar.s
# 	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -mno-relax -o $@ $<

# # make print.o from print.c
# print.o: print.c
# 	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -mno-relax -fno-stack-protector -o $@ $<

# assemble .s file
%.o: %.s
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -mno-relax -o $@ $<

# # compile .c files
# %.o: %.c
# 	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -mno-relax -fno-stack-protector -o $@ $<

# link
# %.elf: %.o start.o putchar.o bram.ld
# 	$(gcc) -Os -march=$(ARCH) -mabi=$(ABI) -ffreestanding -nostdlib -mno-relax -o $@ \
# 		-Wl,--build-id=none,-Bstatic,-T,bram.ld,--strip-debug --print-memory-usage \
# 		$< putchar.o

# # link
%.elf: %.o start.o put.o $(LSCRIPT)
	$(ld) $< put.o -o $@ -T $(LSCRIPT) -m $(EMU) -nostdlib --no-relax --print-memory-usage

%.lst: %.elf
	$(objdump) --disassembler-color=extended --visualize-jumps=color -dS $<

%.bin: %.elf
	$(objcopy) $< -O binary $@

%.hex: %.bin
	python3 bin2hex.py -w 32 $< > $@

.SECONDARY:

.PHONY: clean

clean:
	rm -f *.o *.elf *.hex *.bin




