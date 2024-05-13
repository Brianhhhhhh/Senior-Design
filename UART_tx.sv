module UART_tx(clk, rst_n, TX, trmt, tx_data, tx_done, baud_cnt);

input clk,rst_n,trmt;  //in 50MHz system clock & active low reset, tmrt Asserted for 1 clock to initiate transmission
input [7:0] tx_data; //in Byte to transmit
input [12:0] baud_cnt;
output TX;  //out Serial data output
output reg tx_done; //out Asserted when byte is done transmitting. Stays high till next byte transmitted. 

logic load,shft; //signals from SM
logic [3:0] bit_cnt;
logic [12:0] baud_tracker;
logic [8:0] tx_shft_reg; //ouput from the shift reg block
logic set_done;

typedef enum reg[1:0] {IDLE,TRANSMIT} state_t;
	
state_t state, nxt_state;

assign shft = (~|baud_tracker);

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		tx_shft_reg <= 9'h1FF;
	else if(load)
		tx_shft_reg <= {tx_data, 1'b0};
	else if(shft)
		tx_shft_reg <= {1'b1, tx_shft_reg[8:1]};
end

assign TX = tx_shft_reg[0];

always_ff @ (posedge clk) begin
	if(load || shft)
		baud_tracker <= baud_cnt;
	else
		baud_tracker <= baud_tracker - 1;
end

always_ff @ (posedge clk) begin
	if(load)
		bit_cnt <= 4'h0;
	else if(shft)
		bit_cnt <= bit_cnt + 1;
end


always_comb begin
	load = 1'b0;
	nxt_state = state;
	set_done = 1'b0;
	case (state)
		IDLE: begin
			if(trmt) begin
				load = 1'b1;
				nxt_state = TRANSMIT;
			end
		end
		TRANSMIT: begin
			if(bit_cnt == 10) begin
				nxt_state = IDLE;
				set_done = 1'b1;
			end
		end
	endcase
end
		  
always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end
			
always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n) 
		tx_done <= 1'b1;
	else if(load)
		tx_done <= 1'b0;
	else if(set_done)
		tx_done <= 1'b1;
end

endmodule