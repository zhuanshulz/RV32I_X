`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 02:52:39
// Design Name: 
// Module Name: ex_mem
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

module ex_mem(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active
    
    // from ctrl
    input   wire[5:0]           stall_i,

    // from ex stage
    input   wire[`RegAddrBus]   ex_reg_waddr_i,
    input   wire[`RegBus]       ex_reg_wdata_i,
    input   wire                ex_reg_we_i,
    input   wire[`AluOpBus]     ex_aluop_i,
    input   wire[`RegBus]       ex_mem_addr_i,
    input   wire[`RegBus]       ex_store_data_i,
    // to mem stage
    output  reg[`RegAddrBus]    mem_reg_waddr_o,
    output  reg[`RegBus]        mem_reg_wdata_o,
    output  reg                 mem_reg_we_o,
    output  reg[`AluOpBus]      mem_aluop_o,
    output  reg[`RegBus]        mem_mem_addr_o,
    output  reg[`RegBus]        mem_store_data_o
    );

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin
            mem_reg_waddr_o <= `RegAddrx0;
            mem_reg_wdata_o <= `ZeroWord;
            mem_reg_we_o <= `WriteDisable;
            mem_aluop_o <= `EXE_OP_NOP;
            mem_mem_addr_o <= `ZeroWord;
            mem_store_data_o <= `ZeroWord;
        end else if (stall_i[3] == `Stall && stall_i[4] == `NotStall) begin
            mem_reg_waddr_o <= `RegAddrx0;
            mem_reg_wdata_o <= `ZeroWord;
            mem_reg_we_o <= `WriteDisable;
            mem_aluop_o <= `EXE_OP_NOP;
            mem_mem_addr_o <= `ZeroWord;
            mem_store_data_o <= `ZeroWord;
        end else if (stall_i[3] == `NotStall) begin
            mem_reg_waddr_o <= ex_reg_waddr_i;
            mem_reg_wdata_o <= ex_reg_wdata_i;
            mem_reg_we_o <= ex_reg_we_i;
            mem_aluop_o <= ex_aluop_i;
            mem_mem_addr_o <= ex_mem_addr_i;
            mem_store_data_o <= ex_store_data_i;
        end
    end
endmodule
