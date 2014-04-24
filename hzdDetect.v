`include "defines.v"
module hzdDet(reg1_fwdCtrl, reg2_fwdCtrl, rdReg1_ID, rdReg2_ID, wrReg_EX, wrReg_MEM, wrReg_WB, rdEn1_ID, rdEn2_ID, wrEn_EX, wrEn_MEM, wrEn_WB);
	input [3:0]
		rdReg1_ID, rdReg2_ID,
		wrReg_EX, wrReg_MEM, wrReg_WB;
	input rdEn1_ID, rdEn2_ID, wrEn_EX, wrEn_MEM, wrEn_WB;
	output [1:0] reg1_fwdCtrl, reg2_fwdCtrl;
	
	assign reg1_fwdCtrl = (rdReg1_ID == 4'h0) ? 4'hf :
														(rdReg1_ID == wrReg_EX  & rdEn1_ID & wrEn_EX ) ? `FWD_FROM_EX :
														(rdReg1_ID == wrReg_MEM & rdEn1_ID & wrEn_MEM) ? `FWD_FROM_MEM :
														(rdReg1_ID == wrReg_WB  & rdEn1_ID & wrEn_WB ) ? `FWD_FROM_WB :
														`NO_FWD;

	assign reg2_fwdCtrl = (rdReg2_ID == 4'h0) ? 4'hf :
														(rdReg2_ID == wrReg_EX  & rdEn2_ID & wrEn_EX ) ? `FWD_FROM_EX :
														(rdReg2_ID == wrReg_MEM & rdEn2_ID & wrEn_MEM) ? `FWD_FROM_MEM :
														(rdReg2_ID == wrReg_WB  & rdEn2_ID & wrEn_WB ) ? `FWD_FROM_WB :
														`NO_FWD;
																
endmodule