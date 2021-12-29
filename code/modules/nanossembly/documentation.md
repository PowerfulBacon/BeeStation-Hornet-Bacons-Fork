
Instructions
==================

Reference:
Variables will be written as A, B, C... these can be direct values using # such as #100 to represent the value 100,
or with R to represent a value of a register (R0 to represent register 0).
or with P to represent a pointer to memory.

Special Registers
---------------

RL - Link register
RF - Special flag register. Bit 0: Error bit, Bit 1: Comparison equal, Bit 2: Comparison greater
RP - Program register. Points to the currently executing line of code.

Stack instructions
---------------

SPUSH A - Pushes the value of A to the top of the stack. Sets the error flag if the stack has no more space.
SPOP R - Pops the top value off of the stack and puts the value into the specified register. Sets the error flag if the stack is empty.

Register Assignation
---------------

MOV R A - Moves the value of A into R

Arithmetic
---------------

ADD R A B - Performs A + B and stores the result in register R
SUB R A B - Performs A - B and stores the result in register R
DIV R A B - Performs A / B and stores the result in register R
MUL R A B - Performs A * B and stores the result in register R

Logic
---------------

CMP A B - Compares the value of A to the value of B
AND R A B - Performs A & B and stores the resulting value in the register R
OR R A B - Performs A | B and stores the resulting value in the register R

Branching
--------------

// ... is used to represent the same parameters as previous

[label]: - A label
B [label] - Branch to the label, stores the result of the line this was called from in the link register (RL). In order to perform multi-level branch and returns, the value of RL must be popped to the stack before this is called. To finish a branch and return, simply call 'B RL'
B RL - Branches back to the link register, returning the execution to where the branch was executed from.
B A - Branches to the code line with value A.
BGT ... - Branch if the result of the previous comparison was A > B
BGE ... - Branch if the result of the previous comparison was A >= B
BLT ... - Branch if the result of the previous comparison was A < B
BLE ... - Branch if the result of the previous comparison was A <= B
BEQ ... - Branch if the result of the previous comparison was A == B
BNE ... - Branch if the result of the previous comparison was A != B
BERR ... - Branch if the error bit is set and reset the error bit.
BERRNORESET ... - Branch if the error bit is set.

Errors
-------------

SETERR - Sets the error bit to 1
CLRERR - Sets the error bit to 0

Memory + Lists / Strings
---------------

// Lists and strings are basically the same thing, strings are a list of ascii characters.
// These are a bit more complex and require memory management.
// The way these work is as a string, when you put something into memory ascii2text is called to convert the number value provided into a character, which is then inserted at the specified position. When you get something from memory and put it into a register, it is converted to a number using text2ascii.

RESERVE R A - Reserves A sequential elements from memory and stores the pointer to the first element in register R. Can throw an error if unable to reserver the required amount of memory.
FETCH R P - Fetches the value from memory at point P and stores the result in register R
PUT P A - Puts the value of A into the memory at pointer P
MEMLEFT R - Puts the amount of memory slots left into register R
CMPLIST P1 L1 P2 L2 - Checks the list P1 with length L1 against the list P2 with length L2 for matching elements. Valid with BEQ and BNE

Text
--------------

CMPTEXT P1 L1 P2 L2 - Forms 2 strings starting at P with length L and compares them. Valid with BEQ and BNE. (Exactly the same as CMPLIST)

Misc
===============

Radio Controller
---------------

SETFREQ A - Sets the frequency of the transmission to the value of A
