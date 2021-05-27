`timescale 1ns / 1ps

module pc_reg(
    input wire i_clk, i_resetn, i_we, 
    input wire [31:0] i_pc, 
    output reg [31:0] o_pc
);

    always @(posedge i_clk or negedge i_resetn)
    begin
        if(!i_resetn)
            o_pc <= 'b0;
        else
            o_pc <= i_pc;
    end

endmodule
