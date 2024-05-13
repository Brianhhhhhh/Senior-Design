`timescale 1ns/10ps
module Final_Demo_tb();

logic clk, rst_n;

//////////////////////
// Instantiate CPU //
////////////////////
Final_Demo iDUT(

	//////////// CLOCK //////////
	.REF_CLK(clk),

	//////////// KEY //////////
	.RST_n(rst_n),
	.start_button(1'b1),

	//////////// SW //////////
	.SW(10'h000),

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	.LiDAR_RX_1(),
	.LiDAR_TX_1(),

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	.LiDAR_RX_2(),
	.LiDAR_TX_2()
);

initial begin
  clk = 0;
  rst_n = 0;
  repeat(5)@(negedge clk);
  rst_n = 1;

  repeat(2000) @(posedge clk);

  $stop();

end
  
always
  #5 clk = ~clk;
  
endmodule