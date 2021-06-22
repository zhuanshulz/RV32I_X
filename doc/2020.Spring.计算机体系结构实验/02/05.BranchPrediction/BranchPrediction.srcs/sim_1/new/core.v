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
    input   wire[`InstBus]      inst_data_i,

    // to data mem
    output  wire[`RegBus]       mem_addr_o,
    output  wire                mem_we_o,
    output  wire[`RegBus]       mem_data_o,
    output  wire                mem_ce_o,
    output  wire[3:0]           mem_sel_o,
    //from data mem
    input   wire[`RegBus]       mem_data_i
    );
    // pc_reg <-> if_id
    wire[`InstAddrBus]  if_pc_o;
    wire                if_prediction_o;
    wire[`InstAddrBus]  if_prediction_pc_o;
    // pc_reg <-> id
    wire                id_branch_flag_o;
    wire[`RegBus]       id_branch_address_o;
    wire                id_prediction_result_o;
    wire[`InstAddrBus]  id_predicted_pc_o;
    wire[`InstAddrBus]  id_target_address_o;
    wire                id_is_branch_inst_o;
    // if_id <-> id
    wire[`InstAddrBus]   id_pc_i;
    wire[`InstBus]       id_inst_i;
    wire                 id_prediction_i;
    wire[`InstAddrBus]   id_prediction_pc_i;
    // id <-> id_ex
    wire[`AluOpBus]     id_aluop_o;
    wire[`AluSelBus]    id_alusel_o;
    wire[`RegBus]       id_reg1_data_o;
    wire[`RegBus]       id_reg2_data_o;
    wire[`RegAddrBus]   id_reg_waddr_o;
    wire                id_reg_we_o;
    wire                id_branch_result_o;
    wire                id_branch_result_i;
    wire[`RegBus]       id_load_store_imm_o;
    wire[4:0]           id_major_code_i;
    wire[4:0]           id_major_code_o;
    // id_ex <-> ex
    wire[`AluOpBus]      ex_aluop_i;
    wire[`AluSelBus]     ex_alusel_i;
    wire[`RegBus]        ex_reg1_data_i;
    wire[`RegBus]        ex_reg2_data_i;
    wire[`RegAddrBus]    ex_reg_waddr_i;
    wire                 ex_reg_we_i;
    wire[`RegBus]        ex_load_store_imm_i;
    // ex <-> ex_mem
    wire[`RegAddrBus]   ex_reg_waddr_o;
    wire[`RegBus]       ex_reg_wdata_o;
    wire                ex_reg_we_o;
    wire[`AluOpBus]     ex_aluop_o;
    wire[`RegBus]       ex_mem_addr_o;
    wire[`RegBus]       ex_store_data_o;
    // ex_mem <-> mem
    wire[`RegAddrBus]    mem_reg_waddr_i;
    wire[`RegBus]        mem_reg_wdata_i;
    wire                 mem_reg_we_i;
    wire[`AluOpBus]      mem_aluop_i;
    wire[`RegBus]        mem_mem_addr_i;
    wire[`RegBus]        mem_store_data_i;
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

    // ctrl <-> all
    wire[5:0]           ctrl_stall_o;
    wire                stall_from_ex_i;
    wire                stall_from_id_i;

    // div <-> ex
    wire                div_signed_i;
    wire                div_rem_i;
    wire[`RegBus]       div_opdata1_i;
    wire[`RegBus]       div_opdata2_i;
    wire                div_start_i;
    wire                div_cancel_i;
    wire[`RegBus]       div_result_o;
    wire                div_ready_o;
    
    ctrl u_ctrl(
        .rst_n(rst_n),              // Reset, low active
        .stall_from_ex_i(stall_from_ex_i),
        .stall_from_id_i(stall_from_id_i),
        .stall_o(ctrl_stall_o)
    );

    pc_reg u_pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .stall_i(ctrl_stall_o),
        .pc_o(if_pc_o),
        .ce_o(inst_mem_ce_o),
        .branch_flag_i(id_branch_flag_o),
        .branch_address_i(id_branch_address_o),
        .prediction_o(if_prediction_o),
        .prediction_pc_o(if_prediction_pc_o),
        .prediction_result_i(id_prediction_result_o),
        .predicted_pc_i(id_predicted_pc_o),
        .target_address_i(id_target_address_o),
        .is_branch_inst_i(id_is_branch_inst_o),
        .inst_i(inst_data_i)
    );

    assign inst_addr_o = if_pc_o;

    if_id u_if_id(
        .clk(clk),
        .rst_n(rst_n),
        .stall_i(ctrl_stall_o),
        // from pc_reg
        .if_pc_i(if_pc_o),
        .if_prediction_i(if_prediction_o),
        .if_prediction_pc_i(if_prediction_pc_o),
        // from inst mem 
        .if_inst_i(inst_data_i),
        // to id 
        .id_pc_o(id_pc_i), 
        .id_inst_o(id_inst_i),
        .id_prediction_o(id_prediction_i),
        .id_prediction_pc_o(id_prediction_pc_i)
    );

    id u_id(
        .rst_n(rst_n),
        // to pc_reg
        .branch_flag_o(id_branch_flag_o),
        .branch_address_o(id_branch_address_o),
        .prediction_result_o(id_prediction_result_o),
        .predicted_pc_o(id_predicted_pc_o),
        .target_address_o(id_target_address_o),
        .is_branch_inst_o(id_is_branch_inst_o),
        // from if_id
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
        .prediction_i(id_prediction_i),
        .prediction_pc_i(id_prediction_pc_i),
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
        .branch_result_i(id_branch_result_i),
        .branch_result_o(id_branch_result_o),
        .load_store_imm_o(id_load_store_imm_o),
        .major_code_i(id_major_code_i),
        .major_code_o(id_major_code_o),
        // from ex, data forwarding
        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_reg_wdata_i(ex_reg_wdata_o),
        .ex_reg_we_i(ex_reg_we_o),
        // from mem, data forwarding
        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_reg_wdata_i(mem_reg_wdata_o),
        .mem_reg_we_i(mem_reg_we_o),
        // to ctrl
        .stall_o(stall_from_id_i)
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
        .stall_i(ctrl_stall_o),
        // from id
        .id_aluop_i(id_aluop_o),
        .id_alusel_i(id_alusel_o),
        .id_reg1_data_i(id_reg1_data_o),
        .id_reg2_data_i(id_reg2_data_o),
        .id_reg_waddr_i(id_reg_waddr_o),
        .id_reg_we_i(id_reg_we_o),
        .id_branch_result_i(id_branch_result_o),
        .id_branch_result_o(id_branch_result_i),
        .id_load_store_imm_i(id_load_store_imm_o),
        .id_major_code_i(id_major_code_o),
        .id_major_code_o(id_major_code_i),
        // to ex
        .ex_aluop_o(ex_aluop_i),
        .ex_alusel_o(ex_alusel_i),
        .ex_reg1_data_o(ex_reg1_data_i),
        .ex_reg2_data_o(ex_reg2_data_i),
        .ex_reg_waddr_o(ex_reg_waddr_i),
        .ex_reg_we_o(ex_reg_we_i),
        .ex_load_store_imm_o(ex_load_store_imm_i)
    );

    div u_div(
        .clk(clk),
        .rst_n(rst_n),
        .div_signed_i(div_signed_i),
        .div_rem_i(div_rem_i),
        .opdata1_i(div_opdata1_i),
        .opdata2_i(div_opdata2_i),
        .start_i(div_start_i),
        .cancel_i(1'b0),
        .result_o(div_result_o),
        .ready_o(div_ready_o)
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
        .load_store_imm_i(ex_load_store_imm_i),
        // to ex_mem
        .reg_waddr_o(ex_reg_waddr_o),
        .reg_wdata_o(ex_reg_wdata_o),
        .reg_we_o(ex_reg_we_o),
        .aluop_o(ex_aluop_o),
        .mem_addr_o(ex_mem_addr_o),
        .store_data_o(ex_store_data_o),
        // to ctrl
        .stall_o(stall_from_ex_i),
        // to/from div
        .div_result_i(div_result_o),
        .div_ready_i(div_ready_o),
        .div_opdata1_o(div_opdata1_i),
        .div_opdata2_o(div_opdata2_i),
        .div_start_o(div_start_i),
        .div_signed_o(div_signed_i),
        .div_rem_o(div_rem_i)
    );

    ex_mem u_ex_mem(
        .clk(clk),
        .rst_n(rst_n),
        .stall_i(ctrl_stall_o),
        // from ex stage
        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_reg_wdata_i(ex_reg_wdata_o),
        .ex_reg_we_i(ex_reg_we_o),
        .ex_aluop_i(ex_aluop_o),
        .ex_mem_addr_i(ex_mem_addr_o),
        .ex_store_data_i(ex_store_data_o),
        // to mem stage
        .mem_reg_waddr_o(mem_reg_waddr_i),
        .mem_reg_wdata_o(mem_reg_wdata_i),
        .mem_reg_we_o(mem_reg_we_i),
        .mem_aluop_o(mem_aluop_i),
        .mem_mem_addr_o(mem_mem_addr_i),
        .mem_store_data_o(mem_store_data_i)
    );

    mem u_mem(
        .rst_n(rst_n),
        // from ex_mem
        .reg_waddr_i(mem_reg_waddr_i),
        .reg_wdata_i(mem_reg_wdata_i),
        .reg_we_i(mem_reg_we_i),
        .aluop_i(mem_aluop_i),
        .mem_addr_i(mem_mem_addr_i),
        .store_data_i(mem_store_data_i),
        // to mem_wb
        .reg_waddr_o(mem_reg_waddr_o),
        .reg_wdata_o(mem_reg_wdata_o),
        .reg_we_o(mem_reg_we_o),
        // from/to data_ram
        .mem_data_i(mem_data_i),
        .mem_addr_o(mem_addr_o),
        .mem_we_o(mem_we_o),
        .mem_sel_o(mem_sel_o),
        .mem_data_o(mem_data_o),
        .mem_ce_o(mem_ce_o)
    );

    mem_wb u_mem_wb(
        .clk(clk), 
        .rst_n(rst_n), 
        .stall_i(ctrl_stall_o),
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
