module rv32i_x(
	input 		clk,
   input 		rst_n,

   //DCCM ports
   output 	reg         dccm_wr_en,
   output 	reg         dccm_rd_en,
   output 	reg [31:0]  dccm_wr_addr,
   output   reg [31:0]  dccm_rd_addr,
   output 	reg [31:0]  dccm_wr_data,
   input 	 [31:0]  dccm_rd_data,

   //ICCM ports
   output 	reg [31:0]  iccm_rd_addr,
   output 	reg         iccm_rd_en,
   input 	 [31:0]  iccm_rd_data
);

   always @(posedge clk or negedge rst_n) begin
      if(~rst_n)begin
         iccm_rd_addr <= 'd0;
         iccm_rd_en <= 'd0;
         
         dccm_wr_en <= 'd0;
         dccm_rd_en <= 'd0;
         dccm_wr_addr <= 'd0;
         dccm_rd_addr <= 'd0;
         dccm_wr_data <= 'd0;
      end
      else begin
         iccm_rd_addr <= iccm_rd_addr + 'd1;
         iccm_rd_en <= 'b1;
      end
   end


endmodule
