module UART_rx(clk, rst_n, RX, clr_rdy, rx_data, rdy, baud_cnt);

input clk, rst_n, RX, clr_rdy;
input [12:0] baud_cnt;
output reg [7:0] rx_data;
output reg rdy;

logic start,shft; //signals from SM
logic [3:0] bit_cnt;
logic [8:0] rx_shft_reg; //ouput from the shift reg block
logic [12:0] baud_tracker;
logic set_rdy;
logic IM_1, IM_2; //double flopped RX
logic recieving;

typedef enum reg[1:0] {IDLE,RECIEVE} state_t;
	
state_t state, nxt_state;

//double flop RX
always_ff @(posedge clk) begin
	IM_1 <= RX;
	IM_2 <= IM_1;
end

	
always_ff @(posedge clk) begin
	if(shft)
		rx_shft_reg <= {IM_2, rx_shft_reg[8:1]};
end

assign rx_data = rx_shft_reg[8:0];

assign shft = (~|baud_tracker);

always_ff @(posedge clk) begin
	if(start)
	    baud_tracker <= {1'b0,baud_cnt[12:1]};
	else if (shft)
		baud_tracker <= baud_cnt;
	else if(recieving)
		baud_tracker <= baud_tracker -1;
end

// always_ff @(posedge clk) begin
// 	if(start)
// 		baud_cnt <= 1303;
// 	else if(shft)
// 		baud_cnt <= 2604;
// 	else if(recieving)
// 		baud_cnt <= baud_cnt -1;
// end

always_ff @(posedge clk) begin
	if(start)
		bit_cnt <= 0;
	else if(shft)
		bit_cnt <= bit_cnt + 1;
end

always_comb begin
	start = 1'b0;
	nxt_state = state;
	set_rdy = 1'b0;
	recieving = 1'b0;
	case (state)
		IDLE: begin
			if(!IM_2) begin
				start = 1'b1;
				nxt_state = RECIEVE;
			end
		end
		RECIEVE: begin
			recieving = 1'b1;
			if(bit_cnt == 10) begin //was 10
				set_rdy = 1'b1;
				nxt_state = IDLE;
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
		rdy <= 1'b0;
	else if(clr_rdy)
		rdy <= 1'b0;
	else if(start)
		rdy <= 1'b0;
	else if(set_rdy)
		rdy <= 1'b1;
end

endmodule