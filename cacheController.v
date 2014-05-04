module cacheController(instr, instr_rdy, i_addr, clk, rst_n);
	input clk, rst_n;
	input [15:0] i_addr;
	output reg instr_rdy;
	output [15:0] instr;

localparam IDLE = 1'b0;
localparam INSTR_RD = 1'b1;

wire [63:0] i_fullLine, mem_data, fullLine;
wire i_hit, mem_rdy;

reg state, nextState;

reg mem_rd, mem_wr, icache_we, use_mem;
wire [13:0] mem_addr;

assign fullLine = (use_mem == 1'b1) ? mem_data : i_fullLine;

assign mem_addr = i_addr[15:2];

/////////////////////////////////////////  Mux iCache output //////////////////////////////////////
assign instr =	(i_addr[1:0] == 2'b00) ? fullLine[15:0]  :
								(i_addr[1:0] == 2'b01) ? fullLine[31:16] :
								(i_addr[1:0] == 2'b10) ? fullLine[47:32] :
								fullLine[63:48];

////////////////////////////////////////////  State Flop //////////////////////////////////////////
always @(posedge clk)
	if(rst_n == 1'b0)
		state <= IDLE;
	else
		state <= nextState;


////////////////////////////////////////// iCache controlling SM //////////////////////////////////
always @(*) begin
	//nextState = IDLE;
	//mem_addr = i_addr[15:2];
	//instr_rdy = 1'b0;
	//mem_rd = 1'b0;
	//use_mem = 1'b0;

	case (state)

		IDLE: begin
			icache_we = 1'b0;
			use_mem = 1'b0;
			if (i_hit == 1'b0) begin //cache miss 
				instr_rdy = 1'b0;
				mem_rd = 1'b1;
				nextState = INSTR_RD;
			end else begin  //cache hit
				instr_rdy = 1'b1;
				mem_rd = 1'b0;
				nextState = IDLE;
			end 
		end

		INSTR_RD: begin
			if(mem_rdy == 1'b1) begin
				icache_we = 1'b1;
				mem_rd = 1'b0;
				instr_rdy = 1'b1;
				use_mem = 1'b1;
				nextState = IDLE;
			end else begin
				instr_rdy = 1'b0;
				mem_rd = 1'b1;
				icache_we = 1'b0;
				use_mem = 1'b0;
				nextState = INSTR_RD;
			end

		end


		default:
			nextState <= IDLE;

	endcase
end

/******************************* Instruction Cache, always read, never dirty, leave tag and dirty disconnected *************************/
cache icache(.clk(clk), .rst_n(rst_n), .addr(i_addr[15:2]), .wr_data(mem_data), .wdirty(1'b0), .we(icache_we), .re(1'b1), .rd_data(i_fullLine), .tag_out(), .hit(i_hit), .dirty());

/************************************************************* Unified Memory **********************************************************/
unified_mem mem(.clk(clk), .rst_n(rst_n), .addr(mem_addr), .re(mem_rd), .we(mem_wr), .wdata(), .rd_data(mem_data), .rdy(mem_rdy));

endmodule
