module piezo(input clk, input rst_n, input start, input[1:0]  piezo_indx, output piezo, output piezo_n);

logic [24:0] note_tmr, note_dur;     //note_duration can be up to 2^25 clocks
logic [14:0] freq_tmr, freq;        //15 bits so it can accept vals up to 7kHz
logic note_tmr_full;                //signals for when each of the timers is full 
logic not_playing;                  //signal for when a note isn't playing

assign note_dur = 25'h0800000;
assign note_tmr_full = (note_tmr >= note_dur);

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		freq <= 15'h3E48;
	else if (start) 
		freq <= (piezo_indx == 2'b00) ? 15'h4A11:
                (piezo_indx == 2'b01) ? 15'h7C90:
                (piezo_indx == 2'b10) ? 15'h5D51:
                15'h3E48;
end

//frequency timer
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		freq_tmr <= '0;
	else if (freq_tmr >= freq || not_playing) //when full, reset timer changed == to >=
		freq_tmr <= '0;
	else
		freq_tmr <= freq_tmr + 1;	
end

//note timer
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		note_tmr <= '0;
	else if(not_playing)
		note_tmr <= '0;
	else
		note_tmr <= note_tmr + 1;
end

//one_shot starter flop
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		not_playing <= 1;
	else if (start) //when full, reset timer changed == to >=
		not_playing <= 0;
	else if (note_tmr_full)
		not_playing <= 1;	
end

assign piezo = (freq_tmr > freq[14:1]) ? 1:0;
assign piezo_n = ~piezo;

endmodule