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
        $readmemh ("data_ram_0.mem", u_top.u_data_ram.data_mem0);
        $readmemh ("data_ram_1.mem", u_top.u_data_ram.data_mem1);
        $readmemh ("data_ram_2.mem", u_top.u_data_ram.data_mem2);
        $readmemh ("data_ram_3.mem", u_top.u_data_ram.data_mem3);
    end

    always #5 clk <=~clk;
endmodule
