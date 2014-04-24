module dff_3(q, d, en, rst_n, clk);
	input [2:0] d;
	input en, rst_n, clk;
	output reg [2:0] q;

	always @(posedge clk, negedge rst_n) begin
		if(rst_n) begin
			if(en) q <= d;
			else q <= q;
		end else q <= 0;
	end

endmodule
