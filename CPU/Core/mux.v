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

module mux_6to1 
#(parameter DATAWIDTH = 32)
(
    input wire [DATAWIDTH-1:0] inputA, inputB, inputC, inputD, inputE, inputF,
    input wire [2:0] select,
    output reg [DATAWIDTH-1:0] selected_out
);

    always @(*)
    casex(select)
        3'b000:
            selected_out = inputA;
        3'b001:
            selected_out = inputB;
        3'b010:
            selected_out = inputC;
        3'b011:
            selected_out = inputD;
        3'b100:
            selected_out = inputE;
        3'b101:
            selected_out = inputF;
        default:
            selected_out = 32'bx;
    endcase
endmodule
