module ifu (
    input rst_n,
    input clk,

    // ICCM ports
    output [31:0]    iccm_rd_addr,
    output           iccm_rd_en,
    input  [31:0]    iccm_rd_data,

    // 将读取的指令和数据送入译码单元
    output reg [31:0]    instr_location,
    output reg [31:0]    instr_to_dec,

    // 分支flush信号
    input        flush_from_exe,                //从执行单元来的分支信号
    input [31:0] flush_addr_exe,                //从执行单元来的正确的执行地址
    input        flush_from_dec,                //从译码单元来的分支信号
    input [31:0] flush_addr_dec                //从译码单元来的正确的执行地址
);
    reg [31:0] current_pc;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        current_pc <= 'd0;
    end
    else if(flush_from_exe)begin
        current_pc <= flush_addr_exe;
    end
    else if(flush_from_dec)begin
        current_pc <= flush_addr_dec;
    end
    else begin
        current_pc <= current_pc + 'd4;
    end
end

reg [31:0] instr_location_d1;
 
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        instr_location_d1 <= 'd0;
        
        instr_location <= 'd0;
        instr_to_dec <= 'd0;
    end
    else begin
        instr_location_d1 <= current_pc;

        instr_location <= instr_location_d1;
        instr_to_dec <= iccm_rd_data;
    end
end

assign iccm_rd_addr = current_pc;
assign iccm_rd_en = 'b1;

endmodule