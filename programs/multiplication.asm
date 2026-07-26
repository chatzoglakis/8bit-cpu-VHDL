//This Program implements the Russian Peasant Algorithm to multiply the numbers 5 and 3

LDI 0
STA 253     // FD holds the final result

LDI 5     // Multiplier
STA 255
LDI 3     // Multiplicand
STA 254

loop:
LDA 255
CMPI 0
JEQ exit     //jump at the end if one

ANDI 1    // AND A with 1. (If A is odd, result is 1. If even, result is 0)
CMPI 0
JEQ shifts     // If the result was 0 (A is even), skip the addition

//ADDITION
LDA 253
ADD 254
STA 253

shifts:
LDA 254
SL
STA 254

LDA 255
SR
STA 255

JMP loop

exit:
//OUTPUT RESULT
LDA 253
OUT
HLT