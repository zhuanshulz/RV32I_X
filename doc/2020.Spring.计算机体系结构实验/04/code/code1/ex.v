`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/27 02:39:27
// Design Name: 
// Module Name: ex
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.vh"

module ex(
    input   wire                rst_n,              // Reset, low active
    
    // from id_ex
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegBus]       reg1_data_i,
    input   wire[`RegBus]       reg2_data_i,
    input   wire[`RegAddrBus]   reg_waddr_i,
    input   wire                reg_we_i,

    // div
    input   wire[`RegBus]       div_result_i,
    input   wire                div_ready_i,
    output  reg[`RegBus]        div_opdata1_o,
    output  reg[`RegBus]        div_opdata2_o,
    output  reg                 div_start_o,
    output  reg                 div_signed_o,
    output  reg                 div_rem_o,

    // load & store
    input   wire[`RegBus]       load_store_imm_i,
    output  wire[`AluOpBus]     aluop_o,
    output  wire[`RegBus]       mem_addr_o,
    output  wire[`RegBus]       store_data_o,

    // stall
    output  reg                 stall_o,

    // result
    output  reg[`RegAddrBus]    reg_waddr_o,
    output  reg[`RegBus]        reg_wdata_o,
    output  reg                 reg_we_o
    );

    // result of logic op
    reg[`RegBus] result_logic;
    // result of shift op
    reg[`RegBus] result_shift;
    // result of arithmetic
    reg[`RegBus] result_arithmetic;

    // logic operation
    always @(*) begin
        if (rst_n == `RstEnable) begin
            result_logic <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OP_OR: begin
                    result_logic <= reg1_data_i | reg2_data_i;
                end
                `EXE_OP_XOR: begin
                    result_logic <= reg1_data_i ^ reg2_data_i;
                end
                `EXE_OP_AND: begin
                    result_logic <= reg1_data_i & reg2_data_i;
                end 
                default: begin
                    result_logic <= `ZeroWord;
                end
            endcase
        end
    end

    // shift operation
    always @(*) begin
        if (rst_n == `RstEnable) begin
            result_shift <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OP_SLL: begin
                    result_shift <= reg1_data_i << reg2_data_i[4:0];
                end
                `EXE_OP_SRL: begin
                    result_shift <= reg1_data_i >> reg2_data_i[4:0];
                end 
                `EXE_OP_SRA: begin
                    result_shift <= ({{31{reg1_data_i}}, 1'b0} << (~reg2_data_i[4:0])) 
                                    | (reg1_data_i >> reg2_data_i[4:0]) ;
                end 
                default: begin
                    result_shift <= `ZeroWord;
                end
            endcase
        end
    end

    // whether reg1 is less than reg2
    wire reg1_lt_reg2;
    // whether reg1 is equal to reg2
    wire reg1_eq_reg2;
    // Complement of reg2
    wire[`RegBus] reg2_complement;
    // ~reg1
    wire[`RegBus] reg1_not;
    // result of sum
    wire[`RegBus] result_sum;

    // if sub/slt, calc reg2's complement
    assign reg2_complement = ((aluop_i == `EXE_OP_SUB) || (aluop_i == `EXE_OP_SLT)) ? 
                            (~reg2_data_i) + 1 : reg2_data_i;

    // 1. add; 2. sub; 3. slt
    assign result_sum = reg1_data_i + reg2_complement;

    // 1. slt; 2. sltu
    assign reg1_lt_reg2 = (aluop_i == `EXE_OP_SLT) ? 
                            ((reg1_data_i[31] && ~reg2_data_i[31]) ||
                            (~reg1_data_i[31] && ~reg2_data_i[31] && result_sum[31]) ||
                            (reg1_data_i[31] && reg2_data_i[31] && result_sum[31]))
                            : (reg1_data_i < reg2_data_i);

    // not
    assign reg1_not = ~reg1_data_i;

    // arithmetic operation
    always @(*) begin
        if (rst_n == `RstEnable) begin
            result_arithmetic <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OP_SLT, `EXE_OP_SLTU, `EXE_OP_SLTI, `EXE_OP_SLTIU: begin
                    result_arithmetic <= reg1_lt_reg2;
                end 
                `EXE_OP_ADD, `EXE_OP_SUB, `EXE_OP_ADDI: begin
                    result_arithmetic <= result_sum;
                end
                default: begin
                    result_arithmetic <= `ZeroWord;
                end
            endcase
        end
    end

    
    // mult oprand 1 & 2
    wire[`RegBus] mult_oprand1;
    wire[`RegBus] mult_oprand2;
    // temp result of mult
    wire[`DoubleRegBus] mult_temp;
    wire[`DoubleRegBus] mult_temp_complement;
    // result of mult
    reg[`RegBus] result_mult;

    assign mult_oprand1 = (((aluop_i == `EXE_OP_MUL) || (aluop_i == `EXE_OP_MULH) || (aluop_i == `EXE_OP_MULHSU))
                        && (reg1_data_i[31] == 1'b1)) ? (~reg1_data_i) + 1 : reg1_data_i;

    assign mult_oprand2 = (((aluop_i == `EXE_OP_MUL) || (aluop_i == `EXE_OP_MULH))
                        && (reg2_data_i[31] == 1'b1)) ? (~reg2_data_i) + 1 : reg2_data_i;

    assign mult_temp = mult_oprand1 * mult_oprand2;

    assign mult_temp_complement = (~mult_temp) + 1;

    // mult operation (fix)
    always @(*) begin
        if (rst_n == `RstEnable) begin
            result_mult <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OP_MUL: begin
                    if (reg1_data_i[31] ^ reg2_data_i[31] == 1'b1) begin
                        result_mult <= mult_temp_complement[31:0];
                    end else begin
                        result_mult <= mult_temp[31:0];
                    end
                end
                `EXE_OP_MULH: begin
                    if (reg1_data_i[31] ^ reg2_data_i[31] == 1'b1) begin
                        result_mult <= mult_temp_complement[63:32];
                    end else begin
                        result_mult <= mult_temp[63:32];
                    end
                end
                `EXE_OP_MULHSU: begin
                    if (reg1_data_i[31] == 1'b1) begin
                        result_mult <= mult_temp_complement[63:32];
                    end else begin
                        result_mult <= mult_temp[63:32];
                    end
                end
                `EXE_OP_MULHU: begin
                    result_mult <= mult_temp[63:32];
                end
                default: begin
                    result_mult <= `ZeroWord;
                end
            endcase
        end
    end

    // div
    // stall caused by div
    reg stall_caused_by_div;

    always @(*) begin
        if (rst_n == `RstEnable) begin
            stall_caused_by_div <= `NotStall;
            div_opdata1_o <= `ZeroWord;
            div_opdata2_o <= `ZeroWord;
            div_start_o <= `DivStop;
            div_signed_o <= 1'b0;
            div_rem_o <= 1'b0;
        end else begin
            stall_caused_by_div <= `NotStall;
            div_opdata1_o <= `ZeroWord;
            div_opdata2_o <= `ZeroWord;
            div_start_o <= `DivStop;
            div_signed_o <= 1'b0;
            div_rem_o <= 1'b0;
            case (aluop_i)
                `EXE_OP_DIV: begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o <= reg1_data_i;
                        div_opdata2_o <= reg2_data_i;
                        div_start_o <= `DivStart;
                        div_signed_o <= 1'b1;
                        div_rem_o <= 1'b0;
                        stall_caused_by_div <= `Stall;
                    end else if(div_ready_i == `DivResultReady) begin
                        div_opdata1_o <= reg1_data_i;
                        div_opdata2_o <= reg2_data_i;
                        div_start_o <= `DivStop;
                        div_signed_o <= 1'b1;
                        div_rem_o <= 1'b0;
                        stall_caused_by_div <= `NotStall;
                    end else begin
                        stall_caused_by_div <= `NotStall;
                        div_opdata1_o <= `ZeroWord;
                        div_opdata2_o <= `ZeroWord;
                        div_start_o <= `DivStop;
                        div_signed_o <= 1'b0;
                        div_rem_o <= 1'b0;
                    end
                end 
                `EXE_OP_DIVU: begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o <= reg1_data_i;
                        div_opdata2_o <= reg2_data_i;
                        div_start_o <= `DivStart;
                        div_signed_o <= 1'b0;
                        div_rem_o <= 1'b0;
                        stall_caused_by_div <= `Stall;
                    end else if(div_ready_i == `DivResultReady) begin
                        div_opdata1_o <= reg1_data_i;
                        div_opdata2_o <= reg2_data_i;
                        div_start_o <= `DivStop;
                        div_signed_o <= 1'b0;
                        div_rem_o <= 1'b0;
                        stall_caused_by_div <= `NotStall;
                    end else begin
                        stall_caused_by_div <= `NotStall;
                        div_opdata1_o <= `ZeroWord;
                        div_opdata2_o <= `ZeroWord;
                        div_start_o <= `DivStop;
                        div_signed_o <= 1'b0;
                        div_rem_o <= 1'b0;
                    end
                end 
                `EXE_OP_REM: begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o <= reg1_data_i;
                        div_opdata2_o <= reg2_data_i;
                        div_start_o <= `DivStart;
                        div_signed_o <= 1'b1;
                        div_rem_o <= 1'b1;
                        stall_caused_by_div <= `Stall;
                    end else if(div_ready_i == `DivResultReady) begin
                        div_opdata1_o <= reg1_data_i;
                        div_opdata2_o <= reg2_data_i;
                        div_start_o <= `DivStop;
                        div_signed_o <= 1'b1;
                        div_rem_o <= 1'b1;
                        stall_caused_by_div <= `NotStall;
                    end else begin
                        stall_caused_by_div <= `NotStall;
                        div_opdata1_o <= `ZeroWord;
                        div_opdata2_o <= `ZeroWord;
                        div_start_o <= `DivStop;
                        div_signed_o <= 1'b0;
                        div_rem_o <= 1'b0;
                    end
                end 
                `EXE_OP_REMU: begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o <= reg1_data_i;
                        div_opdata2_o <= reg2_data_i;
                        div_start_o <= `DivStart;
                        div_signed_o <= 1'b0;
                        div_rem_o <= 1'b1;
                        stall_caused_by_div <= `Stall;
                    end else if(div_ready_i == `DivResultReady) begin
                        div_opdata1_o <= reg1_data_i;
                        div_opdata2_o <= reg2_data_i;
                        div_start_o <= `DivStop;
                        div_signed_o <= 1'b0;
                        div_rem_o <= 1'b1;
                        stall_caused_by_div <= `NotStall;
                    end else begin
                        stall_caused_by_div <= `NotStall;
                        div_opdata1_o <= `ZeroWord;
                        div_opdata2_o <= `ZeroWord;
                        div_start_o <= `DivStop;
                        div_signed_o <= 1'b0;
                        div_rem_o <= 1'b0;
                    end
                end 
                default: begin
                    
                end
            endcase
        end
    end

    // load & store
    assign aluop_o = aluop_i;
    assign mem_addr_o = reg1_data_i + load_store_imm_i;
    assign store_data_o = reg2_data_i;


    // stall
    always @(*) begin
        stall_o = stall_caused_by_div;
    end

    // select result according to alusel_i
    always @(*) begin
        reg_waddr_o <= reg_waddr_i;
        reg_we_o <= reg_we_i;
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                reg_wdata_o <= result_logic;
            end
            `EXE_RES_SHIFT: begin
                reg_wdata_o <= result_shift;
            end
            `EXE_RES_ARITHMETIC: begin
                reg_wdata_o <= result_arithmetic;
            end
            `EXE_RES_MUL: begin
                reg_wdata_o <= result_mult;
            end
            `EXE_RES_DIV: begin
                reg_wdata_o <= div_result_i;
            end
            `EXE_RES_JUMP: begin
                reg_wdata_o <= reg1_data_i;
            end
            default: begin
                reg_wdata_o <= `ZeroWord;
            end
        endcase
    end
    
endmodule
