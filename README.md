# SCU-Pipelined-CPU
This project involves the design, implementation, and verification of a 32-bit, 5-stage pipelined CPU using Verilog, based on the SCU Instruction Set Architecture. 

## Authors
Andrew Vattuone, Nico Villegas-Kirchman, Trisha Ganesh

## Description
The CPU supports:
- 11 base instructions (NOP, SVPC, LD, ST, ADD, INC, NEG, SUB, J, BRZ, BRN)
- a 64×32-bit register file
- word-addressed memory

Branch instructions use Zero (Z) and Negative (N) flags from the previous ALU operation to determine conditional execution.

### #1: 1-D Median Stencil Assembly Program
Description:
This SCU ISA assembly program implements a 1-D median stencil for an input array a and output array b of size n. 
For each element b[i] (1 ≤ i ≤ n-2), the program computes the median of three consecutive elements a[i-1], a[i], a[i+1]. 
Boundary elements are handled separately:
- b[0] = a[0]
- b[n-1] = a[n-1]


### #2: Datapath and Control Design
