module ccm_32_32
  ( input logic CLK,
    input logic [31:0] ADR,
    input logic [31:0] D,

   input    [1:0]  store_type,
   input    [1:0]  store_offset,

    output logic [31:0] Q,
    input logic WE );
   

   reg [31:0]   ram_core [0:65535]; // 32位地址宽度
  initial begin
    for(integer i=0;i<=65535; i++)begin
      ram_core[i] = 0;
    end
  end
  parameter SW =  2'b11;
  parameter SH =  2'b10;
  parameter SB =  2'b01;

   always @(posedge CLK) begin
      if (WE) begin// for active high WE - must be specified by user
          ram_core[ADR] <= D; 
          Q <= 'd0; 
          if(store_type == SH)begin
            ram_core[ADR] <= (store_offset[1])?({D[15:0],ram_core[ADR][15:0]}):({ram_core[ADR][31:16],D[15:0]});
          end
          else if(store_type == SB)begin
            ram_core[ADR] <= (store_offset == 2'b00)?({ram_core[ADR][31:8],D[7:0]})
                              :(store_offset == 2'b01)?({ram_core[ADR][31:16],D[7:0],ram_core[ADR][7:0]})
                              :(store_offset == 2'b10)?({ram_core[ADR][31:24],D[7:0],ram_core[ADR][15:0]})
                              :(store_offset == 2'b11)?({D[7:0],ram_core[ADR][23:0]})
                              :ram_core[ADR];
          end
        end 
      else
        Q <= ram_core[ADR];
   end

  //  logic [31:0] ram_test = ram_core[1][31:0];
endmodule
