module exe(
  input clk,
  input rstl,
  input [31:0]  opcode_dec_2_exe_i,           // 操作类型,位宽暂定
  input [31:0]   rs1_dec_2_exe_i,             // 源操作数1
  input [31:0]   rs2_dec_2_exe_i,             // 源操作数2
  input [10:0]   rd_dec_2_exe_i,              // 目的寄存器编号,位宽暂定
  input [31:0]  current_pc,                   //pc
  input [11:0]   imm_12,                      //12位的立即数，从译码阶段获得
  input [6:0]    imm_7,                       //7位的立即数
  input [4:0]    imm_5,                       //5位的立即数
  input [11:0]   offset,                       //branch指令的offset，如果没有可以把两个立即数拼接起来                     

  output [31:0]  opcode_exe_2_mem_o,          // 操作类型,位宽暂定
  output [10:0]   rd_exe_2_mem_o,             // 目的寄存器编号,位宽暂定
  output [31:0]   rd_data_exe_2_mem_o,        // 计算结果
  output [31:0]   mem_address_o,              //store指令存储的地址
  output [31:0]   men_data_o,                 //store指令存储的内容
  output          flush_from_exe,            // 分支跳转,对于分支指令，使用其计算得到的地址，默认是不跳转
  output [31:0]   flush_addr_exe,             //正确的执行地址

  output flush_o,                               //当遇到0作除数
  output flush_pc,                            //冲刷流水线时的PC
  input flush_i                                  //分支预测错误冲刷流水线

)
  wire sign_imm_12; //12位立即数的符号位
  wire [31:0]signed_imm_12; //12位立即数带符号位扩展
  assign sign_imm_12=imm_12[11]:1?0;
  assign signed_imm_12={20{signed_imm_12},imm_12};
  wire sign_imm_7;//7位立即数的符号位
  assign sign_imm_7=imm_7[6]:1?0;
  


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
  wire comparisons_slti;
  // wire signed_rs1_rs2;
  // wire signed_rs1_rs2_negative;
  // wire rs1_rs2_compare;
  // wire rs1_rs2_compare_n;
  // wire posetive_negetive;
  // wire negative_posetive;
  // wire posetive_negetive_com;
  // wire negative_posetive_com;
  assign result_sum = rs1_dec_2_exe_i +rs2_complement;
  assign imm_12_complement=(~imm_12)+1;//12位的立即数取补码
  assign comparisons_sltu=(rs1_dec_2_exe_i<rs2_dec_2_exe_i)?1:0;
  assign comparisons_slt=(opcode_dec_2_exe_i==SLT)？
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

  if(rs1_dec_2_exe_i[31]|rs2_dec_2_exe_i[31])begin
    comparisons_slti= rs1_dec_2_exe_i[30:0]>rs2_dec_2_exe_i；
  end
  else if (~(rs1_dec_2_exe_i[31]|rs2_dec_2_exe_i[31]))begin
    comparisons_slti=rs1_dec_2_exe_i<rs2_dec_2_exe_i;
  end                     
  else if (rs1_dec_2_exe_i[31]>rs2_dec_2_exe_i[31])begin
    comparisons_slti=1;
  end
  else if (rs1_dec_2_exe_i[31]<rs2_dec_2_exe_i[31])begin
    comparisons_slti=0;
  end

  //LOAD&STORE
  wire [31:0]load_address;
  assign load_address=signed_imm_12?(rs1_dec_2_exe_i-imm_12[10:0]):(rs1_dec_2_exe_i+imm_12[10:0]);
  wire [31:0]store_address;
  assign mem_address_o=signed_imm_7?(rs1_dec_2_exe_i-imm_7[6:0]):(rs1_dec_2_exe_i+imm_7[6:0]);



  //branch
  wire flush_from_exe_1;    //BEQ
  wire flush_from_exe_2;    //BNE
  wire flush_from_exe_3;    //BLT
  wire flush_from_exe_4;    //BLTU
  wire flush_from_exe_5;    //BGE
  wire flush_from_exe_6;    //BGEU
  reg flush_from_exe_d;
  assign flush_from_exe_1=((opcode_dec_2_exe_i==BEQ)&(rs1_dec_2_exe_i==rs2_dec_2_exe_i))?1:0;
  assign flush_from_exe_2=((opcode_dec_2_exe_i==BNE)&(rs1_dec_2_exe_i!=rs2_dec_2_exe_i))?1:0;
  assign flush_from_exe_3=((opcode_dec_2_exe_i==BLT)&(((rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31]) ||
                            (rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31] && result_sum[31]) ||
                            (rs1_dec_2_exe_i[31] && rs2_dec_2_exe_i[31] && result_sum[31])))?1:0;//从其他地方拷贝过来，未验证
  assign flush_from_exe_4=((opcode_dec_2_exe_i=BLTU)&(rs1_dec_2_exe_i<rs2_dec_2_exe_i))?1:0;
  assign flush_from_exe_5=((opcode_dec_2_exe_i==BGE)&(!((rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31]) ||
                            (rs1_dec_2_exe_i[31] && ~rs2_dec_2_exe_i[31] && result_sum[31]) ||
                            (rs1_dec_2_exe_i[31] && rs2_dec_2_exe_i[31] && result_sum[31])))?1:0;//从其他地方拷贝过来，未验证                          
  assign flush_from_exe_6=((opcode_dec_2_exe_i==BGEU)&rs1_dec_2_exe_i>=rs2_dec_2_exe_i))?1:0;
  assign flush_from_exe_d=flush_from_exe_1|flush_from_exe_2|flush_from_exe_3|flush_from_exe_4|flush_from_exe_5|flush_from_exe_6;

  always@(posedge clk)begin
    if(rstl==0)
      current_pc<=current_pc;
    case(opcode_dec_2_exe_i)
      BEQ:begin
        if(flush_from_exe_1)begin
          flush_from_exe<=flush_from_exe_d;
          flush_addr_exe<=current_pc+offset;
        end
      end
      BNE:begin
        if(flush_from_exe_2)begin
          flush_from_exe<=flush_from_exe_d;
          flush_addr_exe<=current_pc+offset;
        end
      end
      BLT：begin
       if(flush_from_exe_3)begin
          flush_from_exe<=flush_from_exe_d;
          flush_addr_exe<=current_pc+offset;  
        end
      end
      BLTU:begin
       if(flush_from_exe_4)begin
          flush_from_exe<=flush_from_exe_d;
          flush_addr_exe<=current_pc+offset;  
        end
      end    
      BGE:begin
       if(flush_from_exe_5)begin
          flush_from_exe<=flush_from_exe_d;
          flush_addr_exe<=current_pc+offset;  
        end  
      end
      BGEU:begin
       if(flush_from_exe_6)begin
          flush_from_exe<=flush_from_exe_d;
          flush_addr_exe<=current_pc+offset;  
        end  
      end
      default: current_pc=current_pc;
      endcase
    end


//logic
  always@(posedge clk)
    if(rstl==0)
      rd_data_exe_2_mem_o<=32'h00000000;
    case(opcode_dec_2_exe_i)

      OR: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i|rs2_dec_2_exe_i;
      AND:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i&rs2_dec_2_exe_i;
      XOR:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i^rs2_dec_2_exe_i;
      ORI:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i|signed_imm_12;
      ANDI: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i&signed_imm_12;
      XORI: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i^signed_imm_12;

      ADD:  rd_data_exe_2_mem_o<=result_sum;
      SUB:  rd_data_exe_2_mem_o<=result_sum;
      ADDI：  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i+imm_12;
      AUIPC:  rd_data_exe_2_mem_o<=current_pc+imm_20<<12;
      LUI：  rd_data_exe_2_mem_o<=imm_20<<12;

      SLL:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i<<rs2_dec_2_exe_i;
      SLLI: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i<<imm_5;
      SRL:  rd_data_exe_2_mem_o<=rs1_dec_2_exe_i>>rs2_dec_2_exe_i;
      SRLI: rd_data_exe_2_mem_o<=rs1_dec_2_exe_i>>imm_5;
      SRA:  rd_data_exe_2_mem_o<={rs1_dec_2_exe_i[31],{rs1_dec_2_exe_i>>rs2_dec_2_exe_i}[30:0]};
      SRAI: rd_data_exe_2_mem_o<={rs1_dec_2_exe_i[31],{rs1_dec_2_exe_i>>imm_5}[30:0]};

      SLTIU: rd_data_exe_2_mem_o<={32[comparisons_sltiu]};
      SLT:  rd_data_exe_2_mem_o<={32[comparisons_slt]};
      SLTI: rd_data_exe_2_mem_o<={32[comparisons_slti]};
      SLTI: rd_data_exe_2_mem_o<={32[comparisons_slti]};

      LW: rd_data_exe_2_mem_o<={load_address};
      LH: rd_data_exe_2_mem_o<={16[signed_imm_12],load_address[15:0]};
      LHU:  rd_data_exe_2_mem_o<={16[0],load_address[15:0]};
      LB: rd_data_exe_2_mem_o<={24{signed_imm_12},load_address[7:0]};
      LBU:  rd_data_exe_2_mem_o<={24[0],load_address[7:0]};

      SW: store_data_o<=rs2_dec_2_exe_i;
      SH: store_data_o<={16[0],rs2_dec_2_exe_i[15:0]};
      SB: store_data_o<={24[0],rs2_dec_2_exe_i[7:0]};

      

    default: rd_data_exe_2_mem_o=32'h00000000;
    endcase
  end



endmodule