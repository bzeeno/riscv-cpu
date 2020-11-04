module dff32(
    input wire i_clk, i_resetn,
    input wire [31:0] next,
    output reg [31:0] out
);
    
    always @(posedge i_clk or negedge i_resetn)
    begin
        if(!i_resetn)
            out <= 0;
        else
            out <= next;
    end
    
endmodule
