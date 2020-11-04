module control_unit (
    // from instr mem
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    // from datapath
    input wire z,
    // to datapath
    output reg [3:0] aluc,
    output reg [1:0] pcsrc,
    output reg mem2reg, wmem, aluimm, wreg, jal, jalr, signext
); 
    
    /******************************** Instruction Decode ********************************/
    always @(opcode or funct7 or funct3 or z)
    begin
        case(opcode)
            7'b0110011: // R-Type
            begin
                wreg    = 1'b1;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b0;
                signext = 1'b1;
                wmem    = 1'b0;
                pcsrc   = 2'b00;
                
                case(funct7)
                    7'b0000000: 
                    begin
                        case(funct3)
                            3'b000: aluc  = 4'bx000; // add                               
                            3'b100: aluc  = 4'bx010; // xor                                             
                            3'b110: aluc = 4'bx101; //or                               
                            3'b111: aluc = 4'bx001; //and
                        endcase
                    end
                    
                    7'b0100000: // sub
                    begin
                        aluc = 4'bx100;
                    end
                    
                    default: aluc = 4'bxxxx;
                endcase
            end
            
            7'b0010011: // I-Type
            begin
                wreg    = 1'b1;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b1;
                signext = 1'b0;
                wmem    = 1'b0;
                pcsrc   = 2'b00;

                case(funct3)
                    3'b000: aluc = 4'bx000; // addi
                    3'b100: aluc = 4'bx010; // xori
                    3'b110: aluc = 4'bx101; // ori
                    3'b111: aluc = 4'bx001; // andi
                    3'b001: aluc = 4'b0011; // slli
                    3'b101:                 // sr
                    begin
                        case(funct7)
                            7'b0000000: aluc = 4'b0111; // srli
                            7'b0100000: aluc = 4'b1111; // srai
                            default: aluc =4'bxxxx;
                        endcase
                    end
                endcase
            end
            
            7'b1100011: // B-Type
            begin
                wreg     = 1'b0;
                jal      = 1'b0;
                jalr     = 1'b0;
                mem2reg  = 1'b0;
                aluimm   = 1'b0;
                signext  = 1'b1;
                wmem     = 1'b0;
                aluc     = 4'bx010;
                pcsrc[1] = 1'b0;
                
                case(funct3)
                    3'b000: pcsrc[0] =  z;// beq
                    3'b001: pcsrc[0] = ~z;// bne
                    default: pcsrc = 1'bx;
                endcase
            end
            
            7'b0000011: // Load-Type (lw)
            begin
                wreg    = 1'b1;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b1;
                aluimm  = 1'b1;
                signext = 1'b1;
                wmem    = 1'b0;
                pcsrc   = 2'b00;
                aluc    = 4'bx000;
            end
            
            7'b0100011: // Store-Type (sw)
            begin
                wreg    = 1'b0;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b1;
                signext = 1'b1;
                wmem    = 1'b1;
                pcsrc   = 2'b00;
                aluc    = 4'bx000;
            end
            
            7'b0110111: // lui
            begin
                wreg    = 1'b1;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b1;
                signext = 1'b0;
                wmem    = 1'b0;
                pcsrc   = 2'b00;
                aluc    = 4'bx110;
            end
            
            7'b1101111: // jal
            begin
                wreg    = 1'b1;
                jal     = 1'b1;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b0;
                signext = 1'b0;
                wmem    = 1'b0;
                pcsrc   = 2'b10;
                aluc    = 4'bxxxx;
            end
            
            7'b1100111: // jalr
            begin
                wreg    = 1'b1;
                jal     = 1'b1;
                jalr    = 1'b1;
                mem2reg = 1'b0;
                aluimm  = 1'b0;
                signext = 1'b1;
                wmem    = 1'b0;
                pcsrc   = 2'b01;
                aluc    = 4'bxxxx;
            end
            
            default:
            begin
                wreg    = 1'bx;
                jal     = 1'bx;
                jalr    = 1'bx;
                mem2reg = 1'bx;
                aluimm  = 1'bx;
                signext = 1'bx;
                wmem    = 1'bx;
                pcsrc   = 2'bxx;
                aluc    = 4'bxxxx;
            end
        endcase
    end
    
endmodule

