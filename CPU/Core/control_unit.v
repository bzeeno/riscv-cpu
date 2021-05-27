module control_unit (
    // from instr mem
    input wire i_resetn,
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [4:0] rs1, rs2,
    // from datapath
    input wire i_compare_lt, i_compare_eq,
    input wire i_mem_wreg, i_mem_mem2reg, i_exe_wreg, i_exe_mem2reg,
    input wire [4:0] i_mem_rd, i_exe_rd,
    // to datapath
    output wire o_not_stall, o_flush, 
    output reg [5:0] aluc,
    output reg [1:0] pcsrc,
    output reg [1:0] o_fwda, o_fwdb,
    output wire o_wreg, o_wmem,
    output reg mem2reg, aluimm, jal, jalr, signext, auipc, ls_b, ls_h, load_signext, slt_instr, compare_signed, compare_imm 
); 
    
    /**** Data Forwarding (regdata1)****/
    always @(*)
    begin
        // default: No hazards
        o_fwda = 2'b00;

        // alu out from instr in exe stage
        if (i_exe_wreg & (i_exe_rd != 0) & (i_exe_rd == rs1) & ~i_exe_mem2reg) // if instr in exe stage writes to regfile AND the instr in the ID stage reads the result of the instr in the EXE stage AND EXE instr is not a load
            o_fwda = 2'b01;
        else
        begin
            // alu out from instr in mem stage
            if (i_mem_wreg & (i_mem_rd != 0) & (i_mem_rd == rs1) & ~i_mem_mem2reg) // if MEM instr writes to regfile AND ID instr reads the result of MEM instr AND MEM instr is not a load 
                o_fwda = 2'b10;
            // mem data from instr in mem stage 
            else
                if (i_mem_wreg & (i_mem_rd != 0) & (i_mem_rd == rs1) & i_mem_mem2reg) // if MEM instr writes to regfile AND ID instr reads the result of MEM instr AND MEM instr is a load
                    o_fwda = 2'b11;
        end 
    end

    /**** Data Forwarding (regdata2)****/
    always @(*)
    begin
        // default: No hazards
        o_fwdb = 2'b00;

        // alu out from instr in exe stage
        if (i_exe_wreg & (i_exe_rd != 0) & (i_exe_rd == rs2) & ~i_exe_mem2reg)
            o_fwdb = 2'b01;
        else
        begin
            // alu out from instr in mem stage
            if (i_mem_wreg & (i_mem_rd != 0) & (i_mem_rd == rs2) & ~i_mem_mem2reg)
                o_fwdb = 2'b10;
            // mem data from instr in mem stage 
            else
                if (i_mem_wreg & (i_mem_rd != 0) & (i_mem_rd == rs2) & i_mem_mem2reg)
                    o_fwdb = 2'b11;
        end 
    end

    wire stall;
    reg wmem, wreg;
    reg use_rs1, use_rs2; // boolean that signifies if the current instruction uses rs1/rs2
    assign o_wmem = wmem & o_not_stall;
    assign o_wreg = wreg & o_not_stall;

    assign stall = i_exe_wreg & i_exe_mem2reg & (i_exe_rd != 0) & ( use_rs1 & (i_exe_rd == rs1) | use_rs2 & (i_exe_rd == rs2) );
    assign o_not_stall = ~stall;
    assign o_flush = (pcsrc == 2'b00) ? 1'b0 : 1'b1; // if pcsrc is pc+4 then do not flush. If pcsrc is not pc+4 (jump/branch is taken) then flush

    always @(negedge i_resetn)
    begin
        pcsrc = 2'b00;
    end

    /******************************** Instruction Decode ********************************/
    always @(*)
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
        pcsrc   = 2'b00;
        aluc    = 6'bxxxxxx;
        auipc   = 1'bx;
        slt_instr = 1'bx;
        compare_signed = 1'bx;
        compare_imm = 1'bx;
        use_rs1 = 1'bx;
        use_rs2 = 1'bx;

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
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'b1;
                use_rs2 = 1'b1;
                
                case(funct7)
                    7'b0000000: 
                    begin
                        case(funct3)
                            3'b000: aluc  = 6'bxx0000; // add                               
                            3'b001: aluc  = 6'bx00101; // sll
                            3'b010:                    // slt
                            begin
                                compare_signed = 1'b1;
                                compare_imm = 1'b0;
                                aluc  = 6'bxx0011; 
                                slt_instr = 1'b1;
                            end
                            3'b011:                   // sltu
                            begin
                                compare_signed = 1'b0;
                                compare_imm = 1'b0;
                                aluc  = 6'bxx1011; 
                                slt_instr = 1'b1;
                            end
                            3'b100: aluc  = 6'bxx0100; // xor                                             
                            3'b101: aluc  = 6'bx01101; // srl
                            3'b110: aluc  = 6'bxx1010; // or                               
                            3'b111: aluc  = 6'bxx0010; // and
                            default: aluc = 6'bxxxxxx;
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
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'b1;
                use_rs2 = 1'b0;

                case(funct3)
                    3'b000: aluc = 6'bxx0000; // addi
                    3'b010:                   // slti
                    begin
                        compare_signed = 1'b1;
                        compare_imm = 1'b1;
                        aluc = 6'bxx0011; 
                        slt_instr = 1'b1;
                    end
                    3'b011:                   // sltiu
                    begin
                        compare_signed = 1'b0;
                        compare_imm = 1'b1;
                        aluc = 6'bxx1011; 
                        slt_instr = 1'b1;
                    end
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
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                aluc = 6'bxxxxxx;
                use_rs1 = 1'b1;
                use_rs2 = 1'b1;
                
                case(funct3)
                    3'b000: // beq
                    begin 
                        compare_signed = 1'b1;
                        compare_imm = 1'b0;
                        pcsrc[0] = i_compare_eq; 
                    end

                    3'b001: // bne
                    begin
                        compare_signed = 1'b1;
                        compare_imm = 1'b0;
                        pcsrc[0] = ~i_compare_eq; 
                    end

                    3'b100: // blt
                    begin
                        compare_signed = 1'b1;
                        compare_imm = 1'b0;
                        pcsrc[0] = i_compare_lt; 
                    end

                    3'b101: // bge
                    begin
                        compare_signed = 1'b1;
                        compare_imm = 1'b0;
                        pcsrc[0] = ~i_compare_lt; 
                    end

                    3'b110: // bltu
                    begin
                        compare_signed = 1'b0;
                        compare_imm = 1'b0;
                        pcsrc[0] = i_compare_lt; 
                    end

                    3'b111: // bgeu
                    begin
                        compare_signed = 1'b0;
                        compare_imm = 1'b0;
                        pcsrc[0] = ~i_compare_lt; 
                    end

                    default: pcsrc = 2'b00;
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
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'b1;
                use_rs2 = 1'b0;

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
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'b1;
                use_rs2 = 1'b1;

                case(funct3) 
                    3'b000: // sb
                    begin
                        ls_b = 1'b1;
                        ls_h = 1'b0;
                    end

                    3'b001: // sh
                    begin
                        ls_b = 1'b0;
                        ls_h = 1'b1;
                    end

                    default: // sw
                    begin
                        ls_b = 0;
                        ls_h = 0;
                    end
                endcase
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
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'b0;
                use_rs2 = 1'b0;
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
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'b0;
                use_rs2 = 1'b0;
            end
            
            7'b1101111: // jal
            begin
                pcsrc   = 2'b10;
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
                aluc    = 6'bxxxxxx;
                auipc   = 1'b0;
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'b0;
                use_rs2 = 1'b0;
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
                slt_instr = 1'b0;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'b1;
                use_rs2 = 1'b0;
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
                pcsrc   = 2'b00;
                aluc    = 6'bxxxxxx;
                auipc   = 1'bx;
                slt_instr = 1'bx;
                compare_signed = 1'bx;
                compare_imm = 1'bx;
                use_rs1 = 1'bx;
                use_rs2 = 1'bx;
            end
        endcase
    end
    
endmodule

