`include "defines.v"
module MEM(
  clk,
  memAddr,
  flags,
  wrData,
  memWr,
  memRd,
  branchOp,
  sawBr,
  sawJ,
  rdData,
  PCSrc
);
  input [15:0] memAddr, wrData;
  input [2:0] flags, branchOp;
  input memWr, memRd, clk, sawBr, sawJ;
  output [15:0] rdData;
  output PCSrc;

  wire N, Z, V, cmp;

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

  //DM DM(.clk(clk), .addr(memAddr), .re(memRd), .we(memWr), .wrt_data(wrData), .rd_data(rdData));

endmodule
