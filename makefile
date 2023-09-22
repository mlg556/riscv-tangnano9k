BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

# GOWIN locations
ifeq ($(p), win) # windows
	GW_SH=C:\Gowin\Gowin_V1.9.8.11_Education\IDE\bin\gw_sh
	GW_PRG=C:\Gowin\Gowin_V1.9.8.11_Education\Programmer\bin\programmer_cli.exe
else
	GW_SH=/home/oolon/Gowin/IDE/bin/gw_sh
	GW_PRG=/home/oolon/Gowin/Programmer/bin/programmer_cli
endif

FS=${CURDIR}/impl/pnr/soc.fs

build: ${FS} soc.v
	${GW_SH} run.tcl


load: soc.v
ifeq ($(p), win) # windows
		${GW_PRG} -f ${FS} -r 2 -d ${FAMILY}
else
		/home/oolon/oss-cad-suite/bin/openFPGALoader -b ${BOARD} ${FS}
endif

# load to flash
loadf: soc.v
ifeq ($(p), win) # windows
		${GW_PRG} -f ${FS} -r 5 -d ${FAMILY}
else
		/home/oolon/oss-cad-suite/bin/openFPGALoader -f -b ${BOARD} ${FS}
endif	


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
