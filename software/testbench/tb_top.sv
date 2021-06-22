`timescale 1ns/1ns
module tb_top (
    
);
parameter PERIOD = 10;  // 10ns = 100MHz
    reg clk;
    reg rst_n;
initial begin
    clk = 0;
    rst_n = 0;
    
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_top);    //tb模块名称

    $readmemh("./benchmark/sim_hex/program_iccm.hex" , rv32_x_top.mem_i.iccm.iccm_i0.ram_core       );        // iccm
    $readmemh("./benchmark/sim_hex/data.hex"    , rv32_x_top.mem_i.dccm.dccm_d0.ram_core       );        // dccm
    #10 rst_n = 1;
    $display("\n simulation begin: \n");
    #10000  $finish();
end

initial begin
    forever #(PERIOD/2) clk = ~clk;
end




logic [31:0] total_cycle;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        total_cycle <= 0;
    end
    else begin
        total_cycle <= total_cycle+1;
    end
end




rv32_x_wrapper rv32_x_top (
            .rst_n              ( rst_n       ),
            .clk                ( clk      )
         );

endmodule