`include "defines.v"
module hazard(
	opCode, 
  rdReg1_EX,
  rdReg2_EX,
  wrReg_EX,
  wrReg_MEM,
  wrReg_WB,
  reg1hazSel,
  reg2hazSel
);

  input [3:0] rdReg1_EX, rdReg2_EX, wrReg_EX, wrReg_MEM, wrReg_WB, opCode;
  output [1:0] reg1hazSel, reg2hazSel;

	wire [1:0] check;
	wire [1:0] haz1, haz2;

  assign haz1 = (rdReg1_EX == wrReg_MEM & rdReg1_EX != 4'h0) ? 2'b00 :
                (rdReg1_EX == wrReg_WB & rdReg1_EX != 4'h0) ? 2'b01 :
                2'b11;

  assign haz2 = (rdReg2_EX == wrReg_MEM & rdReg2_EX != 4'h0) ? 2'b00 :
                (rdReg2_EX == wrReg_WB &rdReg2_EX != 4'h0) ? 2'b01 :
                2'b11;

	assign check = (opCode == `LLB) ? 2'b11 :
                 (opCode == `JAL) ? 2'b11 :
                 (opCode == `HLT) ? 2'b11 :
                 (opCode == `B  ) ? 2'b11 :
                 2'b00;

	assign reg1hazSel = haz1 | check;
	assign reg2hazSel = haz2 | check;

endmodule
