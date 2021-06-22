`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 00:52:23
// Design Name: 
// Module Name: pc_reg
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

module pc_reg(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active
    
    // to if_id
    output  reg[`InstAddrBus]   pc_o,               // PC
    output  reg                 ce_o                // ChipEnable
    );

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin
            ce_o <= `ChipDisable;                   // Disable instruction memory when reset 
        end else begin
            ce_o <= `ChipEnable;                    // Enable instruction memory when reset finish 
        end
    end

    always @(posedge clk) begin
        if (ce_o == `ChipDisable) begin
            pc_o <= `ZeroWord;                      // When inst mem is disabled, pc = 0
        end else begin
            pc_o <= pc_o + 4'h4;                        // When inst mem is enabled, pc = pc +4
        end
    end
endmodule
