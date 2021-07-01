module lsu (
    input clk,
    input rst_n,

//   input reg [10:0]  opcode_exe_2_mem_i,          // 操作类型,位宽暂定
  input [4:0]   rd_exe_2_mem_i,             // 目的寄存器编号,位宽暂定
  input [31:0]   rd_data_exe_2_mem_i,        // 计算结果,包括load/store的存储器地址。
  input [31:0]   men_data_i,                 //store指令存储的内容

  input load_valid,
  input store_valid,

   //DCCM ports
   output 	         dccm_wr_en_o,
   output 	         dccm_rd_en_o,
   output 	 [31:0]  dccm_wr_addr_o,
   output    [31:0]  dccm_rd_addr_o,

   output 	 [31:0]  dccm_wr_data_o,
   input 	 [31:0]  dccm_rd_data_i,

   output reg [4:0]    rd_exe_2_mem_o,
   output reg [31:0]   rd_data_exe_2_mem_o
);
    
assign dccm_wr_en_o = store_valid;
assign dccm_rd_en_o = load_valid;

assign dccm_wr_addr_o = store_valid?rd_data_exe_2_mem_i:'d0;
assign dccm_rd_addr_o = load_valid?rd_data_exe_2_mem_i:'d0;
assign dccm_wr_data_o = store_valid?men_data_i:'d0;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        rd_exe_2_mem_o <= 'd0;
        rd_data_exe_2_mem_o <= 'd0;
    end
    else begin
        rd_exe_2_mem_o <= rd_exe_2_mem_i;
        if(load_valid)begin
            rd_data_exe_2_mem_o <= dccm_rd_data_i;
        end
        else begin
            rd_data_exe_2_mem_o <= rd_data_exe_2_mem_i;
        end
    end
end
endmodule