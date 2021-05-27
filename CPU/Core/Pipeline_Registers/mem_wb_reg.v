`timescale 1ns / 1ps

module mem_wb_reg(
    input wire i_clk, i_resetn, 
    // Control signals from MEM stage
    input wire i_mem_mem2reg, i_mem_wreg, 
    // Data from MEM stage
    input wire [4:0] i_mem_rd,
    input wire [31:0] i_mem_data, i_rd_dmem,
    // Control signals to WB stage
    output reg o_wb_mem2reg, o_wb_wreg,
    // Data to WB stage
    output reg [4:0] o_wb_rd,
    output reg [31:0] o_wb_data, o_wb_dmem
);

    always @(posedge i_clk or negedge i_resetn)
    begin
        if(!i_resetn)
        begin
        // Control signals
        o_wb_mem2reg <= 0;
        o_wb_wreg    <= 0;
        // Data signals
        o_wb_data    <= 'b0;
        o_wb_rd      <= 'b0; 
        o_wb_dmem    <= 'b0;
        end

        else
        begin
        // Control signals
        o_wb_mem2reg <= i_mem_mem2reg;
        o_wb_wreg    <= i_mem_wreg;
        // Data signals
        o_wb_data    <= i_mem_data;
        o_wb_rd      <= i_mem_rd; 
        o_wb_dmem    <= i_rd_dmem;
        end
    end

endmodule
