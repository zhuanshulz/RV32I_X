module dec (
	input clk,
	input rst_n,

	input [31:0] instr_ifu_2_dec_i,			//输入的指令
	input [31:0] instr_addr_ifu_2_dec_i,    //输入的指令的地址
	input flush_from_exe,                   //从执行单元来的分支信号
	
	input [4:0]	rd_mem_2_dec_i,
	input [31:0] rd_data_mem_2_dec_i,

	output rd_conflict,
	output reg [10:0] opcode_dec_2_exe_o,       //操作类型
	output reg [31:0] rs1_dec_2_exe_o, 			//源操作数1
	output reg [31:0] rs2_dec_2_exe_o,			//源操作数2
	output reg [19:0] imm,						//立即书字段
	output reg [4:0] rd_dec_2_exe_o,			//目的寄存器编号
	output reg [31:0] instr_addr_dec_2_exe_o,
	output reg [4:0] shamt_o,
	output flush_from_dec,					//译码发现分支错误
	output [31:0] flush_addr_dec 			//正确的执行地址

);
	wire [31:0] instr_ifu_2_dec;
	// reg rst_n_d0;
	// reg rst_n_d1;
	assign instr_ifu_2_dec = (flush_from_exe | (~rst_n))?'d0:instr_ifu_2_dec_i;
	assign flush_from_dec = 'b0;
	assign flush_addr_dec = 'd0;

	//通用寄存器组
	reg [31:0] x[0:31];

	wire identify;
	reg [4:0] rd_dec_2_exe; // 目的寄存器编号
	wire [10:0] opcode_dec_2_exe; //操作类型
	reg [4:0] rs1;
	reg [4:0] rs2;
	reg [19:0] imm_20;
	reg [11:0] imm_12;

	//取出32位指令的关键编码段
	wire [6:0] rv32_opcode =instr_ifu_2_dec [6:0];
	wire [19:0] imm1 = 		instr_ifu_2_dec [31:12];
	wire [11:0] imm2 = 		instr_ifu_2_dec [31:20];
	wire [4:0] rs1_num = 	instr_ifu_2_dec [19:15];
	wire [4:0] rs2_num = 	instr_ifu_2_dec [24:20];
	wire [2:0] funct3 = 	instr_ifu_2_dec [14:12];
	wire [4:0] rd_num = 	instr_ifu_2_dec [11:7];

	integer i=0;

	reg [5*2-1:0] used_rd_order;

	assign rd_conflict = ((((flush_from_exe?5'd0:rs1) == used_rd_order[5*1-1:0])
						| ((flush_from_exe?5'd0:rs1) == used_rd_order[(5*2-1):(5*1)])) & (|rs1))
						| (((flush_from_exe?5'd0:rs2) == used_rd_order[5*1-1:0])
						| ((flush_from_exe?5'd0:rs2) == used_rd_order[(5*2-1):(5*1)])) & (|rs2);

	// always @(posedge clk or negedge rst_n) begin
	// 		if(~rst_n) begin
	// 			rst_n_d0 <= 'd0;
	// 			rst_n_d1 <= 'd0;
	// 		end
	// 		else begin
	// 			rst_n_d0 <= rst_n;
	// 			rst_n_d1 <= rst_n_d0;
	// 		end
	// end
	reg [4:0] shamt;

    integer trace_file;
    
	initial begin
        trace_file = $fopen("trace.txt","w");
    end

	always @(posedge clk ) begin
		if(|rd_mem_2_dec_i)begin
			$fdisplay(trace_file, "%x  %x", rd_mem_2_dec_i, rd_data_mem_2_dec_i);
		end
	end

	always @(posedge clk or negedge rst_n) begin
			if(~rst_n) begin
				opcode_dec_2_exe_o <= 'd0;
				rs1_dec_2_exe_o <= 'd0;
				rs2_dec_2_exe_o <= 'd0;
				imm <= 'd0;
				rd_dec_2_exe_o <= 'd0;
				used_rd_order <= 'd0;

				for( i=0;i<32;i=i+1)begin
					x[i] <= 'd0;
				end
			end
			else begin
				if(|rd_mem_2_dec_i)begin
					x[rd_mem_2_dec_i] <= rd_data_mem_2_dec_i;
				end


				used_rd_order 			<= rd_conflict?(used_rd_order << 5):{used_rd_order[5*1-1:0],rd_dec_2_exe};
				opcode_dec_2_exe_o 		<= rd_conflict?'d0:opcode_dec_2_exe;
				rs1_dec_2_exe_o 		<= rd_conflict?'d0:(((rs1 == rd_mem_2_dec_i) && (|rd_mem_2_dec_i))?rd_data_mem_2_dec_i:x[rs1]);		// 写通
				rs2_dec_2_exe_o 		<= rd_conflict?'d0:(((rs2 == rd_mem_2_dec_i) && (|rd_mem_2_dec_i))?rd_data_mem_2_dec_i:x[rs2]);		// write through
				imm 					<= rd_conflict?'d0:((|imm_20)?{imm_20}:((|imm_12)?{8'd0,imm_12}:20'd0));
				rd_dec_2_exe_o 			<= (flush_from_exe | rd_conflict)?5'd0:(rd_dec_2_exe);
				instr_addr_dec_2_exe_o 	<= (flush_from_exe | rd_conflict)?'d0:instr_addr_ifu_2_dec_i;
				shamt_o					<= shamt;
			end
	end

	assign identify = instr_ifu_2_dec[31:25] != 'd0;		// 用于区别不同的指令
	assign opcode_dec_2_exe = { identify,funct3,rv32_opcode}; // 1+3+7

	//I指令集译码
	always@(*) begin
			rd_dec_2_exe = 'd0;
			imm_20 = 'd0;
			imm_12 = 'd0;
			rs1 = 'd0;
			rs2 = 'd0;
			shamt = 'd0;
			case(rv32_opcode)
				7'b0110111 : 	// LUI
					begin 
						rd_dec_2_exe = rd_num;
						imm_20 = imm1;
					end
				7'b0010111 : 	// AUIPC
					begin 
						rd_dec_2_exe = rd_num;
						imm_20 = imm1;
					end 
				7'b1101111 : 	// JAL
					begin
						rd_dec_2_exe = rd_num;
						imm_20 = {instr_ifu_2_dec[31], instr_ifu_2_dec[19:12], instr_ifu_2_dec[20], instr_ifu_2_dec[30:21]};
					end 
				7'b1100111:		// JALR
					begin 
						rd_dec_2_exe = rd_num;
						rs1 = rs1_num;
						imm_12 = imm2;
					end 
				7'b1100011 : 	// BEQ/BNE/BLT/BGE/BLTU/BGEU
					begin 
						rs1 = rs1_num;
						rs2 = rs2_num;
						imm_12 = {instr_ifu_2_dec[31], instr_ifu_2_dec[7], instr_ifu_2_dec[30:25], instr_ifu_2_dec[11:8]};
					end
				
				7'b0000011:		// LB/LH/LW/LBU/LHU
					begin 
						rd_dec_2_exe = rd_num;
						rs1 = rs1_num;
						imm_12 = imm2;
					end
				7'b0100011:		// SB/SH/SW
					begin 
						rs1 = rs1_num;
						rs2 = rs2_num;
						imm_12 = {instr_ifu_2_dec[31:25], instr_ifu_2_dec[11:7]};
					end 
				
				7'b0010011:		// ADDI/SLTI/SLTIU/XORI/ORI/ANDI
					begin
						case(funct3)
							3'b001,3'b101:		// SLLI/SRLI/SRAI
								begin
									rd_dec_2_exe = rd_num;
									rs1 = rs1_num;
									shamt = instr_ifu_2_dec [24:20];
								end
							default:		// ADDI
								begin
									rd_dec_2_exe = rd_num;
									rs1 = rs1_num;
									imm_12 = imm2;
								end
						endcase
					end
				7'b0110011:
					begin		//// AND// SUB/ SLL/ SLT/ SLTU/ XOR/ SRA/ OR/ AND
						rd_dec_2_exe = rd_num;
						rs1 = rs1_num;
						rs2 = rs2_num;
					end
				7'b0001111:		// FENCE
					begin

					end 
				7'b1110011:		 // ECALL/ EBREAK
					begin
						
					end 
				default:begin
					rd_dec_2_exe = 'd0;
					imm_20 = 'd0;
					imm_12 = 'd0;
					rs1 = 'd0;
					rs2 = 'd0;
					shamt = 'd0;
				end
			endcase
		end


endmodule
				
