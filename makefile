BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5
# GW_SH=C:\Gowin\Gowin_V1.9.8.11_Education\IDE\bin\gw_sh # windows
# GW_PRG=C:\Gowin\Gowin_V1.9.8.11_Education\Programmer\bin\programmer_cli.exe

# linux
GW_SH=/home/oolon/Gowin/IDE/bin/gw_sh
GW_PRG=/home/oolon/Gowin/Programmer/bin/programmer_cli


# GW_SH="/home/oolon/gowin-ide/bin/gw_sh" # linux
FS=${CURDIR}/impl/pnr/soc.fs

build: soc.v
	${GW_SH} run.tcl

# Program Board, add -f for flash
#	
# ${GW_PRG} -f ${FS} -r 2 -d GW1N-9C

# open
load: ${FS} soc.v
	/home/oolon/oss-cad-suite/bin/openFPGALoader -f -b ${BOARD} ${FS} # linux

# gowin programmer
# -r 2 for SRAM, -r 6 for embeddedflash erase,program,verify
# load: ${FS} soc.v
# 	sudo ${GW_PRG} -f ${FS} -r 5 -d GW1N-9C

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
