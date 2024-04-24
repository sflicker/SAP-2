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
ghdl -a --std=08 -fsynopsys -v StatusRegister.vhd
ghdl -a --std=08 -fsynopsys -v memory_data_register.vhd
ghdl -a --std=08 -fsynopsys -v ProgramCounter.vhd
ghdl -a --std=08 -fsynopsys -v passthrough_clock_converter.vhd
ghdl -a --std=08 -fsynopsys -v clock_controller.vhd
ghdl -a --std=08 -fsynopsys -v segment_decoder.vhd
ghdl -a --std=08 -fsynopsys -v digit_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v display_controller.vhd
ghdl -a --std=08 -fsynopsys -v memory_input_multiplexer.vhd
ghdl -a --std=08 -fsynopsys -v IO_controller.vhd
ghdl -a --std=08 -fsynopsys -v StackPointer.vhd
#ghdl -a --std=08 -fsynopsys -v input_port_multiplexer.vhd
#ghdl -a --std=08 -fsynopsys -v ring_counter_6bit.vhd

ghdl -a --std=08 -fsynopsys -v register.vhd
#ghdl -a --std=08 -fsynopsys -v accumulator.vhd
#ghdl -a --std=08 -fsynopsys -v address_rom.vhd
ghdl -a --std=08 -fsynopsys -v ALU.vhd
#ghdl -a --std=08 -fsynopsys -v b.vhd
#ghdl -a --std=08 -fsynopsys -v controller_rom.vhd
#ghdl -a --std=08 -fsynopsys -v IR.vhd
ghdl -a --std=08 -fsynopsys -v IR_operand_latch.vhd
#ghdl -a --std=08 -fsynopsys -v mar.vhd
#ghdl -a --std=08 -fsynopsys -v pc.vhd
#ghdl -a --std=08 -fsynopsys -v output.vhd
#ghdl -a --std=08 -fsynopsys -v presettable_counter.vhd
ghdl -a --std=08 -fsynopsys -v ram_bank.vhd
ghdl -a --std=08 -fsynopsys -v w_bus.vhd
ghdl -a --std=08 -fsynopsys -v proc_controller.vhd
ghdl -a --std=08 -fsynopsys -v proc_top.vhd
ghdl -a --std=08 -fsynopsys -v proc_top_filebased_tb.vhd
#

ghdl -e --std=08 -fsynopsys -v proc_top_filebased_tb

echo "Running Test Bench"
#run
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="test_program_1.txt" --stop-time=100000ns --vcd=test_program_1.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="load_accumulator_test.txt" --stop-time=20000ns --vcd=load_accumulator_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="store_accumulator_test.txt" --stop-time=20000ns --vcd=store_accumulator_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="mvi_test.txt" --stop-time=20000ns --vcd=mvi_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="jump_test.txt" --stop-time=20000ns --vcd=jump_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="loop_test.txt" --stop-time=100000ns --vcd=loop_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="loop_test_with_output.txt" --stop-time=150000ns --vcd=loop_test_with_output.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="out_test.txt" --stop-time=10000ns --vcd=out_test.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="out_test2.txt" --stop-time=10000ns --vcd=out_test2.vcd
ghdl -r --std=08 -fsynopsys -v proc_top_filebased_tb -gfile_name="call_test.txt" --stop-time=250000ns --vcd=call_test.vcd




