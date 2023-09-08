# riscv32-unknown-elf
# assemble: riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o
# link: riscv32-unknown-elf-ld -S blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv -nostdlib --no-relax
# tohex: riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
# dump: riscv32-unknown-elf-objdump -S blinker.o


from sys import argv
from subprocess import check_output

LD = "bram.ld"
EM = "elf32lriscv"
PRE = "riscv32-unknown-elf"
ARCH = "rv32i"
ABI = "ilp32"


# fname = "blinker.s"

# fname_woext = fname.split(".")[0]
# fname_o = fname_woext + ".o"
# fname_elf = fname_woext + ".elf"
# fname_hex = fname_woext + "_ascii.hex"


def main():
    fname = argv[1]
    assemble("start.s")  # so that we have start.o


def assemble(fname):
    # assemble
    # riscv32-unknown-elf-as -march=rv32i -mabi=ilp32 -mno-relax blinker.s -o blinker.o

    fname_woext = fname.split(".")[0]
    fname_o = fname_woext + ".o"

    cmd_as = check_output(
        [
            f"{PRE}-as",
            f"-march={ARCH}",
            f"-mabi={ABI}",
            "-mno-relax",
            fname,
            "-o",
            fname_o,
        ]
    )

    if cmd_as:
        print(cmd_as.decode())


def link(fname):
    # link
    # riscv32-unknown-elf-ld -S blinker.o -o blinker.bram.elf -T bram.ld -m elf32lriscv -nostdlib --no-relax
    fname_woext = fname.split(".")[0]
    fname_o = fname_woext + ".o"
    fname_elf = fname_woext + ".elf"

    cmd_ld = check_output(
        [
            f"{PRE}-ld",
            fname_o,
            "-o",
            fname_elf,
            "-T",
            LD,
            "-m",
            f"{EM}",
            "-nostdlib",
            "--no-relax",
        ]
    )

    if cmd_ld:
        print(cmd_ld.decode())


def to_hex(fname):
    fname_woext = fname.split(".")[0]
    fname_elf = fname_woext + ".elf"
    fname_hex = fname_woext + "_ascii.hex"
    # to hex
    # riscv32-unknown-elf-elf2hex --bit-width 32 --input blinker.elf --output blinker.hex
    cmd_hex = check_output(
        [
            f"{PRE}-elf2hex",
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


def dump(fname):
    fname_woext = fname.split(".")[0]
    fname_elf = fname_woext + ".elf"
    cmd_dump = check_output([f"{PRE}-objdump", "-S", fname_elf])

    if cmd_dump:
        print(cmd_dump.decode())
