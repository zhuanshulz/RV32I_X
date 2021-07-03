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
   wire [1:0]  store_offset;
   wire [1:0]  store_type;

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
    ,.store_type(store_type)
    ,.store_offset(store_offset)

    ,.iccm_rd_addr(iccm_rd_addr)
    ,.iccm_rd_en(iccm_rd_en)
    ,.iccm_rd_data(iccm_rd_data)
);

// Instantiate the mem
ccm ccm_i(
    .rst_n(rst_n),
    .clk(clk),
                                            
    //DCCM ports
    .dccm_wr_en(dccm_wr_en),
    .dccm_rd_en(dccm_rd_en),
    .dccm_wr_addr({2'b00,dccm_wr_addr[31:2]}),
    .store_type(store_type),
    .store_offset(store_offset),

    // .dccm_wr_addr({2'b00,dccm_wr_addr[31:2]}),
    .dccm_rd_addr({2'b00,dccm_rd_addr[31:2]}),
    .dccm_wr_data(dccm_wr_data),
    .dccm_rd_data(dccm_rd_data),

    //ICCM ports        //地址好说是32位对齐的，但是数据就不一定了。
    .iccm_rd_addr({2'b00,iccm_rd_addr[31:2]}),
    .iccm_rd_en(iccm_rd_en),         
    .iccm_rd_data(iccm_rd_data)
);
endmodule