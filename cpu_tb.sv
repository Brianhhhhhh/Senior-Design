module cpu_tb();

logic clk, rst_n;
logic [31:0] rdata, addr;
logic ecall;

//////////////////////
// Instantiate CPU //
////////////////////
cpu iCPU(.clk(clk), .rst_n(rst_n), .rdata(rdata), .addr(addr), .ecall(ecall));

initial begin
 clk = 0;
 rst_n = 0;
@(posedge clk);
rst_n = 1;

  repeat(20000) @(posedge clk);
  $stop();

end
  
always
  #5 clk = ~clk;
  
endmodule