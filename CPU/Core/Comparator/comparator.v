`timescale 1ns / 1ps

module comparator(
    input wire [31:0] a, b, 
    input wire unsigned_op, // if(unsigned operation) => 1 ; else => 0
    output o_a_lt_b, o_a_eq_b // output a less-than b | a equal-to b
);
    // declarations
    wire intermediate_a_lt_b [0:31]; // intermediate a<b wires between 1-bit comparators
    wire a_neg_b_pos; // if(a is neg. and b is pos.) => 1 ; else => 0
    wire b_neg_a_pos; // if(b is neg. and a is pos.) => 1 ; else => 0
    wire both_neg; // if both a and b are negative => 1
    wire diff_sign;
    wire [31:0] mod_a, mod_b; // modified values of a and b (if necessary)

    // intermediate signals
    wire a_lt_b;
    wire final_a_lt_b; // final a_lt_b signal. 
    wire xor_r; // result of xor of input a and b
    
    /*
    If operation is unsigned, pass unmodified a and b inputs and set the first intermediate_a_lt_b signal to 0.


    If operation is signed, check if they have different signs. 

    If they have different signs, set either a_neg_b_pos or b_neg_a_pos. If they have different signs, the positive one is greater.

    If they are both neg. set both_neg to 1 
    convert a and b to their magnitudes to compare their magnitudes
    We'll invert the final result if both neg. so that the one with the greater magnitude will be the smaller number
    */

    assign diff_sign = unsigned_op ? 1'b0 : (a[31] ^ b[31]); // if (unsigned OR same sign) => 0 ; if(different signs) => 1
    assign a_neg_b_pos = (diff_sign) ? (a[31]) : 1'b0;  
    assign b_neg_a_pos = (diff_sign) ? (b[31]) : 1'b0;

    assign both_neg    = (unsigned_op) ? 1'b0 : // if not signed => 0
                         (diff_sign)   ? 1'b0 : // if different signs => 0
                         a[31];                 // else => MSB of a (or b)

    assign mod_a = (both_neg) ? (~a + 1'b1) : a; // get magnitude of a
    assign mod_b = (both_neg) ? (~b + 1'b1) : b; // get magnitude of b

    assign intermediate_a_lt_b[31] = a_neg_b_pos; // set first a_lt_b signal. If a is neg. and b is pos. then this will be 1, which will propogate all the way through the comparator

    generate
        genvar i;
        for(i=31; i>0; i = i-1)
            comparator_1bit compare_a_b(.a(mod_a[i]), .b(mod_b[i]), .a_lt_b(intermediate_a_lt_b[i]), .out(intermediate_a_lt_b[i-1])); 
         
        comparator_1bit compare_a_b(.a(mod_a[0]), .b(mod_b[0]), .a_lt_b(intermediate_a_lt_b[0]), .out(a_lt_b)); 
    endgenerate

    assign final_a_lt_b = (both_neg)    ? ~a_lt_b : a_lt_b; // if both nums were neg., then invert result (since the one with the greater magnitude will be smaller)
    assign o_a_lt_b     = (b_neg_a_pos) ? 1'b0    : a_lt_b; // if b is neg. and a is pos. then a > b. else return a_lt_b

    assign xor_r = a ^ b;
    assign o_a_eq_b = (xor_r == 0); 

endmodule
