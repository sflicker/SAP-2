#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock.vhd
ghdl -a --std=08 -fsynopsys -v ram_bank.vhd
ghdl -a --std=08 -fsynopsys -v control_rom.vhd
ghdl -a --std=08 -fsynopsys -v mem_test_top.vhd
ghdl -a --std=08 -fsynopsys -v mem_test_top_tb.vhd

ghdl -e --std=08 -fsynopsys -v mem_test_top_tb

echo "Running Test Bench"
#run
ghdl -r --std=08 -fsynopsys mem_test_top_tb --stop-time=5000ns --vcd=mem_test_top_tb.vcd


