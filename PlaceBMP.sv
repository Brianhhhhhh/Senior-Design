module PlaceBMP(clk,rst_n,add_fnt,fnt_indx,add_img,rem_img,image_indx,
                xloc,yloc,waddr,wdata,we,busy);


  input clk,rst_n;
  input add_fnt;			// add a character
  input [5:0] fnt_indx;	// one of 42 characters
  // 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ =>,()
  input add_img;			// pulse high for one clock to add image
  input rem_img;			// pulse high for one clock to remove image
  input [4:0] image_indx; 	// index of image in image memory (32 possible)
  input [9:0] xloc;			// x location of image to register
  input [8:0] yloc;			// y location of image to register
  output reg [18:0] waddr;	// write address to videoMem
  output logic [5:0] wdata;	// write 6-bit pixel to videoMem
  output reg we;
  output logic busy;		// asserted if PlaceBMP is busy and cannot accept another command
							// this would be good to put into a status register if you memory map
							// this to your processor....which you should.

  //////////////////////////////////////////
  // Declare any internal registers next //
  ////////////////////////////////////////
  reg [15:0] bmp_addr;				// address to local ROMs that contain images
  reg [15:0] bmp_addr_end;
  reg [13:0] font_addr;
  reg [3:0] font_x_cnt;
  reg [3:0] font_y_cnt;
  reg [9:0] xwid;					// stores x width of image
  reg [8:0] yhght_upper;
  reg [18:0] waddr_wrap;			// holds when to advance linear address into videoMem
  reg [4:0] indx;					//
  reg [5:0] font_indx;				// 1 of 42
  reg rem;							// set if removing image

  typedef enum reg[3:0] {IDLE,ADV1,ADV2,XRD1,XRD2,YRD1,YRD2,WRT,WRT2} state_t;

  state_t state, nxt_state;

  ///////////////////////////
  // Outputs of SM follow //
  /////////////////////////
  logic captureIndx,captureXwid,captureYwid,captureXwid2,captureYwid2;
  logic bmp_addr_inc;
  logic waddr_inc;
  logic fnt_addr_inc;

  ///////////////////////////
  // Internal nets follow //
  /////////////////////////
  wire [5:0] bmp_read0;
  wire [5:0] bmp_read1;
  wire [5:0] bmp_read2;			// add more for more images
  wire [5:0] bmp_read3;			// add more for more images
//   wire [5:0] bmp_read4;			// add more for more images
//   wire [5:0] bmp_read5;			// add more for more images
  wire [5:0] bmp_read;			// muxed output from BMP ROM
  wire waddr_wrap_en;
  wire fnt_wrap;


  ////////////////////////////////////////////////////
  // capture x image width as read from image file //
  //////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  xwid <= 10'h000;
	else if (captureXwid)
	  xwid <= (bmp_read<<6);
	else if (captureXwid2)
	  xwid <= xwid + bmp_read;

  ///////////////////////////////////////////////////////////
  // capture y image upper height as read from image file //
  /////////////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  yhght_upper <= 9'h000;
	else if (captureYwid)
	  yhght_upper <= (bmp_read<<6);

  ////////////////////////////////////////////////////
  // upon read of low byte of Yhght we can compute //
  // the end address of the bit map.              //
  /////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  bmp_addr_end <= 16'h0000;
	else if (captureXwid2)
	  bmp_addr_end <= xwid + bmp_read;		// bmp_read is currently = xwidth
    else if (captureYwid2)
	  /// + 5 = 4-bytes overhead in xwid/ywid, one in advance for latency
      bmp_addr_end <= bmp_addr_end*(yhght_upper+bmp_read) + 16'd5;

  //////////////////////////////////////////////////
  // Address of pixel being read from bitmap ROM //
  ////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    bmp_addr <= 16'h0000;
	  else if (captureIndx)
	    bmp_addr <= 16'h0000;
	  else if (bmp_addr_inc)
	    bmp_addr <= bmp_addr + 1;

  ////////////////////////////////////////////////
  // Address of pixel being read from font ROM //
  //////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_addr <= 16'h0000;
	  else if (captureIndx)
	    font_addr <= 4'd13*fnt_indx + 3;
	  else if (fnt_wrap)
	    font_addr <= font_addr + 10'd531;	// 544 - 13
	  else if (fnt_addr_inc)
	    font_addr <= font_addr + 1;

  ///////////////////////////////////////////////
  // Counts across our 13-pixel wide font map //
  /////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_x_cnt <= 4'h0;
	  else if (fnt_wrap | captureIndx)
	    font_x_cnt <= 4'h0;
	  else if (fnt_addr_inc)
	    font_x_cnt <= font_x_cnt + 1;

  assign fnt_wrap = (font_x_cnt==4'd13) ? 1'b1 : 1'b0;

  ////////////////////////////////////////
  // Counts our Y position in font map //
  //////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_y_cnt <= 4'h0;
	  else if (captureIndx)
	    font_y_cnt <= 4'h0;
	  else if (fnt_wrap)
	    font_y_cnt <= font_y_cnt + 1;

  ///////////////////////////////////////////
  // Holds which BMP ROM we are accessing //
  /////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  indx <= 5'h00;
	else if (captureIndx)
	  indx <= image_indx;

  ////////////////////////////////////////////////
  // Remember if command is to remove an image //
  //////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  rem <= 1'b0;
	else if (captureIndx)
	  rem <= rem_img;

  ////////////////////////////////////
  // write address to video memory //
  //////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    waddr <= 18'h00000;
	  else if (captureIndx)
	    waddr <= yloc*10'd640 + xloc;
	  else if (waddr_wrap_en)
	    waddr <= waddr + (18'd641 - xwid);
	  else if (fnt_wrap)
	    waddr <= waddr + 18'd628;
	  else if (waddr_inc)
	    waddr <= waddr + 1;

  //////////////////////////////////////////////////
  // compute/store address at which we wrap from //
  // end of row of pixels in bmp to new row     //
  ///////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    waddr_wrap <= 18'h00000;
	  else if (captureYwid)
	    waddr_wrap <= waddr + (xwid - 9'h001);
	  else if (waddr_wrap_en)
	    waddr_wrap <= waddr_wrap + 18'd640;

  assign waddr_wrap_en = (waddr==waddr_wrap) ? 1'b1 : 1'b0;

  //////////////////
  // State flops //
  ////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= IDLE;
	else
	  state <= nxt_state;

  always_comb begin
    nxt_state = state;
    captureIndx = 0;
	captureXwid = 0;
	captureYwid = 0;
	captureXwid2 = 0;
	captureYwid2 = 0;
	bmp_addr_inc = 0;
	waddr_inc = 0;
	fnt_addr_inc = 0;
	we = 0;
	busy = 1;		// only not busy if in IDLE
	wdata = 6'hxxx;

	case (state)
	  IDLE: begin
	    busy = 0;
	    if (add_img | rem_img) begin
		  captureIndx = 1;
		  nxt_state = ADV1;
		end else if (add_fnt) begin
		  captureIndx = 1;
		  nxt_state = ADV2;
		end
	  end
	  ADV1: begin	// this state is about advancing bmp_address
	    bmp_addr_inc = 1;
		nxt_state = XRD1;
	  end
	  ADV2: begin	// this state is about advancing bmp_address
	    fnt_addr_inc = 1;
		nxt_state = WRT2;
	  end
	  XRD1: begin
	    captureXwid = 1;
		bmp_addr_inc = 1;
		nxt_state = XRD2;
	  end
	  XRD2: begin
	    captureXwid2 = 1;
		bmp_addr_inc = 1;
		nxt_state = YRD1;
	  end
	  YRD1: begin
	    captureYwid = 1;
		bmp_addr_inc = 1;
		nxt_state = YRD2;
	  end
	  YRD2: begin
	    captureYwid2 = 1;
		bmp_addr_inc = 1;
		nxt_state = WRT;
	  end
	  WRT: begin
	    if (bmp_addr<bmp_addr_end) begin
		  bmp_addr_inc = 1;
		  wdata = (rem) ? 6'h00 : bmp_read;
		  we = (bmp_read==6'h024) ? 1'b0 : 1'b1;	// 128,64,32 is treated as transparent
		  waddr_inc = 1;
		end else
		  nxt_state = IDLE;
	  end
	  WRT2: begin
	    if ((font_y_cnt==4'd15) && (fnt_wrap))
		  nxt_state = IDLE;
		else if (fnt_wrap) begin
		  nxt_state = ADV2;
		end else begin
		  fnt_addr_inc = 1;
		  if(bmp_read==6'h024) 
		  		wdata = 6'h000;
		  else
		  		wdata = bmp_read;
		  we = 1'b1;
		//   we = (bmp_read==6'h024) ? 1'b0 : 1'b1;	// 128,64,32 is treated as transparent
		  waddr_inc = 1;
		end
	  end
	  default: nxt_state = IDLE;
	endcase

  end

  /////////////////////////////////
  // BMP ROMs and mux are below //
  ///////////////////////////////
  BMP_ROM_Font  iROM0(.clk(clk),.addr(font_addr),.dout(bmp_read0));
  BMP_ROM_net iROM1(.clk(clk),.addr(bmp_addr),.dout(bmp_read1));
  BMP_ROM_paddle iROM2(.clk(clk),.addr(bmp_addr),.dout(bmp_read2));
  BMP_ROM_ball iROM3(.clk(clk),.addr(bmp_addr),.dout(bmp_read3));
//   BMP_ROM_p1_win iROM4(.clk(clk),.addr(bmp_addr),.dout(bmp_read4));
//   BMP_ROM_p2_win iROM5(.clk(clk),.addr(bmp_addr),.dout(bmp_read5));
  assign bmp_read = (fnt_addr_inc) ? bmp_read0 :
                    (indx==5'd00) ? bmp_read1 :
                    (indx==5'd01) ? bmp_read2 :
                    // (indx==5'd02) ? bmp_read3 :
                    bmp_read3;
                    // (indx==5'd03) ? bmp_read4 :
					// bmp_read5;

endmodule