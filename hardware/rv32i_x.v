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

   //ICCM ports
   output 	 [31:0]  iccm_rd_addr,
   output 	         iccm_rd_en,
   input 	 [31:0]  iccm_rd_data
);

   // always @(posedge clk or negedge rst_n) begin
   //    if(~rst_n)begin
   //       iccm_rd_addr <= 'd0;
   //       iccm_rd_en <= 'd0;
         
   //       dccm_wr_en <= 'd0;
   //       dccm_rd_en <= 'd0;
   //       dccm_wr_addr <= 'd0;
   //       dccm_rd_addr <= 'd0;
   //       dccm_wr_data <= 'd0;
   //    end
   //    else begin
   //       iccm_rd_addr <= iccm_rd_addr + 'd1;
   //       iccm_rd_en <= 'b1;
   //    end
   // end
wire [31:0] instr_location;
wire [31:0] instr_to_dec;

ifu ifu_i0(
   .rst_n(rst_n)
   ,.clk(clk)

   ,.iccm_rd_addr(iccm_rd_addr)
   ,.iccm_rd_en(iccm_rd_en)
   ,.iccm_rd_data(iccm_rd_data)

   ,.instr_location(instr_location)
   ,.instr_to_dec(instr_to_dec)

   ,.flush_from_exe('b0)
   ,.flush_addr_exe('d0)
   ,.flush_from_dec('b0)
   ,.flush_addr_dec('d0)
);

dec dec_i0(
   .rst_n(rst_n)
   ,.clk(clk)

   ,.instr_addr_ifu_2_dec_i(instr_location)
   ,.instr_ifu_2_dec_i(instr_to_dec)
   ,.flush_from_exe( 'b0 )

   ,.opcode_dec_2_exe_o( )      //操作类型
   ,.rs1_dec_2_exe_o(   )          //源操作数1
   ,.rs2_dec_2_exe_o(   )        // 源操作数2
   ,.imm(  )                  // 20位的立即数，12位立即数也会复用
   ,.rd_dec_2_exe_o( )
   ,.flush_from_dec( )
   ,.flush_addr_dec( )
);

exe exe_i0(
   clk(clk)
   ,.rstl(rst_n)
   ,.opcode_dec_2_exe_i( )
   ,.rs1_dec_2_exe_i( )
   ,.rs2_dec_2_exe_i( )
   ,.rd_dec_2_exe_i( )
   ,.current_pc( )
   ,.imm_12( )
   ,.imm_7( )
   ,.imm_5( )
   ,.offset( )
   
   ,.opcode_exe_2_mem_o( )
   ,.rd_exe_2_mem_o( )
   ,.rd_data_exe_2_mem_o( )
   ,.mem_address_o( )
   ,.men_data_o( )
   ,.flush_from_exe( )
   ,.flush_addr_exe( )

   ,.flush_o( )
   ,.flush_pc( )
   ,.flush_i( )
)
endmodule
