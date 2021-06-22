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

    wire[7:0] test_wire_3;
    assign test_wire_3 = data_mem3[32'h3ffb];
    wire[7:0] test_wire_2;
    assign test_wire_2 = data_mem2[32'h3ffb];
    wire[7:0] test_wire_1;
    assign test_wire_1 = data_mem1[32'h3ffb];
    wire[7:0] test_wire_0;
    assign test_wire_0 = data_mem0[32'h3ffb];

    // write
    always @(*) begin
        if (ce == `ChipDisable) begin
            // mem_data_o <= `ZeroWord;
        end else if (we == `WriteEnable) begin
            case (addr[1:0])
                2'b00: begin
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
                end
                2'b01: begin
                    if (mem_sel[3] == 1'b1) begin
                        data_mem2[addr[`DataMemNumLog2+1:2]] <= mem_data_i[31:24];
                    end 
                    if (mem_sel[2] == 1'b1) begin
                        data_mem1[addr[`DataMemNumLog2+1:2]] <= mem_data_i[23:16];
                    end 
                    if (mem_sel[1] == 1'b1) begin
                        data_mem0[addr[`DataMemNumLog2+1:2]] <= mem_data_i[15:8];
                    end 
                    if (mem_sel[0] == 1'b1) begin
                        data_mem3[addr[`DataMemNumLog2+1:2]+1] <= mem_data_i[7:0];
                    end 
                end
                2'b10: begin
                    if (mem_sel[3] == 1'b1) begin
                        data_mem1[addr[`DataMemNumLog2+1:2]] <= mem_data_i[31:24];
                    end 
                    if (mem_sel[2] == 1'b1) begin
                        data_mem0[addr[`DataMemNumLog2+1:2]] <= mem_data_i[23:16];
                    end 
                    if (mem_sel[1] == 1'b1) begin
                        data_mem3[addr[`DataMemNumLog2+1:2]+1] <= mem_data_i[15:8];
                    end 
                    if (mem_sel[0] == 1'b1) begin
                        data_mem2[addr[`DataMemNumLog2+1:2]+1] <= mem_data_i[7:0];
                    end 
                end
                2'b11: begin
                    if (mem_sel[3] == 1'b1) begin
                        data_mem0[addr[`DataMemNumLog2+1:2]] <= mem_data_i[31:24];
                    end 
                    if (mem_sel[2] == 1'b1) begin
                        data_mem3[addr[`DataMemNumLog2+1:2]+1] <= mem_data_i[23:16];
                    end 
                    if (mem_sel[1] == 1'b1) begin
                        data_mem2[addr[`DataMemNumLog2+1:2]+1] <= mem_data_i[15:8];
                    end 
                    if (mem_sel[0] == 1'b1) begin
                        data_mem1[addr[`DataMemNumLog2+1:2]+1] <= mem_data_i[7:0];
                    end 
                end
                default: begin
                    
                end
            endcase
            
            // if (addr[31:7] == 27'b0) begin
            //     io_device[addr[6:2]] <= mem_data_i;
            // end
            // io_device[addr[6:2]] <= mem_data_i;
            if (addr[7:6] == 2'b0) begin
                io_device[addr[6:2]] <= mem_data_i;
            end
        end
    end

    // read
    always @(*) begin
        if (ce == `ChipDisable) begin
            mem_data_o <= `ZeroWord;
        end else if (we == `WriteDisable) begin
            case (addr[1:0])
                2'b00: begin
                    mem_data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],
                        data_mem2[addr[`DataMemNumLog2+1:2]],
                        data_mem1[addr[`DataMemNumLog2+1:2]],
                        data_mem0[addr[`DataMemNumLog2+1:2]]};
                end 
                2'b01: begin
                    mem_data_o <= {data_mem2[addr[`DataMemNumLog2+1:2]],
                        data_mem1[addr[`DataMemNumLog2+1:2]],
                        data_mem0[addr[`DataMemNumLog2+1:2]],
                        data_mem3[addr[`DataMemNumLog2+1:2]+1]};
                end 
                2'b10: begin
                    mem_data_o <= {data_mem1[addr[`DataMemNumLog2+1:2]],
                        data_mem0[addr[`DataMemNumLog2+1:2]],
                        data_mem3[addr[`DataMemNumLog2+1:2]+1],
                        data_mem2[addr[`DataMemNumLog2+1:2]+1]};
                end 
                2'b11: begin
                    mem_data_o <= {data_mem0[addr[`DataMemNumLog2+1:2]],
                        data_mem3[addr[`DataMemNumLog2+1:2]+1],
                        data_mem2[addr[`DataMemNumLog2+1:2]+1],
                        data_mem1[addr[`DataMemNumLog2+1:2]+1]};
                end 
                default: begin
                    mem_data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],
                        data_mem2[addr[`DataMemNumLog2+1:2]],
                        data_mem1[addr[`DataMemNumLog2+1:2]],
                        data_mem0[addr[`DataMemNumLog2+1:2]]};
                end
            endcase
            
        end else begin
            mem_data_o <= `ZeroWord;
        end
    end
endmodule
