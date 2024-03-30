#!/bin/bash

echo "Starting Test Bench Script"
echo "Cleaning project"

#clean existing
ghdl --clean

echo "Compiling modules"
#compile

ghdl -a --std=08 -fsynopsys -v clock.vhd
#ghdl -a --std=08 -fsynopsys -v single_pulse_generator.vhd
ghdl -a --std=08 -fsynopsys -v clock_converter.vhd
ghdl -a --std=08 -fsynopsys -v passthrough_clock_converter.vhd
ghdl -a --std=08 -fsynopsys -v clock_controller.vhd
ghdl -a --std=08 -fsynopsys -v segment_decoder.vhd
ghdl -a --std=08 -fsynopsys -v digit_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v display_controller.vhd

#ghdl -a --std=08 -fsynopsys -v ring_counter_6bit.vhd

ghdl -a --std=08 -fsynopsys -v accumulator.vhd
#ghdl -a --std=08 -fsynopsys -v address_rom.vhd
ghdl -a --std=08 -fsynopsys -v ALU.vhd
ghdl -a --std=08 -fsynopsys -v b.vhd
#ghdl -a --std=08 -fsynopsys -v controller_rom.vhd
ghdl -a --std=08 -fsynopsys -v IR.vhd
ghdl -a --std=08 -fsynopsys -v mar.vhd
ghdl -a --std=08 -fsynopsys -v pc.vhd
ghdl -a --std=08 -fsynopsys -v output.vhd
#ghdl -a --std=08 -fsynopsys -v presettable_counter.vhd
ghdl -a --std=08 -fsynopsys -v ram_bank.vhd
ghdl -a --std=08 -fsynopsys -v w_bus.vhd
ghdl -a --std=08 -fsynopsys -v proc_controller.vhd
ghdl -a --std=08 -fsynopsys -v proc_top.vhd
ghdl -a --std=08 -fsynopsys -v proc_top_tb.vhd
#

ghdl -e --std=08 -fsynopsys -v proc_top_tb

echo "Running Test Bench"
#run
ghdl -r --std=08 -fsynopsys -v proc_top_tb -gTest_Name="PowerOn" --stop-time=1000ns --vcd=PowerOnTest.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_tb -gTest_Name="Execute" --stop-time=10000ns --vcd=ExecuteTest.vcd


