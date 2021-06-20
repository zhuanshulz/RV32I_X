module iccm_mem(
   input          clk,                                              // clock 
   input          rst_n,            

       //ICCM ports
   input  [31:0]  iccm_rd_addr,
   input          iccm_rd_en,
   output  [31:0] iccm_rd_data
);

ccm_32_32 iccm_i0(
    .CLK(clk),

        //ICCM ports
    .ADR(iccm_rd_addr),
    .D('d0),
    .Q(iccm_rd_data),
    .WE( 1'b0 )
);

endmodule
