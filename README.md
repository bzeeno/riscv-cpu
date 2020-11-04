# Single-Cycle-CPU
Simple single-cycle RISC-V CPU

# Directory Structure
<pre>
├── CPU
│   ├── Core
│   │   ├── ALU
│   │   │   ├── add_sub32.v
│   │   │   ├── alu.v
│   │   │   ├── CLA
│   │   │   │   ├── cla_16bit.v
│   │   │   │   ├── cla_32bit.v
│   │   │   │   ├── cla_4bit.v
│   │   │   │   └── cla_8bit.v
│   │   │   └── shifter.v
│   │   ├── control_unit.v
│   │   ├── dff.v
│   │   ├── imm_decode.v
│   │   ├── mux.v
│   │   ├── regfile.v
│   │   └── sc_core.v
│   ├── Data_Mem
│   │   └── data_mem.v
│   ├── Instruction_Mem
│   │   └── instruction_mem.v
│   └── sc_cpu.v
└── Diagrams
    └── cpu.jpg
</pre>

- The CPU directory contains all of the design files, while the Diagrams directory contains the diagrams

# CPU Design
![](Diagrams/sc_cpu_top.jpg)

## Core
- sc_core (single-cycle core) is the main module that contains
