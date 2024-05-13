module button_synch(in, out, clk, rst_n);

input in, rst_n, clk;
output out;

logic [3:0] im; //intermediate

always_ff @(negedge clk, negedge rst_n) begin
	if(!rst_n) 
        im <= 4'b000;
	else	
        im <= {im[2:0], in};
end

assign out = &im;

endmodule