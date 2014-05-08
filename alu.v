`include "defines.v"
module ALU(dst, V, Z, N, src0, src1, aluOp, shAmt, flagsIn, updateFlagsOnAdd);
  input [15:0] src0, src1;
	input [3:0] aluOp;
	input [3:0] shAmt;
	input [2:0] flagsIn;
	input updateFlagsOnAdd;
	output [15:0] dst;
	output V, Z, N;
	
	wire [15:0] temp;
	wire [15:0] saturated;
	wire tempV, tempZ, tempN;
	wire [15:0] realSra;

	wire [15:0] twosSrc1;
	
	assign twosSrc1 = (~src1+1);

	//sraFix sra(realSra, src0, shAmt); 
	
	//perform all alu operation, unsaturated arithmatic
	assign 	temp = (aluOp == `ALU_ADD) ? src0 + src1 :
					  		 (aluOp == `ALU_SUB) ? src0 + twosSrc1 :
								 (aluOp == `ALU_AND) ? src0 & src1 :
								 (aluOp == `ALU_NOR) ? ~(src0 | src1) :
								 (aluOp == `ALU_SLL) ? src0 << shAmt :
								 (aluOp == `ALU_SRL) ? src0 >> shAmt :
								 //(aluOp == `ALU_SRA) ? realSra :	
								 (aluOp == `ALU_SRA) ? $signed($signed(src0) >>> shAmt) :	
								 (aluOp == `ALU_LHB) ? {src1[7:0], src0[7:0]} :
								 16'd0;
	
  //check for positive or negative overflow
  assign posOV = (aluOp == `ALU_SUB) ? ~src0[15] & ~twosSrc1[15] & temp[15] : ~src0[15] & ~src1[15] & temp[15];
  assign negOV = (aluOp == `ALU_SUB) ? src0[15] & twosSrc1[15] & ~temp[15] : src0[15] & src1[15] & ~temp[15];
  
  
  
  //if we have overflow, saturate our values
  assign saturated = ({posOV, negOV} == 2'b00) ? temp :      //no overflow
                     ({posOV, negOV} == 2'b01) ? 16'h8000 :  //neg overflow
                     ({posOV, negOV} == 2'b10) ? 16'h7FFF :  //pos overflow
                     16'hFFFF;                               //shouldn't happen
      
  //if we did addition or subtraction, use the saturaed value
  assign dst = (aluOp == `ALU_ADD) ? saturated :
               (aluOp == `ALU_SUB) ? saturated :
               (aluOp == `ALU_NOP) ? dst :
               temp;
               
	//set our zero flag 	//assign tempZ = ~| dst;
 
 	//set our overflow flag
  assign tempV =  ({posOV, negOV} == 2'b01) ? 1'b1 :        //neg overflow
                  ({posOV, negOV} == 2'b10) ? 1'b1 :        //pos overflow
                  1'b0; 
              
  //set the negative flag
  assign tempN = dst[15];
               
  //set the zero flag if all bits are zero
  assign Z = (aluOp == `ALU_ADD & updateFlagsOnAdd) ? ~|dst :
					   (aluOp == `ALU_SUB) ? ~|dst :
						 (aluOp == `ALU_AND) ? ~|dst :
						 (aluOp == `ALU_NOR) ? ~|dst :
						 (aluOp == `ALU_SLL) ? ~|dst :
						 (aluOp == `ALU_SRL) ? ~|dst :
						 (aluOp == `ALU_SRA) ? ~|dst :
						 flagsIn[1];
		
	// set the overflow flag on adds and subs			 
	assign V = (aluOp == `ALU_ADD & updateFlagsOnAdd) ? tempV :
	           (aluOp == `ALU_SUB) ? tempV :
	           flagsIn[0];
	           
	// set the negative flag on adds and subs
	assign N = (aluOp == `ALU_ADD & updateFlagsOnAdd) ? tempN :
	           (aluOp == `ALU_SUB) ? tempN :
	           flagsIn[2];
	           
endmodule

/*
module sraFix(out, in, amt);
  input [15:0] in;
  input [3:0] amt;
  output [15:0] out;

  assign out = (amt == 4'b0000) ? in :
               (amt == 4'b0001) ? {in[15], in[15:1]} : 
               (amt == 4'b0010) ? {{2{in[15]}}, in[15:2]} :    
               (amt == 4'b0011) ? {{3{in[15]}}, in[15:3]} :  
               (amt == 4'b0100) ? {{4{in[15]}}, in[15:4]} :
               (amt == 4'b0101) ? {{5{in[15]}}, in[15:5]} :
               (amt == 4'b0110) ? {{6{in[15]}}, in[15:6]} :
               (amt == 4'b0111) ? {{7{in[15]}}, in[15:7]} :
               (amt == 4'b1000) ? {{8{in[15]}}, in[15:8]} :
               (amt == 4'b1001) ? {{9{in[15]}}, in[15:9]} :
               (amt == 4'b1010) ? {{10{in[15]}}, in[15:10]} :
               (amt == 4'b1111) ? {{11{in[15]}}, in[15:11]} :
               (amt == 4'b1100) ? {{12{in[15]}}, in[15:12]} :
               (amt == 4'b1101) ? {{13{in[15]}}, in[15:13]} :
               (amt == 4'b1110) ? {{14{in[15]}}, in[15:14]} :
               {{15{in[15]}}, in[15:2]};
               
endmodule
*/            