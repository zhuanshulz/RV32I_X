`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 00:52:23
// Design Name: 
// Module Name: pc_reg
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

module pc_reg(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active

    // from ctrl
    input   wire[5:0]           stall_i,

    // to if_id
    output  reg[`InstAddrBus]   pc_o,               // PC
    output  reg                 ce_o,               // ChipEnable
    output  wire                prediction_o,
    output  wire[`InstAddrBus]  prediction_pc_o,
    
    // from id
    input   wire                branch_flag_i,      // whether branch happens
    input   wire[`RegBus]       branch_address_i,   // target address
    input   wire                prediction_result_i,
    input   wire[`InstAddrBus]  predicted_pc_i,
    input   wire[`InstAddrBus]  target_address_i,
    input   wire                is_branch_inst_i,

    input   wire[`InstBus]      inst_i
    );

    reg[31:0] btb[31:0];
    reg[1:0] bpb[31:0];

    wire[`InstAddrBus] pc;
    assign pc = pc_o + 4'h4;
    wire[4:0] is_inst_b;
    assign is_inst_b = pc_o[4:0];
    assign prediction_o = ((inst_i[6:2] == `MAJOR_OPCODE_BRANCH) || (inst_i[6:2] == `MAJOR_OPCODE_JALR) || (inst_i[6:2] == `MAJOR_OPCODE_JAL)) ? ((bpb[pc_o[4:0]][1] == 1'b1) ? 1'b1 : 1'b0) : 1'b1;
    assign prediction_pc_o = ((inst_i[6:2] == `MAJOR_OPCODE_BRANCH) || (inst_i[6:2] == `MAJOR_OPCODE_JALR) || (inst_i[6:2] == `MAJOR_OPCODE_JAL)) ? ((bpb[pc_o[4:0]][1] == 1'b1) ? btb[pc_o[4:0]] : `ZeroWord) : `ZeroWord;

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin
            ce_o <= `ChipDisable;                   // Disable instruction memory when reset
            pc_o <= 32'h0001023c;
            btb[0] = `ZeroWord;
            btb[1] = `ZeroWord;
            btb[2] = `ZeroWord;
            btb[3] = `ZeroWord;
            btb[4] = `ZeroWord;
            btb[5] = `ZeroWord;
            btb[6] = `ZeroWord;
            btb[7] = `ZeroWord;
            btb[8] = `ZeroWord;
            btb[9] = `ZeroWord;
            btb[10] = `ZeroWord;
            btb[11] = `ZeroWord;
            btb[12] = `ZeroWord;
            btb[13] = `ZeroWord;
            btb[14] = `ZeroWord;
            btb[15] = `ZeroWord;
            btb[16] = `ZeroWord;
            btb[17] = `ZeroWord;
            btb[18] = `ZeroWord;
            btb[19] = `ZeroWord;
            btb[20] = `ZeroWord;
            btb[21] = `ZeroWord;
            btb[22] = `ZeroWord;
            btb[23] = `ZeroWord;
            btb[24] = `ZeroWord;
            btb[25] = `ZeroWord;
            btb[26] = `ZeroWord;
            btb[27] = `ZeroWord;
            btb[28] = `ZeroWord;
            btb[29] = `ZeroWord;
            btb[30] = `ZeroWord;
            btb[31] = `ZeroWord;
            bpb[0] = `Strongly_Not_Taken;
            bpb[1] = `Strongly_Not_Taken;
            bpb[2] = `Strongly_Not_Taken;
            bpb[3] = `Strongly_Not_Taken;
            bpb[4] = `Strongly_Not_Taken;
            bpb[5] = `Strongly_Not_Taken;
            bpb[6] = `Strongly_Not_Taken;
            bpb[7] = `Strongly_Not_Taken;
            bpb[8] = `Strongly_Not_Taken;
            bpb[9] = `Strongly_Not_Taken;
            bpb[10] = `Strongly_Not_Taken;
            bpb[11] = `Strongly_Not_Taken;
            bpb[12] = `Strongly_Not_Taken;
            bpb[13] = `Strongly_Not_Taken;
            bpb[14] = `Strongly_Not_Taken;
            bpb[15] = `Strongly_Not_Taken;
            bpb[16] = `Strongly_Not_Taken;
            bpb[17] = `Strongly_Not_Taken;
            bpb[18] = `Strongly_Not_Taken;
            bpb[19] = `Strongly_Not_Taken;
            bpb[20] = `Strongly_Not_Taken;
            bpb[21] = `Strongly_Not_Taken;
            bpb[22] = `Strongly_Not_Taken;
            bpb[23] = `Strongly_Not_Taken;
            bpb[24] = `Strongly_Not_Taken;
            bpb[25] = `Strongly_Not_Taken;
            bpb[26] = `Strongly_Not_Taken;
            bpb[27] = `Strongly_Not_Taken;
            bpb[28] = `Strongly_Not_Taken;
            bpb[29] = `Strongly_Not_Taken;
            bpb[30] = `Strongly_Not_Taken;
            bpb[31] = `Strongly_Not_Taken;
        end else begin
            ce_o <= `ChipEnable;                    // Enable instruction memory when reset finish 
        end
    end

    always @(posedge clk) begin
        if (ce_o == `ChipDisable) begin
            // pc_o <= `ZeroWord;                      // When inst mem is disabled, pc = 0
            pc_o <= 32'h0001023c;
        end else if(stall_i[0] == `NotStall) begin
            if (prediction_result_i == 1'b1) begin
                if (prediction_o == 1'b1 && ((inst_i[6:2] == `MAJOR_OPCODE_BRANCH) || (inst_i[6:2] == `MAJOR_OPCODE_JALR) || (inst_i[6:2] == `MAJOR_OPCODE_JAL))) begin
                    pc_o <= btb[pc_o[4:0]];
                end else begin
                    pc_o <= pc_o + 4'h4;
                end
            end else begin
                if (branch_flag_i == `Branch) begin
                    pc_o <= branch_address_i;
                end else if(is_branch_inst_i == 1'b1) begin
                    pc_o <= predicted_pc_i + 4'h4;
                end else begin
                    pc_o <= pc_o + 4'h4;
                end
            end
            // if (is_branch_inst_i == 1'b0 && prediction_result_i == 1'b0) begin
            //     pc_o <= predicted_pc_i + 4'h4;
            // end else if (prediction_result_i == 1'b1) begin
            //     if (prediction_o == 1'b1) begin
            //         pc_o <= btb[pc[4:0]];
            //     end else begin
            //         pc_o <= pc_o + 4'h4;
            //     end
            // end else if(branch_flag_i == `Branch && prediction_result_i == 1'b0) begin
            //     pc_o <= branch_address_i; 
            // end else if(branch_flag_i == `NotBranch && prediction_result_i == 1'b0) begin
            //     pc_o <= predicted_pc_i + 4'h4;
            // end else begin
            //     pc_o <= pc_o + 4'h4;
            // end
            // Update
            if (branch_flag_i == `Branch) begin
                btb[predicted_pc_i[4:0]] <= branch_address_i;
            end
            if (is_branch_inst_i == 1'b1) begin
                case (bpb[predicted_pc_i[4:0]])
                    `Strongly_Not_Taken: begin
                        if (branch_flag_i == `Branch) begin
                            bpb[predicted_pc_i[4:0]] <= `Weakly_Not_Taken;
                        end
                    end
                    `Weakly_Not_Taken: begin
                        if (branch_flag_i == `NotBranch) begin
                            bpb[predicted_pc_i[4:0]] <= `Weakly_Not_Taken;
                        end else begin
                            bpb[predicted_pc_i[4:0]] <= `Weakly_Taken;
                        end
                    end
                    `Weakly_Taken: begin
                        if (branch_flag_i == `Branch) begin
                            bpb[predicted_pc_i[4:0]] <= `Strongly_Taken;
                        end else begin
                            bpb[predicted_pc_i[4:0]] <= `Weakly_Not_Taken;
                        end
                    end
                    `Strongly_Taken: begin
                        if (branch_flag_i == `NotBranch) begin
                            bpb[predicted_pc_i[4:0]] <= `Weakly_Taken;
                        end
                    end
                    default: begin
                        
                    end
                endcase
            end
            
        end
    end

endmodule
