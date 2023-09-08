BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5
PROJECT=soc
# GW_SH=C:\Gowin\Gowin_V1.9.8.11_Education\IDE\bin\gw_sh
GW_SH="/home/oolon/gowin-ide/bin/gw_sh"
FS=./impl/pnr/${PROJECT}.fs

all: ${FS} ${BOARD}.cst ${PROJECT}.v

build: ${FS} ${PROJECT}.v
	${GW_SH} run.tcl

# Program Board
load: ${FS} ${PROJECT}.v
	sudo openFPGALoader -b ${BOARD} ${FS} -f

test: ${PROJECT}_test.o
	vvp ${PROJECT}_test.o;

${PROJECT}_test.o: ${PROJECT}.v ${PROJECT}_tb.v
	iverilog -DBENCH -o ${PROJECT}_test.o ${PROJECT}.v ${PROJECT}_tb.v

view: ${PROJECT}_tb.vcd
	gtkwave ${PROJECT}_tb.vcd

# Cleanup build artifacts, del for windows cmd.exe
clean:
	rm *.o *.json *.fs *.vcd & rm -rf ./impl

.PHONY: load clean test
