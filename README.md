# SCU Pipelined CPU
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
The 1-D median stencil assembly program serves as a benchmark to evaluate the correctness and performance of the 32-bit pipelined CPU. It processes an input array of 32-bit signed integers and computes the median of each interior element based on its neighbors, storing the results in an output array. The conditions are handled explicitly for the first and last elements, and ensure correctness for all array sizes. The program demonstrates the ability to execute the full SCU ISA, including the arithmetic operations ADD and SUB, the memory operations LD and ST, and the branch instructions BRN and BRZ, while correctly handling pipeline hazards through NOP insertion. The program includes comments and labels to provide readability, making the program both functional and a thorough demonstration of the CPU’s instruction flow, correct data handling, and hazard resolution. Note that at the very end we also included a NEG instruction, although it doesn’t do anything for the 1-d stencil code itself.

### #2: Datapath and Control Design
SCU ISA Datapath: 

<img width="933" height="501" alt="Screen Shot 2025-12-22 at 3 09 59 PM" src="https://github.com/user-attachments/assets/6f6f9b87-6456-45fe-8e81-072118238231" />

The datapath diagram utilizes a color-coded signal design to track when signals are active during each pipeline stage: blue for EX, green for MEM, and red for WB. As for the branch instructions (BRZ/BRN), branch control signal from the EX stage is forwarded directly to the MEM stage, bypassing the EX/MEM buffer. This ensures that the branch decision uses the zero (Z) or the negative (N) flags from the preceding instruction, available in the MEM stage. This allows correct determination of whether to Branch without needing to stall the pipeline. Furthermore, this design choice illustrates how control signals and data dependencies are managed in the pipeline to maintain correct instruction flow and hazard resolution. Precise distinction between BRZ and BRN branch conditions further improves correctness. 

### #3: Control Truth Table
SCU ISA Truth Table:

<img width="899" height="246" alt="Screen Shot 2025-12-22 at 3 12 35 PM" src="https://github.com/user-attachments/assets/bf2794b2-1c54-4a3e-80fe-46341f4b2c77" />

The control truth table defines the set of control signals for each of the 11 SCU ISA instructions, ensuring that the datapath components are correct during execution. Each row of the table maps an instruction opcode to its corresponding control outputs, memory access, register writes, and branch. A 0 means that the control will not be activated while a 1 means it will be activated. The values that contain Xs means that we do not care about the result. Whether that operation is activated or not, with an X there, it means it will have no effect on the result.


### #4: Performance Analysis
The instruction count of our program is dependent on the problem size n as well as the specific values of the inputted array a (note that for the instruction count we are including the NOP at the end of the original program and the NEG demonstration instruction at the end of the new program). Initially, since our BRZ, BRN, and J instructions all determined whether to jump or not in the EX stage, we decided to include two NOPs after each of these branching instructions. This was similar to what we found, where 3 NOPs needed to be added after each branch instruction to prevent branching hazards (in our case, since it occurred in the EX stage, we needed only 2 NOPS). However, while we were testing our code, we noticed that the BRZ, BRN, and J instructions were skipping over the second NOP instruction whenever a branch was taken, but the second NOP was not skipped when the branch wasn’t taken. Upon further review, we realized that because our buffers update on the negedge of the clock while our functional units update on the posedge, this means that when BRZ, BRN, and J calculate their values in the EX stage, they are guaranteed to be immediately placed into the IF stage and overwrite any incoming instructions. This means that only the instructions in the ID stage are lost rather than in both the IF and ID stages, so technically only one NOP would be needed rather than two. Therefore, the total number of instructions executed slightly depends on how many branch instructions result in a branch taken or not, as it will determine if the second NOP will be executed or skipped over. Functionally everything is correct, and the only difference is that it makes the CPI slightly more difficult to count without knowing the exact input beforehand. So when the number of instructions executed are counted later in this section, just note that the second NOP after a branch instruction will be skipped only if the branch is taken, which means it doesn’t count toward total instruction execution count.

Aside from the number of NOPs that are executed, the number of instructions executed inside the for loop is dependent on the exact values of a[i-1], a[i], a[i+1]. While the first 20 instructions for setting up the values and the last 7 to determine if another loop iteration should be performed always execute for each iteration of the loop, the number of instructions executed within the if-else block is not always the same. For example, suppose a[i-1] = 3, a[i] = 1, and a[i+1] = 5. Based on tracing out the if-else block manually for this example, 4 instructions execute for the if a[i-1] >= a[i] comparison (branch not taken since true), 3 instructions during the if a[i] >= a[i+1] comparison (branch taken since false, so skip second NOP), 3 instructions during the else if a[i-1] >= a[i+1] comparison (branch taken since false, so skip second NOP), and 3 instructions to set b[i] = a[i-1] = 3 (skip second NOP since branch always taken for J), for a total of 4 + 3 + 3 + 3 = 13 instructions. However, let’s look a different example where a[i-1] = 5, a[i] = 7, and a[i+1] = 2. Tracing this out manually yields 3 executed instructions for the if a[i-1] >= a[i] comparison (branch taken since false, so skip second NOP), 4 instructions for the if a[i-1] >= a[i+1] comparison (branch not taken since true, so include second NOP), and 3 instructions to set b[i] = a[i-1] = 5 (skip second NOP since branch always taken for J), for a total of 3 + 4 + 3 = 10 instructions executed. Thus, the number of instructions executed per loop is not always a fixed value and depends on the exact values of a[i-1], a[i], and a[i+1], making exact CPI calculation for n inputs more difficult.

Finally, the number of instructions executed is not entirely dependent on the number of loop iterations, as if n = 0, n = 1, or n = 2, a smaller but fixed number of instructions will run for these cases, regardless of the exact value of the inputs of the array a. In the case of n = 0, 1 instruction will run to set x0 = 0, 9 instructions to set the SVPC values, 3 instructions to check if n == 0 (note the second NOP is skipped since the branch is taken), 1 instruction for the NOP at the end of the 1-d median stencil portion of the program that represents the end of the program, and 1 instruction for the NEG demo instruction at the new end of the program, for a total of 1 + 9 + 3 + 1 + 1 = 15 instructions. In the case of n = 1, the first 10 instructions will run just like in the n = 0 case, 4 instructions will execute to check if n <= 0 (the second NOP is NOT skipped in this case since the branch is NOT taken), 5 instructions to set b[0] = a[0], 1 instruction to set i = 0, 3 instructions to check if n == 1 (not the second NOP is skipped since the branch is taken), and the same 2 NOP and NEG instructions at the end of the program as when n = 0, for a total of 10 + 4 + 5 + 1 + 3 + 2 = 25 instructions. Finally, when n = 2, the first 20 instructions will run just as they did for the case n = 1, then 4 instructions to check if n == 1 (the second NOP is NOT skipped in this case since the branch is NOT taken), 3 instructions to check if n == 2 (the second NOP is skipped in this case since the branch is taken), 13 instructions to set b[n] = a[n], and the 2 instructions at the end (NOP and NEG), for a total of 20 + 4 + 3 + 13 + 2 = 42 instructions. Only in the cases when n = 0, n = 1, and n = 2 will the exact number of instructions always be known regardless of the values of the array a.

For any cases where n > 2, the first 28 instructions of the program will always execute (since the n == 2 comparison is false, the branch isn’t taken, so the NOP is included in this case), while the final 15 instructions will also always execute, for a total of 28 + 15 = 43 instructions. However, the number of loop instructions depends not only on n, but also on the exact values of the array a (as mentioned earlier in the if-else loop block section). Therefore, to calculate the CPI, we will calculate the maximum number of instructions that could execute in the loop and the minimum number of instructions that could execute in the loop, which will form a range for the possible number of instructions that could execute for a given array of length n > 2. It’s always the case that the first 20 and last 7 instructions run within the loop (except for the very last iteration, which will run 8 times), so 27 instructions will run regardless of the exact values of a. For a single if-else block, the maximum number of instructions that could execute is 4 + 3 + 3 + 3 = 13, while the minimum number of instructions that could execute is 3 + 4 + 3 = 10. Therefore, the maximum number of instructions run per iteration will be (n - 3)*(27 + 13) + (28 + 13) = 40n - 79, while the minimum number of instructions run per iteration will be (n - 3)*(27 + 10) + (28 + 10) = 37n - 73. So the total number of instructions that will run for cases when n > 2 will be between 43 + 37n - 73 = 37n - 30 instructions and 43 + 40n - 79 = 40n - 36 instructions. 
The table below summarizes all the different possible instruction counts based on the input size n:

| Value of Input Size n  |                      Instruction Count                            |
|     :---:              |                            :---:                                  |
|       n &lt;= 0        |                       15 Instructions                             |
|        n = 1           |                       25 Instructions                             |
|        n = 2           |                       42 Instructions                             |
|        n > 2           | 37n - 30 Instructions  Total Instructions  40n - 36 Instructions  |



Counting the total number of instructions yields 15, 25, and 42 for n = 0, n = 1, and n = 2, respectively. To verify this is true, we can use a waveform to determine the time each program finishes reading the final instruction and then use the clock cycle of 10ns to determine the total number of instructions read and thus verify if our values are correct or not. We will do this in the next section after describing the CPI equations. 

Because this datapath is pipelined, all instructions will take only 1 cycle to complete, except for the very last instruction (the NEG instruction), which will take 5 cycles to complete. Therefore, to calculate the total number of cycles it takes for a particular program to complete based on input size n, just add 4 (5 cycles for NEG - 1 cycle for original NEG = 4 cycles). To calculate the CPI, all we need to do is take the total number of cycles and divide it by the total number of instructions executed in the program. The table below shows this for all possible values of the input size n:

| Value of Input Size n  |                      CPI                                                                                                                |
|     :---:              |                            :---:                                                                                                        |
|       n &lt;= 0        |                       (15 + 4 cycles) / 15 instructions = 19 cycles / 15 instructions = 1.266667 CPI                                        |
|        n = 1           |                       (25 + 4 cycles) / 25 instructions = 29 cycles / 25 instructions = 1.16 CPI                                            |
|        n = 2           |                       (42 + 4 cycles) / 42 instructions = 46 cycles / 42 instructions = 1.095238 CPI                                        |
|        n > 2           |Max CPI = (40n - 36 + 4 cycles) / (40n - 36 instructions) = (40n - 32 cycles) / (40n - 36 instructions) = (40n - 32) / (40n - 36) CPI <br /> Min CPI = (37n - 30 + 4 cycles) / (37n - 30 instructions) = (37n - 26 cycles) / (37n - 30 instructions) = (37n - 26) / (37n - 30) CPI <br /> Therefore: (37n - 26) / (37n - 30) CPI <= Actual CPI <= (40n - 32) / (40n - 36) CPI                                                      |

To test if these CPIs are correct, we can use waveforms just like we proposed for the instruction counts. We will verify the correctness of both the instruction counts and the CPIs with waveforms below. In all cases, the start time is at 0ns and the clock rate is 10ns, as it flips its value every 5ns. The waveform below proves both of these facts. We will use these values for all 4 cases (n = 0, n = 1, n = 2, n > 2), and the input array a will be the same default array of [3,1,5,7,2,9,8] starting at address 2 while b will start at address 71.

<img width="430" height="251" alt="Screen Shot 2025-12-22 at 3 17 01 PM" src="https://github.com/user-attachments/assets/5c63de11-1ee4-450a-bdfb-8ad49192b2b2" />


Case 1 (n = 0):
For the instruction count of n = 0, the program finishes reading its final instruction (instruction 111) at 150ns (note that the program still needs a few cycles to fully finish everything, but we’ll save that for the CPI section), indicating that the execution time is  150ns. And since the clock flips every 5ns, this means that one full clock cycle takes 10ns, so it takes 10ns to read one instruction. Therefore, the total number of instructions executed is equal to 150ns / 10ns = 15, which is the same as the number of instructions we manually counted earlier. 

<img width="482" height="225" alt="Screen Shot 2025-12-22 at 3 18 35 PM" src="https://github.com/user-attachments/assets/44a832c9-ba9f-4917-be8e-8ccaa295f2be" />


For the cycle count of n = 0, the waveform below shows that the program finally finishes the execution its final instruction when it loads in -71 into x35 at 190ns (note that technically this occurs 5ns earlier because functional units update on posedge while buffers update on negedge, but the cycle isn’t complete until it finishes the last 5ns so we need to wait 5ns before the 10ns cycle is truly over). Therefore, the total number of clock cycles is 190ns / 10ns/clock cycle = 19 clock cycles, which is what we calculated earlier by hand. Using the observed number of clock cycles and number of instructions, we can calculate the CPI as 19 cycles / 15 instructions = 1.266667 CPI, which is exactly the same as our earlier theoretical calculated version. Note also that the program is behaving completely correctly, with x35 being set to -x3 = -71 and all of the values of b (note that it starts at memory location 71) remaining 0 since n = 0. 

<img width="483" height="212" alt="Screen Shot 2025-12-22 at 3 19 41 PM" src="https://github.com/user-attachments/assets/7efac06a-7f34-4edc-8457-046f76df0d0b" />

Case 2 (n = 1):
For the instruction count of n = 1, the program finishes reading the final instruction at 250ns, as seen in the waveform below. Since it takes 10ns to read one instruction, the total number of instructions executed is therefore 250ns / 10ns/instruction = 25 instructions, which is exactly the same number of instructions we calculated earlier for n = 1.

<img width="475" height="255" alt="Screen Shot 2025-12-22 at 3 20 53 PM" src="https://github.com/user-attachments/assets/12e3f877-5d48-4a62-ae33-617aa2c2d64d" />


For the cycle count when n = 1, the program finally finishes loading in all its values at 290ns. Therefore, the total number of clock cycles is 290ns / 10ns/clock cycle = 29 clock cycles, which is what we calculated earlier by hand. The CPI is therefore 29 clock cycles / 25 instructions = 1.16 CPI, which is exactly the same value that we calculated earlier in the table. Note also that the program is behaving completely correctly, with x35 being set to -x3 = -71 and b[0] = 3 while all other values remain 0, which is expected when n = 1.

<img width="479" height="206" alt="Screen Shot 2025-12-22 at 3 21 41 PM" src="https://github.com/user-attachments/assets/5558327a-250f-4789-8c82-e8f7ffd98f3f" />


#### Case 3 (n=2):
	For the instruction count for n = 2, the program finishes reading the final instruction at 420ns, as seen in the waveform below. Since it takes 10ns to reach each instruction, the total number of instructions executed is equal to 420ns / 10ns/instruction = 42 instructions, which is exactly what we calculated by hand in the table for n = 2. 

<img width="478" height="216" alt="Screen Shot 2025-12-22 at 3 22 40 PM" src="https://github.com/user-attachments/assets/dff20782-006c-4ce6-808f-f701810979df" />

For the cycle count for n = 2, the program finishes loading in its final value at 460ns. Therefore, the total number of clock cycles is 460ns / 10ns/cycle = 46 cycles. The CPI is therefore 46 cycles / 42 instructions = 1.095238 CPI, which is the exact value we calculated by hand earlier in the table. Note also that the program is behaving completely correct, with x35 being set to -x3 = -71 and b[0] = 3 and b[1] = 1 while all other values remain 0, which is expected when n = 2.

<img width="479" height="213" alt="Screen Shot 2025-12-22 at 3 22 52 PM" src="https://github.com/user-attachments/assets/2ae4cdfe-a2d6-4578-959e-7bc7e8b995ff" />

#### Case 4 (n > 2):
	For the case when n > 2, we will now use the full default array of [3,1,5,7,2,9,8], which we were already using for our earlier tests for n = 0, n = 1, and n = 2. However, since we’re using the full array, we’ll now set n = 7 and run the program for that. While the exact instruction and cycle count can’t be known just by knowing the value of n alone, we can calculate the range it’s guaranteed to fall under. The instruction count should be somewhere between 37*7 - 30 = 229 instructions and 40*7 - 36 = 244 instructions, while the CPI should be somewhere between (40*7 - 32) / (40*7 - 36) = 248/244 = 1.0165 and (37*7 - 26) / (37*7 - 30) = 233/229 = 1.0175 CPI. 

Because in our particular case we know the values of the array ahead of time, we can manually calculate the number of instructions. Note that this cannot be done in cases where we do not know the exact values of a beforehand. By carefully tracing through every individual instruction, we can determine the total instruction count to be 28 + (20 + (4 + 3 + 3 + 3) + 7) + (20 + (3 + 3 + 3 + 1) + 7) + (20 + (3 + 4 + 3) + 7) + (20 + (4 + 3 + 3 + 3) + 7) + (20 + (3 + 3 + 4 + 3) + 8) + 14 + 1 = 238 instructions, and since 229 < 238 < 244, this means that our instruction count range estimate is correct. There will be 4 more cycles following the final instruction, for a total of 238 + 4 = 242 cycles, and since 233 < 244 < 248, our cycle range is also therefore correct. The CPI is equal to 242 cycles / 238 instructions = 1.0168 CPI, and since 1.0165 < 1.0168 < 1.0175, this proves that our CPI estimation range is correct according to our by-hand calculation.

Now we’ll test the actual values using the waveforms. For the instruction count, the final instruction is read at 2380ns. Since each instruction takes 10ns to read, this means that the total number of instructions executed is 2380ns / 10ns/instruction = 238 instructions, which is the exact value we calculated by hand above, proving both our by-hand instruction count calculation to be correct and our instruction count range to be correct since 229 < 238 < 244. 

<img width="471" height="224" alt="Screen Shot 2025-12-22 at 3 23 38 PM" src="https://github.com/user-attachments/assets/57c59af3-ab6c-47a6-9d53-a7641dad4fd5" />

For the cycle count, the program finally finishes executing its last instruction by setting x35 = -71 at 2420ns. The total number of clock cycles is therefore 2420ns / 10ns/cycle = 242 cycles, which is the exact value we calculated by hand above. Therefore, the CPI must be 242 cycles / 238 instructions = 1.0168 CPI, and since 1.0165 < 1.0168 < 1.0175, this proves that our CPI estimation range is correct, both through our by-hand calculation and through the waveform.

<img width="475" height="213" alt="Screen Shot 2025-12-22 at 3 24 40 PM" src="https://github.com/user-attachments/assets/4f791a69-82f6-4893-b1dd-13ae79282cb5" />

#### Results:
The total execution time for each case is as follows:
n  = 0: 19*2 = 38 ns
n = 1: 29*2 = 58 ns
n = 2: 46*2 = 92 ns
n > 2: (37n-26)*2 < Execution Time < (40n-32)*2 = 74n-52 ns < Execution Time < 80n-64 ns

### #5: Verification
For verification, a testbench, exercising the 32-bit SCU pipelined CPU and its full instruction set was developed. Arithmetic operations (ADD, SUB, NEG, INC), memory operations (LD, ST), control flow (J, BRZ, BRN), and SVPC were included. The register and the data memory were initialized with representative values to test a variety of scenarios. The test bench runs the entire assembly program on the CPU, simulating all pipeline stages, and captures signals such as PC, instruction fetch, register reads/writes, ALU results, and control signals across the IF, ID, EX, MEM, and WB stages.

The waveforms were examined to verify correct execution of each instruction and proper propagation of the control signals through pipeline registers. There were specific cases that were tested: arrays of length n=0, ensuring that the program exits without any error, n=1 (which verifies b[0]=a[0]), and n=2 which checks the correct handling of the loop b[n-1]=a[n-1]. In addition, branch instructions (BRZ/BRN) were tested for cases, confirming correct use of the Z and N flags from the previous instruction. Both load and store instructions were verified by initializing memory and observing correct read and write values. Furthermore, jump instructions and SVPC operations were confirmed to correctly update the program counter. The resulting waveform shows that all instructions produce the expected results, control signals activate at the current stages, hazards are properly managed, and the cases behave as intended, all of which provide full verification of the CPU functionality. 

The below waveform is for the default case, when a = [3,1,5,7,2,9,8], n = 7, &a = 2, and &b = 71.

<img width="501" height="252" alt="Screen Shot 2025-12-22 at 3 25 14 PM" src="https://github.com/user-attachments/assets/a684b510-eacd-4940-9184-347d0cb1b382" />

The below waveform is for the same above array except testing when n = -1. It shouldn’t change any of the values of b, and the waveform shows this, so it’s correct for this case.

<img width="477" height="280" alt="Screen Shot 2025-12-22 at 3 26 34 PM" src="https://github.com/user-attachments/assets/d4570a03-7821-4fdb-ae55-1abc7d2c1f6b" />

For cases when n = 0, n = 1, n = 2, see the earlier waveforms in the CPI sections. We noted that for all cases, the output behaves exactly as expected.



                                  





