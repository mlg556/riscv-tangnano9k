# riscv32-unknown-elf
# assemble: riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o
# link: riscv32-unknown-elf-ld blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv --no-relax --print-memory-usage
# tohex: riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
# dump: riscv32-unknown-elf-objdump -S blinker.o

RV = riscv32-unknown-elf

gcc = $(RV)-gcc
# as = $(RV)-as
ld = $(RV)-ld
elf2hex = $(RV)-elf2hex
objdump = $(RV)-objdump

ARCH = rv32i
ABI = ilp32
EMU = elf32lriscv
LIBGCC = /opt/riscv32i/lib/gcc/riscv32-unknown-elf/8.2.0/libgcc.a

script = bram.ld

LIBOBJECTS=putchar.o print.o

GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion

# make start.o from start.s
start.o: start.s
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -mno-relax -o $@ $<

# make putchar.o from putchar.s
putchar.o: putchar.s
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -mno-relax -o $@ $<

# make print.o from print.c
print.o: print.c
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -mno-relax -fno-stack-protector -o $@ $<

# -fno-stack-protector
%.o: %.c
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -mno-relax -fno-stack-protector -o $@ $<

# riscv32-unknown-elf-ld blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv --no-relax --print-memory-usage
%.elf: %.o start.o $(LIBOBJECTS)
	$(ld) $< $(LIBOBJECTS) $(LIBGCC) -o $@ -T $(script) -m $(EMU) -nostdlib --no-relax --print-memory-usage

# riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
%.hex: %.elf
	$(elf2hex) --bit-width 32 --input $< --output $@

.SECONDARY:

.PHONY: clean

clean:
	rm -f *.o *.elf *.hex




