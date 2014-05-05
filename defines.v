//Define the opcodes used in our instruction decoder
`define ADD  4'b0000
`define ADDZ 4'b0001
`define SUB  4'b0010
`define AND  4'b0011
`define NOR  4'b0100
`define SLL  4'b0101
`define SRL  4'b0110
`define SRA  4'b0111
`define LW   4'b1000
`define SW   4'b1001
`define LHB  4'b1010
`define LLB  4'b1011
`define B    4'b1100
`define JAL  4'b1101
`define JR   4'b1110
`define HLT  4'b1111

//Define the codes sent the the alu
`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_AND 4'b0010
`define ALU_NOR 4'b0011
`define ALU_SLL 4'b0100
`define ALU_SRL 4'b0101
`define ALU_SRA 4'b0110
`define ALU_LHB 4'b0111
`define ALU_NOP 4'b1111

//Define the codes used for branch logic
`define BNEQ    3'b000
`define BEQ     3'b001
`define BGT     3'b010
`define BLT     3'b011
`define BGTE    3'b100
`define BLTE    3'b101
`define BOVFL   3'b110
`define BUNCOND 3'b111

//Define the codes for hazard/forwarding logic
`define NO_FWD  			2'b00
`define FWD_FROM_EX		2'b01
`define FWD_FROM_MEM	2'b10
`define FWD_FROM_WB		2'b11

//Cache control states
`define IDLE					2'b00
`define INSTR_RD			2'b01
`define EVICT					2'b10
`define DATA_RD				2'b11
