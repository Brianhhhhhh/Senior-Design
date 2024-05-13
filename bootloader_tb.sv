`timescale 1ns/10ps
module bootloader_tb();

logic clk, rst_n;
reg [9:0] SW = 0;
wire UART_TX;

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
	.SW(SW),

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	.LiDAR_RX_1(),
	.LiDAR_TX_1(),

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	.LiDAR_RX_2(),
	.LiDAR_TX_2(),
	.BOOT_RX(UART_TX)
);

reg [7:0]mem[0:33];
logic trmt;
logic tx_done;
logic [7:0] tx_data;


UART_tx TEST_UART_TX(.clk(clk), .rst_n(rst_n), .TX(UART_TX), .trmt(trmt), .tx_data(tx_data), .tx_done(tx_done), .baud_cnt(13'h01b2));

//send num bytes
//set switch
//transmit data from a mem block in this file
//
initial begin
  $readmemh("test.hex",mem);
end

initial begin
  clk = 0;
  rst_n = 0;
  repeat(5)@(negedge clk);
  rst_n = 1;
  SW = 1;
  repeat(5)@(negedge clk);
  tx_data = mem[0];
  @(negedge clk);
  trmt = 1;
  for(int i = 1; i < 35; i=i+1) begin
	@(posedge tx_done);
	tx_data = mem[i];
  end
  trmt = 0;
  repeat(100)@(negedge clk);
  $stop();

end
  
always
  #5 clk = ~clk;
  
endmodule