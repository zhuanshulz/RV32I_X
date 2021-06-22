`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 04:16:31
// Design Name: 
// Module Name: top
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

module top(
    input   wire                clk,                // Clock
    input   wire                rst_n               // Reset, low active
    );

    // inst_rom <-> core
    wire[`InstAddrBus] inst_addr;
    wire[`InstBus] inst;
    wire rom_ce;

    core u_core(
        .clk(clk),
        .rst_n(rst_n), 
        .inst_addr_o(inst_addr),
        .inst_mem_ce_o(rom_ce),
        .inst_data_i(inst)
    );

    inst_rom u_inst_rom(
        .ce_i(rom_ce),
        .addr_i(inst_addr),
        .inst_o(inst)
    );
endmodule
