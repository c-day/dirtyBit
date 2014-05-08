`include "defines.v"
module EX(
  pc, 
  instr,
  reg1, 
  reg2,
  //sextIn,  
  aluSrc, 
  aluOp, 
  shAmt, 
  aluResult,
  flags,
  targetAddr, 
	flagsIn
);

  input [15:0] pc, instr, reg1, reg2;
  //input [15:0] sextIn;
  input [3:0] aluOp, shAmt;
	input [2:0] flagsIn;
	input aluSrc;
  output [15:0] aluResult, targetAddr;
  output [2:0] flags;

  wire [15:0] src1;
  wire [15:0] offset;
  wire [15:0] input1, input2;
  
  //assign src1 = (aluSrc == 1'b1) ? reg2 : sextIn;
  assign src1 = (aluSrc == 1'b1) ? reg2 : 
										(instr[15:12] == `LW) ? {{12{instr[3]}}, instr[3:0]} :
										(instr[15:12] == `SW) ? {{12{instr[3]}}, instr[3:0]} :
										{{8{instr[7]}}, instr[7:0]};

	assign offset = (instr[15:12] == `B) ? {{7{instr[8]}}, instr[8:0]} : 
									(instr[15:12] == `JAL) ? {{4{instr[11]}}, instr[11:0]} :
									{{4{instr[11]}}, instr[11:0]};

  //assign targetAddr = (instr[15:12] != `JAL) ? aluResult : pc + offset + 1;
	assign targetAddr = aluResult;

	assign input1 = ((instr[15:12] == `B) | (instr[15:12] == `JAL)) ? pc + 1 : reg1;
	assign input2 = ((instr[15:12] == `B) | (instr[15:12] == `JAL)) ? offset : src1;

  ALU ALU(.dst(aluResult), .V(flags[0]), .Z(flags[1]), .N(flags[2]), .src0(input1), .src1(input2), .aluOp(aluOp), .shAmt(shAmt), .flagsIn(flagsIn), .instr(instr));

endmodule