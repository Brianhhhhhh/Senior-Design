module alu(jal_instr,jalr_instr,addr,mul_div,to_sub,src0,src1,alu_func1,alu_func2,alu_rslt,divide_stall);

//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions

///////////////////////////////////////////////////////////
// ALU.  Performs ADD, SUB, AND, NOR, SLL, SRL, or SRA  //
// based on func input.  Provides OV and ZR outputs.   //
// Arithmetic is saturating.                          //
///////////////////////////////////////////////////////
// Encoding of func[2:0] is as follows: //
// 000 ==> ADD_SUB       to_sub == 1: SUB
// 001 ==> SLL
// 010 ==> SLT
// 011 ==> SLTU
// 100 ==> XOR
// 101 ==> SRL/A         to_sub == 1: Arithmetic
// 110 ==> OR
// 111 ==> AND

input jal_instr;				// 1 for JAL instruction
input jalr_instr;				// 1 for JALR instruction
input [31:0] addr;
input mul_div;                  // 1 for MUL/DIV instruction
input to_sub;                   // 1 for SUB/SRA instruction
input [31:0] src0,src1;         // data input sources
input func_code_t alu_func1;	// selects fundamental functions to perform
input MUL_DIV_t alu_func2;	    // selects MUL/DIV functions to perform
output [31:0] alu_rslt;			// computation result
output divide_stall;			// computation result



logic [31:0] sum;		        // output of adder
logic [4:0] shamt;				// shift result
logic shft_in;
logic [31:0] shft_r1,shft_r2,shft_r4,shft_r8;
logic [31:0] shft_r_rslt;       // output of shift right
logic [31:0] src1_2s_cmp;       // 2's complement format of src1
logic [31:0] dst_I, dst_MD;     // temperary result to be selected

logic [32:0] mul_src0, mul_src1;// 33 bit multiplicand, extra 1 bit for sign extension
logic [64:0] mul_rslt;          // 65 bit product to be selected depending on functions

logic [31:0] div_src0, div_src1;// 32 bit operands for division
logic [31:0] signed_quo, signed_rem;          // 32 bit results for division
logic [31:0] unsigned_quo, unsigned_rem;          // 32 bit results for division

hardware_divide iHD(.clock(clk), .denom(div_src1), .numer(div_src0), ,quotient(unsigned_quo), .remain(unsigned_rem));
signed_hardware_divide iHD(.clock(clk), .denom(div_src1), .numer(div_src0), ,quotient(signed_quo), .remain(signed_rem));


/////////////////////////////////////////////////
// Implement 2s complement logic for subtract //
///////////////////////////////////////////////
assign src1_2s_cmp = (alu_func1==ADD_SUBf && to_sub) ? -src1 : src1;		// use 2's comp for sub

//////////////////////
// Implement adder //
////////////////////
assign sum = (jal_instr) ? src0 + 3'h4	:
			 (jalr_instr) ? addr + 3'h4	:
			 src0 + src1_2s_cmp;

////////////////////////////////////////////////////
// Decide Shift amount based on instruction type //
//////////////////////////////////////////////////
assign shamt = src1[4:0];

////////////////////////
// Implement shifter //
//////////////////////
assign shft_in = (alu_func1==SRL_Af && to_sub) ? src0[31] : 0;
assign shft_r1 = (shamt[0]) ? {shft_in,src0[31:1]} : src0;
assign shft_r2 = (shamt[1]) ? {{2{shft_in}},shft_r1[31:2]} : shft_r1;
assign shft_r4 = (shamt[2]) ? {{4{shft_in}},shft_r2[31:4]} : shft_r2;
assign shft_r8 = (shamt[3]) ? {{8{shft_in}},shft_r4[31:8]} : shft_r4;
assign shft_r_rslt = (shamt[4]) ? {{16{shft_in}},shft_r8[31:16]} : shft_r8;

///////////////////////////////
// Implement multiplication //
/////////////////////////////
assign mul_src0 = ((alu_func2==MULHSUf) || (alu_func2==MULHf)) ?    {src0[31], src0[31:0]} :        {1'b0, src0[31:0]};
assign mul_src1 = (alu_func2==MULHf)                           ?    {src0[31], src0[31:0]} :        {1'b0, src0[31:0]};
assign mul_rslt = mul_src0 * mul_src1;

assign div_src0 = ((alu_func2==DIVUf) || (alu_func2==REMUf))   ?    {1'b0, src0[31:0]}     :        {src0[31], src0[31:0]};
assign div_src1 = ((alu_func2==DIVUf) || (alu_func2==REMUf))   ?    {1'b0, src1[31:0]}     :        {src1[31], src1[31:0]};
// assign quo = div_src0 / div_src1;
// assign rem = div_src0 - (quo * div_src1);

///////////////////////////////////////////
// Now for multiplexing function of ALU //
/////////////////////////////////////////
assign dst_I  = (alu_func1==ADD_SUBf) ?  sum:
			    (alu_func1==SLLf)     ?  src0 << shamt      :
			    (alu_func1==SLTf)     ?  less_than_signed(src0, src1)  	:
			    (alu_func1==SLTUf)    ?  src0 < src1      	:
			    (alu_func1==XORf)     ?  src0 ^ src1    	:
			    (alu_func1==SRL_Af)   ?  shft_r_rslt    	:
			    (alu_func1==ORf)      ?  src0 | src1    	:
			    (alu_func1==ANDf)     ?  src0 & src1    	:        '0;

assign dst_MD = (alu_func2==MULf)     ?  mul_rslt[31:0] 	:
			    (alu_func2==MULHf)    ?  mul_rslt[63:32]	:
			    (alu_func2==MULHSUf)  ? mul_rslt[63:32] 	:
			    (alu_func2==MULHUf)   ? mul_rslt[63:32] 	:
			    (alu_func2==DIVf)     ?  signed_quo            	:
			    (alu_func2==DIVUf)    ?  unsigned_quo            	:
			    (alu_func2==REMf)     ?  signed_rem            	:
			    (alu_func2==REMUf)    ?  unsigned_rem            	:         '0;

assign alu_rslt = (mul_div) ? dst_MD :       dst_I;
assign divide_stall = (alu_func2==DIVf)  || (alu_func2==DIVUf) ;

endmodule
