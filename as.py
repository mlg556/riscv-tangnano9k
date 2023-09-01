# riscv32-unknown-elf
# assemble: riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o
# link: riscv32-unknown-elf-ld -S blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv -nostdlib --no-relax
# tohex: riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
# dump: riscv32-unknown-elf-objdump -S blinker.o


from sys import argv
from subprocess import check_output

LD = "bram.ld"


fname = argv[1]
# fname = "blinker.s"


fname_woext = fname.split(".")[0]
fname_o = fname_woext + ".o"
fname_elf = fname_woext + ".elf"
fname_hex = fname_woext + "_ascii.hex"

# assemble start.s
cmd_as = check_output(
    [
        "riscv32-unknown-elf-as",
        "-march=rv32i",
        "-mabi=ilp32",
        "-mno-relax",
        "start.s",
        "-o",
        "start.o",
    ]
)

if cmd_as:
    print(cmd_as.decode())

# assemble
# riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o
cmd_as = check_output(
    [
        "riscv32-unknown-elf-as",
        "-march=rv32i",
        "-mabi=ilp32",
        "-mno-relax",
        fname,
        "-o",
        fname_o,
    ]
)

if cmd_as:
    print(cmd_as.decode())

# link
# riscv32-unknown-elf-ld -S blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv -nostdlib --no-relax
cmd_ld = check_output(
    [
        "riscv32-unknown-elf-ld",
        "-S",
        fname_o,
        "-o",
        fname_elf,
        "-T",
        LD,
        "-m",
        "elf32lriscv",
        "-nostdlib",
        "--no-relax",
    ]
)

if cmd_ld:
    print(cmd_ld.decode())

# to hex
# riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
cmd_hex = check_output(
    [
        "riscv32-unknown-elf-elf2hex",
        "--bit-width",
        "32",
        "--input",
        fname_elf,
        "--output",
        fname_hex,
    ]
)

if cmd_hex:
    print(cmd_hex.decode())

cmd_dump = check_output(["riscv32-unknown-elf-objdump", "-S", fname_elf])

if cmd_dump:
    print(cmd_dump.decode())
