module WB(
  memData, 
  aluResult, 
  mem2reg, 
  wrData,
	pc, 
	PCSrc
);
  input [15:0] memData, aluResult, pc;
  input mem2reg, PCSrc;
  output [15:0] wrData;
  
  assign wrData = (mem2reg == 1'b1) ? memData : 
                  //(PCSrc == 1'b1) ? pc + 1 : 
                  aluResult;
  
endmodule