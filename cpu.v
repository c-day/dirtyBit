`include "defines.v"

/***********************************************************************************************************************/
//    WISC.S14 Architecture
//		ECE 552
//		Instructor: 
//			Eric Hoffman
//		Authors:
//			Craig Day
//			Ethan Massey
//		Team:
//			"HoffmansAngels"
//
/**********************************************************************************************************************/
module cpu(clk, rst_n, hlt, pc);
  input clk, rst_n;
  output hlt;
	output [15:0] pc;

  wire [2:0] flags_EX_FF, branchOp_EX_FF, branchOp_FF_MEM, flags_FF_MEM;

  wire [15:0] FWD_reg1, FWD_reg2;

  wire [15:0] pc_IF_FF, pc_FF_ID, instr_IF_FF, instr_FF_ID, instr_ID_FF, instr_FF_EX, cacheIout,
              sext_FF_EX, sext_ID_FF, aluResult_EX_FF, aluResult_FF_MEM, targetAddr_EX_FF,
              targetAddr_FF_MEM, rdData_MEM_FF, rdData_FF_WB, aluResult_MEM_FF, aluResult_FF_WB,
              wrData_WB_ID, reg1_ID_FF, reg1_FF_EX, reg2_ID_FF, reg2_FF_EX, reg2_EX_FF, reg2_FF_MEM,
							pc_FF_EX, pc_ID_FF, pc_EX_FF, pc_FF_MEM, pc_MEM_FF, pc_FF_WB, instr_FF_MEM, instr_EX_FF,
							cacheData, cacheDout, instr_cache_FF;

  wire [3:0]  wrReg_FF_EX, wrReg_ID_FF, wrReg_MUX_FF, opCode_FF_MEM, 
              wrReg_EX_FF, wrReg_FF_MEM, wrReg_MEM_FF, wrReg_FF_WB, aluOp_ID_FF, aluOp_FF_EX,
              shAmt_ID_FF, shAmt_FF_EX, rdReg1_ID_FF, rdReg2_ID_FF;

  wire [1:0] reg1hazSel, reg2hazSel;

  wire IF_ID_EN, ID_EX_EN, EX_MEM_EN, MEM_WB_EN, memRd_FF_EX, memRd_ID_FF, memWr_FF_EX, memWr_ID_FF,
        mem2reg_ID_FF, mem2reg_FF_EX, sawBr_ID_FF, sawBr_FF_EX, sawJ_ID_FF, sawJ_FF_EX, aluSrc_ID_FF,
        aluSrc_FF_EX, hlt_ID_FF, hlt_FF_EX, memRd_EX_FF, memRd_FF_MEM, memWr_EX_FF, mem2reg_EX_FF,
        sawBr_EX_FF, sawBr_FF_MEM, sawJ_EX_FF, hlt_EX_FF, mem2reg_MEM_FF, mem2reg_FF_WB, hlt_MEM_FF,
        wrRegEn_ID_FF, wrRegEn_FF_EX, wrRegEn_EX_FF, wrRegEn_FF_MEM, wrRegEn_MEM_FF, wrRegEn_FF_WB,
				rst_n_IF_ID, rst_n_ID_EX, PCSrc_FF_WB, rst_n_EX_MEM, rst_n_MEM_WB, hlt_FF_MEM, hlt_FF_WB,
				rdReg1En_ID, rdReg2En_ID, memRd_MUX_FF, memWr_MUX_FF, wrRegEn_MUX_FF, LW_Stall ,oldStall,
				pcStallHlt, PCSrc_MEM_IF, instr_rdy, data_rdy;

	assign IF_ID_EN = ~(hlt | LW_Stall | ~instr_rdy | ~data_rdy);
	assign ID_EX_EN = ~(hlt_FF_EX | ~instr_rdy | ~data_rdy);
	assign EX_MEM_EN = ~(hlt_FF_MEM | ~instr_rdy | ~data_rdy);
	assign MEM_WB_EN = ~(hlt | ~instr_rdy | ~data_rdy);

	assign rst_n_IF_ID = rst_n & ~PCSrc_MEM_IF;
	assign rst_n_ID_EX = rst_n & ~PCSrc_MEM_IF;
	assign rst_n_EX_MEM = rst_n;
	assign rst_n_MEM_WB = rst_n;

	assign pc = pc_FF_WB + 1;

	assign pcStallHlt = hlt | LW_Stall | ~instr_rdy | ~data_rdy;

////////////////////////////////////////////// Cache Controller and Unified mem.  They sit outside the pipelin ////////////////////////////////////////////
cacheControl cc(.data(cacheData), .instr(instr_cache_FF), .i_rdy(instr_rdy), .d_rdy(data_rdy), .i_addr(pc_IF_FF), .d_addr(aluResult_FF_MEM), .wr_data(reg2_FF_MEM), .mem_rd(memRd_FF_MEM), .mem_wr(memWr_FF_MEM), .clk(clk), .rst_n(rst_n));

IF IF(
  .clk(clk),
  .hlt(pcStallHlt),
  .nRst(rst_n),
  .altAddress(targetAddr_FF_MEM),
  .useAlt(PCSrc_MEM_IF),
  .pc(pc_IF_FF),
  .instr(instr_IF_FF) // not needed anymore with the caches
);


//////////////////////////////////////////////////  IF/ID flops ///////////////////////////////////////////////////////
dff_16 ff00(.q(pc_FF_ID), .d(pc_IF_FF), .en(IF_ID_EN), .rst_n(rst_n_IF_ID), .clk(clk));
dff_instr ff01(.q(instr_FF_ID), .d(instr_cache_FF), .en(IF_ID_EN), .rst_n(rst_n_IF_ID), .clk(clk));

ID ID(
  .i_clk(clk),
  .i_nRst(rst_n),
  .i_hlt(hlt),
  .i_instr(instr_FF_ID),
  .i_pc(pc_FF_ID),
  .i_wrReg(wrReg_FF_WB),
  .i_wrData(wrData_WB_ID),
  .i_wrEn(wrRegEn_FF_WB),
	.i_Z(flags_EX_FF[1]),
  .o_port0(reg1_ID_FF),
  .o_port1(reg2_ID_FF),
  .o_sext(sext_ID_FF),
  .o_instr(instr_ID_FF),
  .o_wrReg(wrReg_ID_FF),
  .o_memRd(memRd_ID_FF),
  .o_memWr(memWr_ID_FF),
  .o_aluOp(aluOp_ID_FF),
  .o_mem2reg(mem2reg_ID_FF),
  .o_sawBr(sawBr_ID_FF),
  .o_sawJ(sawJ_ID_FF),
  .o_aluSrc(aluSrc_ID_FF),
  .o_shAmt(shAmt_ID_FF),
  .o_rdReg1(rdReg1_ID_FF),
  .o_rdReg2(rdReg2_ID_FF),
  .o_hlt(hlt_ID_FF),
  .o_wrRegEn(wrRegEn_ID_FF),
	.o_rdReg1En(rdReg1En_ID),
	.o_rdReg2En(rdReg2En_ID)
);

hzdDet hzd(
	.reg1_fwdCtrl(reg1hazSel), 
	.reg2_fwdCtrl(reg2hazSel), 
	.rdReg1_ID(rdReg1_ID_FF), 
	.rdReg2_ID(rdReg2_ID_FF), 
	.rdEn1_ID(rdReg1En_ID), 
	.rdEn2_ID(rdReg2En_ID), 
	.wrReg_EX(wrReg_FF_EX), 
	.wrReg_MEM(wrReg_FF_MEM), 
	.wrReg_WB(wrReg_FF_WB), 
	.wrEn_EX(wrRegEn_FF_EX), 
	.wrEn_MEM(wrRegEn_FF_MEM), 
	.wrEn_WB(wrRegEn_FF_WB)
);

///////////////////////////////////////////// Data Forwarding Logic ///////////////////////////////////////////////////
assign FWD_reg1 = (reg1hazSel == `NO_FWD) ? reg1_ID_FF :
									(reg1hazSel == `FWD_FROM_EX) ? aluResult_EX_FF :
									(reg1hazSel == `FWD_FROM_MEM) ?
											(opCode_FF_MEM == `LW) ? cacheData : aluResult_FF_MEM : // is this line necessary? 
									(reg1hazSel == `FWD_FROM_WB) ? wrData_WB_ID :
									reg1_ID_FF;
									
assign FWD_reg2 = (reg2hazSel == `NO_FWD) ? reg2_ID_FF :
									(reg2hazSel == `FWD_FROM_EX) ? aluResult_EX_FF :
									(reg2hazSel == `FWD_FROM_MEM) ?
											(opCode_FF_MEM == `LW) ? cacheData : aluResult_FF_MEM : // is this line necessary? 
									(reg2hazSel == `FWD_FROM_WB) ? wrData_WB_ID :
									reg2_ID_FF;

// do we have a hazard and a LW instr? if so we need to stall the pipe and inject a no-op
assign LW_Stall = (((reg1hazSel == `FWD_FROM_EX) | (reg2hazSel == `FWD_FROM_EX)) & (instr_FF_EX[15:12] == `LW)) & ~oldStall;

dff stallTrack(.q(oldStall), .d(LW_Stall), .en(1'b1), .rst_n(1'b1), .clk(clk));
dff  lastWrRegEnFF(.q(lastWrRegEn), .d(wrRegEn_ID_FF), .en(1'b1), .rst_n(1'b1), .clk(clk));

/////////////////////////////////////////////// ID/EX passthrough /////////////////////////////////////////////////////
assign pc_ID_FF = pc_FF_ID;

/////////////////////////////////////////// No-op injection on stall //////////////////////////////////////////////////
assign memRd_MUX_FF 	= (LW_Stall) ? 1'b0 : memRd_ID_FF;
assign memWr_MUX_FF		= (LW_Stall) ? 1'b0 : memWr_ID_FF;
assign wrRegEn_MUX_FF = (LW_Stall) ? 1'b0 : (oldStall) ? lastWrRegEn : wrRegEn_ID_FF;
assign wrReg_MUX_FF		= (LW_Stall) ? 4'h0 : wrReg_ID_FF;

//////////////////////////////////////////////////  ID/EX flops ///////////////////////////////////////////////////////
dff_16 ff02(.q(pc_FF_EX), .d(pc_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));											// goes into EX stage
dff_16 ff03(.q(reg1_FF_EX), .d(FWD_reg1), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));										// goes into EX stage
dff_16 ff04(.q(reg2_FF_EX), .d(FWD_reg2), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));										// goes into EX stage
dff_instr ff05(.q(instr_FF_EX), .d(instr_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));						// goes into EX stage
dff_16 ff06(.q(sext_FF_EX), .d(sext_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));									// goes into EX stage ******************* Can we just sext in EX to remove this flop?**
dff_4  ff07(.q(wrReg_FF_EX), .d(wrReg_MUX_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));							// passed through to MEM stage, used in forwarding logic
dff_4  ff08(.q(aluOp_FF_EX), .d(aluOp_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));								// goes into EX stage ******************* If we have the intruction, is this needed? **
dff_4  ff09(.q(shAmt_FF_EX), .d(shAmt_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));								// goes into EX stage
dff    ff12(.q(memRd_FF_EX), .d(memRd_MUX_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));							// passed through to MEM stage
dff    ff13(.q(memWr_FF_EX), .d(memWr_MUX_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));							// passed through to MEM stage
dff    ff14(.q(mem2reg_FF_EX), .d(mem2reg_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));						// passed through to MEM stage
dff    ff15(.q(sawBr_FF_EX), .d(sawBr_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));								// passed through to MEM stage
dff    ff16(.q(sawJ_FF_EX), .d(sawJ_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));									// passed through to MEM stage
dff    ff17(.q(aluSrc_FF_EX), .d(aluSrc_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));							// goes into EX stage
dff    ff18(.q(hlt_FF_EX), .d(hlt_ID_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));										// passed through to MEM stage
dff    ff19(.q(wrRegEn_FF_EX), .d(wrRegEn_MUX_FF), .en(ID_EX_EN), .rst_n(rst_n_ID_EX), .clk(clk));					// passed through to MEM stage, used in forwarding logic


EX EX(
  .pc(pc_FF_EX),
  .instr(instr_FF_EX),
  .reg1(reg1_FF_EX),
  .reg2(reg2_FF_EX),
  .sextIn(sext_FF_EX),
  .aluSrc(aluSrc_FF_EX),
  .aluOp(aluOp_FF_EX),
  .shAmt(shAmt_FF_EX),
  .aluResult(aluResult_EX_FF),
  .flags(flags_EX_FF),
  .targetAddr(targetAddr_EX_FF),
	.flagsIn(flags_FF_MEM)
);

////////////////////////////////////////////// EX/MEM passthrough /////////////////////////////////////////////////////
assign wrReg_EX_FF = wrReg_FF_EX;
assign memRd_EX_FF = memRd_FF_EX;
assign memWr_EX_FF = memWr_FF_EX;
assign mem2reg_EX_FF = mem2reg_FF_EX;
assign sawBr_EX_FF = sawBr_FF_EX;
assign sawJ_EX_FF = sawJ_FF_EX;
assign hlt_EX_FF = hlt_FF_EX;
assign wrRegEn_EX_FF = wrRegEn_FF_EX;
assign reg2_EX_FF = reg2_FF_EX;
assign branchOp_EX_FF = instr_FF_EX[11:9];
assign pc_EX_FF = pc_FF_EX;
assign instr_EX_FF = instr_FF_EX;

////////////////////////////////////////////////// EX/MEM flops ///////////////////////////////////////////////////////
dff_16 ff20(.q(aluResult_FF_MEM), .d(aluResult_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));		// passed through to WB stage
dff_16 ff21(.q(targetAddr_FF_MEM), .d(targetAddr_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));	// sent back to IF for use in branch and jump
dff_16 ff22(.q(reg2_FF_MEM), .d(reg2_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));							// goes into MEM stage
dff_16 ff39(.q(pc_FF_MEM), .d(pc_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));									// passed through to WB stage
//dff_instr ff42(.q(instr_FF_MEM), .d(instr_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));					// used in our hazard detection unit ****************** Check Me (need whole instr?)*********
dff_4  ff42(.q(opCode_FF_MEM), .d(instr_EX_FF[15:12]), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));
dff_4  ff23(.q(wrReg_FF_MEM), .d(wrReg_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));						// passed through to WB stage
dff_3  ff24(.q(flags_FF_MEM), .d(flags_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));						// goes into MEM stage
dff_3  ff25(.q(branchOp_FF_MEM), .d(branchOp_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));			// goes into MEM stage
dff    ff26(.q(memRd_FF_MEM), .d(memRd_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));						// goes into MEM stage
dff    ff27(.q(memWr_FF_MEM), .d(memWr_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));						// goes into MEM stage
dff    ff28(.q(mem2reg_FF_MEM), .d(mem2reg_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));				// passed through to WB stage
dff    ff29(.q(sawBr_FF_MEM), .d(sawBr_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));						// goes into MEM stage
dff    ff30(.q(sawJ_FF_MEM), .d(sawJ_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));							// goes into MEM stage
dff    ff31(.q(hlt_FF_MEM), .d(hlt_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));								// passed through to WB stage
dff    ff32(.q(wrRegEn_FF_MEM), .d(wrRegEn_EX_FF), .en(EX_MEM_EN), .rst_n(rst_n_EX_MEM), .clk(clk));

// if we move our branch taken logic, can remove this whole module and all the flops going into it.  
MEM MEM(
  .clk(clk),
  .memAddr(aluResult_FF_MEM),
  .flags(flags_FF_MEM),
  .wrData(reg2_FF_MEM),
  .memWr(memWr_FF_MEM),
  .memRd(memRd_FF_MEM),
  .branchOp(branchOp_FF_MEM),
  .sawBr(sawBr_FF_MEM),
  .sawJ(sawJ_FF_MEM),
  .rdData(rdData_MEM_FF),
  .PCSrc(PCSrc_MEM_IF)
);

////////////////////////////////////////////// MEM/WB passthrough /////////////////////////////////////////////////////
assign wrReg_MEM_FF = wrReg_FF_MEM;
assign aluResult_MEM_FF = aluResult_FF_MEM;
assign mem2reg_MEM_FF = mem2reg_FF_MEM;
assign hlt_MEM_FF = hlt_FF_MEM;
assign wrRegEn_MEM_FF = wrRegEn_FF_MEM;
assign pc_MEM_FF = pc_FF_MEM;
assign PCSrc_MEM_FF = PCSrc_MEM_IF;

////////////////////////////////////////////////// MEM/WB flops ///////////////////////////////////////////////////////
dff_16 ff33(.q(rdData_FF_WB), .d(cacheData), .en(MEM_WB_EN), .rst_n(rst_n_MEM_WB), .clk(clk));							// goes into WB stage
dff_16 ff34(.q(aluResult_FF_WB), .d(aluResult_MEM_FF), .en(MEM_WB_EN), .rst_n(rst_n_MEM_WB), .clk(clk));		// goes into WB stage
dff_16 ff40(.q(pc_FF_WB), .d(pc_MEM_FF), .en(MEM_WB_EN), .rst_n(rst_n_MEM_WB), .clk(clk));									// goes into WB stage
dff_4  ff35(.q(wrReg_FF_WB), .d(wrReg_MEM_FF), .en(MEM_WB_EN), .rst_n(rst_n_MEM_WB), .clk(clk));						// goes back to ID stage where the reg file lives
dff    ff36(.q(mem2reg_FF_WB), .d(mem2reg_MEM_FF), .en(MEM_WB_EN), .rst_n(rst_n_MEM_WB), .clk(clk));				// goes int WB stage
dff    ff37(.q(hlt), .d(hlt_MEM_FF), .en(MEM_WB_EN), .rst_n(rst_n_MEM_WB), .clk(clk));											// halts the whole darn thing when a halt makes it this far
dff    ff38(.q(wrRegEn_FF_WB), .d(wrRegEn_MEM_FF), .en(MEM_WB_EN), .rst_n(rst_n_MEM_WB), .clk(clk));				// goes back to ID stage where the reg file lives
dff    ff41(.q(PCSrc_FF_WB), .d(PCSrc_MEM_FF), .en(MEM_WB_EN), .rst_n(rst_n_MEM_WB), .clk(clk));						// goes into WB stage

WB WB(
  .memData(rdData_FF_WB),
  .aluResult(aluResult_FF_WB),
  .mem2reg(mem2reg_FF_WB),
  .wrData(wrData_WB_ID), 
	.pc(pc_FF_WB),
	.PCSrc(PCSrc_FF_WB)
);

endmodule
