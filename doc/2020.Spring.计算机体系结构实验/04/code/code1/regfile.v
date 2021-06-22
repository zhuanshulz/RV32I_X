`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 01:15:37
// Design Name: 
// Module Name: regfile
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

module regfile(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active
    
    // Write port
    input   wire                we_i,               // write enable
    input   wire[`RegAddrBus]   waddr_i,            // write reg addr
    input   wire[`RegBus]       wdata_i,            // write reg data

    // Read port 1
    input   wire                re1_i,              // read enable1 from id
    input   wire[`RegAddrBus]   raddr1_i,           // read reg addr1 from id
    output  reg[`RegBus]        rdata1_o,           // read reg data1 to id

    // Read port 2
    // similar to read port 1
    input   wire                re2_i, 
    input   wire[`RegAddrBus]   raddr2_i,
    output  reg[`RegBus]        rdata2_o
    );

    // 32 32-bit general purpose registers
    reg[`RegBus] regs[0:`RegNum-1];

    // initial, for loop is not efficient
    initial begin
        regs[0] <= `ZeroWord;
        regs[1] <= `ZeroWord;
        regs[2] <= 32'h0000fff0;
        regs[3] <= `ZeroWord;
        regs[4] <= `ZeroWord;
        regs[5] <= `ZeroWord;
        regs[6] <= `ZeroWord;
        regs[7] <= `ZeroWord;
        regs[8] <= `ZeroWord;
        regs[9] <= `ZeroWord;
        regs[10] <= `ZeroWord;
        regs[11] <= `ZeroWord;
        regs[12] <= `ZeroWord;
        regs[13] <= `ZeroWord;
        regs[14] <= `ZeroWord;
        regs[15] <= `ZeroWord;
        regs[16] <= `ZeroWord;
        regs[17] <= `ZeroWord;
        regs[18] <= `ZeroWord;
        regs[19] <= `ZeroWord;
        regs[20] <= `ZeroWord;
        regs[21] <= `ZeroWord;
        regs[22] <= `ZeroWord;
        regs[23] <= `ZeroWord;
        regs[24] <= `ZeroWord;
        regs[25] <= `ZeroWord;
        regs[26] <= `ZeroWord;
        regs[27] <= `ZeroWord;
        regs[28] <= `ZeroWord;
        regs[29] <= `ZeroWord;
        regs[30] <= `ZeroWord;
        regs[31] <= `ZeroWord;
    end

    // write port
    // write if write enable and dest reg is not x0
    always @(posedge clk) begin
        if (rst_n == `RstDisable) begin
            if ((we_i == `WriteEnable) && (waddr_i != `RegAddrx0)) begin
                regs[waddr_i] <= wdata_i;
            end
        end
    end

    // read port 1
    // read zero when source is x0
    // if read addr = write addr, use write data, this is a forwarding
    // else read regs[addr]
    always @(*) begin
        if (rst_n == `RstEnable) begin
            rdata1_o <= `ZeroWord;
        end else if (raddr1_i == `RegAddrx0) begin
            rdata1_o <= `ZeroWord;
        end else if ((raddr1_i == waddr_i) && (we_i == `WriteEnable) && (re1_i == `ReadEnable)) begin
            rdata1_o <= wdata_i;
        end else if (re1_i == `ReadEnable) begin
            rdata1_o <= regs[raddr1_i];
        end
    end

    // read port 2
    // similar to read port 1
    always @(*) begin
        if (rst_n == `RstEnable) begin
            rdata2_o <= `ZeroWord;
        end else if (raddr2_i == `RegAddrx0) begin
            rdata2_o <= `ZeroWord;
        end else if ((raddr2_i == waddr_i) && (we_i == `WriteEnable) && (re2_i == `ReadEnable)) begin
            rdata2_o <= wdata_i;
        end else if (re2_i == `ReadEnable) begin
            rdata2_o <= regs[raddr2_i];
        end
    end
endmodule
