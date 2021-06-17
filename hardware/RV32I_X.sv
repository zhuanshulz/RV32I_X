module RV32I_X (
	input logic		clk,
    	input logic		rst_n,

   //DCCM ports
   output 	logic         dccm_wren,
   output 	logic         dccm_rden,
   output 	logic [31:0]  dccm_wr_addr,
   output 	logic [31:0]  dccm_wr_data,
   input 	logic [31:0]  dccm_rd_data;

   //ICCM ports
   output 	logic [31:0]  iccm_rd_addr,
   output 	logic         iccm_rden,
   input 	logic [31:0]  iccm_rd_data
		
);
    
endmodule
