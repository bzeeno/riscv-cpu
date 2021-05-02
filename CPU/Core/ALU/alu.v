module alu (
    input wire [31:0] a, b,
    input wire [5:0] aluc,
    output wire zero, // zero flag
    output wire [31:0] result
);
    
    wire [31:0] add_sub_out, and_or_out, xor_lui_out, shift_out, less_than_out; // temporary results. 4x1 mux will choose between these to set as output
    wire compare_ab_sign; // intermediate signals for comparing a and b (slt, bge, etc.)
    
    assign and_or_out    = aluc[3] ? (a | b) : (a & b);   // 2x1 MUX to select between and/or
    assign xor_lui_out   = aluc[3] ? b : (a ^ b); // 2x1 MUX to select between xor/lui
    
    // Add/sub
    add_sub32 add_sub_unit (
        .a(a), .b(b),
        .sub(aluc[3]),
        .out(add_sub_out)
    );
    
    // Shift
    shifter shift_unit (
        .data(a), 
        .sa(b[4:0]),    
        .right(aluc[3]),       
        .arith(aluc[4]),       
        .sh_result(shift_out) 
    );

    comparator compare_unit (
        .a(a), .b(b), .unsigned_op(aluc[3]),
        .o_a_lt_b(less_than_out[0]) // output a less-than b
    );
    assign less_than_out[31:1] = 0;
    
    // 4x1 MUX to determine final output
    mux_6to1 result_mux (
        .inputA(add_sub_out), .inputB(), .inputC(and_or_out), .inputD(less_than_out), .inputE(xor_lui_out), .inputF(shift_out),
        .select(aluc[2:0]),
        .selected_out(result)
    );
  
    assign zero = (result == 0);
endmodule
