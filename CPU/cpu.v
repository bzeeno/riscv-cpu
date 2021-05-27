module cpu(
    input wire i_clk, i_resetn,
    output wire [31:0] instr,
    output wire [31:0] pc,
    output wire [31:0] addr_out, 
    output wire [31:0] mem_out    
);

    wire [31:0] core_dmem_in, core_dmem_out; // input/output data memory for core
    wire wmem;
    
    assign mem_out = core_dmem_in;
    
    core core1 (
        .i_clk(i_clk), .i_resetn(i_resetn),
        .i_instr(instr),
        .i_dmem(core_dmem_in), 
        .o_pc(pc),   
        .o_addr(addr_out),  
        .o_dmem(core_dmem_out), 
        .o_wmem(wmem) 
    );
    
    data_mem dmem (
        .i_clk(i_clk), .we(wmem),
        .i_data(core_dmem_out),
        .i_addr(addr_out),
        .o_data(core_dmem_in)
    );
    
    instruction_mem imem (
        .i_addr(pc),
        .o_instr(instr)
    );
    

endmodule

