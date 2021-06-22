module mem (
    input clk,
    input rst_n,
    
    input [31:0] opcode_exe_2_mem_i,            // 操作类型,位宽暂定
    input [31:0] rd_exe_2_mem_i,                // 目的寄存器编号,位宽暂定
    input [31:0] rd_data_exe_2_mem_i_addr,      // 计算结果，可能是访存地址
    input [31:0] rd_data_exe_2_mem_i_data,      // 访存数据，一般是需要存储的数据。

    output reg [31:0]   rd_mem_2_wb_o,             // 目的寄存器编号,位宽暂定
    output [31:0]   rd_data_mem_2_wb_o,        // 需要写回寄存器文件的数据

       //DCCM ports
   output 	         dccm_wr_en,
   output 	         dccm_rd_en,
   output 	 [31:0]  dccm_wr_addr,
   output    [31:0]  dccm_rd_addr,
   output 	 [31:0]  dccm_wr_data,
   input 	 [31:0]  dccm_rd_data
);

parameter read = 32'd1;
parameter write = 32'd2;
parameter others = 32'd3;

assign dccm_wr_en = opcode_exe_2_mem_i == write;
assign dccm_rd_en = opcode_exe_2_mem_i == read;
assign dccm_wr_addr = dccm_wr_en?rd_data_exe_2_mem_i_addr:'d0;
assign dccm_rd_addr = dccm_rd_en?rd_data_exe_2_mem_i_addr:'d0;
assign dccm_wr_data = dccm_wr_en?rd_data_exe_2_mem_i_data:'d0;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        rd_mem_2_wb_o <= 'd0;
    end
    else begin
        rd_mem_2_wb_o <= rd_exe_2_mem_i;
    end
end


endmodule