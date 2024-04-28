#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock_divider.vhd
ghdl -a --std=08 -fsynopsys -v uart_rx.vhd
ghdl -a --std=08 -fsynopsys -v digit_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v segment_decoder.vhd
ghdl -a --std=08 -fsynopsys -v display_controller.vhd

ghdl -a --std=08 -fsynopsys -v uart_top.vhd
ghdl -a --std=08 -fsynopsys -v uart_top_tb.vhd

ghdl -e --std=08 -fsynopsys -v uart_top_tb

echo "Running Test Bench"
#run
ghdl -r --std=08 -fsynopsys -v uart_top_tb --stop-time=10000000ns --vcd=uart_top_tb.vcd



