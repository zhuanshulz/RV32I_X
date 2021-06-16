module ram_16384x32
  ( input logic CLK,
    input logic [13:0] ADR,
    input logic [31:0] D,

    output logic [31:0] Q,
    input logic WE );
   
   // behavior to be replaced by actual SRAM in VLE

   reg [31:0]   ram_core [16383:0];

   always_ff @(posedge CLK) begin
      if (WE) begin// for active high WE - must be specified by user
         ram_core[ADR] <= D; Q <= 'x; end else
           Q <= ram_core[ADR];
   end

   logic [31:0] ram_test = ram_core[1][31:0];
endmodule
