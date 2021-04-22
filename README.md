# Single-Cycle-CPU
Simple single-cycle RISC-V CPU

Table of Contents
=================

   * [Directory Structure](#directory-structure)
   * [CPU Design](#cpu-design)
      * [Core](#core)
         * [Program Counter](#program-counter)
         * [Control Unit](#control-unit)
         * [Register File](#register-file)
         * [ALU](#alu)
            * [Add/Sub Unit](#addsub-unit)
               * [Carry Look-ahead Adder (CLA)](#carry-look-ahead-adder-cla)
            * [Shifter](#shifter)
         * [Immediate Decoder](#immediate-decoder)
         * [Store Modifier](#store-modifier)
         * [Load Modifier](#load-modifier)
      * [Instruction Memory](#instruction-memory)
      * [Data Memory](#data-memory)

# Directory Structure
<pre>
├── Core
│   ├── ALU
│   │   ├── AddSubUnit
│   │   │   ├── add_sub32.v
│   │   │   └── CLA
│   │   │       ├── cla_16bit.v
│   │   │       ├── cla_32bit.v
│   │   │       ├── cla_4bit.v
│   │   │       └── cla_8bit.v
│   │   ├── alu.v
│   │   └── Shifter
│   │       └── shifter.v
│   ├── control_unit.v
│   ├── core.v
│   ├── dff.v
│   ├── imm_decode.v
│   ├── load_modifier.v
│   ├── mux.v
│   ├── regfile.v
│   └── store_modifier.v
├── Data_Mem
│   └── data_mem.v
├── Instruction_Mem
│   └── instruction_mem.v
└── sc_cpu.v


</pre>

- The CPU directory contains all of the design files, while the Diagrams directory contains the diagrams

# CPU Design
![](Diagrams/cpu.jpg)
- 32-bit computing  
- The CPU utilizes the Harvard architecture
- Design is based on the RISC-V instruction set architecture (ISA)
- The CPU is a simple single-cycle, single-core CPU that can execute the instructions in the base RV32I subset of the RISC-V ISA (except for those related to exceptions and interrupts).

## Core
![](Diagrams/Core.jpg)
- sc_core (single-cycle core) is the main module that contains the control unit, the program counter logic, the ALU, the register file, the immediate decoder, and the load and store modifiers.

### Program Counter
- The program counter (PC) increments by 4 (bytes) each clock cycle, assuming the instruction is not a branch or jump.
- Branches and Jumps:
	- The immediate for branches and jumps is specified by the number of bytes
		- This means the immediate will always be an even number, so, the 0th bit is set to 0 and is not encoded in the instruction (not applicable to jalr)
		- If the branch or jump is taken, then: PC = PC + signext(offset)
	- jal instruction:
		- The jal instruction is the instruction in which an immediate value is added to the PC to determine the target address
		- The PC + 4 (The return address) is saved in the register file at rd, typically at 0x01
	- jalr instruction:
		- The jalr instruction adds a 12-bit immediate value to rs1 to determine the target address
		- The retrun address is saved to rd, typically 0x01

### Control Unit
- The control unit is responsible for sending select signals to multiplexers as well as the ALU control signal.
- Signals:
	- Inputs:
        	- opcode: The first 7 bits of the instruction \[6:0]
        	- funct3: A 3 bit function code that is held in bits \[14:12] of the instruction (LUI and Jump instructions do not contain funct3)
        	- funct7: A 7 bit function code that is held in bits \[31:25] of the instruction (LUI, Jumps, Branches, and Immediates do not contain funct7)
		- zero: The zero flag from the ALU (set to 1 if the output of the ALU is 0)
	
	- Outputs:
		- wreg: The write enbale signal for the register file
		- jal: Selector signal for data to be written to the register file
		- jalr: The selector signal for the multiplexer for jalr and branch instructions
		- mem2reg: The selector signal for the multiplexer that chooses between the ALU result and the data memory
			- 0: ALU result
			- 1: Data from data memory
		- aluimm: The selector signal for input b of the ALU
			- 0: read_data2 from register file
			- 1: Immediate value
		- signext: A signal to determine whether to sign extend the immediate value (If it is an immediate instruction)
		- ls_b: This signal is used only for load and store instructions. This signal determines if the load or store is operating on a byte. (i.e. load byte/store byte)
		- ls_h: This signal is similar to ls_b, except that it determines if the CPU is loading or storing a half-word
		- load_signext: Determines whether to sign extend the loaded data.
		- aluc: The 6-bit ALU control signal. This signal determines which operation the ALU will execute.
			- bits \[2:0] are used as the select signal for the final output of the ALU.
			- bit \[3] is used as the select signal between two operations (i.e. add/sub, and/or, etc.)
			- bit \[4] is used to determine if a shift operation is logical or arithmetic.
			- bit \[5] will be used for integer multiply and divide operations.
		- wmem: The write enable signal for the data memory
		- pcsrc: The selector signal for the program counter multiplexer
			- 0: PC+4
			- 1: Branch Addr
			- 2: Reg Addr
			- 3: Jump Addr
		- auipc: Determines if the instruction is auipc.
		
- Instructions and their respective signal values:


| Instruction | z | wreg | jal | jalr | mem2reg | aluimm | signext | ls_b | ls_h | load_signext | aluc | wmem | pcsrc | auipc |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| add   | x | 1 | 0 | x | 0 | 0 | x | x | x | x | xx0000 | 0 | 00 | 0 |
| sub   | x | 1 | 0 | x | 0 | 0 | x | x | x | x | xx1000 | 0 | 00 | 0 |
| and   | x | 1 | 0 | x | 0 | 0 | x | x | x | x | xx0010 | 0 | 00 | 0 |
| or    | x | 1 | 0 | x | 0 | 0 | x | x | x | x | xx1010 | 0 | 00 | 0 |
| xor   | x | 1 | 0 | x | 0 | 0 | x | x | x | x | xx0100 | 0 | 00 | 0 |
| addi  | x | 1 | 0 | x | 0 | 1 | 1 | x | x | x | xx0000 | 0 | 00 | 0 |
| slti  | x | 1 | 0 | x | 0 | 1 | 1 | x | x | x | xx0011 | 0 | 00 | 0 |
| slt   | x | 1 | 0 | x | 0 | 0 | x | x | x | x | xx0011 | 0 | 00 | 0 |
| sltiu | x | 1 | 0 | x | 0 | 1 | 1 | x | x | x | xx1011 | 0 | 00 | 0 |
| sltu  | x | 1 | 0 | x | 0 | 0 | x | x | x | x | xx1011 | 0 | 00 | 0 |
| andi  | x | 1 | 0 | x | 0 | 1 | 0 | x | x | x | xx0010 | 0 | 00 | 0 |
| ori   | x | 1 | 0 | x | 0 | 1 | 0 | x | x | x | xx1010 | 0 | 00 | 0 |
| sltiu | x | 1 | 0 | x | 0 | 1 | 1 | x | x | x | xx1011 | 0 | 00 | 0 |
| xori  | x | 1 | 0 | x | 0 | 1 | 0 | x | x | x | xx0100 | 0 | 00 | 0 |
| slli  | x | 1 | 0 | x | 0 | 1 | 0 | x | x | x | x00101 | 0 | 00 | 0 |
| srli  | x | 1 | 0 | x | 0 | 1 | 0 | x | x | x | x01101 | 0 | 00 | 0 |
| srai  | x | 1 | 0 | x | 0 | 1 | 0 | x | x | x | x11101 | 0 | 00 | 0 |
| sll   | x | 1 | 0 | x | 0 | 0 | x | x | x | x | x00101 | 0 | 00 | 0 |
| srl   | x | 1 | 0 | x | 0 | 0 | x | x | x | x | x01101 | 0 | 00 | 0 |
| sra   | x | 1 | 0 | x | 0 | 0 | x | x | x | x | x11101 | 0 | 00 | 0 |
| lb    | x | 1 | 0 | x | 1 | 1 | 1 | 1 | 0 | 1 | x00000 | 0 | 00 | 0 |
| lh    | x | 1 | 0 | x | 1 | 1 | 1 | 0 | 1 | 1 | x00000 | 0 | 00 | 0 |	
| lbu   | x | 1 | 0 | x | 1 | 1 | 1 | 1 | 0 | 0 | x00000 | 0 | 00 | 0 |
| lhu   | x | 1 | 0 | x | 1 | 1 | 1 | 0 | 1 | 0 | x00000 | 0 | 00 | 0 |	
| lw    | x | 1 | 0 | x | 1 | 1 | 1 | 0 | 0 | 1 | x00000 | 0 | 00 | 0 |	
| sb    | x | 0 | x | x | x | 1 | 1 | 1 | 0 | x | x00000 | 1 | 00 | 0 |	
| sh    | x | 0 | x | x | x | 1 | 1 | 0 | 1 | x | x00000 | 1 | 00 | 0 |
| sw    | x | 0 | x | x | x | 1 | 1 | 0 | 0 | x | x00000 | 1 | 00 | 0 |
| beq   | 0/1 | 0 | x | 0 | x | 0 | 1 | x | x | x | xx0100 | 0 | z | 0 |			
| bne   | 0/1 | 0 | x | 0 | x | 0 | 1 | x | x | x | xx0100 | 0 | ~z | 0 |
| blt   | 0/1 | 0 | x | 0 | x | 0 | 1 | x | x | x | xx0011 | 0 | ~z | 0 |
| bltu  | 0/1 | 0 | x | 0 | x | 0 | 0 | x | x | x | xx1011 | 0 | ~z | 0 |
| bge   | 0/1 | 0 | x | 0 | x | 0 | 1 | x | x | x | xx0011 | 0 | z | 0 |
| bgeu  | 0/1 | 0 | x | 0 | x | 0 | 0 | x | x | x | xx1011 | 0 | z | 0 |
| lui   | x | 1 | 0 | x | 0 | 1 | x | x | x | x | xx1100 | 0 | 00 | 0 |
| jalr  | x | 1 | 1 | 1 | x | 1 | x | x | x | x | xxxxxx | 0 | 01 | x |
| jal   | x | 1 | 1 | 0 | x | x | x | x | x | x | xxxxxx | 0 | 10 | x |
| auipc | x | 1 | 0 | x | 0 | 1 | 1 | x | x | x | xx0000 | 0 | 00 | 1 |

- Note: Any "z" seen above represents the output z from the ALU, it is not referring to a high impedance state.

### Register File
- Inputs:
	- rs1: Register source 1. Held in bits \[19:15] of instruction
	- rs2: Register source 2. Held in bits \[24:20] of instruction
	- rd: Register destination. Held in bits \[11:7] of instruction
	- data: Data to be written (if applicable)
	- we: write enable signal from control unit
- Outputs:
	- read_data1: 32-bit read data
	- read_data2: 32-bit read data

### ALU
- The ALU performs the basic logic functions as well as addition, subtraction, and shifting. Integer multiplication and division will be added in the future.
- The output is selected by a 6:1 MUX using bits \[2:0] of the aluc signal as the selector
#### Add/Sub Unit
- The add_sub32 module instantiates the Carry Look-ahead Adder (CLA) and converts input b of the ALU if the operation is sub.
	- In order to carry out a sub operation, the add_sub32 unit inverts input b and passes 1 as the carry-in. This effectively converts the binary number to 2's complement and the CLA can then simply add the inputs
	- If the operation is add, then input b is passed to the CLA unchanged and the carry-in is set to 0
##### Carry Look-ahead Adder (CLA)
- The CLA uses a technique in which two 16-bit CLAs are used to make up the 32-bit CLA. However, the 2 16-bit CLAs are made up of 2 8-bit CLAs and those 2 8-bit CLAs are made up of 2 4-bit CLAs.
- The 2 4-bit CLAs (cla_4bit) is where we can see the CLA logic. The CLA uses the following equation, obtained from the truth table, to calculate carries:
	- C<sub>i</sub> = G<sub>i</sub> + P<sub>i</sub> * C<sub>i-1</sub>
		- Where C<sub>i</sub> is the carry out
		- G<sub>i</sub> = input A * input B (Carry Generate)
		- P<sub>i</sub> = input A ⊕ input B (Carry Propagate)
		- Note: C<sub>-1</sub> is the original carry-in
- Using the above formula, we can calculate each carry without having to wait for the previous carry by replacing C<sub>i-1</sub> with the previous C<sub>i</sub> formula, such that the only dependencies are input A, input B, and the original carry-in
	- C<sub>0</sub> = G<sub>0</sub> + P<sub>0</sub> * C<sub>-1</sub>
	- C<sub>1</sub> = G<sub>1</sub> + P<sub>1</sub> * C<sub>0</sub> = G<sub>1</sub> + P<sub>1</sub> * (G<sub>0</sub> + P<sub>0</sub> * C<sub>-1</sub>) =  G<sub>1</sub> + P<sub>1</sub> * G<sub>0</sub> + P<sub>1</sub> * P<sub>0</sub> * C<sub>-1</sub>
	- C<sub>2</sub> = G<sub>2</sub> + P<sub>2</sub> * C<sub>1</sub> = G<sub>2</sub> + P<sub>2</sub> * G<sub>1</sub> + P<sub>2</sub> * P<sub>1</sub> * G<sub>0</sub> + P<sub>2</sub> * P<sub>1</sub> * P<sub>0</sub> * C<sub>-1</sub>
	- C<sub>3</sub> = G<sub>3</sub> + P<sub>3</sub> * C<sub>2</sub> = G<sub>3</sub> + P<sub>3</sub> * G<sub>2</sub> + P<sub>3</sub> * P<sub>2</sub> * G<sub>1</sub> + P<sub>3</sub> * P<sub>2</sub> * P<sub>1</sub> * G<sub>0</sub> + P<sub>3</sub> * P<sub>2</sub> * P<sub>1</sub> * P<sub>0</sub> * C<sub>-1</sub>
	
- The sum is obtained by doing a bitwise XOR of the carry propagate and the obtained carry values

#### Shifter
- The shifter simply shifts the input based on the shift amount, right signal (if right = 0, then shift left), and the shift arithmetic signal (which is aluc\[4])
</br>

### Immediate Decoder
- The immediate decoder decodes the immediate values from the instruction
- The immediate values are either padded with 0s or 1s depending on the signext signal from the control unit
- The immediate value is then passed to the branch and jalr adder, the input b multiplexer for the ALU, and the jal and PC adder.

### Store Modifier
- The store modifier modifies the data to be stored depending on the size of the data to be stored. All the store modifier does is 0 extend the data by the required amount.

### Load Modifier
- The load modifier modifies the data to be loaded depending on the size of the data to be loaded and whether or not the data must be sign extended.

## Instruction Memory
- Holds the 32-bit instructions
- Uses the PC as the address (Note: the instruction memory is word-addressable)
- Designed as a simple ROM

## Data Memory
- Data memory acts as RAM
- Data memory is word-addressable
- The write enable signal is obtained from the control unit in the CPU's core
- The address is calculated by the ALU in the CPU's core
