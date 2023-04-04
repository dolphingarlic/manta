build:
	python3 -m build

pypi_upload: build
	python3 -m twine upload --repository testpypi dist/*

lint:
	python3 -m black src/manta/__init__.py
	python3 -m black src/manta/__main__.py

serve_docs:
	mkdocs serve

total_loc:
	find . -type f \( -iname \*.sv -o -iname \*.v -o -iname \*.py -o -iname \*.yaml -o -iname \*.yml -o -iname \*.md \) | sed 's/.*/"&"/' | xargs  wc -l

real_loc:
	find src test -type f \( -iname \*.sv -o -iname \*.v -o -iname \*.py -o -iname \*.yaml -o -iname \*.md \) | sed 's/.*/"&"/' | xargs  wc -l

test: auto_gen functional_sim

clean:
	rm -f *.out *.vcd
	rm -rf dist/
	rm -rf src/mantaray.egg-info

# API Generation Tests
auto_gen:
	python3 test/auto_gen/run_tests.py

# Functional Simulation
functional_sim: io_core_tb logic_analyzer_tb bit_fifo_tb bridge_rx_tb bridge_tx_tb lut_ram_tb uart_tb uart_tx_tb

io_core_tb:
	iverilog -g2012 -o sim.out -y src/manta test/functional_sim/io_core_tb.sv
	vvp sim.out
	rm sim.out

logic_analyzer_tb:
	iverilog -g2012 -o sim.out -y src/manta test/functional_sim/logic_analyzer_tb.sv
	vvp sim.out
	rm sim.out

bit_fifo_tb:
	iverilog -g2012 -o sim.out -y src/manta test/functional_sim/bit_fifo_tb.sv
	vvp sim.out
	rm sim.out

bridge_rx_tb:
	iverilog -g2012 -o sim.out -y src/manta test/functional_sim/bridge_rx_tb.sv
	vvp sim.out
	rm sim.out

bridge_tx_tb:
	iverilog -g2012 -o sim.out -y src/manta test/functional_sim/bridge_tx_tb.sv
	vvp sim.out
	rm sim.out

lut_ram_tb:
	iverilog -g2012 -o sim.out -y src/manta test/functional_sim/lut_ram_tb.sv
	vvp sim.out
	rm sim.out

uart_tb:
	iverilog -g2012 -o sim.out -y src/manta test/functional_sim/uart_tb.sv
	vvp sim.out
	rm sim.out

uart_tx_tb:
	iverilog -g2012 -o sim.out -y src/manta test/functional_sim/uart_tx_tb.sv
	vvp sim.out
	rm sim.out

# Build Examples

examples: icestick nexys_a7

nexys_a7: nexys_a7_io_core nexys_a7_logic_analyzer nexys_a7_lut_ram

nexys_a7_io_core:
	cd examples/nexys_a7/io_core/;   	\
	manta gen manta.yaml src/manta.v;	\
	python3 lab-bc.py

nexys_a7_logic_analyzer:
	cd examples/nexys_a7/logic_analyzer/;   \
	manta gen manta.yaml src/manta.v;		\
	python3 lab-bc.py

nexys_a7_lut_ram:
	cd examples/nexys_a7/lut_ram/;   	\
	manta gen manta.yaml src/manta.v;	\
	python3 lab-bc.py

icestick: icestick_io_core icestick_lut_ram

icestick_io_core:
	cd examples/icestick/io_core/;	\
	manta gen manta.yaml manta.v;  	\
	./build.sh

icestick_lut_ram:
	cd examples/icestick/lut_ram/; 	\
	manta gen manta.yaml manta.v;  	\
	./build.sh

clean_examples:
	rm -f examples/nexys_a7/io_core/obj/*
	rm -f examples/nexys_a7/io_core/src/manta.v

	rm -f examples/nexys_a7/logic_analyzer/obj/*
	rm -f examples/nexys_a7/logic_analyzer/src/manta.v

	rm -f examples/nexys_a7/lut_ram/obj/*
	rm -f examples/nexys_a7/lut_ram/src/manta.v

	rm -f examples/icestick/io_core/*.bin
	rm -f examples/icestick/io_core/manta.v

	rm -f examples/icestick/lut_ram/*.bin
	rm -f examples/icestick/lut_ram/manta.v