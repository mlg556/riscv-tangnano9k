BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5
PROJECT=soc


all: .//impl//pnr//${PROJECT}.fs ${BOARD}.cst ${PROJECT}.v

build:
	C:\Gowin\Gowin_V1.9.8.11_Education\IDE\bin\gw_sh run.tcl

# Program Board
load: .//impl//pnr//${PROJECT}.fs
	openFPGALoader -b ${BOARD} .//impl//pnr//${PROJECT}.fs -f

test: ${PROJECT}_test.o
	vvp ${PROJECT}_test.o;

${PROJECT}_test.o: ${PROJECT}.v ${PROJECT}_tb.v
	iverilog -DBENCH -o ${PROJECT}_test.o ${PROJECT}.v ${PROJECT}_tb.v

view: ${PROJECT}_tb.vcd
	gtkwave ${PROJECT}_tb.vcd

# Cleanup build artifacts, del for windows cmd.exe
clean:
	cmd //C del *.o *.json *.fs *.vcd & cmd //C rmdir //s //q impl

.PHONY: load clean test
