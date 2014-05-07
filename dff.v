module dff(q, d, en, rst_n, clk);
	input d, en, rst_n, clk;
	output reg q;

	always @(posedge clk, negedge rst_n) begin
		if(rst_n == 1'b0)
			q <= 0;
		else begin
			if(en) q <= d;
			else q <= q;
		end
	end

endmodule