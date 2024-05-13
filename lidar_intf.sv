module lidar_intf(
    input clk,
    input rst_n,
    input RX,
    output TX,
    output reg [15:0] Distance
    );

    logic [8:0] byte_counter;
    logic [15:0] Amp;
    logic [15:0] Temp;
    logic [7:0] rx_data;
    logic rx_done;
    logic [2:0] tx_byte_counter;
    logic [7:0] tx_data;
    logic send_tx;
    logic Distance_valid;

    //LiDAR init information
    reg [7:0] initial_tx_sequence[0:4];	


    UART_rx UART_RX(.clk(clk), .rst_n(rst_n), .RX(RX), .clr_rdy(rx_done), .rx_data(rx_data), .rdy(rx_done), .baud_cnt(13'h01b2));
    UART_tx UART_TX(.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(send_tx), .tx_data(tx_data), .tx_done(tx_done), .baud_cnt(13'h01b2));

    always_ff @( posedge clk, negedge rst_n ) begin
        if(!rst_n) begin
            initial_tx_sequence[0] = 8'h5A;
            initial_tx_sequence[1] = 8'h05;
            initial_tx_sequence[2] = 8'h05;
            initial_tx_sequence[3] = 8'h06;
            initial_tx_sequence[4] = 8'h00;
        end
    end

    always_ff @( posedge clk, negedge rst_n ) begin
        if(!rst_n)
            tx_byte_counter <= 0;
        else if(tx_byte_counter < 5 && tx_done && !send_tx) begin
            tx_data <= initial_tx_sequence[tx_byte_counter];
            send_tx <= 1;
            tx_byte_counter <= tx_byte_counter + 1;
        end
        else
            send_tx <= 0;

    end    

    always_ff @( posedge clk, negedge rst_n ) begin
        if(!rst_n) begin 
            byte_counter <= 0;
            Distance <= 0;
            Amp <= 0;
            Temp <= 0;
            Distance_valid <= 0;
        end
        else if (rx_done) begin
            case(byte_counter)

                //header
                0: begin
                    if(rx_data === 8'h59)
                        byte_counter <= byte_counter + 1;
                end
                //second header
                1: begin
                    if(rx_data === 8'h59)
                        byte_counter <= byte_counter + 1;
                    else
                        byte_counter <= 0;
                end
                //Distance_l
                2: begin
                    if(Distance_valid)
                        Distance[7:0] <= rx_data;
                    byte_counter <= byte_counter + 1;
                end
                //Distance_h
                3: begin
                    if(Distance_valid)
                        Distance[15:8] <= rx_data;
                    byte_counter <= byte_counter + 1;
                end
                //amp_l
                4: begin
                    Amp[7:0] <= rx_data;
                    byte_counter <= byte_counter + 1;
                end
                //amp_h
                5: begin
                    Amp[15:8] <= rx_data;
                    byte_counter <= byte_counter + 1;
                end
                //temp_l
                6: begin
                    Temp[7:0] <= rx_data;
                    byte_counter <= byte_counter + 1;
                end
                //temp_h
                7: begin
                    Temp[15:8] <= rx_data;
                    byte_counter <= byte_counter + 1;
                end
                //checksum
                8: begin
                    byte_counter <= 0;
                end
                default: begin
                end
            endcase
            if(Amp > 16'd100 && ~&Amp)
                Distance_valid <= 1;
            else
                Distance_valid <= 0;
        end
    end

endmodule