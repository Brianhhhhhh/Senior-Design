module data_mem(clk,addr,wrt_data,we,re,word_size,rd_data);

//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions

    input clk;
    input [14:0] addr;      		// Memory address
    input [31:0] wrt_data; 			// Data to write
    input we;       				// Memory write enable
    input re;        				// Memory read enable
	input wrd_size_t word_size;     // word size for LD/STR
    output logic [31:0] rd_data; 	// Data read from memory


	logic we_0, we_1, we_2, we_3;
	logic [7:0] wrt_data_0, wrt_data_1, wrt_data_2, wrt_data_3;
	logic [7:0] rd_data_0, rd_data_1, rd_data_2, rd_data_3;
	
    // Define memory size
    // localparam MEMORY_DEPTH = 8192; 		// 32K bytes => 8192 addresses (8 bits each)
    // logic [7:0] bank0 [MEMORY_DEPTH-1:0]; 	// Memory array 0
	// logic [7:0] bank1 [MEMORY_DEPTH-1:0]; 	// Memory array 1
    // logic [7:0] bank2 [MEMORY_DEPTH-1:0]; 	// Memory array 2
	// logic [7:0] bank3 [MEMORY_DEPTH-1:0]; 	// Memory array 3
	RAM_BLOCK #(.Filename("3")) iRAM0(.clk(clk),.addr(addr[14:2]),.re(re),.we(we_0),.wrt_data(wrt_data_0),.rd_data(rd_data_0));
	RAM_BLOCK #(.Filename("2")) iRAM1(.clk(clk),.addr(addr[14:2]),.re(re),.we(we_1),.wrt_data(wrt_data_1),.rd_data(rd_data_1));
	RAM_BLOCK #(.Filename("1")) iRAM2(.clk(clk),.addr(addr[14:2]),.re(re),.we(we_2),.wrt_data(wrt_data_2),.rd_data(rd_data_2));
	RAM_BLOCK #(.Filename("0")) iRAM3(.clk(clk),.addr(addr[14:2]),.re(re),.we(we_3),.wrt_data(wrt_data_3),.rd_data(rd_data_3));


	logic [7:0] data_out0,data_out1,data_out2,data_out3;	// wires for load

	// assign data_out0 = bank0[addr[14:2]];
	// assign data_out1 = bank1[addr[14:2]];
	// assign data_out2 = bank2[addr[14:2]];
	// assign data_out3 = bank3[addr[14:2]];
	assign data_out0 = rd_data_0;
	assign data_out1 = rd_data_1;
	assign data_out2 = rd_data_2;
	assign data_out3 = rd_data_3;

    // Memory write operation
    always_comb begin
		we_0 = 0;
		we_1 = 0;
		we_2 = 0;
		we_3 = 0;
		wrt_data_0 = '0;
		wrt_data_1 = '0;
		wrt_data_2 = '0;
		wrt_data_3 = '0;
		if (we && ~re) begin
			case (word_size)
				BYTE: begin
					if(addr[1:0] == 2'b00) begin
						we_0 = 1;
						wrt_data_0 = wrt_data[7:0];
					end
					else if(addr[1:0] == 2'b01) begin
						we_1 = 1;
						wrt_data_1 = wrt_data[7:0];
					end
					else if(addr[1:0] == 2'b10) begin
						we_2 = 1;
						wrt_data_2 = wrt_data[7:0];
					end
					else begin
						we_3 = 1;
						wrt_data_3 = wrt_data[7:0];
					end
				end
				HALF: begin
				  if (addr[1]) begin
					 we_2 = 1;
					 we_3 = 1;
				  	 wrt_data_2 = wrt_data[7:0];
					 wrt_data_3 = wrt_data[15:8];
				  end else begin
					 we_0 = 1;
					 we_1 = 1;
				  	 wrt_data_0 = wrt_data[7:0];
					 wrt_data_1 = wrt_data[15:8];
				  end
				end
				default: begin				// this is word write
					 we_0 = 1;
					 we_1 = 1;
					 we_2 = 1;
					 we_3 = 1;
					 wrt_data_0 = wrt_data[7:0];
					 wrt_data_1 = wrt_data[15:8];
					 wrt_data_2 = wrt_data[23:16];
					 wrt_data_3 = wrt_data[31:24];
    	    	end
			endcase
        end
	end


	always_comb begin
		rd_data = 'z;
		if (re && ~we) begin
			case (word_size)
				BYTE: begin
					if(addr[1:0] == 2'b00)
						rd_data = {{24{data_out0[7]}},data_out0};
					else if(addr[1:0] == 2'b01)
						rd_data = {{24{data_out1[7]}},data_out1};
					else if(addr[1:0] == 2'b10)
						rd_data = {{24{data_out2[7]}},data_out2};
					else
						rd_data = {{24{data_out3[7]}},data_out3};
				end
				HALF: begin
					if (addr[1]) 
						rd_data = {{16{data_out3[7]}},data_out3,data_out2};
					else 
						rd_data = {{16{data_out1[7]}},data_out1,data_out0};
				end
				WORD: begin
					rd_data = {data_out3,data_out2,data_out1,data_out0};
				end
				BYTE_UNSIGN: begin
					if(addr[1:0] == 2'b00)
						rd_data = {24'b0,data_out0};
					else if(addr[1:0] == 2'b01)
						rd_data = {24'b0,data_out1};
					else if(addr[1:0] == 2'b10)
						rd_data = {24'b0,data_out2};
					else
						rd_data = {24'b0,data_out3};
				end
				HALF_UNSIGN: begin
					if (addr[1]) begin
						rd_data = {{16'b0},data_out3,data_out2};
					end else begin
						rd_data = {{16'b0},data_out1,data_out0};
					end
				end
			endcase
		end 
	end

endmodule