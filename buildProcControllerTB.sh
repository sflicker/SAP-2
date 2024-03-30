#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock.vhd
ghdl -a --std=08 -fsynopsys -v clock_controller.vhd
ghdl -a --std=08 -fsynopsys -v proc_controller.vhd
ghdl -a --std=08 -fsynopsys -v proc_controller_tb.vhd

ghdl -e --std=08 -fsynopsys -v proc_controller_tb

echo "Running Test Bench"
#run
ghdl -r --std=08 -fsynopsys proc_controller_tb --stop-time=5000ns --vcd=proc_controller_tb.vcd


