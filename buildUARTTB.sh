#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v uart_rx.vhd
ghdl -a --std=08 -fsynopsys -v uart_tx.vhd
ghdl -a --std=08 -fsynopsys -v uart_tb.vhd

ghdl -e --std=08 -fsynopsys -v uart_tb

echo "Running Test Bench"
#run
ghdl -r --std=08 -fsynopsys -v uart_tb --stop-time=10000000ns --vcd=uart_tb.vcd



