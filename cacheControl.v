`include "defines.v"
module cacheControl(data, instr, i_rdy, d_rdy, i_addr, d_addr, data_rd, data_wr, clk, rst_n);
	input clk, rst_n, data_rd, data_wr;
	input [15:0] i_addr, d_addr;
	output [15:0] data, instr;
	output reg i_rdy, d_rdy;
	
reg [1:0] state, nextState;

wire i_hit, d_hit, d_dirty, mem_rdy;
wire [15:0] det_addr;
wire [63:0] mem_data, i_fullLine, d_fullLine, fullLine;

reg iCache_we, dCache_we, dCache_rd, dCache_dirty, i_useMem, d_useMem, uMem_rd, uMem_wr, useDataAddr, memRd_corrected, memWr_corrected;
reg [63:0] d_wrData;

always @(posedge clk, negedge rst_n) begin
	if(rst_n  == 1'b0)
		state <= `IDLE;
	else
		state <= nextState;
end

always @(negedge rst_n) begin
	d_rdy = 1'b0;
	i_rdy = 1'b0;
end

assign fullLine = (i_useMem == 1'b0) ? i_fullLine : mem_data;

/////////////////////////////////////////  Mux iCache output //////////////////////////////////////
assign instr =	(i_addr[1:0] == 2'b00) ? fullLine[15:0]  :
								(i_addr[1:0] == 2'b01) ? fullLine[31:16] :
								(i_addr[1:0] == 2'b10) ? fullLine[47:32] :
								fullLine[63:48];

//Cache
//input [13:0] addr;		// address to be read or written, 2-LSB's are dropped
//input [63:0] wr_data;	// 64-bit cache line to write
//input wdirty;			// dirty bit to be written
//input we;				// write enable for cache line
//input re;				// read enable (for power purposes only)

/******************************* Instruction Cache, always read, never dirty, leave tag and dirty disconnected *************************/
cache icache(.clk(clk), .rst_n(rst_n), .addr(i_addr[15:2]), .wr_data(mem_data), .wdirty(1'b0), .we(iCache_we), .re(1'b1), .rd_data(i_fullLine), .tag_out(), .hit(i_hit), .dirty());

/******************************* Data Cache *************************/
cache dcache(.clk(clk), .rst_n(rst_n), .addr(d_addr[15:2]), .wr_data(d_wrData), .wdirty(dCache_dirty), .we(dCache_we), .re(1'b1), .rd_data(d_fullLine), .tag_out(), .hit(d_hit), .dirty(d_dirty));


//Unified memory
//input re,we;
//input [13:0] addr;				// 2 LSB's are dropped since accessing as four 16-bit words
//input [63:0] wdata;
assign det_addr = useDataAddr ? d_addr : i_addr;
unified_mem umem(.clk(clk), .rst_n(rst_n), .addr(det_addr[15:2]), .re(uMem_rd), .we(uMem_wr), .wdata(d_fullLine), .rd_data(mem_data), .rdy(mem_rdy));


always @(*) begin
	//i_rdy = 1'b1;//
	d_rdy = 1'b1;//
	//iCache_we = 1'b0;//
	//dCache_we = 1'b0;//
	//dCache_rd = 1'b0;//
	//dCache_dirty = 1'b0;//
	//i_useMem = 1'b0;//
	//d_useMem = 1'b0;//
	//uMem_rd = 1'b0;//
	//uMem_wr = 1'b0;//
	useDataAddr = 1'b0;//
	//memRd_corrected = 1'b0;
	//memWr_corrected = 1'b0;
	case (state)
		`IDLE: begin
				i_useMem = 1'b0;
				d_useMem = 1'b0;
				if (data_rd | data_wr) begin
					iCache_we = 1'b0;
					//useDataAddr = 1'b1;
					if(d_hit) begin
						dCache_we = 1'b0;
						dCache_dirty = data_wr;
						uMem_rd = 1'b0;
						uMem_wr = 1'b0;
						nextState = `IDLE;
					end else begin
						dCache_dirty = 1'b0;
						//d_rdy = 1'b0;
						if(d_dirty) begin
							uMem_wr = data_wr;
							uMem_rd = data_rd;
							dCache_we = 1'b0;
							nextState = `EVICT;
						end else begin
							uMem_wr = 1'b0;
							uMem_rd = data_rd;
							dCache_we = 1'b1;
							nextState = `DATA_RD;
						end
					end
				end else begin
					dCache_dirty = 1'b0;
					uMem_wr = 1'b0;
					useDataAddr = 1'b0;
					memRd_corrected = data_rd;
					memWr_corrected = data_wr;
					if(i_hit) begin
						i_rdy = 1'b1;
						i_useMem = 1'b0;
						iCache_we = 1'b0;
						uMem_rd = 1'b0;
						nextState = `IDLE;
					end else begin
						i_rdy = 1'b0;
						iCache_we = 1'b1;
						uMem_rd = 1'b1;
						nextState = `INSTR_RD;
					end
				end
		end
		`INSTR_RD: begin
				uMem_wr = 1'b0;
				i_useMem = 1'b1;
				if (mem_rdy) begin
					i_rdy = 1'b1;
					uMem_rd = 1'b0;
					iCache_we = 1'b1;
					nextState = `IDLE;
				end else begin
					i_rdy = 1'b0;
					uMem_rd = 1'b1;
					iCache_we = 1'b0;
					nextState = `INSTR_RD;
				end
		end
		`EVICT: begin
				uMem_rd = 1'b0;
				if (mem_rdy) begin
					uMem_wr = 1'b0;
					nextState = `DATA_RD;
				end else begin
					uMem_wr = 1'b1;
					nextState = `EVICT;
				end
		end
		`DATA_RD: begin
				d_useMem = 1'b1;
				uMem_wr = 1'b0;
				if (mem_rdy) begin
					uMem_rd = 1'b0;
					dCache_we = 1'b1;
					memRd_corrected = 1'b0;
					memWr_corrected = 1'b0;
					nextState = `IDLE;
				end else begin
					uMem_rd = 1'b1;
					dCache_we = 1'b0;
					nextState = `DATA_RD;
				end
		end
		default: 
			nextState = `IDLE;
	endcase
end



endmodule
