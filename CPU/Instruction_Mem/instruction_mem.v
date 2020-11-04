module instruction_mem (
    input wire [31:0] i_addr,
    output wire [31:0] o_instr
);

    wire [31:0] rom [0:31];
                                            // (pc)  label    instruction
    assign rom[5'h00] = 32'h00000537;       // (00)  main:    lui  $10, 0
    assign rom[5'h01] = 32'h05056593;       // (04)           ori  $11, $10, 80
    assign rom[5'h02] = 32'h00500613;       // (08)           addi $12, $0,  5
    assign rom[5'h03] = 32'h014000ef;       // (0c)  call:    jal  sum
    assign rom[5'h04] = 32'h00c02023;       // (10)           sw   $12, $0,  0  
    assign rom[5'h05] = 32'h00002683;       // (14)           lw   $13, $0,  0
    assign rom[5'h06] = 32'h0005f713;       // (18)           andi $14, $11, 0
    assign rom[5'h07] = 32'h00e00c63;       // (1c)           beq  $0,  $14, BEQ
    assign rom[5'h08] = 32'h00b007b3;       // (20)  sum:     add  $15, $0,  $11
    assign rom[5'h09] = 32'h00000837;       // (24)           lui  $16, 0
    assign rom[5'h0A] = 32'h00c86813;       // (28)           ori  $16, $16, 12
    assign rom[5'h0B] = 32'h00480067;       // (2c)           jalr $0,  $16, 4
    assign rom[5'h0C] = 32'h00180813;       // (30)           addi $16, $16, 1 (shouldn't execute)
    assign rom[5'h0D] = 32'hfffff8b7;       // (34)  BEQ:     lui  $17, 65535 (16 1's)
    assign rom[5'h0E] = 32'hfff8e893;       // (38)           ori  $17, 65535 (16 1's)
    assign rom[5'h0F] = 32'h01100663;       // (3c)           beq  $0,  $17, BEQ2
    assign rom[5'h10] = 32'h0018c913;       // (40)           xori $18, $17, 1
    assign rom[5'h11] = 32'h01089993;       // (44)  BEQ2:    slli $19, $17, 16
    assign rom[5'h12] = 32'h00195a13;       // (48)           srli $20, $18, 1
    assign rom[5'h13] = 32'h40195a93;       // (4c)           srai $21, $18, 1
    assign rom[5'h14] = 32'h01599463;       // (50)           bne  $19, $21, BNE
    assign rom[5'h15] = 32'h001a0a13;       // (54)           addi $20, $20, 1 (shouldn't execute)
    assign rom[5'h16] = 32'h011a9463;       // (58)  BNE:     bne  $21, $17, BNE2
    assign rom[5'h17] = 32'h01306b33;       // (5c)           or   $22, $0,  $19 (shouldn't execute)
    assign rom[5'h18] = 32'h013acbb3;       // (60)  BNE2:    xor  $23, $21, $19
    assign rom[5'h19] = 32'h40c58c33;       // (64)           sub  $24, $11, $12
    assign rom[5'h1A] = 32'h00b02223;       // (68)           sw   $11, $0,  1
    assign rom[5'h1B] = 32'h01102423;       // (6c)           sw   $17, $0,  2
    assign rom[5'h1C] = 32'h0000006f;       // (70)  finish:  jal $0, finish
                   
    assign o_instr = rom[i_addr[6:2]];
                   

endmodule