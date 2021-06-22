`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 02:39:27
// Design Name: 
// Module Name: ex
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

module ex(
    input   wire                rst_n,              // Reset, low active
    
    // from id_ex
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegBus]       reg1_data_i,
    input   wire[`RegBus]       reg2_data_i,
    input   wire[`RegAddrBus]   reg_waddr_i,
    input   wire                reg_we_i,

    // result
    output  reg[`RegAddrBus]    reg_waddr_o,
    output  reg[`RegBus]        reg_wdata_o,
    output  reg                 reg_we_o
    );

    // result of logic op
    reg[`RegBus] result_logic;

    // calculate according to aluop_i
    always @(*) begin
        if (rst_n == `RstEnable) begin
            result_logic <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP: begin
                    result_logic <= reg1_data_i | reg2_data_i;
                end 
                default: begin
                    result_logic <= `ZeroWord;
                end
            endcase
        end
    end

    // select result according to alusel_i
    always @(*) begin
        reg_waddr_o <= reg_waddr_i;
        reg_we_o <= reg_we_i;
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                reg_wdata_o <= result_logic;
            end
            default: begin
                reg_wdata_o <= `ZeroWord;
            end
        endcase
    end
endmodule
