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
    wire[`DataAddrBus] mem_addr;
    wire mem_we;
    wire[`DataBus] mem_data_from_core;
    wire mem_ce;
    wire[3:0] mem_sel;
    wire[`DataBus] mem_data_to_core;


    core u_core(
        .clk(clk),
        .rst_n(rst_n), 
        .inst_addr_o(inst_addr),
        .inst_mem_ce_o(rom_ce),
        .inst_data_i(inst),
        .mem_addr_o(mem_addr),
        .mem_we_o(mem_we),
        .mem_data_o(mem_data_to_core),
        .mem_ce_o(mem_ce),
        .mem_sel_o(mem_sel),
        .mem_data_i(mem_data_from_core)
    );

    inst_rom u_inst_rom(
        .ce_i(rom_ce),
        .addr_i(inst_addr),
        .inst_o(inst)
    );

    data_ram u_data_ram(
        .clk(clk),                // Clock
        .ce(mem_ce),
        .we(mem_we),
        .addr(mem_addr),
        .mem_sel(mem_sel),
        .mem_data_i(mem_data_to_core),
        .mem_data_o(mem_data_from_core)
    );
endmodule
