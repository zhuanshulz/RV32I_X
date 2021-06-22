`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 01:36:39
// Design Name: 
// Module Name: id
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.vh"

module id(
    input   wire                rst_n,              // Reset, low active

    // to ctrl
    output  wire                stall_o,
    
    // from if_id
    input   wire[`InstAddrBus]  pc_i,
    input   wire[`InstBus]      inst_i,
    input   wire                prediction_i,
    input   wire[`InstAddrBus]  prediction_pc_i,

    // to pc_reg
    output  reg                 branch_flag_o,
    output  reg[`RegBus]        branch_address_o,
    output  wire                prediction_result_o,
    output  reg[`InstAddrBus]   predicted_pc_o,
    output  reg[`InstAddrBus]   target_address_o,
    output  reg                 is_branch_inst_o,

    // from regfile
    input   wire[`RegBus]       reg1_data_i,
    input   wire[`RegBus]       reg2_data_i,
    // to regfile
    output  reg                 reg1_re_o,
    output  reg                 reg2_re_o,
    output  reg[`RegAddrBus]    reg1_addr_o,
    output  reg[`RegAddrBus]    reg2_addr_o,

    // to id_ex
    output  reg[`AluOpBus]      aluop_o,
    output  reg[`AluSelBus]     alusel_o,
    output  reg[`RegBus]        reg1_data_o,
    output  reg[`RegBus]        reg2_data_o,
    output  reg[`RegAddrBus]    reg_waddr_o,
    output  reg                 reg_we_o,
    output  reg                 branch_result_o,
    input   wire                branch_result_i,
    output  reg[`RegBus]        load_store_imm_o,
    input   wire[4:0]           major_code_i,
    output  reg[4:0]            major_code_o,

    // from ex, data forwarding
    input   wire[`RegAddrBus]   ex_reg_waddr_i,
    input   wire[`RegBus]       ex_reg_wdata_i,
    input   wire                ex_reg_we_i,

    // from mem, data forwding
    input   wire[`RegAddrBus]   mem_reg_waddr_i,
    input   wire[`RegBus]       mem_reg_wdata_i,
    input   wire                mem_reg_we_i
    );

    // load dependency
    reg stall_caused_by_load_reg1;
    reg stall_caused_by_load_reg2;
    wire last_inst_load;

    assign last_inst_load =  (major_code_i == `MAJOR_OPCODE_LOAD) ? 1'b1 : 1'b0;

    // mispredict stall
    reg prediction_result;
    reg stall_caused_by_mispredict;

    // to ex
    assign inst_o = inst_i;
 
    // for R type but compatible to other type
    wire[4:0] major_code = inst_i[6:2];             // major code
    wire[4:0] rd = inst_i[11:7];                    // rd
    wire[2:0] funct3 = inst_i[14:12];               // funct3
    wire[4:0] rs1 = inst_i[19:15];                  // rs1
    wire[4:0] rs2 = inst_i[24:20];                  // rs2
    wire[6:0] funct7 = inst_i[31:25];               // funct7
    wire[9:0] opcode = {inst_i[20], inst_i[30], inst_i[14:12], inst_i[6:2]};

    // save immediate
    reg[`RegBus] imm;                               // immediate

    
    // whether reg1 is less than reg2
    wire reg1_lt_reg2;
    // Complement of reg2
    wire[`RegBus] reg2_complement;
    // result of sum
    wire[`RegBus] result_sum;
    // if sub/slt, calc reg2's complement
    assign reg2_complement = (funct3 == `FUNCT3_BLT || funct3 == `FUNCT3_BGE) ? 
                            (~reg2_data_o) + 1 : 
                            ((funct3 == `FUNCT3_BLTU || funct3 == `FUNCT3_BGEU) ? 
                            reg2_data_o : `ZeroWord);
    assign result_sum = reg1_data_o + reg2_complement;
    assign reg1_lt_reg2 = (funct3 == `FUNCT3_BLT || funct3 == `FUNCT3_BGE) ? 
                            ((reg1_data_o[31] && ~reg2_data_o[31]) ||
                            (~reg1_data_o[31] && ~reg2_data_o[31] && result_sum[31]) ||
                            (reg1_data_o[31] && reg2_data_o[31] && result_sum[31])) : 
                            ((funct3 == `FUNCT3_BLTU || funct3 == `FUNCT3_BGEU) ? 
                            (reg1_data_o < reg2_data_i) : 1'b0);

    // instruction is valid or not
    reg inst_valid;

    reg[`RegBus] jalr_reg_data;

    // instruction decoding
    always @(*) begin
        if (rst_n == `RstEnable || branch_result_i == `NotBranch) begin
            aluop_o <= `EXE_OP_NOP;
            alusel_o <= `EXE_RES_NOP;
            reg_waddr_o <= `RegAddrx0;
            reg_we_o <= `WriteDisable;
            reg1_re_o <= `ReadDisable;
            reg2_re_o <= `ReadDisable;
            reg1_addr_o <= `RegAddrx0;
            reg2_addr_o <= `RegAddrx0;
            imm <= `ZeroWord;
            inst_valid <= `InstInvalid;                   // ???
            branch_flag_o <= `NotBranch;
            branch_result_o <= `Branch;
            branch_address_o <= `ZeroWord;
            load_store_imm_o <= `ZeroWord;
            major_code_o <= 5'b11111;
            prediction_result <= 1'b1;
            predicted_pc_o <= pc_i;
            target_address_o <= `ZeroWord;
            is_branch_inst_o <= 1'b0;
        end else begin
            aluop_o <= `EXE_OP_NOP;
            alusel_o <= `EXE_RES_NOP;
            reg_waddr_o <= rd;
            reg_we_o <= `WriteDisable;
            reg1_re_o <= `ReadDisable;
            reg2_re_o <= `ReadDisable;
            reg1_addr_o <= rs1;
            reg2_addr_o <= rs2;
            imm <= `ZeroWord;
            inst_valid <= `InstInvalid;                 // ???
            branch_flag_o <= `NotBranch;
            branch_result_o <= `Branch;
            branch_address_o <= `ZeroWord;
            load_store_imm_o <= `ZeroWord;
            major_code_o <= major_code;
            prediction_result <= 1'b1;
            predicted_pc_o <= pc_i;
            target_address_o <= `ZeroWord;
            is_branch_inst_o <= 1'b0;

            case (major_code)                               // classify inst according to major code
                `MAJOR_OPCODE_LUI: begin                    // can regard as logic or with 0
                    aluop_o <= `EXE_OP_OR;
                    alusel_o <= `EXE_RES_LOGIC;
                    reg_we_o <= `WriteEnable;
                    reg1_re_o <= `ReadDisable;
                    reg2_re_o <= `ReadDisable;
                    imm <= `TYPE_U_IMM;
                    inst_valid <= `InstValid;
                end
                `MAJOR_OPCODE_AUIPC: begin                  // kind of add
                    aluop_o <= `EXE_OP_ADD;
                    alusel_o <= `EXE_RES_ARITHMETIC;
                    reg_we_o <= `WriteEnable;
                    reg1_re_o <= `ReadEnable;               // but don't read reg
                    reg2_re_o <= `ReadDisable;
                    imm <= `TYPE_U_IMM;
                    inst_valid <= `InstValid;
                end
                `MAJOR_OPCODE_LOAD: begin
                    case (funct3)
                        `FUNCT3_LB: begin
                            aluop_o <= `EXE_OP_LB;
                            alusel_o <= `EXE_RES_LOAD_STORE;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            load_store_imm_o <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_LH: begin
                            aluop_o <= `EXE_OP_LH;
                            alusel_o <= `EXE_RES_LOAD_STORE;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            load_store_imm_o <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_LW: begin
                            aluop_o <= `EXE_OP_LW;
                            alusel_o <= `EXE_RES_LOAD_STORE;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            load_store_imm_o <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_LBU: begin
                            aluop_o <= `EXE_OP_LBU;
                            alusel_o <= `EXE_RES_LOAD_STORE;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            load_store_imm_o <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_LHU: begin
                            aluop_o <= `EXE_OP_LHU;
                            alusel_o <= `EXE_RES_LOAD_STORE;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            load_store_imm_o <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        default: begin
                            
                        end 
                    endcase
                end
                `MAJOR_OPCODE_STORE: begin
                    case (funct3)
                        `FUNCT3_SB: begin
                            aluop_o <= `EXE_OP_SB;
                            alusel_o <= `EXE_RES_LOAD_STORE;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_S_IMM;
                            load_store_imm_o <= `TYPE_S_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_SH: begin
                            aluop_o <= `EXE_OP_SH;
                            alusel_o <= `EXE_RES_LOAD_STORE;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_S_IMM;
                            load_store_imm_o <= `TYPE_S_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_SW: begin
                            aluop_o <= `EXE_OP_SW;
                            alusel_o <= `EXE_RES_LOAD_STORE;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_S_IMM;
                            load_store_imm_o <= `TYPE_S_IMM;
                            inst_valid <= `InstValid;
                        end
                        default: begin
                            
                        end
                    endcase
                end
                `MAJOR_OPCODE_BRANCH: begin                 // conditional branch instruction
                    case (funct3)
                        `FUNCT3_BEQ: begin
                            aluop_o <= `EXE_OP_BEQ;
                            alusel_o <= `EXE_RES_NOP;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_B_IMM;
                            inst_valid <= `InstValid;
                            if (reg1_data_o == reg2_data_o) begin
                                branch_flag_o <= `Branch;
                                branch_result_o <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                branch_address_o <= {`TYPE_B_IMM + pc_i};
                                prediction_result <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                predicted_pc_o <= pc_i;
                                target_address_o <= {`TYPE_B_IMM + pc_i};
                            end else begin
                                prediction_result <= (prediction_i == 1'b0) ? 1'b1 : 1'b0;
                            end
                            is_branch_inst_o <= 1'b1;
                        end 
                        `FUNCT3_BNE: begin
                            aluop_o <= `EXE_OP_BEQ;
                            alusel_o <= `EXE_RES_NOP;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_B_IMM;
                            inst_valid <= `InstValid;
                            if (reg1_data_o != reg2_data_o) begin
                                branch_flag_o <= `Branch;
                                branch_result_o <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                branch_address_o <= {`TYPE_B_IMM + pc_i};
                                prediction_result <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                predicted_pc_o <= pc_i;
                                target_address_o <= {`TYPE_B_IMM + pc_i};
                            end else begin
                                prediction_result <= (prediction_i == 1'b0) ? 1'b1 : 1'b0;
                            end
                            is_branch_inst_o <= 1'b1;
                        end 
                        `FUNCT3_BLT: begin
                            aluop_o <= `EXE_OP_BEQ;
                            alusel_o <= `EXE_RES_NOP;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_B_IMM;
                            inst_valid <= `InstValid;
                            if (reg1_lt_reg2 == 1'b1) begin
                                branch_flag_o <= `Branch;
                                branch_result_o <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                branch_address_o <= {`TYPE_B_IMM + pc_i};
                                prediction_result <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                predicted_pc_o <= pc_i;
                                target_address_o <= {`TYPE_B_IMM + pc_i};
                            end else begin
                                prediction_result <= (prediction_i == 1'b0) ? 1'b1 : 1'b0;
                            end
                            is_branch_inst_o <= 1'b1;
                        end 
                        `FUNCT3_BGE: begin
                            aluop_o <= `EXE_OP_BEQ;
                            alusel_o <= `EXE_RES_NOP;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_B_IMM;
                            inst_valid <= `InstValid;
                            if (reg1_lt_reg2 == 1'b0) begin
                                branch_flag_o <= `Branch;
                                branch_result_o <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                branch_address_o <= {`TYPE_B_IMM + pc_i};
                                prediction_result <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                predicted_pc_o <= pc_i;
                                target_address_o <= {`TYPE_B_IMM + pc_i};
                            end else begin
                                prediction_result <= (prediction_i == 1'b0) ? 1'b1 : 1'b0;
                            end
                            is_branch_inst_o <= 1'b1;
                        end 
                        `FUNCT3_BLTU: begin
                            aluop_o <= `EXE_OP_BEQ;
                            alusel_o <= `EXE_RES_NOP;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_B_IMM;
                            inst_valid <= `InstValid;
                            if (reg1_lt_reg2 == 1'b1) begin
                                branch_flag_o <= `Branch;
                                branch_result_o <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                branch_address_o <= {`TYPE_B_IMM + pc_i};
                                prediction_result <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                predicted_pc_o <= pc_i;
                                target_address_o <= {`TYPE_B_IMM + pc_i};
                            end else begin
                                prediction_result <= (prediction_i == 1'b0) ? 1'b1 : 1'b0;
                            end
                            is_branch_inst_o <= 1'b1;
                        end 
                        `FUNCT3_BGEU: begin
                            aluop_o <= `EXE_OP_BEQ;
                            alusel_o <= `EXE_RES_NOP;
                            reg_we_o <= `WriteDisable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadEnable;
                            imm <= `TYPE_B_IMM;
                            inst_valid <= `InstValid;
                            if (reg1_lt_reg2 == 1'b0) begin
                                branch_flag_o <= `Branch;
                                branch_result_o <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                branch_address_o <= {`TYPE_B_IMM + pc_i};
                                prediction_result <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_B_IMM + pc_i})) ? 1'b1 : 1'b0;
                                predicted_pc_o <= pc_i;
                                target_address_o <= {`TYPE_B_IMM + pc_i};
                            end else begin
                                prediction_result <= (prediction_i == 1'b0) ? 1'b1 : 1'b0;
                            end
                            is_branch_inst_o <= 1'b1;
                        end 
                        default: begin
                            
                        end
                    endcase
                end
                `MAJOR_OPCODE_JAL: begin                    // Unconditional jump
                    aluop_o <= `EXE_OP_JAL;
                    alusel_o <= `EXE_RES_JUMP;
                    reg_we_o <= `WriteEnable;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadDisable;
                    imm <= `TYPE_J_IMM;
                    inst_valid <= `InstValid;
                    branch_flag_o <= `Branch;
                    branch_result_o <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_J_IMM + pc_i})) ? 1'b1 : 1'b0;
                    branch_address_o <= {`TYPE_J_IMM + pc_i};
                    prediction_result <= (prediction_i == 1'b1 && (prediction_pc_i == {`TYPE_J_IMM + pc_i})) ? 1'b1 : 1'b0;
                    predicted_pc_o <= pc_i;
                    target_address_o <= {`TYPE_J_IMM + pc_i};
                    is_branch_inst_o <= 1'b1;
                end
                `MAJOR_OPCODE_JALR: begin
                    aluop_o <= `EXE_OP_JALR;
                    alusel_o <= `EXE_RES_JUMP;
                    reg_we_o <= `WriteEnable;
                    reg1_re_o <= `ReadEnable;
                    reg2_re_o <= `ReadDisable;
                    imm <= `TYPE_I_IMM;
                    inst_valid <= `InstValid;
                    branch_flag_o <= `Branch;
                    branch_result_o <= (prediction_i == 1'b1 && (prediction_pc_i == {{`TYPE_I_IMM + jalr_reg_data} & 32'hfffffffe})) ? 1'b1 : 1'b0;
                    branch_address_o <= {{`TYPE_I_IMM + jalr_reg_data} & 32'hfffffffe};  // low 1 bit set zero
                    prediction_result <= (prediction_i == 1'b1 && (prediction_pc_i == {{`TYPE_I_IMM + jalr_reg_data} & 32'hfffffffe})) ? 1'b1 : 1'b0;
                    predicted_pc_o <= pc_i;
                    target_address_o <= {{`TYPE_I_IMM + jalr_reg_data} & 32'hfffffffe};
                    is_branch_inst_o <= 1'b1;
                end
                `MAJOR_OPCODE_OP_IMM: begin
                    case (funct3)                           // classify inst according to funct3
                        `FUNCT3_ORI: begin
                            aluop_o <= `EXE_OP_OR;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_XORI: begin
                            aluop_o <= `EXE_OP_XOR;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_ANDI: begin
                            aluop_o <= `EXE_OP_AND;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_SLLI: begin
                            aluop_o <= `EXE_OP_SLL;
                            alusel_o <= `EXE_RES_SHIFT;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_SRLI: begin         // `FUNCT3_SRAI is same
                            case (funct7)
                                `FUNCT7_SRLI: begin
                                    aluop_o <= `EXE_OP_SRL;
                                    alusel_o <= `EXE_RES_SHIFT;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o <= `ReadEnable;
                                    reg2_re_o <= `ReadDisable;
                                    imm <= `TYPE_I_IMM;
                                    inst_valid <= `InstValid;
                                end
                                `FUNCT7_SRAI: begin
                                    aluop_o <= `EXE_OP_SRA;
                                    alusel_o <= `EXE_RES_SHIFT;
                                    reg_we_o <= `WriteEnable;
                                    reg1_re_o <= `ReadEnable;
                                    reg2_re_o <= `ReadDisable;
                                    imm <= `TYPE_I_IMM;
                                    inst_valid <= `InstValid;
                                end
                                default: begin
                                    
                                end
                            endcase
                        end
                        `FUNCT3_ADDI: begin
                            aluop_o <= `EXE_OP_ADD;
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_SLTI: begin
                            aluop_o <= `EXE_OP_SLT;         // slt is same
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        `FUNCT3_SLTIU: begin
                            aluop_o <= `EXE_OP_SLTU;         // sltu is same
                            alusel_o <= `EXE_RES_ARITHMETIC;
                            reg_we_o <= `WriteEnable;
                            reg1_re_o <= `ReadEnable;
                            reg2_re_o <= `ReadDisable;
                            imm <= `TYPE_I_IMM;
                            inst_valid <= `InstValid;
                        end
                        default: begin
                            
                        end
                    endcase
                end
                `MAJOR_OPCODE_OP:begin
                    if (funct7 == `FUNCT7_MUL) begin
                        case (funct3)
                            `FUNCT3_MUL: begin
                                aluop_o <= `EXE_OP_MUL;
                                alusel_o <= `EXE_RES_MUL;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_MULH: begin
                                aluop_o <= `EXE_OP_MULH;
                                alusel_o <= `EXE_RES_MUL;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_MULHSU: begin
                                aluop_o <= `EXE_OP_MULHSU;
                                alusel_o <= `EXE_RES_MUL;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_MULHU: begin
                                aluop_o <= `EXE_OP_MULHU;
                                alusel_o <= `EXE_RES_MUL;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_DIV: begin
                                aluop_o <= `EXE_OP_DIV;
                                alusel_o <= `EXE_RES_DIV;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_DIVU: begin
                                aluop_o <= `EXE_OP_DIVU;
                                alusel_o <= `EXE_RES_DIV;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_REM: begin
                                aluop_o <= `EXE_OP_REM;
                                alusel_o <= `EXE_RES_DIV;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_REMU: begin
                                aluop_o <= `EXE_OP_REMU;
                                alusel_o <= `EXE_RES_DIV;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            default: begin
                                
                            end
                        endcase
                    end else begin
                        case (funct3)
                            `FUNCT3_OR: begin
                                aluop_o <= `EXE_OP_OR;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_XOR: begin
                                aluop_o <= `EXE_OP_XOR;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_AND: begin
                                aluop_o <= `EXE_OP_AND;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_SLL: begin
                                aluop_o <= `EXE_OP_SLL;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_SRL: begin         // `FUNCT3_SRAI is same
                                case (funct7)
                                    `FUNCT7_SRL: begin
                                        aluop_o <= `EXE_OP_SRL;
                                        alusel_o <= `EXE_RES_SHIFT;
                                        reg_we_o <= `WriteEnable;
                                        reg1_re_o <= `ReadEnable;
                                        reg2_re_o <= `ReadEnable;
                                        imm <= `TYPE_R_IMM;
                                        inst_valid <= `InstValid;
                                    end
                                    `FUNCT7_SRA: begin
                                        aluop_o <= `EXE_OP_SRA;
                                        alusel_o <= `EXE_RES_SHIFT;
                                        reg_we_o <= `WriteEnable;
                                        reg1_re_o <= `ReadEnable;
                                        reg2_re_o <= `ReadEnable;
                                        imm <= `TYPE_R_IMM;
                                        inst_valid <= `InstValid;
                                    end
                                    default: begin
                                        
                                    end
                                endcase
                            end
                            `FUNCT3_ADD: begin          //      
                                if (funct7 == `FUNCT7_ADD) begin
                                    aluop_o <= `EXE_OP_ADD;
                                end else begin
                                    aluop_o <= `EXE_OP_SUB;
                                end
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_SLT: begin
                                aluop_o <= `EXE_OP_SLT;         // slti is same
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            `FUNCT3_SLTU: begin
                                aluop_o <= `EXE_OP_SLTU;         // sltui is same
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg_we_o <= `WriteEnable;
                                reg1_re_o <= `ReadEnable;
                                reg2_re_o <= `ReadEnable;
                                imm <= `TYPE_R_IMM;
                                inst_valid <= `InstValid;
                            end
                            default: begin
                                
                            end
                        endcase
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end

    // get oprand 1
    // oprand may be imm, when reg1_re_o is disable
    always @(*) begin
        stall_caused_by_load_reg1 <= `NotStall;
        if (rst_n == `RstEnable) begin
            reg1_data_o <= `ZeroWord;
            jalr_reg_data <= `ZeroWord;
        end else if (last_inst_load == 1'b1 && ex_reg_waddr_i ==reg1_addr_o
                && reg1_re_o == 1'b1) begin
            stall_caused_by_load_reg1 <= `Stall;
        end else if (major_code == `MAJOR_OPCODE_AUIPC) begin
            reg1_data_o <= pc_i;                        // oprand1 of auipc is pc
        end else if (major_code == `MAJOR_OPCODE_JAL || major_code == `MAJOR_OPCODE_JALR) begin //  || major_code == `MAJOR_OPCODE_JALR
            reg1_data_o <= pc_i + 4;                    // oprand of JAL is pc + 4
            if ((reg1_re_o == `ReadEnable) && (ex_reg_we_i == `WriteEnable) 
                    && (ex_reg_waddr_i == reg1_addr_o)) begin
                jalr_reg_data <= ex_reg_wdata_i;              // data forwarding from ex
            end else if ((reg1_re_o == `ReadEnable) && (mem_reg_we_i == `WriteEnable) 
                        && (mem_reg_waddr_i == reg1_addr_o)) begin
                jalr_reg_data <= mem_reg_wdata_i;             // data forwarding from mem
            end else if (reg1_re_o == `ReadEnable) begin
                jalr_reg_data <= reg1_data_i;
            end
        end else if ((reg1_re_o == `ReadEnable) && (ex_reg_we_i == `WriteEnable) 
                    && (ex_reg_waddr_i == reg1_addr_o)) begin
            reg1_data_o <= ex_reg_wdata_i;              // data forwarding from ex
        end else if ((reg1_re_o == `ReadEnable) && (mem_reg_we_i == `WriteEnable) 
                    && (mem_reg_waddr_i == reg1_addr_o)) begin
            reg1_data_o <= mem_reg_wdata_i;             // data forwarding from mem
        end else if (reg1_re_o == `ReadEnable) begin
            reg1_data_o <= reg1_data_i;
        end else if (reg1_re_o == `ReadDisable) begin
            reg1_data_o <= imm;
        end else begin
            reg1_data_o <= `ZeroWord;
        end
    end

    // get oprand 2
    always @(*) begin
        stall_caused_by_load_reg2 <= `NotStall;
        if (rst_n == `RstEnable) begin
            reg2_data_o <= `ZeroWord;
        end else if (last_inst_load == 1'b1 && ex_reg_waddr_i ==reg2_addr_o
                && reg2_re_o == 1'b1) begin
            stall_caused_by_load_reg2 <= `Stall;
        end else if ((reg2_re_o == `ReadEnable) && (ex_reg_we_i == `WriteEnable) 
                    && (ex_reg_waddr_i == reg2_addr_o)) begin
            reg2_data_o <= ex_reg_wdata_i;              // data forwarding from ex
        end else if ((reg2_re_o == `ReadEnable) && (mem_reg_we_i == `WriteEnable) 
                    && (mem_reg_waddr_i == reg2_addr_o)) begin
            reg2_data_o <= mem_reg_wdata_i;             // data forwarding from mem
        end else if (reg2_re_o == `ReadEnable) begin
            reg2_data_o <= reg2_data_i;
        end else if (reg2_re_o == `ReadDisable) begin
            reg2_data_o <= imm;
        end else begin
            reg2_data_o <= `ZeroWord;
        end
    end

    assign stall_o = stall_caused_by_load_reg1 | stall_caused_by_load_reg2 | stall_caused_by_mispredict;
    assign prediction_result_o = prediction_result;
endmodule
