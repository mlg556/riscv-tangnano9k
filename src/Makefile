# riscv32-unknown-elf
# assemble: riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o
# link: riscv32-unknown-elf-ld blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv --no-relax --print-memory-usage
# tohex: riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
# dump: riscv32-unknown-elf-objdump -S blinker.o

# GCC
# LIBC := C:\xpack-riscv-none-elf-gcc\lib\gcc\riscv-none-elf\13.2.0\rv32i\ilp32\libgcc.a
# others? C:\xpack-riscv-none-elf-gcc\riscv-none-elf\lib\rv32i\ilp32\libg.a


# toolchain paths etc...
# windows
RV := C:\dev\xpack-riscv-none-elf-gcc\bin\riscv-none-elf
LIBC := C:\dev\xpack-riscv-none-elf-gcc\lib\gcc\riscv-none-elf\13.2.0\rv32i\ilp32\libgcc.a 
PY := python

gcc := $(RV)-gcc
ld := $(RV)-ld
elf2hex := $(RV)-elf2hex
objdump := $(RV)-objdump
objcopy := $(RV)-objcopy

ARCH := rv32i
ABI := ilp32
EMU := elf32lriscv
LINKSCRIPT := ram.ld

# GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
# GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion

LIBOBJECTS := tang.o io.o

# assemble .s file
%.o: %.s
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -mno-relax -o $@ $<

%.o: %.c
	$(gcc) -c -march=$(ARCH) -mabi=$(ABI) -Os -mno-relax --std=c99 -ffreestanding -o $@ $<

# $(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<
# # link
%.elf: %.o start.o $(LIBOBJECTS) $(LINKSCRIPT)
	$(ld) $< $(LIBOBJECTS) $(LIBC) -T $(LINKSCRIPT) -m $(EMU) --no-relax --print-memory-usage -S -o $@

%.lst: %.elf
	$(objdump) --disassembler-color=extended --visualize-jumps=color -dS $<

%.bin: %.elf
	$(objcopy) $< -O binary $@

%.hex: %.bin
	$(PY) bin2hex.py -w 32 $< > $@

.SECONDARY:

.PHONY: clean

clean:
	rm -f *.o *.elf *.hex *.bin




