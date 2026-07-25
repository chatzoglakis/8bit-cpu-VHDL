import serial
import time
import sys

if len(sys.argv) != 1:
    print("SYNTAX ERROR: NO PROGRAM GIVEN")
    sys.exit(1)

ser = serial.Serial('COM3', 9600)
time.sleep(2) # Give the port a second to initialize

with open(sys.argv[0], "rb") as file:
    firmware = file.read()

print(f"Uploading {len(firmware)} bytes...")

# Send the bytes one by one
for byte in firmware:
    ser.write(bytes([byte]))
    time.sleep(0.001) # Tiny pause to not overwhelm the FPGA

print("Upload complete")
ser.close()
