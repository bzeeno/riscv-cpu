module add_sub32(
    input wire [31:0] a, b,
    input wire sub,
    output wire [31:0] out
);

    wire [31:0] cla_input;
    
    assign cla_input = b ^ {32{sub}}; // if 1, invert. If 0, remains the same
    
    cla_32bit cla_unit(.a(a), .b(cla_input), .c_in(sub), .sum(out), .c_out());

endmodule
