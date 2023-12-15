BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

# GOWIN locations
GW_SH=C:\Gowin\Gowin_V1.9.8.11_Education\IDE\bin\gw_sh
GW_PRG=C:\Gowin\Gowin_V1.9.8.11_Education\Programmer\bin\programmer_cli.exe

FS=${CURDIR}/impl/pnr/soc.fs

all: build load monitor

all_flash: build load_flash monitor

build: soc.v
	${GW_SH} run.tcl

load: soc.v
	${GW_PRG} -f ${FS} -r 2 -d ${FAMILY}

# load to flash
load_flash: soc.v
	${GW_PRG} -f ${FS} -r 5 -d ${FAMILY}

monitor:
	python -m serial.tools.miniterm COM21 115200 --eol LF

# verilog stuff
test: soc_test.o
	vvp soc_test.o;

soc_test.o: soc.v soc_tb.v
	iverilog -DBENCH -o soc_test.o soc.v soc_tb.v

view: soc_tb.vcd
	gtkwave soc_tb.vcd

# Cleanup build artifacts, del for windows cmd.exe
clean:
	rm *.o *.json *.fs *.vcd & rm -rf ./impl

.PHONY: load clean test
