module IF(
  clk, 
  hlt,
  nRst,
  altAddress, 
  useAlt, 
  pc,
  instr
);

  input clk, hlt, useAlt, nRst;
  input [15:0] altAddress;
  output reg [15:0] pc;
	output [15:0] instr;
  
  wire [15:0] nextPc;
  wire [1:0] sel;
  
  assign nextPc = (useAlt == 1'b1) ? altAddress : pc + 1;
  assign sel = {nRst, hlt};
  
  always @(posedge clk, negedge nRst) begin
    case (sel)
      2'b10: pc <= nextPc;
      2'b11: pc <= pc;
      default: pc <= 16'd0;
    endcase
  end
  
  IM IM(.clk(clk), .addr(pc), .rd_en(1'b1), .instr(instr));
  
endmodule