module IF(
  clk, 
  hlt,
  nRst,
  altAddress, 
  useAlt, 
  pc
);

  input clk, hlt, useAlt, nRst;
  input [15:0] altAddress;
  output reg [15:0] pc;

  wire [15:0] nextPc;
  
  assign nextPc = (useAlt == 1'b1) ? altAddress : pc + 1;
  
  always @(posedge clk, negedge nRst) begin
    if(nRst == 1'b0)
			pc <= 0;
		else begin
			if(hlt) pc <= pc;
			else pc <= nextPc;
		end
  end
  
endmodule