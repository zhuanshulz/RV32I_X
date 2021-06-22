`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 02:29:45
// Design Name: 
// Module Name: id_ex
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

module id_ex(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active

    // from ctrl
    input   wire[5:0]           stall_i,

    // from id stage
    input   wire[`AluOpBus]     id_aluop_i,
    input   wire[`AluSelBus]    id_alusel_i,
    input   wire[`RegBus]       id_reg1_data_i,
    input   wire[`RegBus]       id_reg2_data_i,
    input   wire[`RegAddrBus]   id_reg_waddr_i,
    input   wire                id_reg_we_i,
    input   wire                id_branch_result_i,
    input   wire[`RegBus]       id_load_store_imm_i,
    input   wire[4:0]           id_major_code_i,
    // to id
    output  reg                 id_branch_result_o,
    output  reg[4:0]            id_major_code_o,

    // to ex stage
    output  reg[`AluOpBus]      ex_aluop_o,
    output  reg[`AluSelBus]     ex_alusel_o,
    output  reg[`RegBus]        ex_reg1_data_o,
    output  reg[`RegBus]        ex_reg2_data_o,
    output  reg[`RegAddrBus]    ex_reg_waddr_o,
    output  reg                 ex_reg_we_o,
    output  reg[`RegBus]        ex_load_store_imm_o
    );

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin
            ex_aluop_o <= `EXE_OP_NOP;
            ex_alusel_o <= `EXE_RES_NOP;
            ex_reg1_data_o <= `ZeroWord;
            ex_reg2_data_o <= `ZeroWord;
            ex_reg_waddr_o <= `RegAddrx0;
            ex_reg_we_o <= `WriteDisable;
            id_branch_result_o <= `NotBranch;
            ex_load_store_imm_o <= `ZeroWord;
            id_major_code_o <= 5'b1;
        end else if (stall_i[2] == `Stall && stall_i[3] == `NotStall) begin
            ex_aluop_o <= `EXE_OP_NOP;
            ex_alusel_o <= `EXE_RES_NOP;
            ex_reg1_data_o <= `ZeroWord;
            ex_reg2_data_o <= `ZeroWord;
            ex_reg_waddr_o <= `RegAddrx0;
            ex_reg_we_o <= `WriteDisable;
            id_branch_result_o <= `NotBranch;
            ex_load_store_imm_o <= `ZeroWord;
            id_major_code_o <= 5'b1;
        end else if (stall_i[2] == `NotStall) begin
            ex_aluop_o <= id_aluop_i;
            ex_alusel_o <= id_alusel_i;
            ex_reg1_data_o <= id_reg1_data_i;
            ex_reg2_data_o <= id_reg2_data_i;
            ex_reg_waddr_o <= id_reg_waddr_i;
            ex_reg_we_o <= id_reg_we_i;
            id_branch_result_o <= id_branch_result_i;
            ex_load_store_imm_o <= id_load_store_imm_i;
            id_major_code_o <= id_major_code_i;
        end
    end
endmodule
