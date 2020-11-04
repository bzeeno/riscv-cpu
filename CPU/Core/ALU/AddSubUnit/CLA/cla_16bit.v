module cla_16bit(
    input wire [15:0] a, b, // 16-bit inputs
    input wire c_in,
    output wire [15:0] sum,
    output wire c_out
    );
    
    wire carry; // carry signals between cla_8bit units
    
    cla_8bit cla8_unit0 (
        .a(a[7:0]), .b(b[7:0]), // 8-bit inputs
        .c_in(c_in),
        .sum(sum[7:0]),
        .c_out(carry)
    );
    
    cla_8bit cla8_unit1 (
        .a(a[15:8]), .b(b[15:8]), // 8-bit inputs
        .c_in(carry),
        .sum(sum[15:8]),
        .c_out(c_out)
    );
    
endmodule
