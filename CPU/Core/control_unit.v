module control_unit (
    // from instr mem
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    // from datapath
    input wire z,
    // to datapath
    output reg [5:0] aluc,
    output reg [1:0] pcsrc,
    output reg mem2reg, wmem, aluimm, wreg, jal, jalr, signext, auipc, ls_b, ls_h, load_signext
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
                ls_b    = 1'bx;
                ls_h    = 1'bx;
                load_signext = 1'bx;
                wmem    = 1'b0;
                pcsrc   = 2'b00;
                auipc   = 1'b0;
                
                case(funct7)
                    7'b0000000: 
                    begin
                        case(funct3)
                            3'b000: aluc  = 6'bxx0000; // add                               
                            3'b001: aluc  = 6'bx00101; // sll
                            3'b010: aluc  = 6'bxx0011; // slt
                            3'b011: aluc  = 6'bxx1011; // sltu
                            3'b100: aluc  = 6'bxx0100; // xor                                             
                            3'b101: aluc  = 6'bx01101; // srl
                            3'b110: aluc  = 6'bxx1010; // or                               
                            3'b111: aluc  = 6'bxx0010; // and
                        endcase
                    end
                    
                    7'b0100000: // sra/sub
                    begin
                        case(funct3)
                            3'b000: aluc = 6'bxx1000; // sub
                            3'b101: aluc = 6'bx11101; // sra
                        endcase
                    end

                    7'b0000001: // Mul/Div
                    begin
                        case(funct3)
                            3'b000: aluc = 6'b000001; // mul
                            3'b001: aluc = 6'b010001; // mulh
                            3'b010: aluc = 6'b100001; // mulhsu
                            3'b011: aluc = 6'b110001; // mulhu
                            3'b100: aluc = 6'b001001; // div
                            3'b101: aluc = 6'b011001; // divu
                            3'b110: aluc = 6'b101001; // rem
                            3'b111: aluc = 6'b111001; // remu
                        endcase
                    end
                    
                    default: aluc = 6'bxxxxxx;
                endcase
            end
            
            7'b0010011: // I-Type
            begin
                wreg    = 1'b1;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b1;
                signext = 1'b1;
                ls_b    = 1'bx;
                ls_h    = 1'bx;
                load_signext = 1'bx;
                wmem    = 1'b0;
                pcsrc   = 2'b00;
                auipc   = 1'b0;

                case(funct3)
                    3'b000: aluc = 6'bxx0000; // addi
                    3'b010: aluc = 6'bxx0011; // slti
                    3'b011: aluc = 6'bxx1011; // sltiu
                    3'b100: aluc = 6'bxx0100; // xori
                    3'b110: aluc = 6'bxx1010; // ori
                    3'b111: aluc = 6'bxx0010; // andi
                    3'b001:                   // slli
                    begin
                        aluc = 6'bx00101; 
                        signext = 1'b0;
                    end
                    3'b101:                 // sr
                    begin
                        signext = 1'b0;
                        case(funct7)
                            7'b0000000: aluc = 6'bx01101; // srli
                            7'b0100000: aluc = 6'bx11101; // srai
                            default:    aluc = 6'bxxxxxx;
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
                ls_b    = 1'bx;
                ls_h    = 1'bx;
                load_signext = 1'bx;
                wmem     = 1'b0;
                auipc    = 1'b0;
                pcsrc[1] = 1'b0;
                
                case(funct3)
                    3'b000: // beq
                    begin 
                        pcsrc[0] = z; 
                        aluc     = 6'bxx0100;
                    end

                    3'b001: // bne
                    begin
                        pcsrc[0] = ~z; 
                        aluc     = 6'bxx0100;
                    end

                    3'b100: // blt
                    begin
                        pcsrc[0] = ~z; 
                        aluc     = 6'bxx0011;
                    end

                    3'b101: // bge
                    begin
                        pcsrc[0] = z; 
                        aluc     = 6'bxx0011;
                    end

                    3'b110: // bltu
                    begin
                        pcsrc[0] = ~z; 
                        aluc     = 6'bxx1011;
                    end

                    3'b111: // bgeu
                    begin
                        pcsrc[0] = z; 
                        aluc     = 6'bxx1011;
                    end

                    default: pcsrc = 1'bx;
                endcase
            end
            
            7'b0000011: // Load-Type 
            begin
                wreg    = 1'b1;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b1;
                aluimm  = 1'b1;
                signext = 1'b1;
                wmem    = 1'b0;
                pcsrc   = 2'b00;
                aluc    = 6'bxx0000;
                auipc   = 1'b0;
                case(funct3)
                    3'b000: // lb
                    begin
                        ls_b         = 1'b1;
                        ls_h         = 1'b0;
                        load_signext = 1'b1;
                    end

                    3'b001: // lh
                    begin
                        ls_b         = 1'b0;
                        ls_h         = 1'b1;
                        load_signext = 1'b1;
                    end

                    3'b010: // lw
                    begin
                        ls_b         = 1'b0;
                        ls_h         = 1'b0;
                        load_signext = 1'b0;
                    end

                    3'b100: // lbu
                    begin
                        ls_b         = 1'b1;
                        ls_h         = 1'b0;
                        load_signext = 1'b0;
                    end

                    3'b101: // lhu
                    begin
                        ls_b         = 1'b0;
                        ls_h         = 1'b1;
                        load_signext = 1'b0;
                    end

                endcase
            end
            
            7'b0100011: // Store-Type 
            begin
                wreg    = 1'b0;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b1;
                signext = 1'b1;
                wmem    = 1'b1;
                pcsrc   = 2'b00;
                aluc    = 6'bxx0000;
                auipc   = 1'b0;
            end
            
            7'b0110111: // lui
            begin
                wreg    = 1'b1;
                jal     = 1'b0;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b1;
                signext = 1'b0;
                ls_b    = 1'bx;
                ls_h    = 1'bx;
                load_signext = 1'bx;
                wmem    = 1'b0;
                pcsrc   = 2'b00;
                aluc    = 6'bxx1100;
                auipc   = 1'b0;
            end

            7'b0010111: // auipc
            begin
                wreg    = 1'b1;
                jal     = 1'b0;
                jalr    = 1'bx;
                mem2reg = 1'b0;
                aluimm  = 1'b1;
                signext = 1'b1;
                ls_b    = 1'bx;
                ls_h    = 1'bx;
                load_signext = 1'bx;
                wmem    = 1'b0;
                pcsrc   = 2'b00;
                aluc    = 6'bxx0000;
                auipc   = 1'b1;
            end
            
            7'b1101111: // jal
            begin
                wreg    = 1'b1;
                jal     = 1'b1;
                jalr    = 1'b0;
                mem2reg = 1'b0;
                aluimm  = 1'b0;
                signext = 1'b0;
                ls_b    = 1'bx;
                ls_h    = 1'bx;
                load_signext = 1'bx;
                wmem    = 1'b0;
                pcsrc   = 2'b10;
                aluc    = 6'bxxxxxx;
                auipc   = 1'b0;
            end
            
            7'b1100111: // jalr
            begin
                wreg    = 1'b1;
                jal     = 1'b1;
                jalr    = 1'b1;
                mem2reg = 1'b0;
                aluimm  = 1'b0;
                signext = 1'b1;
                ls_b    = 1'bx;
                ls_h    = 1'bx;
                load_signext = 1'bx;
                wmem    = 1'b0;
                pcsrc   = 2'b01;
                aluc    = 6'bxxxxxx;
                auipc   = 1'b0;
            end
            
            default:
            begin
                wreg    = 1'bx;
                jal     = 1'bx;
                jalr    = 1'bx;
                mem2reg = 1'bx;
                aluimm  = 1'bx;
                signext = 1'bx;
                ls_b    = 1'bx;
                ls_h    = 1'bx;
                load_signext = 1'bx;
                wmem    = 1'bx;
                pcsrc   = 2'bxx;
                aluc    = 6'bxxxxxx;
                auipc   = 1'bx;
            end
        endcase
    end
    
endmodule

