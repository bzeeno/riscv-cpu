module mux_2to1
#(parameter DATAWIDTH = 32)
(
    input wire [DATAWIDTH-1:0] inputA, inputB,
    input wire select,
    output wire [DATAWIDTH-1:0] selected_out
);

    assign selected_out = select ? inputA : inputB;

endmodule

module mux_3to1 
#(parameter DATAWIDTH = 32)
(
    input wire [DATAWIDTH-1:0] inputA, inputB, inputC,
    input wire [1:0] select,
    output reg [DATAWIDTH-1:0] selected_out
);

    always @(*)
    casex(select)
        2'b00:
            selected_out = inputA;
        2'b01:
            selected_out = inputB;
        2'b10:
            selected_out = inputC;
        default:
            selected_out = 32'bx;
    endcase
    

endmodule

module mux_4to1 
#(parameter DATAWIDTH = 32)
(
    input wire [DATAWIDTH-1:0] inputA, inputB, inputC, inputD,
    input wire [1:0] select,
    output reg [DATAWIDTH-1:0] selected_out
);

    always @(*)
    casex(select)
        2'b00:
            selected_out = inputA;
        2'b01:
            selected_out = inputB;
        2'b10:
            selected_out = inputC;
        2'b11:
            selected_out = inputD;
        default:
            selected_out = 32'bx;
    endcase
    

endmodule
