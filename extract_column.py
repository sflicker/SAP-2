import csv
import argparse

# Set up the argument parser
parser = argparse.ArgumentParser(description='Extract a column from a CSV file.')
parser.add_argument('input_file', help='The input CSV file.')
parser.add_argument('output_file', help='The output CSV file.')
parser.add_argument('column', type=int, help='The index of the column to extract (starting from 0).')
parser.add_argument('min_rows', type=int, help='The total number of rows. Will pad if shorter')
parser.add_argument('pad_width', type=int, help='For pad rows the number of 0 bits')

# Parse the arguments
args = parser.parse_args()

# Use the arguments
input_filename = args.input_file
output_filename = args.output_file
column_index = args.column  # Column index is now based on user input
min_rows = args.min_rows
pad_width = args.pad_width

with open(input_filename, newline='', encoding='utf-8') as infile, \
     open(output_filename, 'w', newline='', encoding='utf-8') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)

    row_count = 0    
    for row in reader:
        if len(row) > column_index:
            row_count = row_count + 1
            writer.writerow([row[column_index]])

    while row_count < min_rows:
        writer.writerow(['0' * pad_width])
        row_count += 1
        