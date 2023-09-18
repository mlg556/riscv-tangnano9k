import serial
from time import sleep

PORT = "COM21"
BAUD = 115_200  # a little bit slower

# read prelude file
prelude = []

with open("prelude.forth") as f:
    prelude = f.readlines()

with serial.Serial(port=PORT, baudrate=BAUD, timeout=1, write_timeout=1) as ser:
    for line in prelude:
        for char in line:
            ser.write(char.encode())
            sleep(0.001)
        ser.write("\n\r".encode())
        read = ser.readline()
        print(read.decode(), end="")


# for line in prelude:
#     print(line)
