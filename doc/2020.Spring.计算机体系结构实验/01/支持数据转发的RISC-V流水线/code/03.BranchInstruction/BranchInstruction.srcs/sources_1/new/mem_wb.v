`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 03:01:30
// Design Name: 
// Module Name: mem_wb
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

module mem_wb(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active
    
    // from ctrl
    input   wire[5:0]           stall_i,

    // from mem stage
    input   wire[`RegAddrBus]   mem_reg_waddr_i,
    input   wire[`RegBus]       mem_reg_wdata_i,
    input   wire                mem_reg_we_i,
    // to wb stage
    output  reg[`RegAddrBus]    wb_reg_waddr_o,
    output  reg[`RegBus]        wb_reg_wdata_o,
    output  reg                 wb_reg_we_o
    );

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin
            wb_reg_waddr_o <= `RegAddrx0;
            wb_reg_wdata_o <= `ZeroWord;
            wb_reg_we_o <= `WriteDisable;
        end else if (stall_i[4] == `Stall && stall_i[5] == `NotStall) begin
            wb_reg_waddr_o <= `RegAddrx0;
            wb_reg_wdata_o <= `ZeroWord;
            wb_reg_we_o <= `WriteDisable;
        end else if (stall_i[4] == `NotStall) begin
            wb_reg_waddr_o <= mem_reg_waddr_i;
            wb_reg_wdata_o <= mem_reg_wdata_i;
            wb_reg_we_o <= mem_reg_we_i;
        end
    end
endmodule
