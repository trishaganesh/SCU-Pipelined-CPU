# SCU-Pipelined-CPU
This project involves the design, implementation, and verification of a 32-bit, 5-stage pipelined CPU using Verilog, based on the SCU Instruction Set Architecture. 

## Authors
Andrew Vattuone, Nico Villegas-Kirchman, Trisha Ganesh

## Description

Modern processors rely on instruction pipelining to achieve high throughput, allowing multiple instructions to occupy execution stages simultaneously. A Verilog implementation of a 32-bit pipelined processor was designed to support the SCU Instruction Set Architecture (ISA), including 64 general purpose registers, five pipeline stages (IF, ID, EX, MEM, WB), and a word-addressed memory model.  The design included the construction of the datapath and control logic that provide support for 11 core  instructions: NOP, SVPC, LD, ST, ADD, INC, NEG, SUB, J, BRZ, and BRN, along with branch logic handling and to ensure correct execution. To evaluate correctness and performance, a benchmark program was developed to compute a one-dimensional median stencil over an array of 32-bit signed Integers. The final waveform simulation confirmed instruction flow, hazard resolution, and correctness of results. Together,  these components help us understand how a pipelined processor executes instructions efficiently and correctly.                                          

The CPU supports:
- 11 base instructions (NOP, SVPC, LD, ST, ADD, INC, NEG, SUB, J, BRZ, BRN)
- a 64×32-bit register file
- word-addressed memory

Branch instructions use Zero (Z) and Negative (N) flags from the previous ALU operation to determine conditional execution.

## Components
### #1: 1-D Median Stencil Assembly Program
Description:
This SCU ISA assembly program implements a 1-D median stencil for an input array a and output array b of size n. 
For each element b[i] (1 ≤ i ≤ n-2), the program computes the median of three consecutive elements a[i-1], a[i], a[i+1]. 
Boundary elements are handled separately:
- b[0] = a[0]
- b[n-1] = a[n-1]


### #2: Datapath and Control Design
