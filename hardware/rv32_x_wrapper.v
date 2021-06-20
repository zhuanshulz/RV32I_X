module rv32_x_wrapper (
    input rst_n,
    input clk
);
    
   // DCCM ports
   wire         dccm_wr_en;
   wire         dccm_rd_en;
   wire [31:0]  dccm_wr_addr;
   wire [31:0]  dccm_rd_addr;
   wire [31:0]  dccm_wr_data;
   wire [31:0]  dccm_rd_data;

   // ICCM ports
   wire [31:0]    iccm_rd_addr;   
   wire           iccm_rd_en;
   wire [31:0]   iccm_rd_data;

rv32i_x rv32i_x_core(
    .clk(clk)
    ,.rst_n(rst_n)

    ,.dccm_wr_en(dccm_wr_en)
    ,.dccm_rd_en(dccm_rd_en)
    ,.dccm_wr_addr(dccm_wr_addr)
    ,.dccm_rd_addr(dccm_rd_addr)
    ,.dccm_wr_data(dccm_wr_data)
    ,.dccm_rd_data(dccm_rd_data)

    ,.iccm_rd_addr(iccm_rd_addr)
    ,.iccm_rd_en(iccm_rd_en)
    ,.iccm_rd_data(iccm_rd_data)
);

// Instantiate the mem
mem mem_i(
    .rst_n(rst_n),
    .clk(clk),
                                            
    //DCCM ports
    .dccm_wr_en(dccm_wr_en),
    .dccm_rd_en(dccm_rd_en),
    .dccm_wr_addr(dccm_wr_addr),
    .dccm_rd_addr(dccm_rd_addr),
    .dccm_wr_data(dccm_wr_data),
    .dccm_rd_data(dccm_rd_data),

    //ICCM ports
    .iccm_rd_addr(iccm_rd_addr),
    .iccm_rd_en(iccm_rd_en),         
    .iccm_rd_data(iccm_rd_data)
);
endmodule