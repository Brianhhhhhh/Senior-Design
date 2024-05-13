module IM(clk,addr,rd_en,we,waddr,wdata,instr);

input clk;
input [12:0] addr, waddr;
input rd_en, we;							// asserted when instruction read desired, asserted when bootloading
input [31:0] wdata;

output reg [31:0] instr;				//output of insturction memory

reg [31:0]instr_mem[0:8191];			// 16K*32 instruction memory

initial begin
  $readmemh("wiscv.hex",instr_mem);
end

always_ff @(negedge clk) begin
  if(we)
    instr_mem[waddr] <= wdata;
  if(rd_en)
    instr <= instr_mem[addr];
end

endmodule
