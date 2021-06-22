`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 03:05:31
// Design Name: 
// Module Name: core
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

module core(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active
    
    // to inst mem
    output  wire[`InstAddrBus]  inst_addr_o,
    output  wire                inst_mem_ce_o,
    // from inst mem
    input   wire[`InstBus]      inst_data_i
    );
    // pc_reg <-> if_id
    wire[`InstAddrBus]  if_pc_o;
    // if_id <-> id
    wire[`InstAddrBus]   id_pc_i;
    wire[`InstBus]       id_inst_i;
    // id <-> id_ex
    wire[`AluOpBus]     id_aluop_o;
    wire[`AluSelBus]    id_alusel_o;
    wire[`RegBus]       id_reg1_data_o;
    wire[`RegBus]       id_reg2_data_o;
    wire[`RegAddrBus]   id_reg_waddr_o;
    wire                id_reg_we_o;
    // id_ex <-> ex
    wire[`AluOpBus]      ex_aluop_i;
    wire[`AluSelBus]     ex_alusel_i;
    wire[`RegBus]        ex_reg1_data_i;
    wire[`RegBus]        ex_reg2_data_i;
    wire[`RegAddrBus]    ex_reg_waddr_i;
    wire                 ex_reg_we_i;
    // ex <-> ex_mem
    wire[`RegAddrBus]   ex_reg_waddr_o;
    wire[`RegBus]       ex_reg_wdata_o;
    wire                ex_reg_we_o;
    // ex_mem <-> mem
    wire[`RegAddrBus]    mem_reg_waddr_i;
    wire[`RegBus]        mem_reg_wdata_i;
    wire                 mem_reg_we_i;
    // mem <-> mem_wb
    wire[`RegAddrBus]   mem_reg_waddr_o;
    wire[`RegBus]       mem_reg_wdata_o;
    wire                mem_reg_we_o;
    // mem_wb <-> wb(regfile)
    wire                wb_we_i; 
    wire[`RegAddrBus]   wb_waddr_i; 
    wire[`RegBus]       wb_wdata_i;
    // id <-> regfile
    wire                regfile_re1_i;
    wire[`RegAddrBus]   regfile_raddr1_i;
    wire[`RegBus]       regfile_rdata1_o;
    wire                regfile_re2_i;
    wire[`RegAddrBus]   regfile_raddr2_i;
    wire[`RegBus]       regfile_rdata2_o;

    pc_reg u_pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .pc_o(if_pc_o),
        .ce_o(inst_mem_ce_o)
    );

    assign inst_addr_o = if_pc_o;

    if_id u_if_id(
        .clk(clk),
        .rst_n(rst_n),
        // from pc_reg
        .if_pc_i(if_pc_o),
        // from inst mem 
        .if_inst_i(inst_data_i),
        // to id 
        .id_pc_o(id_pc_i), 
        .id_inst_o(id_inst_i)
    );

    id u_id(
        .rst_n(rst_n),
        // from if_id
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
        // from/to regfile
        .reg1_data_i(regfile_rdata1_o),
        .reg2_data_i(regfile_rdata2_o),
        .reg1_re_o(regfile_re1_i),
        .reg2_re_o(regfile_re2_i),
        .reg1_addr_o(regfile_raddr1_i),
        .reg2_addr_o(regfile_raddr2_i),
        // to id_ex
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_data_o(id_reg1_data_o),
        .reg2_data_o(id_reg2_data_o),
        .reg_waddr_o(id_reg_waddr_o),
        .reg_we_o(id_reg_we_o),
        // from ex, data forwarding
        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_reg_wdata_i(ex_reg_wdata_o),
        .ex_reg_we_i(ex_reg_we_o),
        // from mem, data forwarding
        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_reg_wdata_i(mem_reg_wdata_o),
        .mem_reg_we_i(mem_reg_we_o)
    );

    regfile u_regfile(
        .clk(clk), 
        .rst_n(rst_n), 
        // from mem_wb
        .we_i(wb_we_i), 
        .waddr_i(wb_waddr_i), 
        .wdata_i(wb_wdata_i), 
        // from/to id
        .re1_i(regfile_re1_i), 
        .raddr1_i(regfile_raddr1_i),  
        .rdata1_o(regfile_rdata1_o), 
        .re2_i(regfile_re2_i), 
        .raddr2_i(regfile_raddr2_i),
        .rdata2_o(regfile_rdata2_o)
    );

    id_ex u_id_ex(
        .clk(clk), 
        .rst_n(rst_n), 
        // from id
        .id_aluop_i(id_aluop_o),
        .id_alusel_i(id_alusel_o),
        .id_reg1_data_i(id_reg1_data_o),
        .id_reg2_data_i(id_reg2_data_o),
        .id_reg_waddr_i(id_reg_waddr_o),
        .id_reg_we_i(id_reg_we_o),
        // to ex
        .ex_aluop_o(ex_aluop_i),
        .ex_alusel_o(ex_alusel_i),
        .ex_reg1_data_o(ex_reg1_data_i),
        .ex_reg2_data_o(ex_reg2_data_i),
        .ex_reg_waddr_o(ex_reg_waddr_i),
        .ex_reg_we_o(ex_reg_we_i)
    );

    ex u_ex(
        .rst_n(rst_n),
        // from id_ex
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_data_i(ex_reg1_data_i),
        .reg2_data_i(ex_reg2_data_i),
        .reg_waddr_i(ex_reg_waddr_i),
        .reg_we_i(ex_reg_we_i),
        // to ex_mem
        .reg_waddr_o(ex_reg_waddr_o),
        .reg_wdata_o(ex_reg_wdata_o),
        .reg_we_o(ex_reg_we_o)
    );

    ex_mem u_ex_mem(
        .clk(clk),
        .rst_n(rst_n),
        // from ex stage
        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_reg_wdata_i(ex_reg_wdata_o),
        .ex_reg_we_i(ex_reg_we_o),
        // to mem stage
        .mem_reg_waddr_o(mem_reg_waddr_i),
        .mem_reg_wdata_o(mem_reg_wdata_i),
        .mem_reg_we_o(mem_reg_we_i)
    );

    mem u_mem(
        .rst_n(rst_n),
        // from ex_mem
        .reg_waddr_i(mem_reg_waddr_i),
        .reg_wdata_i(mem_reg_wdata_i),
        .reg_we_i(mem_reg_we_i),
        // to mem_wb
        .reg_waddr_o(mem_reg_waddr_o),
        .reg_wdata_o(mem_reg_wdata_o),
        .reg_we_o(mem_reg_we_o)
    );

    mem_wb u_mem_wb(
        .clk(clk), 
        .rst_n(rst_n), 
        // from mem stage
        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_reg_wdata_i(mem_reg_wdata_o),
        .mem_reg_we_i(mem_reg_we_o),
        // to wb stage(regfile)
        .wb_reg_waddr_o(wb_waddr_i),
        .wb_reg_wdata_o(wb_wdata_i),
        .wb_reg_we_o(wb_we_i)
    );
endmodule
