`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/29 16:46:39
// Design Name: 
// Module Name: ctrl
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

module ctrl(
    input   wire                rst_n,              // Reset, low active

    input   wire                stall_from_ex_i,
    input   wire                stall_from_id_i,
    output  reg[5:0]            stall_o
    );

    always @(*) begin
        if (rst_n == `RstEnable) begin
            stall_o <= 6'b000000;
        end else if (stall_from_ex_i == `Stall) begin
            stall_o <= 6'b001111;
        end else if (stall_from_id_i == `Stall) begin
            stall_o <= 6'b000111;
        end else begin
            stall_o <= 6'b000000;
        end
    end
endmodule
