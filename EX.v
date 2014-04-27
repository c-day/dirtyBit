`include "defines.v"
module EX(
  pc, 
  instr,
  reg1, 
  reg2,
  sextIn,  
  aluSrc, 
  aluOp, 
  shAmt, 
  aluResult,
  flags,
  targetAddr, 
	flagsIn,

	branchOp,
	sawBr,
	sawJ,
	PCSrc
);

  input [15:0] pc, instr, reg1, reg2;
  input [15:0] sextIn;
  input [3:0] aluOp, shAmt;
	input [2:0] flagsIn;
	input aluSrc;
  output [15:0] aluResult, targetAddr;
  output [2:0] flags;

  wire [15:0] src1;
  wire [15:0] offset;

	input sawJ, sawBr;
	input [2:0] branchOp;
	output PCSrc;

	wire cmp;




  assign N = flags[2];
  assign Z = flags[1];
  assign V = flags[0];

  assign cmp = (branchOp == `BNEQ & Z == 1'b0) ? 1'b1 :
                 (branchOp == `BEQ & Z == 1'b1) ? 1'b1 :
                 (branchOp == `BGT & Z == 1'b0 & N == 1'b0) ? 1'b1 :
                 (branchOp == `BLT & N == 1'b1) ? 1'b1 :
                 (branchOp == `BGTE & N == 1'b0) ? 1'b1 :
                 (branchOp == `BLTE & (N == 1'b1 | Z == 1'b1)) ? 1'b1 :
                 (branchOp == `BOVFL & V == 1'b1) ? 1'b1 :
                 (branchOp == `BUNCOND) ? 1'b1 :
                 1'b0;

  assign PCSrc = (sawBr & cmp) | sawJ;



  
  assign src1 = (aluSrc == 1'b1) ? reg2 : sextIn;
  
  assign offset = (instr[15:12] == `B) ? {{6{instr[8]}}, instr[8:0]} : {{4{instr[11]}}, instr[11:0]};

  assign targetAddr = (instr[15:12] == `JR) ? aluResult : pc + offset + 1;

  ALU ALU(.dst(aluResult), .V(flags[0]), .Z(flags[1]), .N(flags[2]), .src0(reg1), .src1(src1), .aluOp(aluOp), .shAmt(shAmt), .flagsIn(flagsIn));

endmodule