module rf(clk,rst_n,p0_addr,p1_addr,p0,p1,re0,re1,dst_addr,dst,we);
//////////////////////////////////////////////////////////////////
// Triple ported register file.  Two read ports (p0 & p1), and //
// one write port (dst).  Data is written on clock high, and  //
// read on clock low //////////////////////////////////////////
//////////////////////

	input clk;
	input rst_n;
	input [4:0] p0_addr, p1_addr;			// two read port addresses
	input re0,re1;							// read enables (power not functionality)
	input [4:0] dst_addr;					// write address
	input [31:0] dst;						// dst bus
	input we;								// write enable

	output [31:0] p0,p1;  					// output read ports

	logic [31:0] p0_raw, p1_raw;			// raw read output from SRAM

	/////////////////////////////////////////////////////////////////////
	// Instantiate two dualport memory to create a tripple port rf	  //
	// Always write same data to both sram instance at the same time //
	//////////////////////////////////////////////////////////////////
	dualPort32x32 sram0(
		.clk(clk),
		.rst_n(rst_n),
		.we(we),
		.re(re0),
		.waddr(dst_addr),
		.raddr(p0_addr),
		.wdata(dst),			
		.rdata(p0_raw)
	);
	dualPort32x32 sram1(
		.clk(clk),
		.rst_n(rst_n),
		.we(we),
		.re(re1),
		.waddr(dst_addr),
		.raddr(p1_addr),
		.wdata(dst),
		.rdata(p1_raw)
	);


	// R0 always stay at 16'h0000
	assign p0 = ~|p0_addr ? 16'h0000 : p0_raw;
	assign p1 = ~|p1_addr ? 16'h0000 : p1_raw;

endmodule
