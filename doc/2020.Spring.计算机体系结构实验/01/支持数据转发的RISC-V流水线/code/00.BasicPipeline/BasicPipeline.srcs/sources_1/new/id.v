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
    
    // from if_id
    input   wire[`InstAddrBus]  pc_i,
    input   wire[`InstBus]      inst_i,

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
    output  reg                 reg_we_o
    );

    // for R type but compatible to other type
    wire[4:0] major_code = inst_i[6:2];             // major code
    wire[4:0] rd = inst_i[11:7];                    // rd
    wire[2:0] funct3 = inst_i[14:12];               // funct3
    wire[4:0] rs1 = inst_i[19:15];                  // rs1
    wire[4:0] rs2 = inst_i[24:20];                  // rs2
    wire[6:0] funct7 = inst_i[31:25];               // funct7

    // save immediate
    reg[`RegBus] imm;                               // immediate

    // instruction is valid or not
    reg inst_valid;

    // instruction decoding
    always @(*) begin
        if (rst_n == `RstEnable) begin
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
            reg_waddr_o <= `RegAddrx0;
            reg_we_o <= `WriteDisable;
            reg1_re_o <= `ReadDisable;
            reg2_re_o <= `ReadDisable;
            reg1_addr_o <= `RegAddrx0;
            reg2_addr_o <= `RegAddrx0;
            imm <= `ZeroWord;
            inst_valid <= `InstValid;                   // ???
        end else begin
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
            reg_waddr_o <= rd;
            reg_we_o <= `WriteDisable;
            reg1_re_o <= `ReadDisable;
            reg2_re_o <= `ReadDisable;
            reg1_addr_o <= rs1;
            reg2_addr_o <= rs2;
            imm <= `ZeroWord;
            inst_valid <= `InstInvalid;                 // ???
        end

        case (major_code)                               // classify inst according to major code
            `MAJOR_OPCODE_OP_IMM: begin
                case (funct3)                           // classify inst according to funct3
                    `FUNCT3_ORI: begin
                        aluop_o <= `EXE_OR_OP;
                        alusel_o <= `EXE_RES_LOGIC;
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
            default: begin
                
            end
        endcase
    end

    // get oprand 1
    // oprand may be imm, when reg1_re_o is disable
    always @(*) begin
        if (rst_n == `RstEnable) begin
            reg1_data_o <= `ZeroWord;
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
        if (rst_n == `RstEnable) begin
            reg2_data_o <= `ZeroWord;
        end else if (reg2_re_o == `ReadEnable) begin
            reg2_data_o <= reg2_data_i;
        end else if (reg2_re_o == `ReadDisable) begin
            reg2_data_o <= imm;
        end else begin
            reg2_data_o <= `ZeroWord;
        end
    end
endmodule
