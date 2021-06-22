`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 04:37:33
// Design Name: 
// Module Name: top_tb
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

module top_tb();
    reg clk;
    reg rst_n;

    top u_top(
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 1'b0;
        rst_n = `RstEnable;
        #40 rst_n = `RstDisable;
        #200000 $finish;
    end

    initial begin
        $readmemh ("inst_rom.mem", u_top.u_inst_rom.inst_mem);
    end

    always #5 clk <=~clk;
endmodule
