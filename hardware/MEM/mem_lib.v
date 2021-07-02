module ccm_32_32
  ( input logic CLK,
    input logic [31:0] ADR,
    input logic [31:0] D,

    output logic [31:0] Q,
    input logic WE );
   

   reg [31:0]   ram_core [0:65535]; // 32位地址宽度

   always @(posedge CLK) begin
      if (WE) begin// for active high WE - must be specified by user
          ram_core[ADR] <= D; 
          Q <= 'd0; 
        end 
      else
        Q <= ram_core[ADR];
   end

  //  logic [31:0] ram_test = ram_core[1][31:0];
endmodule
