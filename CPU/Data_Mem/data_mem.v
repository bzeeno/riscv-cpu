module data_mem (
    input wire i_clk, we,
    input wire [31:0] i_data,
    input wire [31:0] i_addr,
    output wire [31:0] o_data
);

    reg [31:0] ram [0:31];

    always @(posedge i_clk)
    begin
        if(we)
            ram[i_addr[4:0]] = i_data;
    end
    
    integer i;
    initial
    begin
        for(i=0;i<32;i=i+1)
            ram[i] = 0;
    end
    
    assign o_data = ram[i_addr[4:0]];

endmodule
