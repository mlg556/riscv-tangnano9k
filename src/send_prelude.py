import serial
from time import sleep

PORT = "COM21"
BAUD = 115_200  # a little bit slower

# read prelude file
prelude = []

with open("prelude.forth") as f:
    prelude = f.readlines()

# for line in prelude[:20]:
#     for char in line:
#         print(char, end="")
#     print("")

with serial.Serial(port=PORT, baudrate=BAUD, timeout=1, write_timeout=1) as ser:
    for line in prelude:
        for char in line:
            sleep(0.0001)
            ser.write(char.encode())
        sleep(0.0001)
        ser.write("\n".encode())
        a = ser.readline()
        b = ser.readline()
        print(a.decode(), end="")
        print(b.decode(), end="")


# for line in prelude:
#     print(line)
