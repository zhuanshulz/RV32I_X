module lsu (
    input clk,
    input rst_n,

  input [10:0]  opcode_exe_2_mem_i,          // 操作类型,位宽暂定
  input [4:0]   rd_exe_2_mem_i,             // 目的寄存器编号,位宽暂定
  input [31:0]   rd_data_exe_2_mem_i,        // 计算结果,包括load/store的存储器地址。
  input [31:0]   mem_data_i,                 //store指令存储的内容
  input [31:0]  current_pc_lsu_i,
  input load_valid,
  input store_valid,

   //DCCM ports
   output 	         dccm_wr_en_o,
   output 	         dccm_rd_en_o,
   output 	 [31:0]  dccm_wr_addr_o,
   output    [31:0]  dccm_rd_addr_o,

   output    [1:0]  store_type,
   output    [1:0]  store_offset,

   output 	 [31:0]  dccm_wr_data_o,
   input 	 [31:0]  dccm_rd_data_i,

   output reg [4:0]    rd_mem_2_dec_o,
   output [31:0]   rd_data_mem_2_dec_o
);
    
  parameter LH =  3'b001;     //利用func3字段进行区别
  parameter LB =  3'b000;
  parameter LW =  3'b010;
  parameter LBU = 3'b100;
  parameter LHU = 3'b101;
  
  assign store_type = store_valid?(opcode_exe_2_mem_i[8:7] + 2'b01):2'b00;
  assign store_offset = store_valid?(rd_data_exe_2_mem_i[1:0]):2'b00;

assign dccm_wr_en_o = store_valid;
assign dccm_rd_en_o = load_valid;

assign dccm_wr_addr_o = store_valid?rd_data_exe_2_mem_i:'d0;
assign dccm_rd_addr_o = load_valid?rd_data_exe_2_mem_i:'d0;
assign dccm_wr_data_o = store_valid?mem_data_i:'d0;

reg [10:0] opcode_exe_2_mem;
reg load_valid_d;
reg [31:0] rd_data_exe_2_mem;
wire [31:0] dccm_rd_data;
assign dccm_rd_data = (rd_data_exe_2_mem[1:0] == 2'b00)?dccm_rd_data_i
                        :(rd_data_exe_2_mem[1:0] == 2'b01)?{8'd0,dccm_rd_data_i[31:8]}
                        :(rd_data_exe_2_mem[1:0] == 2'b10)?{16'd0,dccm_rd_data_i[31:16]}
                        :(rd_data_exe_2_mem[1:0] == 2'b11)?{24'd0,dccm_rd_data_i[31:24]}:'d0;

assign rd_data_mem_2_dec_o = load_valid_d?(opcode_exe_2_mem[9:7] == LW? dccm_rd_data
                                        :opcode_exe_2_mem[9:7] == LH? {{16{dccm_rd_data[15]}},dccm_rd_data[15:0]}
                                        :opcode_exe_2_mem[9:7] == LB? {{24{dccm_rd_data[7]}},dccm_rd_data[7:0]}
                                        :opcode_exe_2_mem[9:7] == LBU? {24'd0,dccm_rd_data[7:0]}
                                        :opcode_exe_2_mem[9:7] == LHU? {16'd0,dccm_rd_data[15:0]}:'d0):((|rd_mem_2_dec_o)?rd_data_exe_2_mem:'d0);


always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        rd_mem_2_dec_o <= 'd0;
        rd_data_exe_2_mem <= 'd0;
        opcode_exe_2_mem <= 'd0;
        load_valid_d <= 'd0;
    end
    else begin
        opcode_exe_2_mem <= opcode_exe_2_mem_i;
        load_valid_d <= load_valid;
        rd_mem_2_dec_o <= store_valid?'d0:rd_exe_2_mem_i;
        rd_data_exe_2_mem <= rd_data_exe_2_mem_i;
    end
end

// integer trace_file;
// initial begin
//    trace_file = $fopen("trace.txt","w");
// end

// always @(posedge clk or negedge rst_n) begin
//     if(~rst_n)begin
        
//     end
//     else begin
//         if(|current_pc_lsu_i)begin
//             $fdisplay(trace_file,"pc:%x    cycles:%x",current_pc_lsu_i,tb_top.total_cycle);
//         end
//     end
// end
endmodule