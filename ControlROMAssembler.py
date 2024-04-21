import csv

input_filename = "SAP-2 Microprogram control rom - Sheet1.csv"
output_filename = "control_rom.csv"
index_filename = "instruction_index.csv"

def read_control_signals(filename):
    with open(filename, newline='') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # skip the format line
        next(reader) 
        return [row for row in reader]
    
def write_control_rom_settings(control_signals):

    control_rom_data = []
    with open(output_filename, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        for row_number, signals in enumerate(control_signals):
            op = signals[0]
            opcode = signals[1]
            comment = signals[2]
            binary_string = ''.join(signals[3:])
            row = [row_number, op, opcode, comment, binary_string]
            control_rom_data.append(row)
            writer.writerow(row)

    return control_rom_data

def find_nop_index(control_rom_data):
    nop_index = '0'
    for fields in control_rom_data:
        row_number, op, opcode = fields[0], fields[1], fields[2]
        if op == "NOP":
            nop_index = row_number
            break
    return nop_index

def build_and_write_instruction_index(control_rom_data, nop_index):
    opcode_index = {opcode: nop_index for opcode in range(256)}

    first_opcode_index = {}
    for fields in control_rom_data:
        str_opcode = fields[2]
        row_number = fields[0]
        print ("str_opcode: ", str_opcode, ", row_number: ", row_number)
        if str_opcode: 
            hex_opcode = int(str_opcode, 16)
            if hex_opcode not in first_opcode_index:
                opcode_index[hex_opcode] = row_number
                first_opcode_index[hex_opcode] = row_number

    with open(index_filename, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        for opcode in range(256):
            bin_index = format(opcode_index[opcode], '010b') 
            writer.writerow([f"{opcode:02X}", bin_index])


control_signals = read_control_signals(input_filename)
control_rom_data = write_control_rom_settings(control_signals)
nop_index = find_nop_index(control_rom_data)
build_and_write_instruction_index(control_rom_data, nop_index)

print(f"Control ROM settings written to {output_filename}")
print(f"Instruction Index Written to {index_filename}")

