module RAM_BLOCK (clk,addr,re,we,wrt_data,rd_data);

parameter string Filename = "wiscv_bankx.hex";
/////////////////////////////////////////////////////////
// Data memory.  Single ported, can read or write but //
// not both in a single cycle.  Precharge on clock   //
// high, read/write on clock low.                   //
/////////////////////////////////////////////////////
input clk;
input [12:0] addr;
input re;				// asserted when instruction read desired
input we;				// asserted when write desired
input [7:0] wrt_data;	// data to be written

output reg [7:0] rd_data;	//output of data memory

localparam MEMORY_DEPTH = 8192; 		// 32K bytes => 8192 addresses (8 bits each)

reg [7:0]data_mem[0:MEMORY_DEPTH-1]; // 8k x 8

/////////////////////////////////////////////////////////
// Model read and write, data is latched on clock low //
///////////////////////////////////////////////////////

always_ff @(negedge clk) begin    // Changed from latch to FF.
  if (re)
    rd_data <= data_mem[addr];
  if (we)
    data_mem[addr] <= wrt_data;
end

initial begin
  $readmemh({"wiscv_bank",Filename,".hex"},data_mem);
end

endmodule
