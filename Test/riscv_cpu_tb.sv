`timescale 1ns / 1ns
module sc_cpu_tb();

    logic clk, resetn;
    logic [31:0] instr, pc, addr_out, mem_out;
    
    
    /*************************** DUT ******************************/
    cpu cpu_dut (
        .i_clk(clk), .i_resetn(resetn),
        .instr(instr),
        .pc(pc),
        .addr_out(addr_out), 
        .mem_out(mem_out)    
    );
    /**************************************************************/
    
    initial begin
           resetn = 0;
           clk  = 1;
           #1 resetn = 1;
           #1399 $finish;
    end
    always #10 clk = !clk;
        
endmodule
