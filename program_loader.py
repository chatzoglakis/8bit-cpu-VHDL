import serial
import time
import sys

if len(sys.argv) != 2:
    print("SYNTAX ERROR: NO PROGRAM GIVEN")
    sys.exit(1)

ser = serial.Serial('COM3', 9600)
time.sleep(2) # Give the port a second to initialize

with open(sys.argv[1], "r") as file:
    lines = file.readlines()

firmware = []
#Convert the text into raw bytes
for line in lines:
    clean_line = line.strip()

    # Skip any empty lines at the bottom of the text file
    if len(clean_line) > 0:
        # Convert the string (base 2) into a real integer
        raw_byte = int(clean_line, 2)
        firmware.append(raw_byte)

print(f"Uploading {len(firmware)} bytes...")

# Send the bytes one by one
for byte in firmware:
    ser.write(bytes([byte]))
    time.sleep(0.001) # Tiny pause to not overwhelm the FPGA

print("Upload complete")
ser.close()
