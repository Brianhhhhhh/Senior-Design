module UART_Boot(clk, rst_n, RX, we, waddr, wdata, boot_en, boot_done);
    input clk, rst_n, RX;
    input boot_en;
    output logic boot_done;
    output logic we;
    output logic [14:0] waddr;
    output logic [31:0] wdata;

    logic rx_rdy, num_en, high_en, en4, en3, en2;
    logic [7:0] rx_data, high_NB, byte4, byte3, byte2;

    logic [15:0] num_bytes;
    logic set_boot_done;
    logic inc_addr;

    //instantiate UART_RX
    UART_rx iRX(.clk(clk), .rst_n(rst_n), .RX(RX), .clr_rdy(rx_rdy), .rx_data(rx_data), .rdy(rx_rdy), .baud_cnt(13'h01b2)); // hardcode baud to 115200

    //SM
    typedef enum reg [2:0] {IDLE, HIGH_NB, DATA_4, DATA_3, DATA_2, DATA_1} state_t;
    state_t state, next_state;

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            state <= IDLE;
            boot_done <= 1'b0;
        end  else begin
            state <= next_state;
            if(set_boot_done)
                boot_done <= 1'b1;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            num_bytes <= 16'h0000;
            high_NB <= 8'h00;
            byte4 <= 8'h00;
            byte3 <= 8'h00;
            byte2 <= 8'h00;
            waddr <= 15'h0000;            
        end
        //full num_bytes register
        else if (num_en) begin
            num_bytes <= {high_NB, rx_data};
        end
        //num_bytes high byte register
        else if (high_en) begin
            high_NB <= rx_data;
        end
        //highest data byte register (31:24)
        else if (en4) begin
            byte4 <= rx_data;
        end
        //second highest data byte register (23:16)
        else if (en3) begin
            byte3 <= rx_data;
        end
        //second lowest data byte register (15:8)
        else if (en2) begin
            byte2 <= rx_data;
        end
        //waddr incrementer
        else if (inc_addr) begin
            waddr <= waddr + 4;
        end
    end

    always_comb begin
        /// default outputs ///
        next_state = state;
        we = 1'b0;
        num_en = 1'b0;
        high_en = 1'b0;
        en4 = 1'b0;
        en3 = 1'b0;
        en2 = 1'b0;
        set_boot_done = 1'b0;
        wdata = '0;
        inc_addr = 1'b0;
        case (state)
            HIGH_NB: begin
                if (rx_rdy) begin
                    num_en = 1'b1;
                    next_state = DATA_4;
                end
            end
            DATA_4: begin
                if (rx_rdy) begin
                    en4 = 1'b1;
                    next_state = DATA_3;
                end
                else if ((waddr) == num_bytes[14:0]) begin
                    next_state = IDLE;
                    set_boot_done = 1'b1;
                end
            end           
            DATA_3: begin
                if (rx_rdy) begin
                    en3 = 1'b1;
                    next_state = DATA_2;
                end
            end
            DATA_2: begin
                if (rx_rdy) begin
                    en2 = 1'b1;
                    next_state = DATA_1;
                end
            end
            DATA_1: begin
                if (rx_rdy) begin
                    wdata = {byte4, byte3, byte2, rx_data};
                    we = 1'b1;
                    inc_addr = 1'b1;
                    next_state = DATA_4;
                end
            end
            /// Default case = IDLE ///
            default: begin
                if (rx_rdy && boot_en) begin
                    high_en = 1'b1;
                    next_state = HIGH_NB;
                end
            end
        endcase
    end

endmodule