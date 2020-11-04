module imm_decode(
    input wire [31:0] i_instr,
    input wire [6:0] i_opcode,
    input wire i_signext,
    output reg [31:0] o_imm_val
);
    
    always @(i_instr or i_opcode)
    casex(i_opcode) // check opcode
        7'b0000011: o_imm_val <= { {20{i_instr[31]&i_signext}} , i_instr[31:20] };                                            // LW
        7'b0100011: o_imm_val <= { {20{i_instr[31]&i_signext}} , i_instr[31:25] , i_instr[11:7] };                            // SW
        7'b1101111: o_imm_val <= { {12{i_instr[31]&i_signext}} , i_instr[19:12] , i_instr[20] , i_instr[30:21] , 1'b0 };      // JAL
        7'b1100111: o_imm_val <= { {20{i_instr[31]&i_signext}} , i_instr[31:20] };                                            // JALR
        7'b1100011: o_imm_val <= { {20{i_instr[31]&i_signext}} , i_instr[7] , i_instr[30:25] , i_instr[11:8] , {1{1'b0}} };   // Branch
        7'b0110111: o_imm_val <= { i_instr[31:12], {12'b000000000000} };                                                      // lui
        7'b0010011: 
        begin
            if(i_instr[14:12] == 3'b001 | i_instr[14:12] == 3'b101)                                                           // slli/srli/srlai
                    o_imm_val <= { {27'b0} , i_instr[24:20] };
            else 
                o_imm_val <= { {20{i_instr[31]&i_signext}} , i_instr[31:20] };                                                // ADDI/ANDI/ORI/XORI                                            
        end
        default: o_imm_val <= 32'bx;
    endcase
    
endmodule
