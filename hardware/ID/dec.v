module dec (
instr_ifu_2_dec_i,
instr_addr_ifu_2_dec_o,
flush_from_exe,
clk,
opcode_dec_2_exe_o,
rs1_dec_2_exe_o,
rs2_dec_2_exe_o,
rd_dec_2_exe_o,
flush_from_dec,
flush_addr_dec,
)
	input [31:0] instr_ifu_2_dec_i;			//输入的指令
	input [31:0] instr_addr_ifu_2_dec_o;        //输入的指令的地址
	input flush_from_exe;                   //从执行单元来的分支信号
	input clk;
	
	output [6:0] opcode_dec_2_exe_o;       //操作类型
	output [31:0] rs1_dec_2_exe_o; 			//源操作数1
	output [31:0] rs2_dec_2_exe_o;			//源操作数2
	output [4:0] rd_dec_2_exe_o;			//目的寄存器编号
	output flush_from_dec;				//译码发现分支错误
	output [] flush_addr_dec; 			//正确的执行地址
	reg [19:0] imm_20;				//20位立即数
	reg [11:0] imm_12;				//12位立即数
	//通用寄存器组
	reg [31:0] x0;
	reg [31:0] x1;
	reg [31:0] x2;
	reg [31:0] x3;
	reg [31:0] x4;
	reg [31:0] x5;
	reg [31:0] x6;
	reg [31:0] x7;
	reg [31:0] x8;
	reg [31:0] x9;
	reg [31:0] x10;
	reg [31:0] x11;
	reg [31:0] x12;
	reg [31:0] x13;
	reg [31:0] x14;
	reg [31:0] x15;
	reg [31:0] x16;
	reg [31:0] x17;
	reg [31:0] x18;
	reg [31:0] x19;
	reg [31:0] x20;
	reg [31:0] x21;
	reg [31:0] x22;
	reg [31:0] x23;
	reg [31:0] x24;
	reg [31:0] x25;
	reg [31:0] x26;
	reg [31:0] x27;
	reg [31:0] x28;
	reg [31:0] x29;
	reg [31:0] x30;
	reg [31:0] x31;
	//取出32位指令的关键编码段
	wire [6:0] rv32_opcode = instr_ifu_2_dec_i [6:0];
	wire [19:0] imm1 = instr_ifu_2_dec_i [31:12];
	wire [11:0] imm2 = instr_ifu_2_dec_i [31:20];
	wire [4:0] rs1_num = instr_ifu_2_dec_i [19:15];
	wire [4:0] rs2_num = instr_ifu_2_dec_i [24:20];
	wire [2:0] funct3 = instr_ifu_2_dec_i [14:12];
	wire [4:0] rd_num = instr_ifu_2_dec_i [11:7];
	
	
	//I指令集译码
	always@(postedge clk)
		begin
			case(rv32_opcode)
				7'b0110111 : 
					begin 
						rd_dec_2_exe_o = rd_num;
						imm_20 = imm1;
					end
				7'b0010111 : 
					begin 
						rd_dec_2_exe_o = rd_num,
						imm_20 = imm1;
					end 
				7'b1101111 : 
					begin
						rd_dec_2_exe_o = rd_num, 
						imm_20 = {instr_ifu_2_dec_i[20], instr_ifu_2_dec_i[10:1], instr_ifu_2_dec_i[11], instr_ifu_2_dec_i[19:12]};
					end 
				7'b1100111:
					begin 
						rd_dec_2_exe_o = rd_num;
						rs1 = rs1_num;
						imm_12 = imm2;
					end 
				7'b1100011 : 
					begin 
						case(funct3)
							3'b000:
								begin
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[12], instr_ifu_2_dec_i[10:5], instr_ifu_2_dec_i[4:1], instr_ifu_2_dec_i[11]};
								end 
							3'b001 :
								begin 
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[12], instr_ifu_2_dec_i[10:5], instr_ifu_2_dec_i[4:1], instr_ifu_2_dec_i[11]};
								end
							3'b100：
								begin 
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[12], instr_ifu_2_dec_i[10:5], instr_ifu_2_dec_i[4:1], instr_ifu_2_dec_i[11]};
								end
							3'b101:
								begin 
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[12], instr_ifu_2_dec_i[10:5], instr_ifu_2_dec_i[4:1], instr_ifu_2_dec_i[11]};
								end
							3'b110:
								begin 
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[12], instr_ifu_2_dec_i[10:5], instr_ifu_2_dec_i[4:1], instr_ifu_2_dec_i[11]};
								end
							3'b111:
								begin 
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[12], instr_ifu_2_dec_i[10:5], instr_ifu_2_dec_i[4:1], instr_ifu_2_dec_i[11]};
								end
							default
						endcase
					end 
				
				7'b0000011:
					begin 
						case(funct3)
							3'b000:
								begin 
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b001:
								begin 
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b010:
								begin 
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b100:
								begin 
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b101:
								begin 
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							default
						endcase
					end 
				7'b0100011:
					begin 
						case(funct3)
							3'b000:
								begin 
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[31:25], instr_ifu_2_dec_i[11:7]};
								end 
							3'b001:
								begin 
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[31:25], instr_ifu_2_dec_i[11:7]};
								end 
							3'b010:
								begin 
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_12 = {instr_ifu_2_dec_i[31:25], instr_ifu_2_dec_i[11:7]};
								end 
							default
						endcase
					end 
				
				7'b0010011:
					begin
						case(funct3)
							3'b000:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b010:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b011:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b100:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b110:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b111:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
							3'b001:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									shamt = instr_ifu_2_dec_i [24:20];
									imm_7 = 7'b0000000
								end
							3'b101:
								if (instr_ifu_2_dec_i [31:25] == 7'b0000000)
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									shamt = instr_ifu_2_dec_i [24:20];
								else
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									shamt = instr_ifu_2_dec_i [24:20];
							default
						endcase
					end
				7'b0110011:
					begin
						case(funct3)
							3'b000:
								begin
									if (instr_ifu_2_dec_i [31:25] == 7'b0000000)
										rd_dec_2_exe_o = rd_num;
										rs1 = rs1_num;
										rs2 = rs2_num;
									else
										rd_dec_2_exe_o = rd_num;
										rs1 = rs1_num;
										rs2 = rs2_num;
								end 
							3'b001:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_7 = 7'b0000000;
								end 
							3'b010:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_7 = 7'b0000000;
								end 
							3'b011:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_7 = 7'b0000000;
								end 
							3'b100:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_7 = 7'b0000000;
								end 
							3'b101:
								begin 
									if (instr_ifu_2_dec_i[31:25] == 7'b0000000)
										rd_dec_2_exe_o = rd_num;
										rs1 = rs1_num;
										rs2 = rs2_num;
									else
										rd_dec_2_exe_o = rd_num;
										rs1 = rs1_num;
										rs2 = rs2_num;
								end 
							3'b110:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_7 = 7'b0000000;
								end 
							3'b111:
								begin
									rd_dec_2_exe_o = rd_num;
									rs1 = rs1_num;
									rs2 = rs2_num;
									imm_7 = 7'b0000000;
								end
							default
						endcase
					end
				7'b0001111:
					begin
						rd_dec_2_exe_o = rd_num;
						rs1 = rs1_num;
						succ = instr_ifu_2_dec_i [23:20];
						pred = instr_ifu_2_dec_i [27:24];
						fm = instr_ifu_2_dec_i [31:28];
					end 
				7'b1110011:
					begin
						if (instr_ifu_2_dec_i [31:20] == 12'b000000000000)
							instr_ifu_2_dec_i [11:7] = 5'b00000;
							instr_ifu_2_dec_i [14:12] = 3'b000;
							instr_ifu_2_dec_i [19:15] = 5'b00000;
						else
							instr_ifu_2_dec_i [11:7] = 5'b00000;
							instr_ifu_2_dec_i [14:12] = 3'b000;
							instr_ifu_2_dec_i [19:15] = 5'b00000;
					end 
				default
			endcase
		end
endmodule
				
