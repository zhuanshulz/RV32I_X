`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 02:57:54
// Design Name: 
// Module Name: mem
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

module mem(
    input   wire                rst_n,              // Reset, low active
    
    // from ex_mem
    input   wire[`RegAddrBus]   reg_waddr_i,
    input   wire[`RegBus]       reg_wdata_i,
    input   wire                reg_we_i,

    // to mem_wb
    output  reg[`RegAddrBus]    reg_waddr_o,
    output  reg[`RegBus]        reg_wdata_o,
    output  reg                 reg_we_o
    );

    always @(*) begin
        if (rst_n == `RstEnable) begin
            reg_waddr_o <= `RegAddrx0;
            reg_wdata_o <= `ZeroWord;
            reg_we_o <= `WriteDisable;
        end else begin
            reg_waddr_o <= reg_waddr_i;
            reg_wdata_o <= reg_wdata_i;
            reg_we_o <= reg_we_i;
        end
    end
endmodule
