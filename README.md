# 32-bit Pipelined MIPS Processor 

## Overview

This project implements a 32-bit, five-stage pipelined processor in Verilog based on a MIPS-style instruction set architecture. The design includes instruction fetch, decode, execute, memory, and writeback stages, along with hazard detection and data forwarding to support correct pipeline operation.

The processor was developed as part of a digital design course and focuses on fundamental pipeline concepts, including data hazards, control hazards, and inter-stage communication.

## Key Features

- Five-stage pipeline: IF, ID, EX, MEM, WB
- Data hazard handling using data forwarding 
- Load-use hazard detection with pipeline stalling
- Control hazard handling via pipeline flush on branch/jump
- Register file with dual read ports and single write port
- Parameterized modules for reuse 
- Modular RTL design with clear stage separation

## Architecture Overview

The processor is organized as a standard five-stage pipeline:

1. **Instruction Fetch (IF)** – Program counter update and instruction retrieval  
2. **Instruction Decode (ID)** – Register file access, control signal generation, and branch evaluation  
3. **Execute (EX)** – ALU operations and operand selection with forwarding  
4. **Memory (MEM)** – Data memory access for load/store instructions  
5. **Writeback (WB)** – Results written back to the register file  

Pipeline registers are used between each stage to maintain instruction flow, and dedicated units handle hazard detection and forwarding.

## Hazard Handling

The processor includes mechanisms to handle common pipeline hazards:

- **Data Hazards**
  - Forwarding unit resolves most RAW hazards using EX/MEM and MEM/WB paths
  - Load-use hazards are detected and resolved by stalling the pipeline for one cycle

- **Control Hazards**
  - Branch decisions are made in the decode stage
  - The pipeline is flushed on taken branches and jumps to prevent incorrect instruction execution
 
## Limitations

- This design follows a course-defined MIPS-style architecture and does not fully implement the complete MIPS ISA
- Instruction encoding and control logic are simplified relative to a full MIPS implementation 
- Multiply and divide operations are implemented directly in the ALU without full HI/LO register support
- Memory system is simplified and does not include byte addressing or caching

## Verification

The processor was verified using simulation with a test program designed to exercise:

- Arithmetic and logical operations
- Data forwarding cases
- Load-use hazards
- Branch and jump behavior

Correct pipeline behavior was verified under these conditions.

## Notes on Provided Components

The instruction memory contents and portions of the testbench were provided as part of the course framework and used for simulation and verification.
 
    
