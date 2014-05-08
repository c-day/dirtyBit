`include "defines.v"
module cacheControl(data, instr, i_rdy, d_rdy, i_addr, d_addr, wr_data, mem_rd, mem_wr, clk, rst_n);
	input clk, rst_n, mem_rd, mem_wr;
	input [15:0] i_addr, d_addr, wr_data;
	output [15:0] data, instr;
	output reg i_rdy, d_rdy;
	
reg [1:0] state, nextState;

wire mem_rdy, i_hit, d_hit, dirty;
wire [7:0] dCache_tag;
wire [63:0] i_fullLine, d_fullLine, mem_data;
wire [63:0] instrLine, dataLine;

reg uMem_rd, uMem_wr, i_useMem, d_useMem;
reg iCache_wr, dCache_wr, wr_dirty;
reg [13:0] mem_addr;
reg [63:0] mem_wrData, dCache_wrData;

always @(posedge clk, negedge rst_n) begin
	if(rst_n  == 1'b0)
		state <= `IDLE;
	else
		state <= nextState;
end

/////////////////////////////////////////  Mux iCache output //////////////////////////////////////
assign instrLine = (i_useMem == 1'b0) ? i_fullLine : mem_data;

assign instr =	(i_addr[1:0] == 2'b00) ? instrLine[15:0]  :
								(i_addr[1:0] == 2'b01) ? instrLine[31:16] :
								(i_addr[1:0] == 2'b10) ? instrLine[47:32] :
								instrLine[63:48];

/////////////////////////////////////////  Mux dCache output //////////////////////////////////////
assign dataLine = (d_useMem == 1'b0) ? d_fullLine : mem_data;

assign data =	(d_addr[1:0] == 2'b00) ? dataLine[15:0]  :
							(d_addr[1:0] == 2'b01) ? dataLine[31:16] :
							(d_addr[1:0] == 2'b10) ? dataLine[47:32] :
							dataLine[63:48];

/******************************* Instruction Cache, always read, never dirty, leave tag and dirty disconnected *************************/
cache icache(.clk(clk), .rst_n(rst_n), .addr(i_addr[15:2]), .wr_data(mem_data), .wdirty(1'b0), .we(iCache_wr), .re(1'b1), .rd_data(i_fullLine), .tag_out(), .hit(i_hit), .dirty());

/******************************* Data Cache *************************/
cache dcache(.clk(clk), .rst_n(rst_n), .addr(d_addr[15:2]), .wr_data(dCache_wrData), .wdirty(wr_dirty), .we(dCache_wr), .re(1'b1), .rd_data(d_fullLine), .tag_out(dCache_tag), .hit(d_hit), .dirty(dirty));

unified_mem umem(.clk(clk), .rst_n(rst_n), .addr(mem_addr), .re(uMem_rd), .we(uMem_wr), .wdata(mem_wrData), .rd_data(mem_data), .rdy(mem_rdy));


always @(*) begin
	uMem_wr = 1'b0;
	uMem_rd = 1'b0;
	iCache_wr = 1'b0;
	dCache_wr = 1'b0;
	i_useMem = 1'b0;
	d_useMem = 1'b0;
	i_rdy = 1'b0;
	d_rdy = 1'b0;
	wr_dirty = 1'b0;
	mem_addr = 14'd0;
	dCache_wrData = 64'd0;
	mem_wrData = 64'd0;
	case (state)
		`IDLE: begin
				iCache_wr = 1'b0;
				dCache_wr = 1'b0;
				i_useMem = 1'b0;
				d_useMem = 1'b0;
				i_rdy = 1'b0;
				d_rdy = 1'b0;
				wr_dirty = 1'b0;
				mem_addr = d_addr[15:2];
				if(((~mem_rd & ~mem_wr) | d_hit) & ~i_hit) begin
					if(mem_wr) begin
						dCache_wr = 1'b1;
						wr_dirty = 1'b1;
						dCache_wrData = (d_addr[1:0] == 2'b00) ? {d_fullLine[63:16], wr_data}  :
												(d_addr[1:0] == 2'b01) ? {d_fullLine[63:32], wr_data, d_fullLine[15:0]} :
												(d_addr[1:0] == 2'b10) ? {d_fullLine[63:48], wr_data, d_fullLine[31:0]} :
												{wr_data, d_fullLine[47:0]};
						d_useMem = 1'b0;
					end
					i_rdy = 1'b0;
				  d_rdy = 1'b1;
				  uMem_rd = 1'b1;
				  mem_addr = i_addr[15:2];
				  nextState = `INSTR_RD;
				end else if((mem_rd | mem_wr) & ~d_hit) begin
				  i_rdy = 1'b0;
				  d_rdy = 1'b0;
				  if(dirty) begin
						uMem_wr = 1'b1;
						mem_addr = {dCache_tag, d_addr[5:0]};
						mem_wrData = d_fullLine;
				    nextState = `EVICT;
				  end else begin
						mem_addr = d_addr[15:2];
						uMem_rd = 1'b1;
				    nextState = `DATA_RD;
					end
				end else begin
					if(mem_wr) begin
							dCache_wr = 1'b1;
							wr_dirty = 1'b1;
							dCache_wrData = (d_addr[1:0] == 2'b00) ? {d_fullLine[63:16], wr_data}  :
												(d_addr[1:0] == 2'b01) ? {d_fullLine[63:32], wr_data, d_fullLine[15:0]} :
												(d_addr[1:0] == 2'b10) ? {d_fullLine[63:48], wr_data, d_fullLine[31:0]} :
												{wr_data, d_fullLine[47:0]};
							d_useMem = 1'b0;
					end
				  i_rdy = 1'b1;
				  d_rdy = 1'b1;
				  nextState = `IDLE;
				end
		end
		`INSTR_RD: begin
			if(mem_rdy) begin
		    i_rdy = 1'b1;
				iCache_wr = 1'b1;
				i_useMem = 1'b1;
		    nextState = `IDLE;
		  end else begin
		    i_rdy = 1'b0;
		    nextState = `INSTR_RD;
		  end
		end
		`EVICT: begin
			if(mem_rdy) begin
				nextState = `DATA_RD;
		  end else begin
		    nextState = `EVICT;
		  end
		end
		`DATA_RD: begin
			if(mem_wr) begin
				dCache_wr = 1'b1;
				wr_dirty = 1'b1;
				dCache_wrData = (d_addr[1:0] == 2'b00) ? {d_fullLine[63:16], wr_data}  :
												(d_addr[1:0] == 2'b01) ? {d_fullLine[63:32], wr_data, d_fullLine[15:0]} :
												(d_addr[1:0] == 2'b10) ? {d_fullLine[63:48], wr_data, d_fullLine[31:0]} :
												{wr_data, d_fullLine[47:0]};
				d_useMem = 1'b0;
				d_rdy = 1'b1;
				nextState = `IDLE;
			end else begin
				mem_addr = d_addr[15:2];
				uMem_rd = 1'b1;
				if(mem_rdy) begin
			  	d_rdy = 1'b1;
					dCache_wr = 1'b1;
					d_useMem = 1'b1;
			  	nextState = `IDLE;
				end else begin
			  	d_rdy = 1'b0;
			  	nextState = `DATA_RD;
				end
			end
		end
		default: 
			nextState = `IDLE;
	endcase
end

endmodule
