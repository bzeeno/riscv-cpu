module shifter(
    input wire [31:0] data, // data to shift
    input wire [4:0] sa,    // shift amount
    input wire right,       // boolean to shift right (or left)
    input wire arith,       // boolean for arithmetic shift
    output reg [31:0] sh_result // shift result 
);

    always @(*)
    begin
        if(~right)
            sh_result = data << sa; // if not shift right, shift left 
        else if (~arith)
            sh_result = data >> sa; // if not arithmetic, shift right logical
        else
            sh_result = $signed(data) >>> sa; // else shift arithmetic right
    end

endmodule
