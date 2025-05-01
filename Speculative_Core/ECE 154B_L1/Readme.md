# RISC-V-32I-5-Stage-Pipeline-Core
**5 stage pipeline implementation of RISC-V 32I Processor.**

The repository contains the implementation of a 5 stage Pipelined processor as per the requirements provided in 
[Requirements_pdf](https://github.com/rachit182/ece154b/blob/main/ECE%20154B_L1/lab1-1.pdf)

In case of pipelined implementation what we do is that we divide our instruction into multiple stages and in case of 5 stage pipelined implementation we will offcourse divide the instruction into 5 different stages. Five different stages are given as:
- Instruction Fetch
- Instruction Decode
- Instruction Execution
- Memory Read/Write
- Write Back

This pipelined implementation of processor supports six basic instructions:
- R-Type
- I-Type
- S-Type
- B-Type
- J-Type
- U-Type

This RISC V 5 Stage pipeline Implementation does encounters hazards, and it has been surpassed by implementing a hazard unit to handle all types of hazards(Structural and Data Hazard). 5 Stage pipeline requires a series of registers between the complete datapath, these registers will be responsible for tracking of instruction or different partss of instructions required by different modules. The instructions needs to be propogated into all five stages for the instruction to be executed correctly and with the help of these registers the corresponding instructions propogate or different parts of instructions accordingly.

## Implementation Details

 **1. Fetch Cycle Datapath**
 
The Fetch cycle is the first stage of instruction execution process. The main goal of the fetch cycle is to retrieve the next instruction from memory so        that it can be decoded and executed by the processor.
     
**2. Decode Cycle Datapath** 

The decode cycle in a is the second stage of instruction execution. The main objective of this stage is to interpret       the fetched instruction and prepare      the necessary inputs (registers, control signals) for subsequent stages.

**3. Execution Cycle Datapath**

The Execution cycle is the third stage of instruction execution process. Its main role is to perform the arithmetic or logical   operation dictated by the          instruction, calculate memory addresses for load/store operations, or determine the outcome of a branch.
    
**4. Memory Read/Write Cycle Datapath**

The Memory Read or Write Cycle is the fourth stage of instruction execution process. This stage is responsible for interacting with data memory during load     or store instructions. If the instruction is not a memory operation, this stage is skipped, and the processor moves to the writeback stage.

**5. Write Back Cycle Datapath**

The Writeback cycle is the fifth and final stage of instruction execution process. The main purpose of this stage is to write the result of an instruction (whether it be from an arithmetic operation or a memory load) back to the destination register.

**Note: Hazard Unit**

**Hazard units** in a pipeline processor are responsible for detecting and resolving hazards that can occur when executing instructions in a pipelined         
architecture. 
**Hazards** can cause incorrect program execution or reduce performance by stalling the pipeline. 
There are three primary types of hazards: **data hazards, control hazards, and structural hazards**. 
In a 32-bit RISC-V 5-stage pipeline, **hazard detection and forwarding units** are critical components that help manage these hazards.

**Structural Hazard**
1. Hardware does not support the execution of instruction in same clock cycle.
2. Without having Two memories RISC-V pipelining architecture will have structural hazard.

**Data Hazard**
1. Data to be executed is not available.
2. May occur when pipeline is stalled.
3. Solve by using forwarding or bypassing technique.

**Solution to Data Hazard.**
1.Solving Data Hazards with nops
2.Solving Data Hazard with Forwarding / Bypassing

The Data Hazard is solved using Forwarding/ Bypassing

## Hazard Handling

Occurs when an instruction depends on the results of the previous instruction which is not yet completed.

- **Data Hazards**

  - **Forwarding** - Forward the result from the Memory Stage and the WriteBack stage to the Execute stage.

  - **Stalling** ( for load word ) - Data read from memory is available only at the end of clock cycle. So, we stall the next instructions and forward the memory data from WriteBack stage.

- **Control Hazards**

  - Flushing - Whenever the decision is made to take a branch in Execute stage, flush the next two instructions (Decode and Fetch Stages).


# Simulation Results

