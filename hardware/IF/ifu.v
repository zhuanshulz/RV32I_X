module ifu (
    input rst_n,
    input clk,

    // ICCM ports
    output [31:0]    iccm_rd_addr,
    output           iccm_rd_en,
    input  [31:0]    iccm_rd_data,

    input ifu_stall_i,

    // 将读取的指令和数据送入译码单元
    output reg [31:0]    instr_location,
    output [31:0]    instr_to_dec,

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
        current_pc <= ifu_stall_i?current_pc:(current_pc + 'd4);
    end
end

reg flush_from_exe_d1;
reg ifu_stall_i_d0;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        ifu_stall_i_d0 <= 'b0;
       flush_from_exe_d1 <= 'd0; 
       instr_location <= 'd0;
    end
    else begin
        ifu_stall_i_d0 <= ifu_stall_i;
        flush_from_exe_d1 <= flush_from_exe;
        instr_location <= flush_from_exe?'d0:(ifu_stall_i?instr_location:current_pc);
    end
end

assign instr_to_dec = (flush_from_exe|flush_from_exe_d1)?'d0:((ifu_stall_i| ifu_stall_i_d0)?instr_to_dec:iccm_rd_data);
assign iccm_rd_addr = current_pc;
assign iccm_rd_en = 'b1;

endmodule