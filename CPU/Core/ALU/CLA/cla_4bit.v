module cla_4bit (
    input wire [3:0] i_a, i_b, // 4-bit inputs
    input wire c_in,
    output wire [3:0] o_sum,
    output wire c_out
);

    wire [3:0] g, p; // generate and propogate terms
    wire [2:0] c; // carry
    
    assign g = i_a & i_b;
    assign p = i_a ^ i_b;
    
    // CLA carry terms
    assign c[0] = g[0] | (p[0] & c_in); 
    assign c[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c_in);
    assign c[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c_in);
    assign c_out = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c_in);

    // CLA sum
    assign o_sum = p ^ {c,c_in}; // sum = p XOR carry including carry in

endmodule