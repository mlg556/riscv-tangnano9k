# using bronzebeard

from subprocess import Popen, PIPE
from sys import argv, exit
from binascii import hexlify


fname = argv[1]
# fname = "fib.S"
fname_woext = fname.split(".")[0]

fname_hex = f"{fname_woext}.hex"
fname_asciihex = f"{fname_woext}_ascii.hex"
fname_asciidighex = f"{fname_woext}_asciidig.hex"
fname_v = f"{fname_woext}.v"

cmd = Popen(
    ["bronzebeard", fname, "-o", fname_hex],
    stdin=PIPE,
    stdout=PIPE,
    stderr=PIPE,
    shell=True,
)

_, err = cmd.communicate(b"")

if err:
    print(err.decode())
    exit(0)

code_hex = []

with open(fname_hex, "rb") as f:
    code_hex = f.read()

code = []

word_size = 4
for i in range(0, len(code_hex), word_size):
    word = code_hex[i : i + word_size]
    word = word[::-1]
    code.append(hexlify(word).decode())

print(fname_asciihex)

[print(line) for line in code]

with open(fname_asciihex, "w+") as f:
    for line in code:
        f.write(line + "\n")

# # used with neeman's Digital simulator
# with open(fname_asciidighex, "w+") as f:
#     f.write("v2.0 raw\n")
#     for line in code:
#         f.write(line + "\n")

# # used for hardcoding into verilog file
# with open(fname_v, "w+") as f:
#     f.write("task LOADMEM;\n")
#     f.write("\tbegin\n")
#     for i, line in enumerate(code):
#         f.write(f"\t\tMEM[{i}] = 32'h{line};\n")
#     f.write("\tend\n")
#     f.write("endtask\n")
