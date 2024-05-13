//`default_nettype none

module bootloader(
       input wire clk, rst_n,

       input wire debug,
       output reg [12:0] addr,
       output reg [31:0] data,
       //output reg increment,

       input wire RX
);

logic increment;

// Write State Machine
typedef enum reg {IDLE, SET} write_state_t;
write_state_t write_state, nxt_write_state;
reg [2:0] transmission_count, rx_count;
reg shift, clr_rx_rdy;

// UART
wire rx_rdy;//, tx_done;
//reg trmt;
wire [7:0] rx_data;//, tx_data;

//UART iUART(.clk(clk),.rst_n(rst_n),.RX(RX),.TX(TX),.rx_rdy(rx_rdy),.clr_rx_rdy(clr_rx_rdy),.rx_data(rx_data),.trmt(trmt),.tx_data(tx_data),.tx_done(tx_done), .baud(baud));
UART_rx iRX(.clk(clk), .rst_n(rst_n), .RX(RX), .clr_rdy(clr_rx_rdy), .rx_data(rx_data), .rdy(rx_rdy), .baud_cnt(13'h01b2)); // hardcode baud to 115200

always_ff @(posedge clk, negedge rst_n) begin : counter
       if(!rst_n)
              addr <= 0;
       else if(!debug)
              addr <= 0;
       else if(increment)
              addr <= addr + 1;
end

always_ff @(posedge clk, negedge rst_n) begin
       if(!rst_n) 
              write_state <= IDLE;
       else 
              write_state <= nxt_write_state;
end

always_ff @(posedge clk, negedge rst_n) begin
       if(!rst_n)
              data <= 'b0;
       else if(shift)
              data <= {data[23:0], rx_data};
end

always_ff @(posedge clk, negedge rst_n) begin
       if(!rst_n)
              rx_count <= 3'b0;
       else if(increment) // Reset
              rx_count <= 3'b0;
       else if(shift) // Set
              rx_count <= rx_count + 1;
end

always_comb begin : writeStateMachine
       nxt_write_state = write_state;
       increment = 0;
       shift = 0;
       clr_rx_rdy = 0;
       case(write_state)
              default: begin
                            if(debug && rx_rdy) begin
                                   shift = 1;
                                   clr_rx_rdy = 1;
                            end
                            if(rx_count === 3'b100) nxt_write_state = SET;
                       end
              SET:     begin
                            increment = 1;
                            nxt_write_state = IDLE;
                       end  
       endcase
end


// wire q_empty;
// reg remove;
// wire [31:0] data_out;


// Transmission for debug
// circular_queue #(.Q_WIDTH('d32), .Q_SIZE('d8)) iCPUQueue(.clk(clk),.rst_n(rst_n),.data_in(outdata),.add(write),
//                                                                .remove(remove),.data_out(data_out),.q_full(),.q_empty(q_empty), 
//                                                                .remaining(), .containing()
//                                                                );

// typedef enum reg[1:0] {STEADY, SPLIT, SEND} tx_state_t;
// tx_state_t tx_state, nxt_tx_state;

// reg shift_tx, store, tx_increment, tx_rst;

// always_ff @(posedge clk, negedge rst_n) begin
//        if(!rst_n)
//               tx_state <= STEADY;
//        else
//               tx_state <= nxt_tx_state;
// end

// reg [31:0] stored_data_out;

// always_ff @(posedge clk, negedge rst_n) begin
//        if(!rst_n)
//               stored_data_out <= 'b0;
//        else if(shift_tx) // Shift
//               stored_data_out <= {8'b0, stored_data_out[31:8]};
//        else if(store)  // Set
//               stored_data_out <= data_out;
// end

// assign tx_data = stored_data_out[7:0];

// always_ff @(posedge clk, negedge rst_n) begin // vishnu changed this
//        if(!rst_n)
//               transmission_count <= 'b0;
//        else if(tx_rst)
//               transmission_count <= 'b0;
//        else if(tx_increment)
//               transmission_count <= transmission_count + 1;
// end

// always_comb begin : txStateMachine
//        nxt_tx_state = tx_state;
//        shift_tx = 0;
//        store = 0;
//        tx_increment = 0;
//        tx_rst = 0;
//        trmt = 0;
//        remove = 0;
//        case(tx_state)
//               default:  if(!q_empty) begin 
//                             remove = 1;
//                             store = 1;
//                             nxt_tx_state = SPLIT;
//                      end
//               SPLIT: begin
//                             trmt = 1;
//                             tx_increment = 1;
//                             nxt_tx_state = SEND;
//                             // shift_tx = 1;
//                      end
//               SEND:  begin
//                             if(transmission_count === 3'b100) begin
//                                    nxt_tx_state = STEADY;
//                                    tx_rst = 1;
//                             end 
//                             else if(tx_done) begin
//                                    shift_tx = 1;
//                                    trmt = 1;
//                                    tx_increment = 1;
//                             end
//                      end
//        endcase
// end


endmodule
