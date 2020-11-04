module cla_8bit (
    input wire [7:0] a, b, // 8-bit inputs
    input wire c_in,
    output wire [7:0] sum,
    output wire c_out
);
    
     wire carry; // carry signals between cla_4bit units
    
    cla_4bit cla4_unit0 (
        .i_a(a[3:0]), .i_b(b[3:0]), // 4-bit inputs
        .c_in(c_in),
        .o_sum(sum[3:0]),
        .c_out(carry)
    );
    
    cla_4bit cla4_unit1 (
        .i_a(a[7:4]), .i_b(b[7:4]), // 4-bit inputs
        .c_in(carry),
        .o_sum(sum[7:4]),
        .c_out(c_out)
    );
    
endmodule
