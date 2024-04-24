#! /bin/bash

python3 /home/scott/code/hdl/vhdl/SAP-2/ControlROMAssembler.py
python3 extract_column.py control_rom.csv control_rom.txt 4 1024 33
python3 extract_column.py instruction_index.csv instruction_index.txt 1 256 10
