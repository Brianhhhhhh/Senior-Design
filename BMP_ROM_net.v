module BMP_ROM_net(clk,addr,dout);

  input clk;     // 50MHz clock
  input [15:0] addr;
  output reg [5:0] dout;   // 5-bit color pixel out

  reg [5:0] rom[0:13443];

  initial
    $readmemh("net.hex",rom);

  always @(posedge clk)
    dout <= rom[addr];

endmodule
