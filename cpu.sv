module cpu(clk,rst_n,ecall,rdata,boot_we,boot_waddr,boot_wdata,addr,re,we,wdata, boot_en);


//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions


input clk,rst_n;
input [31:0] rdata;								// exteral data input from the switches, 16'hDEAD if addr != 16'hC001

//bootloader interface
input boot_we;
input [14:0] boot_waddr;
input [31:0] boot_wdata;

input boot_en;
output ecall;									// end of call, exit if high
output [31:0] addr;								// rename dst_EX_DM to addr as a top level port
output re;										// rename dm_re_EX_DM to re as a top level port
output we;										// rename dm_we_EX_DM to we as a top level port
output [31:0] wdata;							// rename p0_EX_DM to wdata as a top level port

//////////////////////////////////
// Intermediate Logic ////////////
//////////////////////////////////
logic [31:0] addr_cur_IF;							// pc address in IF
logic [31:0] instr_IF;								// instruction IF
logic [31:0] imm_ID;								// sign extended immediates ID
logic stall_p0, stall_p1, stall;					// stall logic

// control signal from ID
logic [31:0] addr_cur_ID;							// pc address in ID
logic [31:0] instr_ID;								// instruction ID
logic [31:0] br_addr_ID;								// branch address
logic mul_div_ID;                                     // if the instruction is mul/div
logic to_sub_ID;                                      // if the instruction is sub/sra
logic br_instr_ID;                                    // if the instruction is branch
logic jal_instr_ID;                                   // JAL jump
logic jalr_instr_ID;                                  // JALR jump
logic rf_re0_ID;                                      // reg file read enable 0
logic rf_re1_ID;                                      // reg file read enable 1
logic rf_we_ID;                                       // reg file write enable
logic [4:0] rf_p0_addr_ID;                            // reg file port 0 address
logic [4:0] rf_p1_addr_ID;                            // reg file port 1 address
logic [4:0] rf_dst_addr_ID;                           // reg file write address
func_code_t alu_func1_ID;                       	   // ALU fundamental function
MUL_DIV_t alu_func2_ID;                         	   // ALU EXTENDED function (MUL & DIV)
wrd_size_t word_size_ID; 							   // word size for LD/STR
br_code_t br_cc_ID;								   // branch condition code
src0sel_t src0sel_ID;                           	   // src 0 select
src1sel_t src1sel_ID;                           	   // src 1 select
logic dm_re_ID;                                 	   // data memory read enable
logic dm_we_ID;                                       // data memory write enable
logic [31:0] p0_ID,p1_ID;								   // data out from reg file ports
logic [31:0] src0_ID,src1_ID;							   // input sources for ALU
//forwarding
logic [31:0] p0_ID_temp,p1_ID_temp;						// input sources for ALU


// control signal from EX
logic [31:0] p1_EX;								   // data out from reg file ports
logic [31:0] instr_EX;								// instruction EX
logic [31:0] addr_cur_EX;							// pc address in EX
logic [31:0] src0_EX,src1_EX;						// input sources for ALU
logic [31:0] alu_rslt_EX;								// alu result
logic mul_div_EX;                                     // if the instruction is mul/div
logic to_sub_EX;                                      // if the instruction is sub/sra
logic jal_instr_EX;                                   // JAL jump
logic jalr_instr_EX;                                  // JALR jump
logic rf_we_EX;                                       // reg file write enable
logic [4:0] rf_dst_addr_EX;                           // reg file write address
func_code_t alu_func1_EX;                       	   // ALU fundamental function
MUL_DIV_t alu_func2_EX;                         	   // ALU EXTENDED function (MUL & DIV)
wrd_size_t word_size_EX; 							   // word size for LD/STR
logic dm_re_EX;                                 	   // data memory read enable
logic dm_we_EX;                                       // data memory write enable
logic rf_re0_EX;
logic rf_re1_EX;

logic [4:0] rf_p0_addr_EX;
logic [4:0] rf_p1_addr_EX;


// control signal from DM
logic [31:0] instr_DM;
logic [31:0] alu_rslt_DM;
logic [31:0] p1_DM;
logic [4:0] rf_dst_addr_DM;
logic rf_we_DM;
logic dm_re_DM;
logic dm_we_DM;
wrd_size_t word_size_DM;
logic [31:0] mem_data_DM;							   // data loaded from memory
logic [4:0] rf_p1_addr_DM;
logic [31:0] addr_cur_DM;


// control signal from WB
logic [31:0] dst_WB;								   // reg file dst data value to be written into reg file
logic dm_re_WB;
logic [4:0] rf_dst_addr_WB;
logic [31:0] mem_data_WB;
logic [31:0] alu_rslt_WB;
logic [31:0] dst_data_WB;
logic rf_we_WB;										   // reg file dst write enable
logic [31:0] addr_cur_WB;

logic [31:0] mem_data_DM_immediate;

logic divide_stall;
logic divide_op;
logic [14:0] dm_addr;
logic [31:0] dm_wdata;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////// Instruction Fetch ////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////
// Instantiate program counter //
////////////////////////////////
pc iPC(.clk(clk), .rst_n(rst_n), .stall(stall||divide_stall), .boot_en(boot_en), .flow_change(flow_change_ID),.br_addr(br_addr_ID),.pc(addr_cur_IF));

/////////////////////////////////////
// Instantiate instruction memory //
///////////////////////////////////
// iaddr only use lower 14 bits because it's a 16KB IM
IM iIM(.clk(clk), .addr(addr_cur_IF[14:2]), .rd_en(!ecall), .we(boot_we), .waddr(boot_waddr[14:2]), .wdata(boot_wdata), .instr(instr_IF));

pipeline_IF_ID #(.PIPE_EN(1)) iIF_ID (.clk(clk), .rst_n(rst_n), .flush(flow_change_ID && !stall), .stall(stall || divide_stall), .addr_i(addr_cur_IF),.instr_i(instr_IF),.addr_o(addr_cur_ID),.instr_o(instr_ID));
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////// Instruction Decode ///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////
// Instantiate immediate decode ////
///////////////////////////////////
imm_decoder iImm_dec(.instr(instr_ID), .imm(imm_ID));

/////////////////////////////////////
// Instantiate instruction decode //
///////////////////////////////////
id iId(.instr(instr_ID),.mul_div(mul_div_ID),.to_sub(to_sub_ID),.br_instr(br_instr_ID),.jal_instr(jal_instr_ID),.jalr_instr(jalr_instr_ID),.rf_re0(rf_re0_ID),
		.rf_re1(rf_re1_ID),.rf_we(rf_we_ID),.rf_p0_addr(rf_p0_addr_ID),.rf_p1_addr(rf_p1_addr_ID),.rf_dst_addr(rf_dst_addr_ID),
		.alu_func1(alu_func1_ID),.alu_func2(alu_func2_ID),.word_size(word_size_ID),.br_cc(br_cc_ID),.src0sel(src0sel_ID),.src1sel(src1sel_ID),.dm_re(dm_re_ID),.dm_we(dm_we_ID));

////////////////////////////////
// Instantiate register file //
//////////////////////////////
rf iRF(.clk(clk), .rst_n(rst_n), .p0_addr(rf_p0_addr_ID),.p1_addr(rf_p1_addr_ID),.re0(rf_re0_ID),.re1(rf_re1_ID),.dst_addr(rf_dst_addr_WB),
	   .dst(dst_WB),.we(rf_we_WB),.p0(p0_ID_temp),.p1(p1_ID_temp));

///////////////////////////////////
// Instantiate register src mux //
/////////////////////////////////
src_mux ISRC_MUX(.src0sel(src0sel_ID),.src1sel(src1sel_ID),.p0(p0_ID),.p1(p1_ID),.pc(addr_cur_ID),.imm(imm_ID),.src0(src0_ID),.src1(src1_ID));

/////////////////////////////////////////////
// Instantiate branch determination logic //
///////////////////////////////////////////
br_bool iBRL(.jal_instr(jal_instr_ID),.stall(stall || divide_stall),.jalr_instr(jalr_instr_ID),.br_instr(br_instr_ID),.br_cc(br_cc_ID),.src0(src0_ID),.src1(src1_ID),.imm(imm_ID),.pc(addr_cur_ID),
				.flow_change(flow_change_ID),.br_addr(br_addr_ID));


pipeline_ID_EX #(.PIPE_EN(1)) iID_EX (.clk(clk),.rst_n(rst_n),.stall(stall || divide_stall),.instr_i(instr_ID),.p1_i(p1_ID),.addr_i(addr_cur_ID),.src0_i(src0_ID),.src1_i(src1_ID),
										.mul_div_i(mul_div_ID),.to_sub_i(to_sub_ID),.jal_instr_i(jal_instr_ID),.jalr_instr_i(jalr_instr_ID),.rf_we_i(rf_we_ID),
										.rf_dst_addr_i(rf_dst_addr_ID),.alu_func1_i(alu_func1_ID),.alu_func2_i(alu_func2_ID),.word_size_i(word_size_ID),.dm_re_i(dm_re_ID),
										.dm_we_i(dm_we_ID),.rf_p0_addr_i(rf_p0_addr_ID),.rf_p1_addr_i(rf_p1_addr_ID),.rf_re0_i(rf_re0_ID),.rf_re1_i(rf_re1_ID),.instr_o(instr_EX),.p1_o(p1_EX),.addr_o(addr_cur_EX),.src0_o(src0_EX),.src1_o(src1_EX),.mul_div_o(mul_div_EX),
										.to_sub_o(to_sub_EX),.jal_instr_o(jal_instr_EX),.jalr_instr_o(jalr_instr_EX),.rf_we_o(rf_we_EX),.rf_dst_addr_o(rf_dst_addr_EX),
										.alu_func1_o(alu_func1_EX),.alu_func2_o(alu_func2_EX),.word_size_o(word_size_EX),.dm_re_o(dm_re_EX),.dm_we_o(dm_we_EX),.rf_p0_addr_o(rf_p0_addr_EX),.rf_p1_addr_o(rf_p1_addr_EX),.rf_re0_o(rf_re0_EX),.rf_re1_o(rf_re1_EX));


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////// Execute Stage //////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////
// Instantiate ALU //
////////////////////

alu iALU (.jal_instr(jal_instr_EX),.jalr_instr(jalr_instr_EX),.addr(addr_cur_EX),.mul_div(mul_div_EX),.to_sub(to_sub_EX),.src0(src0_EX),.src1(src1_EX),.alu_func1(alu_func1_EX),
			.alu_func2(alu_func2_EX),.alu_rslt(alu_rslt_EX), .divide_stall(divide_op));

/////////////////////////////////////////////
// Instantiate branch determination logic //
///////////////////////////////////////////

pipeline_EX_DM #(.PIPE_EN(1))iEX_DM (.clk(clk),.rst_n(rst_n),.instr_i(instr_EX),.addr_i(addr_cur_EX),.alu_rslt_i(alu_rslt_EX),.rf_dst_addr_i(rf_dst_addr_EX),.p1_i(p1_EX),.rf_we_i(rf_we_EX),
										.dm_re_i(dm_re_EX),.dm_we_i(dm_we_EX),.word_size_i(word_size_EX),.rf_p1_addr_i(rf_p1_addr_EX),.instr_o(instr_DM),.alu_rslt_o(alu_rslt_DM),.p1_o(p1_DM),.rf_we_o(rf_we_DM),
										.rf_dst_addr_o(rf_dst_addr_DM),.dm_re_o(dm_re_DM),.dm_we_o(dm_we_DM),.word_size_o(word_size_DM),.addr_o(addr_cur_DM),.rf_p1_addr_o(rf_p1_addr_DM));



//TODO: if external mem is connected, should consider the WB to ID forwarding!
//TODO: assign all of these signals
assign wdata = p1_DM;
assign we = dm_we_DM;
assign addr = alu_rslt_DM;
assign re = dm_re_DM;
assign mem_data_DM = (re && alu_rslt_DM[15:4] === 12'hC00) ? rdata: mem_data_DM_immediate;
assign dst_data_WB = mem_data_WB;


// EX to ID and DM to ID forwarding for RAW harzard
assign p0_ID = (rf_we_EX && (rf_dst_addr_EX != 5'h0) && (rf_p0_addr_ID == rf_dst_addr_EX) && rf_re0_ID) ?	alu_rslt_EX 	:
			   (rf_we_DM && (rf_dst_addr_DM != 5'h0) && (rf_p0_addr_ID == rf_dst_addr_DM) && rf_re0_ID) ?	(dm_re_DM)? mem_data_DM : alu_rslt_DM 	:
			   (rf_we_WB && (rf_dst_addr_WB != 5'h0) && (rf_p0_addr_ID == rf_dst_addr_WB) && rf_re0_ID) ?	(dm_re_WB)? mem_data_WB	: alu_rslt_WB	: p0_ID_temp;

assign p1_ID = (rf_we_EX && (rf_dst_addr_EX != 5'h0) && (rf_p1_addr_ID == rf_dst_addr_EX) && rf_re1_ID) ?	alu_rslt_EX 	:
			   (rf_we_DM && (rf_dst_addr_DM != 5'h0) && (rf_p1_addr_ID == rf_dst_addr_DM) && rf_re1_ID) ?	(dm_re_DM)? mem_data_DM : alu_rslt_DM  	:
			   (rf_we_WB && (rf_dst_addr_WB != 5'h0) && (rf_p1_addr_ID == rf_dst_addr_WB) && rf_re1_ID) ?	(dm_re_WB)? mem_data_WB	: alu_rslt_WB	: p1_ID_temp;


// Stall logic
assign stall_p0 = (rf_re0_ID && rf_we_EX && (rf_dst_addr_EX == rf_p0_addr_ID) && (rf_dst_addr_EX != 5'h0) && (!flow_change_ID) && dm_re_EX);
assign stall_p1 = (rf_re1_ID && rf_we_EX && (rf_dst_addr_EX == rf_p1_addr_ID) && (rf_dst_addr_EX != 5'h0) && (!flow_change_ID) && dm_re_EX);
assign stall = stall_p0 || stall_p1;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////// Memory Stage //////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////
// Instantiate data memory //
////////////////////////////

assign dm_addr = boot_we ? boot_waddr : alu_rslt_DM[14:0];
assign dm_wdata = boot_we ? boot_wdata : p1_DM;

// addr only use lower 13 bits because it's a 8KB DM
data_mem iDM(.clk(clk),.addr(dm_addr),.wrt_data(dm_wdata),.we((dm_we_DM && (alu_rslt_DM[15:12] !== 12'hC00)) || boot_we),.re(dm_re_DM),.word_size(word_size_DM),
       .rd_data(mem_data_DM_immediate));

assign ecall = (instr_DM === 32'h000000073) ? 1'b1	: 1'b0;

pipeline_DM_WB #(.PIPE_EN(1)) iDM_WB (.clk(clk), .rst_n(rst_n),.addr_i(addr_cur_DM),.rf_dst_addr_i(rf_dst_addr_DM),.rf_we_i(rf_we_DM),.dm_re_i(dm_re_DM),.mem_data_i(mem_data_DM),
										.alu_rslt_i(alu_rslt_DM),.addr_o(addr_cur_WB),.rf_dst_addr_o(rf_dst_addr_WB),.rf_we_o(rf_we_WB),.dm_re_o(dm_re_WB),.mem_data_o(mem_data_WB),.alu_rslt_o(alu_rslt_WB));



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////// Write-Back Stage ///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

logic [3:0] count;

//divide info
always_ff @(posedge divide_op, negedge rst_n) begin
	if(~rst_n) begin
		divide_stall <= 0;
		count <= '0;
	end
	else begin
		if(count == 4'b0111) begin
			divide_stall <= 1;
			count <= '0;
		end
		else begin
			divide_stall <= 1;
			count <= count + 1;
		end
	end
end




//////////////////////////
// Instantiate dst mux //
////////////////////////

dst_mux iDSTMUX(.dm_re(dm_re_WB),.mem_data(dst_data_WB),.alu_rslt(alu_rslt_WB),.dst(dst_WB));

endmodule
