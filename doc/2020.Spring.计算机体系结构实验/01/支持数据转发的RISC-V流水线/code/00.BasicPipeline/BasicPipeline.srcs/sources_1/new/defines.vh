// defines.vh

// Global defines
`define RstEnable           1'b0            // Reset signal, active low 
`define RstDisable          1'b1            // Reset signal, deactive high
`define WriteEnable         1'b1            // Enable writing
`define WriteDisable        1'b0            // Disable writing
`define ReadEnable          1'b1            // Enable reading
`define ReadDisable         1'b0            // Disable writing
///////////////////////////////////////////////////////////////////
`define AluOpBus            7:0
`define AluSelBus           2:0
///////////////////////////////////////////////////////////////////
`define InstValid           1'b1            // Valid instruction
`define InstInvalid         1'b0            // Invalid instruction
`define True                1'b1            // Logical true
`define False               1'b0            // Logical false
`define ChipEnable          1'b1            // Enable chip
`define ChipDisable         1'b0            // Disable chip
`define ZeroWord            32'h00000000    // 32bit value 0

`define EXE_NOP_OP          8'b00000000
`define EXE_ORI_OP          8'b01011010
`define EXE_OR_OP           8'b00100101
`define EXE_RES_NOP         3'b000
`define EXE_RES_LOGIC       3'b001

// Instruction & Instruction memory
`define InstAddrBus         31:0            // Instruction memory address bus
`define InstBus             31:0            // Instruction memory data bus
`define InstMemNum          65536           // Total 64K instruction memory
`define InstMemNumLog2      16              // Actual bus width of instruction memory

// Register file
`define RegAddrBus          4:0             // Register file address bus
`define RegBus              31:0            // Register file bus
`define RegWidth            32              // Width of registers
`define RegNum              32              // Number of registers
`define RegNumLog2          5               // Address width of registers
`define RegAddrx0          5'b00000        // Address of x0

// instructions

// Instructions' type
`define TYPE_R                  6'b100000
`define TYPE_I                  6'b010000
`define TYPE_S                  6'b001000
`define TYPE_B                  6'b000100
`define TYPE_U                  6'b000010
`define TYPE_J                  6'b000001

// Immediate of all type
`define TYPE_R_IMM              32'h00000000
`define TYPE_I_IMM              {{21{inst_i[31]}}, {inst_i[30:20]}}
`define TYPE_S_IMM              {{21{inst_i[31]}}, {inst_i[30:25]}, {inst_i[11:7]}}
`define TYPE_B_IMM              {{20{inst_i[31]}}, {inst_i[7]}, {inst_i[30:25]}, {inst_i[11:8]}, {1'b0}}
`define TYPE_U_IMM              {{inst_i[31:12]}, {12'h000}}
`define TYPE_J_IMM              {{12{inst_i[31]}}, {inst_i[19:12]}, {inst_i[20]}, {inst_i[30:25]}, {inst_i[24:21]}, {1'b0}}

// Major opcodes inst[6:2], inst[1:0]=11
`define MAJOR_OPCODE_LOAD       5'b00000
`define MAJOR_OPCODE_MISC_MEM   5'b00011
`define MAJOR_OPCODE_OP_IMM     5'b00100
`define MAJOR_OPCODE_AUIPC      5'b00101
`define MAJOR_OPCODE_STORE      5'b01000
`define MAJOR_OPCODE_OP         5'b01100
`define MAJOR_OPCODE_LUI        5'b01101
`define MAJOR_OPCODE_BRANCH     5'b11000
`define MAJOR_OPCODE_JALR       5'b11001
`define MAJOR_OPCODE_JAL        5'b11011
`define MAJOR_OPCODE_SYSTEM     5'b11100

// function3 inst[14:12]
// LUI, no funct3
// AUIPC, no funct3
// JAL, no funct3
// JALR
`define FUNCT3_JALR             3'b000
// BRANCH
`define FUNCT3_BEQ              3'b000
`define FUNCT3_BNE              3'b001
`define FUNCT3_BLT              3'b100
`define FUNCT3_BGE              3'b101
`define FUNCT3_BLTU             3'b110
`define FUNCT3_BGEU             3'b111
// LOAD
`define FUNCT3_LB               3'b000
`define FUNCT3_LH               3'b001
`define FUNCT3_LW               3'b010
`define FUNCT3_LBU              3'b100
`define FUNCT3_LHU              3'b101
// STORE
`define FUNCT3_SB               3'b000
`define FUNCT3_SH               3'b001
`define FUNCT3_SW               3'b010
// OP_IMM
`define FUNCT3_ADDI             3'b000//
`define FUNCT3_SLTI             3'b010//
`define FUNCT3_SLTIU            3'b011//
`define FUNCT3_XORI             3'b100//
`define FUNCT3_ORI              3'b110//
`define FUNCT3_ANDI             3'b111//
`define FUNCT3_SLLI             3'b001//
`define FUNCT3_SRLI             3'b101//
`define FUNCT3_SRAI             3'b101//
// OP
// OP RV32I
`define FUNCT3_ADD              3'b000//
`define FUNCT3_SUB              3'b000//
`define FUNCT3_SLL              3'b001//
`define FUNCT3_SLT              3'b010//
`define FUNCT3_SLTU             3'b011//
`define FUNCT3_XOR              3'b100//
`define FUNCT3_SRL              3'b101//
`define FUNCT3_SRA              3'b101//
`define FUNCT3_OR               3'b110//
`define FUNCT3_AND              3'b111//
// OP RV32M
`define FUNCT3_MUL              3'b000
`define FUNCT3_MULH             3'b001
`define FUNCT3_MULHSU           3'b010
`define FUNCT3_MULHU            3'b011
`define FUNCT3_DIV              3'b100
`define FUNCT3_DIVU             3'b101
`define FUNCT3_REM              3'b110
`define FUNCT3_REMU             3'b111
// MISC_MEM
`define FUNCT3_FENCE            3'b000
`define FUNCT3_FENCE_I          3'b001  // Zifencei
// SYSTEM
`define FUNCT3_ECALL            3'b000
`define FUNCT3_EBREAK           3'b000
`define FUNCT3_CSRRS            3'b010  // Zicsr

// function7 inst[31:25](R-type)
// OP-IMM
`define FUNCT7_SLLI             7'b0000000
`define FUNCT7_SRLI             7'b0000000
`define FUNCT7_SRAI             7'b0100000
// OP RV32I
`define FUNCT7_ADD              7'b0000000
`define FUNCT7_SUB              7'b0100000
`define FUNCT7_SLL              7'b0000000
`define FUNCT7_SLT              7'b0000000
`define FUNCT7_SLTU             7'b0000000
`define FUNCT7_XOR              7'b0000000
`define FUNCT7_SRL              7'b0000000
`define FUNCT7_SRA              7'b0100000
`define FUNCT7_OR               7'b0000000
`define FUNCT7_AND              7'b0000000
// OP RV32M
`define FUNCT7_MUL              7'b0000001
`define FUNCT7_MULH             7'b0000001
`define FUNCT7_MULHSU           7'b0000001
`define FUNCT7_MULHU            7'b0000001
`define FUNCT7_DIV              7'b0000001
`define FUNCT7_DIVU             7'b0000001
`define FUNCT7_REM              7'b0000001
`define FUNCT7_REMU             7'b0000001