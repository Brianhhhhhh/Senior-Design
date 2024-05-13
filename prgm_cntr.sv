module pc(clk,rst_n,stall,flow_change,br_addr,pc, boot_en);
////////////////////////////////////////////////////////////////////////////\
// This module implements the program counter logic. It normally increments \\
// the PC by 1, but when a branch is taken will add the 9-bit immediate      \\
// field to the PC+1.  In case of a jmp_imm it will add the 12-bit immediate //
// field to the PC+1.  In the case of a jmp_reg it will use the register    //
// port zero (p0) register access as the new value of the PC.  It also     //
// provides PC+1 as nxt_pc for JAL instructions.                          //
///////////////////////////////////////////////////////////////////////////
input clk,rst_n;
input stall;
input flow_change;              // if the previous instruction is branch and taken
input [31:0] br_addr;           // branch target address
input boot_en;
output logic [31:0] pc;					// the PC, forms address to instruction memory

//intermediate logic
logic [31:0] nxt_pc;

/////////////////////////////////////
// implement incrementer for PC+4 //
///////////////////////////////////
assign nxt_pc = (flow_change) ? br_addr  :  pc + 4;

////////////////////////////////
// Implement the PC register //
//////////////////////////////
always @(posedge clk, negedge rst_n)
  if (!rst_n)
    pc <= 32'h0000;
  else if (boot_en)
    pc <= 32'h0000;
  else if (!stall)
	  pc <= nxt_pc;


endmodule