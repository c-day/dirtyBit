`include "defines.v"
module control(
  instr,
  rdEnReg1,
  rdEnReg2,
  wrRegEn,
  rdReg1,
  rdReg2,
  wrReg,
  memRd,
  memWr,
  aluOp,
  shAmt,
  mem2reg,
  sawBr,
  sawJ,
  aluSrc,
  hlt, 
	Z
);
  input [15:0] instr;
	input Z;
  output rdEnReg1, rdEnReg2, wrRegEn, memRd, memWr, mem2reg, sawBr, sawJ, aluSrc, hlt;
  output [3:0] rdReg1, rdReg2, wrReg, aluOp, shAmt;

  wire [3:0] opCode = instr[15:12];

	assign hlt = (opCode == `HLT) ? 1'b1 : 1'b0;

  assign rdEnReg1 = (opCode == `HLT) ? 1'b0 :
                    (opCode == `B  ) ? 1'b0 :
                    (opCode == `JAL) ? 1'b0 :
										1'b1;

  assign rdEnReg2 = (opCode == `ADD) ? 1'b1 :
                    (opCode == `ADDZ) ? 1'b1 :
                    (opCode == `SUB) ? 1'b1 :
                    (opCode == `AND) ? 1'b1 :
                    (opCode == `NOR) ? 1'b1 :
										(opCode == `JR ) ? 1'b1 :
										(opCode == `SW ) ? 1'b1 :
                    1'b0;

  assign wrRegEn = (opCode == `HLT) ? 1'b0 :
                   (opCode == `SW ) ? 1'b0 :
                   (opCode == `B  ) ? 1'b0 :
                   (opCode == `JR ) ? 1'b0 :
									 ((opCode == `ADDZ) & (Z == 1'b0)) ? 1'b0 :
                   1'b1;

  assign memRd = (opCode == `LW) ? 1'b1 : 1'b0;

  assign memWr = (opCode == `SW) ? 1'b1 : 1'b0;

  assign mem2Reg = memRd;

  assign sawBr = (opCode == `B) ? 1'b1 : 1'b0;

  assign sawJ = (opCode == `JAL) ? 1'b1 :
                (opCode == `JR ) ? 1'b1 :
                1'b0;

  assign rdReg1 = (opCode == `LHB) ? instr[11:8] :
                  (opCode == `LLB) ? 4'h0 :
									instr[7:4];

  assign rdReg2 = (opCode == `SW) ? instr[11:8] : 
									(opCode == `JR) ? 4'h0 :
									instr[3:0];

  assign wrReg = (opCode == `JAL) ? 4'hF :
								 (opCode == `SW ) ? 4'h0 :
                 (opCode == `B  ) ? 4'h0 :
                 (opCode == `JR ) ? 4'h0 :
                 (opCode == `HLT) ? 4'h0 :
                 instr[11:8];

  assign aluSrc = (opCode == `LLB) ? 1'b0 : 
                  (opCode == `SW ) ? 1'b0 :
									(opCode == `JR ) ? 1'b1 :
                  rdEnReg2;

  assign aluOp = (opCode == `ADD) ? `ALU_ADD :
                 (opCode == `ADDZ) ? `ALU_ADD :
                 (opCode == `SUB) ? `ALU_SUB :
                 (opCode == `SLL) ? `ALU_SLL :
                 (opCode == `SRA) ? `ALU_SRA :
                 (opCode == `SRL) ? `ALU_SRL :
                 (opCode == `AND) ? `ALU_AND :
                 (opCode == `NOR) ? `ALU_NOR :
                 (opCode == `LHB) ? `ALU_LHB :
                 (opCode == `LLB) ? `ALU_ADD :
                 (opCode == `LW ) ? `ALU_ADD :
								 (opCode == `SW ) ? `ALU_ADD :
								 (opCode == `JR ) ? `ALU_ADD :
								 (opCode == `B  ) ? `ALU_ADD :
                 `ALU_NOP;

  assign shAmt = instr[3:0];

endmodule
