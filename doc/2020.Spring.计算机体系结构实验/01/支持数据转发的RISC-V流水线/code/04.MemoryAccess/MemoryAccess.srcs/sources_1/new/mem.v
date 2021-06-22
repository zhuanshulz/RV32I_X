`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 02:57:54
// Design Name: 
// Module Name: mem
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

module mem(
    input   wire                rst_n,              // Reset, low active
    
    // from ex_mem
    input   wire[`RegAddrBus]   reg_waddr_i,
    input   wire[`RegBus]       reg_wdata_i,
    input   wire                reg_we_i,
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`RegBus]       mem_addr_i,
    input   wire[`RegBus]       store_data_i,

    // to mem_wb
    output  reg[`RegAddrBus]    reg_waddr_o,
    output  reg[`RegBus]        reg_wdata_o,
    output  reg                 reg_we_o,

    // from data_mem
    input   wire[`RegBus]       mem_data_i,
    // to data_rom
    output  reg[`RegBus]        mem_addr_o,
    output  wire                mem_we_o,
    output  reg[3:0]            mem_sel_o,
    output  reg[`RegBus]        mem_data_o,
    output  reg                 mem_ce_o
    );

    wire[`RegBus] zero32;
    reg mem_we;

    assign mem_we_o = mem_we;
    assign zero32 = `ZeroWord;

    always @(*) begin
        if (rst_n == `RstEnable) begin
            reg_waddr_o <= `RegAddrx0;
            reg_wdata_o <= `ZeroWord;
            reg_we_o <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b0000;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
        end else begin
            reg_waddr_o <= reg_waddr_i;
            reg_wdata_o <= reg_wdata_i;
            reg_we_o <= reg_we_i;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b0000;
            mem_ce_o <= `ChipDisable;
            case (aluop_i)
                `EXE_OP_LB: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    mem_sel_o <= 4'b0000;
                    reg_wdata_o <= {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                end
                `EXE_OP_LH: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    mem_sel_o <= 4'b0000;
                    reg_wdata_o <= {{16{mem_data_i[31]}}, mem_data_i[31:16]};
                end
                `EXE_OP_LW: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    mem_sel_o <= 4'b0000;
                    reg_wdata_o <= mem_data_i;
                end
                `EXE_OP_LBU: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    mem_sel_o <= 4'b0000;
                    reg_wdata_o <= {24'b0, mem_data_i[31:24]};
                end
                `EXE_OP_LHU: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    mem_sel_o <= 4'b0000;
                    reg_wdata_o <= {16'b0, mem_data_i[31:16]};
                end
                `EXE_OP_SB: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_ce_o <= `ChipEnable;
                    mem_sel_o <= 4'b0001;
                    mem_data_o <= {24'b0, store_data_i[7:0]};
                end
                `EXE_OP_SH: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_ce_o <= `ChipEnable;
                    mem_sel_o <= 4'b0011;
                    mem_data_o <= {16'b0, store_data_i[15:0]};
                end
                `EXE_OP_SW: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_ce_o <= `ChipEnable;
                    mem_sel_o <= 4'b1111;
                    mem_data_o <= store_data_i;
                end
                default: begin
                    
                end
            endcase
        end
    end
endmodule
