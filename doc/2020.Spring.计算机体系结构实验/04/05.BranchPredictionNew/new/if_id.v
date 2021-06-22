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

    // from ctrl
    input   wire[5:0]           stall_i,

    // from if stage
    input   wire[`InstAddrBus]  if_pc_i,            // pc from if stage
    input   wire[`InstBus]      if_inst_i,          // instrution from if stage
    input   wire                if_prediction_i,
    input   wire[`InstAddrBus]  if_prediction_pc_i,

    // to id stage
    output  reg[`InstAddrBus]   id_pc_o,            // pc to id stage
    output  reg[`InstBus]       id_inst_o,          // instuction to id stage
    output  reg                 id_prediction_o,
    output  reg[`InstAddrBus]   id_prediction_pc_o
    );

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin              // set zero when reset
            id_pc_o <= `ZeroWord;
            id_inst_o <= `ZeroWord;
            id_prediction_o <= 1'b0;
            id_prediction_pc_o <= `ZeroWord;
        end else if (stall_i[1] == `Stall && stall_i[2] == `NotStall) begin
            id_pc_o <= `ZeroWord;
            id_inst_o <= `ZeroWord;
            id_prediction_o <= 1'b0;
            id_prediction_pc_o <= `ZeroWord;
        end else if (stall_i[1] == `NotStall) begin                              // send to id stage
            id_pc_o <= if_pc_i;
            id_inst_o <= if_inst_i;
            id_prediction_o <= if_prediction_i;
            id_prediction_pc_o <= if_prediction_pc_i;
        end
    end
endmodule
