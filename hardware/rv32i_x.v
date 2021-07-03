module rv32i_x(
	input 		clk,
   input 		rst_n,

   //DCCM ports
   output 	         dccm_wr_en,
   output 	         dccm_rd_en,
   output 	 [31:0]  dccm_wr_addr,
   output    [31:0]  dccm_rd_addr,
   output 	 [31:0]  dccm_wr_data,
   input 	 [31:0]  dccm_rd_data,
   output    [ 1:0]  store_type,
   output    [ 1:0]  store_offset,

   //ICCM ports
   output 	 [31:0]  iccm_rd_addr,
   output 	         iccm_rd_en,
   input 	 [31:0]  iccm_rd_data
);

wire [31:0] instr_location;
wire [31:0] instr_to_dec;
wire [31:0] flush_addr_exe;
wire flush_from_exe;
wire [31:0] men_data_o;
wire ifu_stall;

ifu ifu_i0(
   .rst_n(rst_n)
   ,.clk(clk)

   ,.iccm_rd_addr(iccm_rd_addr)
   ,.iccm_rd_en(iccm_rd_en)
   ,.iccm_rd_data(iccm_rd_data)

   ,.ifu_stall_i(ifu_stall)

   ,.instr_location(instr_location)
   ,.instr_to_dec(instr_to_dec)

   ,.flush_from_exe(flush_from_exe)
   ,.flush_addr_exe(flush_addr_exe)
   // ,.flush_from_dec('b0)
   // ,.flush_addr_dec('d0)
);

wire [19:0]    imm_20;
wire [31:0]    rs1_data;
wire [31:0]    rs2_data;
wire [4:0]     rd_num;
wire [31:0]    instr_location_dec_o;
wire [31:0]    instr_location_exe_o;
wire [31:0]    rd_data_exe_2_mem_o;
wire [10:0]    opcode_dec_o;
wire [4:0]     rd_exe_2_mem;
wire [4:0]     rd_mem_2_dec;
wire [31:0]    rd_data_mem_2_dec;
wire [4:0]     shamt;
dec dec_i0(
   .rst_n(rst_n)
   ,.clk(clk)

   ,.instr_addr_ifu_2_dec_i   ( instr_location)
   ,.instr_ifu_2_dec_i        ( instr_to_dec)
   ,.flush_from_exe           ( flush_from_exe )

   ,.rd_mem_2_dec_i           ( rd_mem_2_dec )
   ,.rd_data_mem_2_dec_i      ( rd_data_mem_2_dec)

   ,.rd_conflict              ( ifu_stall )
   ,.opcode_dec_2_exe_o       ( opcode_dec_o )      //操作类型
   ,.rs1_dec_2_exe_o          ( rs1_data  )          //源操作数1
   ,.rs2_dec_2_exe_o          ( rs2_data  )        // 源操作数2
   ,.imm                      ( imm_20 )                  // 20位的立即数，12位立即数也会复用
   ,.rd_dec_2_exe_o           ( rd_num )
   ,.instr_addr_dec_2_exe_o   ( instr_location_dec_o )

   ,.shamt_o                    (shamt)
   // ,.flush_from_dec( )
   // ,.flush_addr_dec( )
);
wire load_valid;
wire store_valid;
wire [10:0] opcode_exe_2_mem;
wire [31:0] mem_data;
exe exe_i0(
   .clk(clk)
   ,.rstl(rst_n)
   ,.opcode_dec_2_exe_i( opcode_dec_o )   //opcode 的格式为[10]:代表instr[31:25]不为零。[9:7]代表funct3。[6:0]代表opcode。
   ,.rs1_dec_2_exe_i(rs1_data )
   ,.rs2_dec_2_exe_i(rs2_data )
   ,.rd_dec_2_exe_i( rd_num )
   ,.current_pc_exe_i( instr_location_dec_o )
   ,.imm_20(imm_20)
   ,.imm_12(imm_20[11:0] )
   ,.imm_7( imm_20[11:5])
   ,.imm_5( imm_20[4:0])
   ,.offset( imm_20[11:0])
   ,.shamt(shamt)
   
   ,.opcode_exe_2_mem_o(opcode_exe_2_mem )
   ,.rd_exe_2_mem_o(rd_exe_2_mem )
   ,.rd_data_exe_2_mem_o(rd_data_exe_2_mem_o )
   ,.mem_data_o( mem_data )
   ,.flush_from_exe(flush_from_exe )      // 异步复位
   ,.flush_addr_exe(flush_addr_exe )
   ,.current_pc_exe_o(instr_location_exe_o)

   ,.load_valid( load_valid)
   ,.store_valid( store_valid)
   // ,.flush_o( )
   // ,.flush_pc( )
   // ,.flush_i( )
);

lsu lsu_i0(
   .clk(clk)
   ,.rst_n(rst_n)

   ,.opcode_exe_2_mem_i    (opcode_exe_2_mem  )
   ,.rd_exe_2_mem_i        (rd_exe_2_mem        )
   ,.rd_data_exe_2_mem_i   (rd_data_exe_2_mem_o )
   ,.current_pc_lsu_i      (instr_location_exe_o)
   ,.mem_data_i            ( mem_data           )
   ,.load_valid            (load_valid          )
   ,.store_valid           (store_valid         )
   ,.store_type            (store_type          )
   ,.store_offset          (store_offset        )
   ,.dccm_wr_en_o          (dccm_wr_en          )
   ,.dccm_rd_en_o          (dccm_rd_en          )
   ,.dccm_wr_addr_o        (dccm_wr_addr        )
   ,.dccm_rd_addr_o        (dccm_rd_addr        )
   ,.dccm_wr_data_o        (dccm_wr_data        )
   ,.dccm_rd_data_i        (dccm_rd_data        )

   ,.rd_mem_2_dec_o        (rd_mem_2_dec      )      // 这个接口返回给dec译码单元处理保存数据
   ,.rd_data_mem_2_dec_o   (rd_data_mem_2_dec )
);


endmodule
