# riscv32-unknown-elf
# assemble: riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o
# link: riscv32-unknown-elf-ld blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv --no-relax --print-memory-usage
# tohex: riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
# dump: riscv32-unknown-elf-objdump -S blinker.o

# toolchain prefix for windows
RV = C:\riscv64-unknown-elf-gcc-2018.07.0-x86_64-w64-mingw32\bin\riscv64-unknown-elf
# RV = C:\xpack-riscv-none-elf-gcc-13.2.0-1\bin/riscv-none-elf

# toolchain prefix path for linux
# RV = riscv32-unknown-elf

gcc = $(RV)-gcc
# as = $(RV)-as
ld = $(RV)-ld
elf2hex = $(RV)-elf2hex
objdump = $(RV)-objdump
objcopy = $(RV)-objcopy

ARCH = rv32i
ABI = ilp32
EMU = elf32lriscv
# LIBGCC = /opt/riscv32i/lib/gcc/riscv32-unknown-elf/8.2.0/libgcc.a

script = bram.ld

GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion

# make start.o from start.s
start.o: start.s
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -mno-relax -o $@ $<

# make putchar.o from putchar.s
putchar.o: putchar.s
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -mno-relax -o $@ $<


%.o: %.c
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -mno-relax -fno-stack-protector -o $@ $<

%.o: %.s
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -mno-relax -fno-stack-protector -o $@ $<

# riscv32-unknown-elf-ld blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv --no-relax --print-memory-usage
%.elf: %.o start.o putchar.o
	$(ld) $< putchar.o -o $@ -T $(script) -m $(EMU) -nostdlib --no-relax --print-memory-usage
# $(ld) $< $(LIBGCC) -o $@ -T $(script) -m $(EMU) -nostdlib --no-relax --print-memory-usage

%.lst: %.elf
	$(objdump) -S $<

%.bin: %.elf
	$(objcopy) $< -O binary $@

%.hex: %.bin
	python bin2hex.py -w 32 $< > $@
# riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
# %.hex: %.elf
# 	$(elf2hex) --bit-width 32 --input $< --output $@

.SECONDARY:

.PHONY: clean

clean:
	rm -f *.o *.elf *.hex *.bin




