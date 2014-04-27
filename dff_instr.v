
module dff_instr(q, d, en, rst_n, clk);
	input [15:0] d;
	input en, rst_n, clk;
	output reg [15:0] q;

	always @(posedge clk, negedge rst_n) begin
		if(rst_n) begin
			if(en) q <= d;
			else q <= q;
		end else q <= 16'hb000;
	end

endmodule