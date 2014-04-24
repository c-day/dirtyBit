module dff(q, d, en, rst_n, clk);
	input d, en, rst_n, clk;
	output reg q;

	always @(posedge clk, negedge rst_n) begin
		if(rst_n) begin
			if(en) q <= d;
			else q <= q;
		end else q <= 0;
	end

endmodule