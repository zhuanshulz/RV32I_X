module exe(
  input clk,
  input rstl,
  input [10:0]  opcode_dec_2_exe_i,           // 操作类型,位宽暂定
  input [31:0]   rs1_dec_2_exe_i,             // 源操作数1
  input [31:0]   rs2_dec_2_exe_i,             // 源操作数2
  input [4:0]   rd_dec_2_exe_i,              // 目的寄存器编号,位宽暂定
  input [31:0]  current_pc,                   //pc
  input [19:0]  imm_20,                       //20位的立即数
  input [11:0]   imm_12,                      //12位的立即数，从译码阶段获得
  input [6:0]    imm_7,                       //7位的立即数
  input [4:0]    imm_5,                       //5位的立即数
  input [11:0]   offset,                       //branch指令的offset，如果没有可以把两个立即数拼接起来                     

  output reg [10:0]  opcode_exe_2_mem_o,          // 操作类型,位宽暂定
  output reg [4:0]   rd_exe_2_mem_o,             // 目的寄存器编号,位宽暂定
  output reg [31:0]   rd_data_exe_2_mem_o,        // 计算结果,包括load/store的存储器地址。
  output reg [31:0]   men_data_o,                 //store指令存储的内容
  output reg        flush_from_exe,            // 分支跳转,对于分支指令，使用其计算得到的地址，默认是不跳转
  output reg [31:0]   flush_addr_exe,             //正确的执行地址

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

  parameter SW =  11'bx_000_0100011;
  parameter SH =  11'bx_001_0100011;
  parameter SB =  11'bx_010_0100011;

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

  wire sign_imm_12; //12位立即数的符号位
  wire [31:0]signed_imm_12; //12位立即数带符号位扩展
  assign sign_imm_12=imm_12[11]?1:0;
  assign signed_imm_12={{20{imm_12[11]}},imm_12};
  wire sign_imm_7;//7位立即数的符号位
  assign sign_imm_7=imm_7[6]?1:0;
  


  //Adder
  //判断rs1是否比rs2小
  wire rs1_lt_rs2;
  //判断rs1与rs2是否相等
  wire rs_eq_rs2;
  //rs2的补
  wire [31:0]rs2_complement;
  //rs1的非
  wire [31:0]rs1_not;
  //算和的结果
  wire [31:0] result_sum;
  //如果是减法，那么就是用补码，即操作数取反+1
  assign rs2_complement = (opcode_dec_2_exe_i == SUB)?
                    (~rs2_dec_2_exe_i)+1:rs2_dec_2_exe_i;
  assign result_sum = rs1_dec_2_exe_i +rs2_complement;
  

  // //Shifts
  // wire operand_a_rev;
  // wire shift_left_result;
  // genvar k;
  //   generate 
  //   for(k = 0; k < 32; k++)
  //     assign operand_a_rev[k] = re1_dec_2_exe_i[31-k];
  //   // for (k = 0; k < 32; k++)
  //   //   assign operand_a_rev32[k] = fu_data_i.operand_a[31-k];
  // endgenerate
  
  // genvar j;
  //   generate
  //     for(j = 0; j < riscv::XLEN; j++)
  //       assign shift_left_result[j] = shift_right_result[31-j];

  //     for(j = 0; j < 32; j++)
  //       assign shift_left_result32[j] = shift_right_result32[31-j];

  //   endgenerate
  // wire shift_left;//首先先判断是否为左移
  // wire shift_arithmetic;//判断是否为算数右移
  // wire shift_amt;
  // wire [31:0] shift_op_a_32;
  // wire [31:0] shift_result;
  // assign shift_amt=rs2_dec_2_exe_i;

  // assign shift_left=(opcode_dec_2_exe_i==SLL)|(opcode_dec_2_exe_i==SLLI)

  // assign shift_arithmetic=(opcode_dec_2_exe_i==SRA)|(opcode_dec_2_exe_i==SRAI)

  // wire [31:0] shift_op_32; //用于移位操作存储结果

  // assign shift_op_32 = (opcode_dec_2_exe_i==SLL) ? operand_a_rev;
  // assign shift_op_a_32 = {shift_arithmetic & shift_op_32[31],shift_op_32};
  // assign 
  // assign shift_result= shift_left? shift_le
  //Comparisons
  wire result_sum_imm;
  wire comparisons_sign;
  wire comparisons_sltiu;
  wire comparisons_slt;
  wire comparisons_sltu;
  reg comparisons_slti;
  // wire signed_rs1_rs2;
  // wire signed_rs1_rs2_negative;
  // wire rs1_rs2_compare;
  // wire rs1_rs2_compare_n;
  // wire posetive_negetive;
  // wire negative_posetive;
  // wire posetive_negetive_com;
  // wire negative_posetive_com;
  wire [11:0] imm_12_complement;
  assign result_sum = rs1_dec_2_exe_i +rs2_complement;
  assign imm_12_complement=(~imm_12)+1'b1;//12位的立即数取补码
  assign comparisons_sltu=(rs1_dec_2_exe_i<rs2_dec_2_exe_i)?1:0;
  assign comparisons_slt=(opcode_dec_2_exe_i==SLT)?
                           ((rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31]) ||
                            (rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31] && result_sum[31]) ||
                            (rs1_dec_2_exe_i[31] && rs2_dec_2_exe_i[31] && result_sum[31]))
                            : (rs1_dec_2_exe_i < rs2_dec_2_exe_i);//从其他模块粘贴过来，未验证是否正确
  assign comparisons_sltiu=rs1_dec_2_exe_i<imm_12?1:0;

  // assign signed_rs1_rs2=rs1_dec_2_exe_i[31]|rs2_dec_2_exe_i[31];//判断两个是否同为正
  // assign rs1_rs2_compare=signed_rs1_rs2? rs1_dec_2_exe_i[30:0]>rs2_dec_2_exe_i:0;
  
  // assign signed_rs1_rs2_negative=~(rs1_dec_2_exe_i[31]|rs2_dec_2_exe_i[31]);//判断两个是否同为负
  // assign rs1_rs2_compare_n=signed_rs1_rs2_negative?rs1_dec_2_exe_i<rs2_dec_2_exe_i:0;
  
  // assign posetive_negetive=rs1_dec_2_exe_i[31]>rs2_dec_2_exe_i[31];//如果是一正一负
  // assign posetive_negetive_com=posetive_negetive?1:0;
  // assign negative_posetive=rs1_dec_2_exe_i[31]<rs2_dec_2_exe_i[31];//如果是一负一正
  // assign negative_posetive_com=negative_posetive:0:1;
  // assign comparisons_slti=(opcode_dec_2_exe_i==SLTI)?

  wire rs1_s;
  assign rs1_s={rs1_dec_2_exe_i[31]};
  wire rs2_s;
  assign rs2_s={rs2_dec_2_exe_i[31]};

  wire rs1_ne_rs2_ne;
  assign rs1_ne_rs2_ne=rs1_dec_2_exe_i[31]&{rs2_dec_2_exe_i[31]};
  
  always @(*) begin
  if(rs1_dec_2_exe_i[31]&rs2_dec_2_exe_i[31])begin
     comparisons_slti = (rs1_dec_2_exe_i[30:0]>rs2_dec_2_exe_i[30:0])?1'b1:1'b0;
  end
  else if (~(rs1_dec_2_exe_i[31])&(rs2_dec_2_exe_i[31]))begin
     comparisons_slti=rs1_dec_2_exe_i<rs2_dec_2_exe_i?1:0;
  end                     
  else if (rs1_dec_2_exe_i[31]>rs2_dec_2_exe_i[31])begin
     comparisons_slti=1;
  end
  else if (rs1_dec_2_exe_i[31]<rs2_dec_2_exe_i[31])begin
     comparisons_slti=0;
  end
end
  //LOAD&STORE
  wire [31:0]load_address;
  assign load_address = (rs1_dec_2_exe_i+{{20{imm_12[11]}},imm_12[11:0]});
  wire [31:0]store_address;
  wire [11:0]offset_2; 


  assign offset_2={imm_7,imm_5};

  wire rs1_less_rs2;
  assign rs1_less_rs2=rs1_dec_2_exe_i<rs2_dec_2_exe_i?1:0;

  //branch
  wire flush_from_exe_3;    //BLT
  wire flush_from_exe_4;    //BLTU
  wire flush_from_exe_5;    //BGE
  wire flush_from_exe_6;    //BGEU
  wire flush_from_exe_d;
  assign flush_from_exe_3=((opcode_dec_2_exe_i==BLT)&&((rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31]) ||
                            (rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31] && result_sum[31]) ||
                            (rs1_dec_2_exe_i[31] && rs2_dec_2_exe_i[31] && result_sum[31])))?1:0;//从其他地方拷贝过来，未验证
  assign flush_from_exe_4=((opcode_dec_2_exe_i==BLTU)&&rs1_less_rs2)?1:0;
  assign flush_from_exe_5=((opcode_dec_2_exe_i==BGE)&&(~((rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31]) ||
                            (rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31] && result_sum[31]) ||
                            (rs1_dec_2_exe_i[31] && rs2_dec_2_exe_i[31] && result_sum[31]))))?1:0;//从其他地方拷贝过来，未验证                          
  assign flush_from_exe_6=((opcode_dec_2_exe_i==BGEU)&(rs1_dec_2_exe_i>=rs2_dec_2_exe_i))?1:0;
  assign flush_from_exe_d = flush_from_exe_3|flush_from_exe_4|flush_from_exe_5|flush_from_exe_6;

  //jump
  wire signed_imm_20;//20位立即数的符号位
  //wire [31:0]jump_address;

  wire  [31:0]jump_jalr;
  assign jump_jalr=rs1_dec_2_exe_i+imm_12;
  wire  [31:0] jump_jalr_negative;
  assign jump_jalr_negative=rs1_dec_2_exe_i-imm_12;
  wire [15:0]signed_imm_12_16;
  assign signed_imm_12_16={16{sign_imm_12}};
  wire [23:0]signed_imm_12_24;
  assign signed_imm_12_24={24{sign_imm_12}};
  wire [30:0] rs1_great_rs2;
  assign rs1_great_rs2={31{rs1_dec_2_exe_i>>rs2_dec_2_exe_i}};
  wire [30:0] rs1_great_imm;
  assign rs1_great_imm={30{rs1_dec_2_exe_i>>imm_5}};

  always@(posedge clk or negedge rstl)begin
    if(rstl==0)begin
      //current_pc<=0;
      rd_data_exe_2_mem_o<=32'h00000000;
      opcode_exe_2_mem_o <= 'd0;
      rd_exe_2_mem_o <= 'd0;
      men_data_o <= 'd0;
      flush_from_exe <= 1'b0;
      load_valid <= 'b0;
      store_valid <= 'b0;
    end
    else begin
      flush_from_exe <= 1'b0;
      men_data_o <= 'd0;
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
          flush_addr_exe <= current_pc+{{19{offset[11]}},offset,1'b0};
        end
      end
      BNE:begin
        if(rs1_dec_2_exe_i !=rs2_dec_2_exe_i)begin
          flush_from_exe <= 1'b1;
          flush_addr_exe<=current_pc+{{19{offset[11]}},offset,1'b0};
        end
      end
      BLT:begin
       if(flush_from_exe_3)begin
          flush_from_exe <= 1'b0;
          flush_addr_exe<=current_pc+{{19{offset[11]}},offset,1'b0};
        end
      end
      BLTU:begin
       if(flush_from_exe_4)begin
          flush_from_exe <= 1'b1;
          flush_addr_exe<=current_pc+{{19{offset[11]}},offset,1'b0};
        end
      end    
      BGE:begin
       if(flush_from_exe_5)begin
          flush_from_exe <= 1'b1;
          flush_addr_exe<=current_pc+{{19{offset[11]}},offset,1'b0};
        end  
      end
      BGEU:begin
       if(flush_from_exe_6)begin
          flush_from_exe <= 1'b1;
          flush_addr_exe<=current_pc+{{19{offset[11]}},offset,1'b0};
        end  
      end
      JAL:begin
        flush_from_exe <= 1'b1;
        flush_addr_exe <= current_pc + {{11{imm_20[19]}},imm_20,1'b0};
        rd_data_exe_2_mem_o <= current_pc + 32'd4;
        end
      JALR:begin
        if(signed_imm_12[11])begin
          flush_addr_exe<={jump_jalr[31:1],1'b0};
          rd_data_exe_2_mem_o<={jump_jalr[31:1],1'b0}+ 32'd4;
        end
        if(~signed_imm_12[11])begin
          flush_addr_exe<={jump_jalr_negative[31:1],1'b0};
          rd_data_exe_2_mem_o<={jump_jalr_negative[31:1],1'b0}+ 32'd4;
        end
      end
      OR:   rd_data_exe_2_mem_o <= rs1_dec_2_exe_i|rs2_dec_2_exe_i;
      AND:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i&rs2_dec_2_exe_i;
      XOR:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i^rs2_dec_2_exe_i;
      ORI:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i|signed_imm_12;
      ANDI: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i&signed_imm_12;
      XORI: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i^signed_imm_12;

      ADD:  rd_data_exe_2_mem_o<=result_sum;
      SUB:  rd_data_exe_2_mem_o<=result_sum;
      ADDI:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i+{20'd0,imm_12};
      AUIPC:  rd_data_exe_2_mem_o<=current_pc+{12'd0,imm_20};
      LUI: rd_data_exe_2_mem_o <= {12'd0,imm_20};

      SLL:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i<<rs2_dec_2_exe_i;
      SLLI: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i<<imm_5;
      SRL:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i>>rs2_dec_2_exe_i;
      SRLI: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i>>imm_5;
      SRA:  rd_data_exe_2_mem_o<={rs1_dec_2_exe_i[31],{rs1_great_rs2}};
      SRAI: rd_data_exe_2_mem_o<={rs1_dec_2_exe_i[31],{rs1_great_imm}};

      SLTIU: rd_data_exe_2_mem_o<={32{comparisons_sltiu}};
      SLT:  rd_data_exe_2_mem_o<={32{comparisons_slt}};
      SLTI: rd_data_exe_2_mem_o<={32{comparisons_slti}};
      SLTU: rd_data_exe_2_mem_o<={32{comparisons_sltu}};

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
        men_data_o<=rs2_dec_2_exe_i;
      end
      SH: begin
        store_valid <= 'b1;
        rd_data_exe_2_mem_o <= rs1_dec_2_exe_i + {{20{imm_12[11]}},imm_12};
        men_data_o<={16'b0,rs2_dec_2_exe_i[15:0]};
      end
      SB: begin
        store_valid <= 'b1;
        rd_data_exe_2_mem_o <= rs1_dec_2_exe_i + {{20{imm_12[11]}},imm_12};
        men_data_o<={24'b0,rs2_dec_2_exe_i[7:0]};
      end
      default:begin 
        rd_data_exe_2_mem_o <= 32'h00000000;
      end 
      endcase

      if(flush_from_exe)begin
        load_valid <= 'b0;
        store_valid <= 'b0;
        flush_from_exe <= 1'b0;
        men_data_o <= 'd0;
        rd_data_exe_2_mem_o<=32'h00000000;
        opcode_exe_2_mem_o <= 'd0;
        rd_exe_2_mem_o <= 'd0;
        flush_addr_exe <= 'd0;
      end
    end
  end
endmodule




