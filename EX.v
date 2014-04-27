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
	PCSrc
);

  input [15:0] pc, instr, reg1, reg2;
  input [15:0] sextIn;
  input [3:0] aluOp, shAmt;
	input [2:0] flagsIn;
	input aluSrc;
  output [15:0] aluResult, targetAddr;
  output [2:0] flags;
	output PCSrc;

  wire [15:0] src1;
  wire [15:0] offset;


  wire N, Z, V, cmp;
	wire [2:0] branchOp;

	assign branchOp = instr[11:9];

  assign N = flagsIn[2];
  assign Z = flagsIn[1];
  assign V = flagsIn[0];

  assign cmp = (branchOp == `BNEQ & Z == 1'b0) ? 1'b1 :
                 (branchOp == `BEQ & Z == 1'b1) ? 1'b1 :
                 (branchOp == `BGT & Z == 1'b0 & N == 1'b0) ? 1'b1 :
                 (branchOp == `BLT & N == 1'b1) ? 1'b1 :
                 (branchOp == `BGTE & N == 1'b0) ? 1'b1 :
                 (branchOp == `BLTE & (N == 1'b1 | Z == 1'b1)) ? 1'b1 :
                 (branchOp == `BOVFL & V == 1'b1) ? 1'b1 :
                 (branchOp == `BUNCOND) ? 1'b1 :
                 1'b0;

  assign PCSrc = ((instr[15:12] == `B) & cmp) | (instr[15:12] == `JAL | instr[15:12] == `JR);

  
  assign src1 = (aluSrc == 1'b1) ? reg2 : sextIn;
  
  assign offset = (instr[15:12] == `B) ? {{6{instr[8]}}, instr[8:0]} : {{4{instr[11]}}, instr[11:0]};

  assign targetAddr = (instr[15:12] == `JR) ? aluResult : pc + offset + 1;

  ALU ALU(.dst(aluResult), .V(flags[0]), .Z(flags[1]), .N(flags[2]), .src0(reg1), .src1(src1), .aluOp(aluOp), .shAmt(shAmt), .flagsIn(flagsIn));

endmodule