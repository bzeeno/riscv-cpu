`timescale 1ns / 1ns
module cla_32bit (
    input wire [31:0] a, b, // 32-bit inputs
    input wire c_in,        // carry in
    output wire [31:0] sum, // sum result
    output wire c_out       // carry out
    );
    
    wire carry; // carry signal between cla_16 units
    
    cla_16bit cla16_unit0 (
        .a(a[15:0]), .b(b[15:0]), // 4-bit inputs
        .c_in(c_in),
        .sum(sum[15:0]),
        .c_out(carry)
    );
    
    cla_16bit cla16_unit1 (
        .a(a[31:16]), .b(b[31:16]), // 4-bit inputs
        .c_in(carry),
        .sum(sum[31:16]),
        .c_out(c_out)
    );
    
endmodule
