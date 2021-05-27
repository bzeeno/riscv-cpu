`timescale 1ns / 1ps

module id_exe_reg(
    input wire i_clk, i_resetn,
    // Control signals from ID stage
    input wire i_id_mem2reg, i_id_wmem, i_id_aluimm, i_id_slt_instr, i_id_wreg, i_id_auipc, i_id_lsb, i_id_lsh, i_id_loadsignext, i_id_jal,
    input wire [5:0] i_id_aluc,
    // Data from ID stage 
    input wire i_id_lt,  // less-than result
    input wire [4:0] i_id_rd,
    input wire [31:0] i_id_pc, i_id_regdata1, i_id_regdata2, i_id_imm, i_id_p4,
    // Control signals to EXE stage
    output reg o_exe_mem2reg, o_exe_wmem, o_exe_aluimm, o_exe_slt_instr, o_exe_wreg, o_exe_auipc, o_exe_lsb, o_exe_lsh, o_exe_loadsignext, o_exe_jal,
    output reg [5:0] o_exe_aluc, 
    // Data to EXE stage
    output reg o_exe_lt,
    output reg [4:0] o_exe_rd,
    output reg [31:0] o_exe_pc, o_exe_regdata1, o_exe_regdata2, o_exe_imm, o_exe_p4
);

    always @(posedge i_clk or negedge i_resetn)
    begin
        if (!i_resetn)
        begin
        // control signals
        o_exe_mem2reg     <= 0;
        o_exe_wmem        <= 0;
        o_exe_aluc        <= 6'b000000;
        o_exe_aluimm      <= 0;
        o_exe_slt_instr   <= 0; 
        o_exe_wreg        <= 0;
        o_exe_auipc       <= 0;
        o_exe_lsb         <= 0;
        o_exe_lsh         <= 0;
        o_exe_loadsignext <= 0;
        o_exe_jal         <= 0;
        // data signals
        o_exe_lt          <= 0;
        o_exe_pc          <= 0;
        o_exe_regdata1    <= 'b0;
        o_exe_regdata2    <= 'b0;
        o_exe_rd          <= 'b0;
        o_exe_imm         <= 'b0;
        o_exe_p4          <= 'b0;
        end

        else
        begin
        // control signals
        o_exe_mem2reg     <= i_id_mem2reg;
        o_exe_wmem        <= i_id_wmem;
        o_exe_aluc        <= i_id_aluc;
        o_exe_aluimm      <= i_id_aluimm;
        o_exe_slt_instr   <= i_id_slt_instr; 
        o_exe_wreg        <= i_id_wreg;
        o_exe_auipc       <= i_id_auipc;
        o_exe_lsb         <= i_id_lsb;
        o_exe_lsh         <= i_id_lsh;
        o_exe_loadsignext <= i_id_loadsignext;
        o_exe_jal         <= i_id_jal;
        // data signals
        o_exe_lt          <= i_id_lt;
        o_exe_pc          <= i_id_pc;
        o_exe_regdata1    <= i_id_regdata1;
        o_exe_regdata2    <= i_id_regdata2;
        o_exe_rd          <= i_id_rd;
        o_exe_imm         <= i_id_imm;
        o_exe_p4          <= i_id_p4;
        end
    end

endmodule
