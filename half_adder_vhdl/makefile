BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

all: half_adder.fs

# Synthesis
half_adder.json: half_adder.v
	yosys -p "read half_adder.v top.v ; synth_gowin -top half_adder -json half_adder.json"

# Place and Route
half_adder_pnr.json: half_adder.json
	nextpnr-gowin --json half_adder.json --freq 27 --write half_adder_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${BOARD}.cst

# Generate Bitstream
half_adder.fs: half_adder_pnr.json
	gowin_pack -d ${FAMILY} -o half_adder.fs half_adder_pnr.json

# Program Board
load: half_adder.fs
	openFPGALoader -b ${BOARD} half_adder.fs -f

half_adder_test.o: half_adder.v half_adder_tb.v
	iverilog -o half_adder_test.o -s test half_adder.v half_adder_tb.v

test: half_adder_test.o
	vvp half_adder_test.o

# Cleanup build artifacts, del for windows cmd.exe
clean:
	del half_adder.fs 

.PHONY: load clean test
.INTERMEDIATE: half_adder_pnr.json half_adder.json half_adder_test.o