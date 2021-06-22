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
    
    // from id stage
    input   wire[`AluOpBus]     id_aluop_i,
    input   wire[`AluSelBus]    id_alusel_i,
    input   wire[`RegBus]       id_reg1_data_i,
    input   wire[`RegBus]       id_reg2_data_i,
    input   wire[`RegAddrBus]   id_reg_waddr_i,
    input   wire                id_reg_we_i,

    // to ex stage
    output  reg[`AluOpBus]      ex_aluop_o,
    output  reg[`AluSelBus]     ex_alusel_o,
    output  reg[`RegBus]        ex_reg1_data_o,
    output  reg[`RegBus]        ex_reg2_data_o,
    output  reg[`RegAddrBus]    ex_reg_waddr_o,
    output  reg                 ex_reg_we_o
    );

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin
            ex_aluop_o <= `EXE_NOP_OP;
            ex_alusel_o <= `EXE_RES_NOP;
            ex_reg1_data_o <= `ZeroWord;
            ex_reg2_data_o <= `ZeroWord;
            ex_reg_waddr_o <= `RegAddrx0;
            ex_reg_we_o <= `WriteDisable;
        end else begin
            ex_aluop_o <= id_aluop_i;
            ex_alusel_o <= id_alusel_i;
            ex_reg1_data_o <= id_reg1_data_i;
            ex_reg2_data_o <= id_reg2_data_i;
            ex_reg_waddr_o <= id_reg_waddr_i;
            ex_reg_we_o <= id_reg_we_i;
        end
    end
endmodule
