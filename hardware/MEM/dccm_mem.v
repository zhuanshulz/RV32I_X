module dccm_mem(
   input          clk,                                              // clock 
   input          rst_n,                                             

   input    [1:0]  store_type,
   input    [1:0]  store_offset,                                                      

   input          dccm_wr_en,                                        // write enable
   input          dccm_rd_en,                                        // read enable
   input  [31:0]  dccm_wr_addr,                        // write address
   input  [31:0]  dccm_rd_addr,                     // read address for the upper bank in case of a misaligned access
   input  [31:0]  dccm_wr_data,                 // write data
   output  [31:0] dccm_rd_data              // read data from the lo bank
);


always @(posedge clk) begin
    if (rst_n) begin
         if (dccm_wr_addr[31:0]==(32'h7f030000>>2) && dccm_wr_en) begin
            if(dccm_wr_data[7:0] == 8'h00) begin
               $display("\n current cycle:%d \n\n",tb_top.total_cycle);
            end
            else if(dccm_wr_data[7:0] == 8'hff) begin
               $display("\n\nexecution successful!!!\n");
               $display("\n current cycle:%d \n",tb_top.total_cycle);
               $finish();
            end else begin
               $write("%c",dccm_wr_data[7:0]);
            end
         end
    end
end

ccm_32_32 dccm_d0(
    .CLK(clk),
                                            
    //DCCM ports
    .WE(dccm_wr_en),
    .store_type(store_type),
    .store_offset(store_offset),
   //  .dccm_rden(dccm_rden),
    .ADR(dccm_wr_en?dccm_wr_addr:dccm_rd_addr),
    .D(dccm_wr_data),
    .Q(dccm_rd_data)
);

endmodule
