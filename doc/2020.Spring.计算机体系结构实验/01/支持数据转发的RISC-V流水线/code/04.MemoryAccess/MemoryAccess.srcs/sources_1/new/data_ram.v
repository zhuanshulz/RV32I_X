`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/06 19:27:19
// Design Name: 
// Module Name: data_ram
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

module data_ram(
    input   wire                clk,                // Clock
    input   wire                ce,
    input   wire                we,
    input   wire[`DataAddrBus]  addr,
    input   wire[3:0]           mem_sel,
    input   wire[`DataBus]      mem_data_i,
    output  reg[`DataBus]       mem_data_o
    );

    reg[`ByteWidth] data_mem0[0:`DataMemNum-1];
    reg[`ByteWidth] data_mem1[0:`DataMemNum-1];
    reg[`ByteWidth] data_mem2[0:`DataMemNum-1];
    reg[`ByteWidth] data_mem3[0:`DataMemNum-1];

    reg[`DataBus] io_device[0:31];

    // write
    always @(*) begin
        if (ce == `ChipDisable) begin
            // mem_data_o <= `ZeroWord;
        end else if (we == `WriteEnable) begin
            if (mem_sel[3] == 1'b1) begin
                data_mem3[addr[`DataMemNumLog2+1:2]] <= mem_data_i[31:24];
            end 
            if (mem_sel[2] == 1'b1) begin
                data_mem2[addr[`DataMemNumLog2+1:2]] <= mem_data_i[23:16];
            end 
            if (mem_sel[1] == 1'b1) begin
                data_mem1[addr[`DataMemNumLog2+1:2]] <= mem_data_i[15:8];
            end 
            if (mem_sel[0] == 1'b1) begin
                data_mem0[addr[`DataMemNumLog2+1:2]] <= mem_data_i[7:0];
            end 

            if (addr[31:7] == 27'b0) begin
                io_device[addr[6:2]] <= mem_data_i;
            end
        end
    end

    // read
    always @(*) begin
        if (ce == `ChipDisable) begin
            mem_data_o <= `ZeroWord;
        end else if (we == `WriteDisable) begin
            mem_data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],
                        data_mem2[addr[`DataMemNumLog2+1:2]],
                        data_mem1[addr[`DataMemNumLog2+1:2]],
                        data_mem0[addr[`DataMemNumLog2+1:2]]};
        end else begin
            mem_data_o <= `ZeroWord;
        end
    end
endmodule
