`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/29 15:21:27
// Design Name: 
// Module Name: div
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

module div(
    input   wire                clk,                // Clock
    input   wire                rst_n,              // Reset, low active
    
    input   wire                div_signed_i,       // 1'b1 means signed div
    input   wire                div_rem_i,          // 1'b1 means rem/remu
    input   wire[`RegBus]       opdata1_i,          // dividend
    input   wire[`RegBus]       opdata2_i,          // divisor
    input   wire                start_i,
    input   wire                cancel_i,

    output  reg[`RegBus]        result_o,
    output  reg                 ready_o
    );

    // minuend - n
    wire[32:0] div_temp;
    // total 32 loops
    reg[5:0] count;
    // low 32bits store dividend and middle results
    // in kth loop, dividend[k:0] is middle result
    // dividend[31:k+1] store data not calc yet
    // high 32bits store minuend
    reg[64:0] dividend;
    // 00: DivFree; 01: DivByZero; 10: DivOn; 11: DivEnd            
    reg[1:0] status;
    // divisor
    reg[`RegBus] divisor;
    reg[`RegBus] temp_op1;
    reg[`RegBus] temp_op2;
    
    // div_temp
    assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};

    always @(posedge clk) begin
        if (rst_n == `RstEnable) begin
            status <= `DivFree;
            ready_o <= `DivResultNotReady;
            result_o <= {`ZeroWord};
        end else begin
            case (status)
                `DivFree: begin
                    if (start_i == `DivStart && cancel_i == 1'b0) begin
                        if (opdata2_i == `ZeroWord) begin
                            status <= `DivByZero;
                        end else begin
                            status <= `DivOn;
                            count <= 6'b000000;
                            if (div_signed_i == 1'b1 && opdata1_i[31] == 1'b1) begin
                                temp_op1 = ~opdata1_i + 1;
                            end else begin
                                temp_op1 = opdata1_i;
                            end
                            if (div_signed_i == 1'b1 && opdata2_i[31] == 1'b1) begin
                                temp_op2 = ~opdata2_i + 1;
                            end else begin
                                temp_op2 = opdata2_i;
                            end
                            dividend <= {1'b0, `ZeroWord, `ZeroWord};
                            dividend[32:1] <= temp_op1;
                            divisor <= temp_op2;
                        end
                    end else begin
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord};
                    end
                end
                `DivByZero: begin
                    dividend <= {opdata1_i, `AllOneWord};
                    status <= `DivEnd;
                end
                `DivOn: begin
                    if (cancel_i == 1'b0) begin
                        if (count != 6'b100000) begin
                            if (div_temp[32] == 1'b1) begin
                                dividend <= {dividend[63:0], 1'b0};
                            end else begin
                                dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                            end
                            count <= count + 1;
                        end else begin
                            if ((div_signed_i == 1'b1) &&
                                ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
                                dividend[31:0] <= ~dividend[31:0] + 1;
                            end
                            if ((div_signed_i == 1'b1) &&
                                (opdata1_i[31] ^ dividend[64]) == 1'b1) begin
                                dividend[64:33] <= ~dividend[64:33] + 1;
                            end
                            status <= `DivEnd;
                            count <= 6'b000000;
                        end
                    end else begin
                        status <= `DivFree;
                    end
                end
                `DivEnd: begin
                    if (div_rem_i == 1'b0) begin
                        result_o <= dividend[31:0];
                    end else begin
                        result_o <= dividend[64:33];
                    end
                    ready_o <= `DivResultReady;
                    if (start_i == `DivStop) begin
                        status <= `DivFree;
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord};
                    end
                end
                default: begin
                    
                end
            endcase
        end
    end

endmodule
