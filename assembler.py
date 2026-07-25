import sys

def find_labels(lines):
    label_addresses = {}
    curr_byte = 0

    for line in lines:
        # check for comments
        line = line.split("//")[0].strip().upper()
        if not line:
            continue

        fields = line.split(" ")

        if ":" in line:
            label = line.split(":")[0]
            num_string = str(curr_byte)

            label_addresses[label] = num_string

            if len(fields) > 2:
                curr_byte += 2
            elif len(fields) > 1:
                curr_byte += 1
        else:
            if len(fields) > 1:
                curr_byte += 2
            else:
                curr_byte += 1


    return label_addresses

opcodes = {
    "ADD":   "00000000",
    "SUB":   "00000001",
    "AND":   "00000010",
    "OR":    "00000011",
    "XOR":   "00000100",
    "NAND":  "00000101",
    "LDA":   "00000110",
    "STA":   "00000111",
    "CMP":   "00001000",
    "ADDI":  "00001001",
    "ANDI":  "00001010",
    "ORI":   "00001011",
    "XORI":  "00001100",
    "NANDI": "00001101",
    "JMP":   "00001110",
    "JEQ":   "00001111",
    "JNE":   "00010000",
    "JGT":   "00010001",
    "JLT":   "00010010",
    "CMPI":  "00010011",
    "LDI":   "00010100",
    "SL":    "00010101",
    "SR":    "00010110",
    "ASR":   "00010111",
    "NOT":   "00011000",
    "OUT":   "00011001",
    "HLT":   "00011010",
    "WAIT":  "00011011"
}

if len(sys.argv) < 2 or len(sys.argv) > 3:
    print("SYNTAX ERROR\ncorrect format should be \"python assembler.py <src filename> <dst filename>(optional)")
    sys.exit(1)

input_file = sys.argv[1]
if len(sys.argv) == 3:
    output_file = sys.argv[2]
else:
    output_file = "code.txt"

with open(input_file, "r") as file:
    lines = file.readlines()

labels = find_labels(lines)

machine_code = []

for line in lines:
    #check for comments
    line = line.split("//")[0].strip().upper()
    if not line:
        continue

    # check if there is a label "declaration"
    has_label_declaration = False
    declared_label = ""
    if ":" in line:
        has_label_declaration = True
        declared_label = line.split(":")[0]

    fields = line.split()
    index = 0
    if has_label_declaration:
        index += 1
        if len(fields) == 1:
            continue

    instruction = fields[index]

    if instruction in opcodes:
        machine_code.append(opcodes[instruction])

        if len(fields) > 1:
            index += 1
            operand = fields[index]
            if operand in labels and operand != declared_label:
                operand = labels[operand]
            machine_code.append(format(int(operand), '08b'))
    else:
        print("ERROR: UNKNOWN INSTRUCTION: " + instruction)
        sys.exit(1)

with open(output_file, 'w') as file:
    for element in machine_code:
        file.write(element)
        file.write("\n")

print("ASSEMBLY SUCCESSFUL")
