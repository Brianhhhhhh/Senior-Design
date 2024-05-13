module dualPort32x32(clk,rst_n,we,re,waddr,raddr,wdata,rdata);

	input clk;					// clock
	input rst_n;                                    // reset
	input we;					// write enable
	input re;					// read enable
	input [4:0] waddr;			// write address
	input [4:0] raddr;			// read address
	input [31:0] wdata;			// data to write
	output reg [31:0] rdata;	// read data output
	
	reg [31:0] mem [32];		// 16 by 32 SRAM block

	// posedge write, negedge read memory
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
		begin
		    for(int i=0; i<32; i++)
			mem[i] <= '0;
		end else begin
		if(we && (waddr!=0))
			mem[waddr] <= wdata;
	        end
	end
	always @(negedge clk) begin

		rdata <= mem[raddr];

	end
	
endmodule
