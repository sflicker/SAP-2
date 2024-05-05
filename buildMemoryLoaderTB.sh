#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock.vhd
ghdl -a --std=08 -fsynopsys -v uart_rx.vhd
ghdl -a --std=08 -fsynopsys -v uart_tx.vhd
ghdl -a --std=08 -fsynopsys -v memory_loader.vhd
ghdl -a --std=08 -fsynopsys -v memory_loader_tb.vhd

ghdl -e --std=08 -fsynopsys -v memory_loader_tb

echo "Running Test Bench"
#run
ghdl -r --std=08 -fsynopsys -v memory_loader_tb --stop-time=40ms --vcd=memory_loader_tb.vcd



