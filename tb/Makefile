SRC = *.sv
SRC_RTL = ~/Documents/do-an2/vit_npu/rtl/*.sv
TOP = tb_new

# modelsim 
VLOG = vlog
VSIM = vsim 
DO_FILE = script.do

all: compile sim

compile: 
	@echo "Compiling Systolic Design..."
	$(VLOG) $(SRC)
	$(VLOG) $(SRC_RTL)


sim: compile 
	@echo "Running simulation... "
	$(VSIM) -c $(TOP) -do "run -all; quit"

wave: compile 
	@echo "Running simulation with waveform..."
	$(VSIM) $(TOP) -do $(DO_FILE)

clean:
	@echo "Cleaning up..."
	rm -rf work transcript vsim.wlf


