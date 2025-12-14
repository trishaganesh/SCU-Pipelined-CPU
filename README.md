# SCU-Pipelined-CPU
This project involves the design, implementation, and verification of a 32-bit, 5-stage pipelined CPU using Verilog, based on the SCU Instruction Set Architecture. 

## Authors
Andrew Vattuone, Nico Villegas-Kirchman, Trisha Ganesh

## Description

Modern processors rely on instruction pipelining to achieve high throughput, allowing multiple instructions to occupy execution stages simultaneously. A Verilog implementation of a 32-bit pipelined processor was designed to support the SCU Instruction Set Architecture (ISA), including 64 general purpose registers, five pipeline stages (IF, ID, EX, MEM, WB), and a word-addressed memory model.  The design included the construction of the datapath and control logic that provide support for 11 core  instructions: NOP, SVPC, LD, ST, ADD, INC, NEG, SUB, J, BRZ, and BRN, along with branch logic handling and to ensure correct execution. To evaluate correctness and performance, a benchmark program was developed to compute a one-dimensional median stencil over an array of 32-bit signed Integers. The final waveform simulation confirmed instruction flow, hazard resolution, and correctness of results. Together,  these components help us understand how a pipelined processor executes instructions efficiently and correctly.                                          

The 32-bit pipelined CPU was designed to support the SCU Instruction Set Architecture (ISA), featuring  64 general-purpose registers (x0–x63), a word-addressed memory model, and five pipeline stages: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB). These five pipeline stages help increase instruction throughput by overlapping execution and by reducing the critical path for each stage. The CPU supports the execution of 11 core instructions: NOP, SVPC, LD, ST, ADD, INC, NEG, SUB, J, BRZ, and BRN, while handling branch logic and pipeline hazards to ensure proper execution. 

During the IF stage, instructions are fetched from memory using the Program Counter (PC), incrementing sequentially and updates based on the jump or branch instructions. Sequential fetching helps ensure a smooth instruction flow, well the branch updates allow correct program flow. The instruction is decoded during the ID stage and reads operands from the register file, extracting any immediate values. This ensures that decoding and operating fetching do not delay any arithmetic or memory operations. 

During the EX stage, the ALU performs both arithmetic and logical operations (addition, subtraction, negation) or directly passes values when they are required. The branch instructions are evaluated using zero (Z) and negative (N) flags from the previous ALU operation (from the later MEM stage), allowing efficient execution without needing additional instructions. Lastly, the MEM stage accesses the memory for load (LD) and store (ST) instructions and the WB stage writes the computed results back to the destination register, ensuring consistency. 

The datapath includes the register file, ALU, multiplexers for operand selection, PC-update core logic, and memory units. Control signals are generated based on the instruction opcodes for the ALU, memory access, branch decisions, and register writes. The truth table maps the opcodes to control outputs. This ensures the correct execution and handling of hazards, including the NOP insertion. NOP insertion was implemented to handle data hazards and prevent conflicts between instructions that depend on previous results. This maintains correctness without complex forwarding logic. For example, in the 1-D median stencil program, the LD instructions load consecutive array elements efficiently from memory. The ADD and SUB instructions compute differences to compute the median while the ST instructions store the results in the output array. Pipeline hazards are carefully managed with NOP insertion to prevent any conflict between memory and arithmetic operations. Furthermore, the waveform simulations confirm proper instruction flow, memory access, branch execution, and accuracy in results. Overall, the CPU design illustrates how choices in datapath, branch execution, and management of hazards allow the processor to execute instructions efficiently and correctly, while supporting all 11 SCU ISA instructions in a cohesive Verilog implementation. 


## Components

### #1: 1-D Median Stencil Assembly Program
The 1-D median stencil assembly program serves as a benchmark to evaluate the correctness and performance of the 32-bit pipelined CPU. It processes an input array of 32-bit signed integers and computes the median of each interior element based on its neighbors, storing the results in an output array. The conditions are handled explicitly for the first and last elements, and ensure correctness for all array sizes. The program demonstrates the ability to execute the full SCU ISA, including the arithmetic operations ADD and SUB, the memory operations LD and ST, and the branch instructions BRN and BRZ, while correctly handling pipeline hazards through NOP insertion. The program includes comments and labels to provide readability, making the program both functional and a thorough demonstration of the CPU’s instruction flow, correct data handling, and hazard resolution. Note that at the very end we also included a NEG instruction since we’re required to demo it, although it doesn’t do anything for the 1-d stencil code itself.

### #2: Datapath and Control Design

### #3: Control Truth Table
SCU ISA Truth Table:
