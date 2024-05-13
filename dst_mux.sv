module dst_mux(dm_re,mem_data,alu_rslt,dst);
////////////////////////////////////////////////////////////////////////
// Simple 2:1 mux determining if ALU or DM is source for write to RF //
//////////////////////////////////////////////////////////////////////
input dm_re;                      // DM read enable
input [31:0] mem_data;		        // DM data
input [31:0] alu_rslt;				    // ALU output

output reg [31:0] dst;		        // output to be written to RF


always @(*)
  if (dm_re)
    dst <= mem_data;
  else
    dst <= alu_rslt;

endmodule
