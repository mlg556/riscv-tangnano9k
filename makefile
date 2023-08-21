BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5
PROJECT=soc

all: ${PROJECT}.fs ${BOARD}.cst

# Synthesis
${PROJECT}.json: ${PROJECT}.v
	yosys -p "read_verilog ${PROJECT}.v; synth_gowin -top ${PROJECT} -json ${PROJECT}.json"

# Place and Route
${PROJECT}_pnr.json: ${PROJECT}.json
	nextpnr-gowin --json ${PROJECT}.json --freq 27 --write ${PROJECT}_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${BOARD}.cst

# Generate Bitstream
${PROJECT}.fs: ${PROJECT}_pnr.json
	gowin_pack -d ${FAMILY} -o ${PROJECT}.fs ${PROJECT}_pnr.json

# Program Board
load: ${PROJECT}.fs
	openFPGALoader -b ${BOARD} ${PROJECT}.fs -f

${PROJECT}_test.o: ${PROJECT}.v ${PROJECT}_tb.v
	iverilog -o ${PROJECT}_test.o ${PROJECT}.v ${PROJECT}_tb.v

test: ${PROJECT}_test.o
	vvp ${PROJECT}_test.o;

# gtkwave ${PROJECT}_tb.vcd
# Cleanup build artifacts, del for windows cmd.exe
clean:
	cmd //C del *.o *.json *.fs *.vcd

.PHONY: load clean test
# .INTERMEDIATE: ${PROJECT}_pnr.json ${PROJECT}.json ${PROJECT}_test.o