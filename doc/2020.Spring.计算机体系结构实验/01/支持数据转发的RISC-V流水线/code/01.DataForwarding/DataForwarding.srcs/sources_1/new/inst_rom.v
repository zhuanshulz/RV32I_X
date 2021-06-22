`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 04:24:15
// Design Name: 
// Module Name: inst_rom
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

module inst_rom(
    input   wire                ce_i,
    input   wire[`InstAddrBus]  addr_i,
    output  reg[`InstBus]       inst_o
    );

    // Instruction memory
    reg[`InstBus] inst_mem[0:`InstMemNum-1];

    always @(*) begin
        if (ce_i == `ChipDisable) begin
            inst_o <= `ZeroWord;
        end else begin
            inst_o <= inst_mem[addr_i >> 2];
        end
    end
endmodule
