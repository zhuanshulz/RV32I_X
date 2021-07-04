module exe(
  input clk,
  input rstl,
  input [10:0]  opcode_dec_2_exe_i,           // 操作类型,位宽暂定
  input [31:0]   rs1_dec_2_exe_i,             // 源操作数1
  input [31:0]   rs2_dec_2_exe_i,             // 源操作数2
  input [4:0]   rd_dec_2_exe_i,              // 目的寄存器编号,位宽暂定
  input [31:0]  current_pc_exe_i,                   //pc
  input [19:0]  imm_20,                       //20位的立即数
  input [11:0]   imm_12,                      //12位的立即数，从译码阶段获得
  input [6:0]    imm_7,                       //7位的立即数
  input [4:0]    imm_5,                       //5位的立即数
  input [11:0]   offset,                       //branch指令的offset，如果没有可以把两个立即数拼接起来                     
  input [4:0]   shamt,

  output reg [10:0]  opcode_exe_2_mem_o,          // 操作类型,位宽暂定
  output reg [4:0]   rd_exe_2_mem_o,             // 目的寄存器编号,位宽暂定
  output reg [31:0]   rd_data_exe_2_mem_o,        // 计算结果,包括load/store的存储器地址。
  output reg [31:0]   mem_data_o,                 //store指令存储的内容
  output reg        flush_from_exe,            // 分支跳转,对于分支指令，使用其计算得到的地址，默认是不跳转
  output reg [31:0]   flush_addr_exe,             //正确的执行地址
  output reg [31:0]   current_pc_exe_o,

  output reg load_valid,
  output reg store_valid
  //output flush_o,                               //当遇到0作除数，不要了
  //output flush_pc,                            //冲刷流水线时的PC。不要了
  //input flush_i                                  //分支预测错误冲刷流水线,暂且不加
);
  parameter LH =  11'bx_001_0000011;
  parameter LB =  11'bx_000_0000011;
  parameter LW =  11'bx_010_0000011;
  parameter LBU = 11'bx_100_0000011;
  parameter LHU = 11'bx_101_0000011;

  parameter SW =  11'bx_010_0100011;
  parameter SH =  11'bx_001_0100011;
  parameter SB =  11'bx_000_0100011;

  parameter SLL =   11'b0_001_0110011;
  parameter SLLI =  11'b0_001_0010011;
  parameter SRL =   11'b0_101_0110011;
  parameter SRLI =  11'b0_101_0010011;
  parameter SRA =   11'b1_101_0110011;
  parameter SRAI =  11'b1_101_0010011;
  
  parameter ADD =   11'b0_000_0110011;
  parameter ADDI =  11'bx_000_0010011;
  parameter SUB =   11'b1_000_0110011;
  parameter LUI =   11'bx_xxx_0110111;
  parameter AUIPC = 11'bx_xxx_0010111;
  parameter XOR =   11'b0_100_0110011;
  parameter XORI =  11'bx_100_0010011;
  parameter OR =    11'b0_110_0110011;
  parameter ORI =   11'bx_110_0010011;
  parameter AND =   11'b0_111_0110011;
  parameter ANDI =  11'bx_111_0010011;
  
  parameter SLT =   11'b0_010_0110011;
  parameter SLTI =  11'bx_010_0010011;
  parameter SLTU =  11'b0_011_0110011;
  parameter SLTIU = 11'bx_011_0010011;

  parameter BEQ =   11'bx_000_1100011;
  parameter BNE =   11'bx_001_1100011;
  parameter BLT =   11'bx_100_1100011;
  parameter BLTU =  11'bx_110_1100011;
  parameter BGE =   11'bx_101_1100011;
  parameter BGEU =  11'bx_111_1100011;

  parameter JAL =   11'bx_xxx_1101111;
  parameter JALR =  11'bx_xxx_1100111;

  parameter ECALL = 11'b0_xxx_1110011;
  parameter EBREAK= 11'b1_xxx_1110011;

  always@(posedge clk or negedge rstl)begin
    if(rstl==0)begin
      //current_pc_exe_i<=0;
      rd_data_exe_2_mem_o<=32'h00000000;
      opcode_exe_2_mem_o <= 'd0;
      rd_exe_2_mem_o <= 'd0;
      mem_data_o <= 'd0;
      flush_from_exe <= 1'b0;
      load_valid <= 'b0;
      store_valid <= 'b0;
      current_pc_exe_o <= 'd0;
    end
    else begin
      current_pc_exe_o <= current_pc_exe_i;
      flush_from_exe <= 1'b0;
      mem_data_o <= 'd0;
      rd_data_exe_2_mem_o<=32'h00000000;
      opcode_exe_2_mem_o <= opcode_dec_2_exe_i;
      rd_exe_2_mem_o <= rd_dec_2_exe_i;
      flush_addr_exe <= 'd0;
      load_valid <= 'b0;
      store_valid <= 'b0;
      casex(opcode_dec_2_exe_i)
      BEQ:begin
        if(rs1_dec_2_exe_i==rs2_dec_2_exe_i)begin
          flush_from_exe <= 1'b1;
          flush_addr_exe <= current_pc_exe_i+{{19{offset[11]}},offset,1'b0};
        end
      end
      BNE:begin
        if(rs1_dec_2_exe_i !=rs2_dec_2_exe_i)begin
          flush_from_exe <= 1'b1;
          flush_addr_exe<= current_pc_exe_i+{{19{offset[11]}},offset,1'b0};
        end
      end
      BLT:begin
       if(((rs1_dec_2_exe_i[31] && (~rs2_dec_2_exe_i[31])) //rs1 <0; rs2 >0
                                    || ((rs1_dec_2_exe_i[31] && rs2_dec_2_exe_i[31] && (rs1_dec_2_exe_i > rs2_dec_2_exe_i))  //rs1 <0; rs2 <0
                                          || ((~rs1_dec_2_exe_i[31]) && (~rs2_dec_2_exe_i[31]) && (rs1_dec_2_exe_i < rs2_dec_2_exe_i)))))begin //rs1>0 rs2>0
          flush_from_exe <= 1'b1;
          flush_addr_exe<=current_pc_exe_i+{{19{offset[11]}},offset,1'b0};
        end
      end
      BLTU:begin
       if(rs1_dec_2_exe_i < rs2_dec_2_exe_i)begin
          flush_from_exe <= 1'b1;
          flush_addr_exe<=current_pc_exe_i+{{19{offset[11]}},offset,1'b0};
        end
      end    
      BGE:begin
       if(~((rs1_dec_2_exe_i[31] && (~rs2_dec_2_exe_i[31])) //rs1 <0; rs2 >0
                                    || ((rs1_dec_2_exe_i[31] && rs2_dec_2_exe_i[31] && (rs1_dec_2_exe_i > rs2_dec_2_exe_i))  //rs1 <0; rs2 <0
                                          || ((~rs1_dec_2_exe_i[31]) && (~rs2_dec_2_exe_i[31]) && (rs1_dec_2_exe_i < rs2_dec_2_exe_i)))))begin
          flush_from_exe <= 1'b1;
          flush_addr_exe<=current_pc_exe_i+{{19{offset[11]}},offset,1'b0};
        end  
      end
      BGEU:begin
       if(rs1_dec_2_exe_i >= rs2_dec_2_exe_i)begin
          flush_from_exe <= 1'b1;
          flush_addr_exe<=current_pc_exe_i+{{19{offset[11]}},offset,1'b0};
        end  
      end
      JAL:begin
        flush_from_exe <= 1'b1;
        flush_addr_exe <= current_pc_exe_i + {{11{imm_20[19]}},imm_20,1'b0};
        rd_data_exe_2_mem_o <= current_pc_exe_i + 32'd4;
        end
      JALR:begin
        flush_from_exe <= 1'b1;
        flush_addr_exe <= rs1_dec_2_exe_i + {{20{imm_12[11]}},imm_12};
        rd_data_exe_2_mem_o <= current_pc_exe_i + 32'd4;
      end
      OR:   rd_data_exe_2_mem_o <= rs1_dec_2_exe_i | rs2_dec_2_exe_i;
      AND:  rd_data_exe_2_mem_o <= rs1_dec_2_exe_i & rs2_dec_2_exe_i;
      XOR:  rd_data_exe_2_mem_o <= rs1_dec_2_exe_i ^ rs2_dec_2_exe_i;
      ORI:  rd_data_exe_2_mem_o <= rs1_dec_2_exe_i | {{20{imm_12[11]}},imm_12};
      ANDI: rd_data_exe_2_mem_o <= rs1_dec_2_exe_i & {{20{imm_12[11]}},imm_12};
      XORI: rd_data_exe_2_mem_o <= rs1_dec_2_exe_i ^ {{20{imm_12[11]}},imm_12};

      ADD:    rd_data_exe_2_mem_o <= rs1_dec_2_exe_i + rs2_dec_2_exe_i;
      SUB:    rd_data_exe_2_mem_o <= rs1_dec_2_exe_i + ((~rs2_dec_2_exe_i) + 32'd1);
      ADDI:   rd_data_exe_2_mem_o <= rs1_dec_2_exe_i + {{20{imm_12[11]}},imm_12};
      AUIPC:  rd_data_exe_2_mem_o <= current_pc_exe_i+ {{20{imm_12[11]}},imm_12};
      LUI:    rd_data_exe_2_mem_o <= {imm_20 , 12'd0};   // LUI load upper immediate

      SLL:  rd_data_exe_2_mem_o <= rs1_dec_2_exe_i << rs2_dec_2_exe_i;
      SLLI: rd_data_exe_2_mem_o <= rs1_dec_2_exe_i << shamt;
      SRL:  rd_data_exe_2_mem_o <= rs1_dec_2_exe_i >> rs2_dec_2_exe_i;
      SRLI: rd_data_exe_2_mem_o <= rs1_dec_2_exe_i >> shamt;
      SRA:  rd_data_exe_2_mem_o <= rs1_dec_2_exe_i >>> rs2_dec_2_exe_i; 
      SRAI: rd_data_exe_2_mem_o <= rs1_dec_2_exe_i >>> shamt;

      SLTIU: rd_data_exe_2_mem_o  <= (rs1_dec_2_exe_i < {20'd0,imm_12}) ? 32'd1:32'd0;
      SLT:   rd_data_exe_2_mem_o  <= ((rs1_dec_2_exe_i[31] && (~rs2_dec_2_exe_i[31])) //rs1 <0; rs2 >0
                                    || ((rs1_dec_2_exe_i[31] && rs2_dec_2_exe_i[31] && (rs1_dec_2_exe_i > rs2_dec_2_exe_i))  //rs1 <0; rs2 <0
                                          || ((~rs1_dec_2_exe_i[31]) && (~rs2_dec_2_exe_i[31]) && (rs1_dec_2_exe_i < rs2_dec_2_exe_i))))?32'd1:32'd0; //rs1 >0; rs2 >0
                                    
      SLTI:  rd_data_exe_2_mem_o  <= ((rs1_dec_2_exe_i[31] && (~imm_12[11])) //rs1 <0; imm >0
                                    || ((rs1_dec_2_exe_i[31] && imm_12[11] && (rs1_dec_2_exe_i > {{20{imm_12[11]}},imm_12}))  //rs1 <0; imm <0
                                          || ((~rs1_dec_2_exe_i[31]) && (~imm_12[11]) && (rs1_dec_2_exe_i < {{20{imm_12[11]}},imm_12}))))?32'd1:32'd0; //rs1 >0; imm >0
      SLTU:  rd_data_exe_2_mem_o  <= (rs1_dec_2_exe_i < rs2_dec_2_exe_i) ? 32'd1:32'd0;

      LW:   begin
        load_valid <= 'b1;
        rd_data_exe_2_mem_o<=(rs1_dec_2_exe_i+{{20{imm_12[11]}},imm_12[11:0]});
      end
      LH:   begin
        load_valid <= 'b1;
        rd_data_exe_2_mem_o<=(rs1_dec_2_exe_i+{{20{imm_12[11]}},imm_12[11:0]});
      end
      LHU:  begin
        load_valid <= 'b1;
        rd_data_exe_2_mem_o<=(rs1_dec_2_exe_i+{{20{imm_12[11]}},imm_12[11:0]});
      end
      LB:   begin
        load_valid <= 'b1;
        rd_data_exe_2_mem_o<=(rs1_dec_2_exe_i+{{20{imm_12[11]}},imm_12[11:0]});
      end
      LBU:  begin
        load_valid <= 'b1;
        rd_data_exe_2_mem_o<=(rs1_dec_2_exe_i+{{20{imm_12[11]}},imm_12[11:0]});
      end

      SW: begin 
        store_valid <= 'b1;
        rd_data_exe_2_mem_o <= rs1_dec_2_exe_i + {{20{imm_12[11]}},imm_12};
        mem_data_o<=rs2_dec_2_exe_i;
      end
      SH: begin
        store_valid <= 'b1;
        rd_data_exe_2_mem_o <= rs1_dec_2_exe_i + {{20{imm_12[11]}},imm_12};
        mem_data_o<={16'b0,rs2_dec_2_exe_i[15:0]};
      end
      SB: begin
        store_valid <= 'b1;
        rd_data_exe_2_mem_o <= rs1_dec_2_exe_i + {{20{imm_12[11]}},imm_12};
        mem_data_o<={24'b0,rs2_dec_2_exe_i[7:0]};
      end

      ECALL:begin
        
      end
      EBREAK:begin
        
      end
      default:begin 
        rd_data_exe_2_mem_o <= 32'h00000000;
      end 
      endcase

      if(flush_from_exe)begin
        load_valid <= 'b0;
        store_valid <= 'b0;
        flush_from_exe <= 1'b0;
        mem_data_o <= 'd0;
        rd_data_exe_2_mem_o<=32'h00000000;
        opcode_exe_2_mem_o <= 'd0;
        rd_exe_2_mem_o <= 'd0;
        flush_addr_exe <= 'd0;
        current_pc_exe_o <= 'd0;
      end
    end
  end
endmodule




