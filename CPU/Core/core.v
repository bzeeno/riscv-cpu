module core(
    input wire i_clk, i_resetn,
    input wire [31:0] i_instr, // instruction from instruction memory
    input wire [31:0] i_dmem,  // data from data memory
    output wire [31:0] o_pc,   // program counter
    output wire [31:0] o_alu,  // alu output
    output wire [31:0] o_dmem, // data to data memory
    output wire o_wmem         // write data memory 
);

    // Instruction Signals
    wire [6:0] opcode = i_instr[6:0];
    wire [4:0] rd     = i_instr[11:7];
    wire [4:0] rs1    = i_instr[19:15];
    wire [4:0] rs2    = i_instr[24:20];
    wire [2:0] funct3 = i_instr[14:12];
    wire [6:0] funct7 = i_instr[31:25];
    
    // pc signals
    wire [31:0] pc_next;                           // next value for pc
    wire [31:0] p4;                                // pc+4
    wire [31:0] jalr_branch_inputb;                // output of 2:1 MUX that chooses between p4 and reg_rdata1
    wire [31:0] jal_pc;                            // pc for jal
    wire [31:0] jalr_branch_pc;                    // pc for branch or jalr
    
    // ALU Signals
    wire [5:0] aluc;
    wire [31:0] alu_inputa;
    wire [31:0] alu_inputb;
    wire z;
    wire [31:0] r;
    // control unit signals
    wire [1:0] pcsrc;
    wire mem2reg, wmem, aluimm, wreg, jal, jalr, signext, auipc, ls_b, ls_h, load_signext;
    
    // immediate decoder signal 
    wire [31:0] imm_val; // hold immediate value from instr
    
     // Regfile signals
    wire [31:0] reg_wdata;
    wire [31:0] reg_rdata1, reg_rdata2; // read data from reg file
    wire [31:0] alu_mem_data; // temp wire to wreg_mux
    wire [31:0] dmem_mod; // modified dmem data
    
    /********************** CONTROL UNIT **********************/
    control_unit controller(
        // from instr mem
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        // from datapath
        .z(z),
        // to datapath
        .aluc(aluc),
        .pcsrc(pcsrc),
        .mem2reg(mem2reg), .wmem(o_wmem), .aluimm(aluimm), .wreg(wreg), .jal(jal), .jalr(jalr), .signext(signext), .auipc(auipc), .ls_b(ls_b), .ls_h(ls_h), .load_signext(load_signext)
    );
    /**********************************************************/
    
    
    /********************** PC *********************/
    // pc dff
    dff32 pc_ff(
        .i_clk(i_clk), .i_resetn(i_resetn),
        .next(pc_next),
        .out(o_pc)
    );
    
    // get p4 (pc+4)
    cla_32bit p4_adder(
        .a(o_pc), .b(32'h4), // 32-bit inputs
        .c_in(0),            // carry in
        .sum(p4),            // sum result
        .c_out()             // carry out
    );
    
    // Inputb for cla
    assign jalr_branch_inputb = jalr ? reg_rdata1 : o_pc; // iamhere
      
    // add imm to pc (branch) or reg_data1 (jalr). 
    cla_32bit br_jalr_adder (  
        .a(imm_val), .b(jalr_branch_inputb),
        .c_in(0),
        .sum(jalr_branch_pc),
        .c_out()
    );
    
    // jal pc iamhere
    cla_32bit jal_pc_adder (
        .a(imm_val), .b(o_pc),
        .c_in(0),
        .sum(jal_pc),
        .c_out()
    ); 
    
    // 3:1 MUX to select next pc
    mux_3to1 next_pc_mux (
        .inputA(p4), .inputB(jalr_branch_pc), .inputC(jal_pc),
        .select(pcsrc),
        .selected_out(pc_next)
    ); 
    /***********************************************/
    
    
    /********************** REGFILE **********************/
    assign alu_mem_data = mem2reg ? dmem_mod : r;
    
    // write data to regfile mux
    // 1 -> p4
    // 0 -> alu OR data mem
    assign reg_wdata = jal ? p4 : alu_mem_data;
    
    regfile register_file (
        .clk(i_clk), .resetn(i_resetn),
        .rs1(rs1), .rs2(rs2), .rd(rd), // register source 1, 2; register destination
        .reg_write(wreg),
        .write_data(reg_wdata),
        .read_data1(reg_rdata1), .read_data2(reg_rdata2)
    );
    /*****************************************************/
    
    
    /********************** IMMEDIATE DECODER **********************/
    // Get immediate value based on opcode 
    imm_decode immediate_decoder (
        .i_instr(i_instr),
        .i_opcode(opcode),
        .i_signext(signext),
        .o_imm_val(imm_val)
    );
    /**************************************************************/
    
    
    /********************** ALU **********************/
    // input a mux
    assign alu_inputa = auipc ? o_pc : reg_rdata1;
    
    // input b mux
    assign alu_inputb = aluimm ? imm_val : reg_rdata2;
    
    alu alu_unit(
        .a(alu_inputa), .b(alu_inputb),
        .aluc(aluc),
        .zero(z), // zero flag
        .result(r)
    );
    /*************************************************/
    
    /********************** STORE MODIFIER **********************/
    store_modifier store_unit (
        .sb(ls_b), .sh(ls_h), 
        .data_in(reg_rdata2),
        .data_out(o_dmem)
    );
    /************************************************************/
    
    /*********************** LOAD MODIFIER **********************/
    load_modifier load_unit (
        .lb(ls_b), .lh(ls_h), .load_signext(load_signext),
        .data_in(i_dmem),
        .data_out(dmem_mod)
    );
    /************************************************************/

    /********************** OUTPUTS **********************/
    assign o_alu = r;
    /*****************************************************/
endmodule

