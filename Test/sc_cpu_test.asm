main:
    lui  x10, 0          # x[10] = 0
    ori  x11, x10, 80    # x[11] = 80
    addi x12, x0, 5      # x[12] = 5

call:
    jal  sum             # x[01] = 10
    sw   x12, 0(x0)      # dmem[0] = 5
    lw   x13, 0(x0)      # x[13] = 5
    andi x14, x11, 0     # x[14] = 0
    beq  x0, x14, BEQ    # should be taken

sum: 
    add  x15, x0, x11    # x[15] = 80
    lui  x16, 0          # 
    ori  x16, x16, 12    # x[16] = 12
    jalr x0, 4(x16)      # jump to line 8 (pc = 0x10)
    addi x16, x16, 1     # shouldn't execute

BEQ:
    lui  x17, 1048575    # loads 20 1's into MSBs of x17
    srai x17, x17, 16  # x[17] = all 1's
    beq  x0, x17, BEQ2   # shouldn't be taken
    xori x18, x17, 1     # x[18] = all 1's except lsb
    
BEQ2:
    slli x19, x17, 16    # x[19] = 16 MSBs 1 and 16 LSBs 0
    srli x20, x18, 1     # x[20] = all 1's except MSB
    srai x21, x18, 1     # x[21] = all 1's
    bne  x19, x21, BNE   # should be taken
    addi x20, x20, 1     # shouldn't execute

BNE:
    bne  x21, x17, BNE2  # shouldn't be taken
    or   x22, x0, x19    # x[22] = x[19] = 16MSBs 1, 16LSBs 0

BNE2:
    xor  x23, x21, x19   # x[23] = 16MSBs 0, 16LSBs 1
    sub  x24, x11, x12   # x[24] = 75
    sw   x11, 1(x0)      # dmem[1] = 80
    sw   x17, 2(x0)      # dmem[2] = all 1's 
    auipc x25, 1         # x[25] = 0x6d
    blt  x0, x24, BLT    # should be taken
    addi x25, x25, 10    # shouldn't execute

BLT:
    blt  x24, x0, main    # shouldn't be taken
    bge  x11, x0, BGE      # should be taken
    addi x25, x25, 10    # shouldn't execute

BGE:
    bgeu  x0, x17, main    # shouldn't be taken
    addi  x10, x0, 1       # x[10] = 1
    addi  x11, x0, -10     # x[11] = -10
    sw    x11, 3(x0)       # dmem[3] = -10
    lb    x26, 3(x0)       # x[26] = -10
    lbu   x27, 3(x0)       # x[27] = 0x000000f6 (-10)
    lh    x28, 2(x0)       # x[28] = all 1's
    lhu   x29, 2(x0)       # x[29] = 0x0000FFFF
    sb    x21, 4(x0)       # dmem[4] = 0x000000FF
    sh    x21, 5(x0)       # dmem[5] = 0x0000FFFF
    slti  x30, x0, -10     # x[30] = 0
    sltiu x31, x0, -10     # x[31] = 1
    addi  x2, x0, 1        # x[2] = 1
    sll   x2, x21, x2      # x[2] = all 1's except LSb
    slt   x3, x0, x21      # x[3] = 0
    sltu  x4, x0, x21      # x[4] = 1
    srl   x5, x21, 16      # x[5] = 16 MSBs 0, 16LSBs 1
    sra   x6, x21, 16      # x[6] = all 1's
    

finish:
    jal x0, finish
