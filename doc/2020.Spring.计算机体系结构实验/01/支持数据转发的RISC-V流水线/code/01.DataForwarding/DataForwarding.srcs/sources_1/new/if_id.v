`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 01:03:36
// Design Name: 
// Module Name: if_id
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

module if_id(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active
    
    // from if stage
    input   wire[`InstAddrBus]  if_pc_i,            // pc from if stage
    input   wire[`InstBus]      if_inst_i,          // instrution from if stage

    // to id stage
    output  reg[`InstAddrBus]   id_pc_o,            // pc to id stage
    output  reg[`InstBus]       id_inst_o           // instuction to id stage
    );

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin              // set zero when reset
            id_pc_o <= `ZeroWord;
            id_inst_o <= `ZeroWord;
        end else begin                              // send to id stage
            id_pc_o <= if_pc_i;
            id_inst_o <= if_inst_i;
        end
    end
endmodule
