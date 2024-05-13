module id(instr,mul_div,to_sub,br_instr,jal_instr,jalr_instr,rf_re0,rf_re1,rf_we,rf_p0_addr,rf_p1_addr,rf_dst_addr,alu_func1,alu_func2,word_size,src0sel,src1sel,br_cc,dm_re,dm_we);

//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions

    input [31:0] instr;                                 // Instruction to be decoded

    output mul_div;                                     // if the instruction is mul/div
	output to_sub;										// if the instruction is sub/sra
    output br_instr;                                    // if the instruction is branch
    output jal_instr;                                   // JAL jump
    output jalr_instr;                                  // JALR jump
    output rf_re0;                                      // reg file read enable 0
    output rf_re1;                                      // reg file read enable 1
    output rf_we;                                       // reg file write enable
    output [4:0] rf_p0_addr;                            // reg file port 0 address
    output [4:0] rf_p1_addr;                            // reg file port 1 address
    output [4:0] rf_dst_addr;                           // reg file write address
    output func_code_t alu_func1;                       // ALU fundamental function
    output MUL_DIV_t alu_func2;                         // ALU EXTENDED function (MUL & DIV)
    output wrd_size_t word_size;                        // word size for LD/STR
    output src0sel_t src0sel;                           // src 0 select
    output src1sel_t src1sel;                           // src 1 select
    output br_code_t br_cc;                             // branch condition code
    output logic dm_re;                                 // data memory read enable
    output logic dm_we;                                 // data memory write enable


    //////////////////////////////////
    ///// Intermediate Logic /////////
    //////////////////////////////////
    opcode_t opcode;
	logic mul_div_w;
	logic to_sub_w;
    logic br_instr_w;
    logic jal_instr_w;
    logic jalr_instr_w;
    logic rf_re0_w;
    logic rf_re1_w;
    logic rf_we_w;
    logic [4:0] rf_p0_addr_w;
    logic [4:0] rf_p1_addr_w;
    logic [4:0] rf_dst_addr_w;
    func_code_t alu_func1_w;
    MUL_DIV_t alu_func2_w;
    wrd_size_t word_size_w;
    br_code_t br_cc_w; 
    src0sel_t src0sel_w;
    src1sel_t src1sel_w;
    logic dm_re_w;
    logic dm_we_w;




    assign opcode = opcode_t'(instr[6:0]);

    always @(instr) begin
        mul_div_w = 0;
		    to_sub_w = 0;
        br_instr_w = 0;
        jal_instr_w = 0;
        jalr_instr_w = 0;
        rf_re0_w = 0;
        rf_re1_w = 0;
        rf_we_w = 0;
        rf_p0_addr_w = instr[19:15];
        rf_p1_addr_w = instr[24:20];
        rf_dst_addr_w = instr[11:7];
        alu_func1_w = ADD_SUBf;
        alu_func2_w = MULf;
        word_size_w = WORD;
        br_cc_w = br_code_t'('0);
        src0sel_w = RF2SRC0;
        src1sel_w = RF2SRC1;
        dm_re_w = 0;
        dm_we_w = 0;

        case (opcode)
    	    // logic reg (arithmetic) operation 
    	    REGREG: begin
    	    	rf_re0_w = 1;
    	    	rf_re1_w = 1;
    	    	rf_we_w = 1;
    	    	alu_func1_w = func_code_t'(instr[14:12]);
                alu_func2_w = MUL_DIV_t'(instr[14:12]);
                mul_div_w = instr[25];
				to_sub_w = instr[30];
    	    end

    	    // logic imm (arithmetic) operation 
    	    REGIMM: begin
    	    	rf_re0_w = 1;
    	    	src1sel_w = IMM12_2SRC1;
    	    	rf_we_w = 1;
    	    	alu_func1_w = func_code_t'(instr[14:12]);
    	    end

    	    // Store operation 
    	    STR: begin
    	    	rf_re0_w = 1;
    	    	rf_re1_w = 1;
    	    	dm_we_w = 1;
    	    	word_size_w = wrd_size_t'(instr[14:12]);
    	    	src1sel_w = IMM12_2_2SRC1;
    	    end

    	    // Load instructions
    	    LD: begin
    	      rf_re0_w = 1;
    	      rf_we_w = 1;
    	      dm_re_w = 1;
    	      src1sel_w = IMM12_2SRC1;
    	      word_size_w = wrd_size_t'(instr[14:12]);
    	    end

    	    // Branch instructions
    	    BR: begin
    	      rf_re0_w = 1;
    	      rf_re1_w = 1;
    	      rf_dst_addr_w = '0;				// write to zero register
    	      br_instr_w = 1;
              br_cc_w = br_code_t'(instr[14:12]);
    	    end

    	    // Jump and link instruction
    	    JAL: begin
    	      // rd <= {pc + 4}
    	      src0sel_w = PC2SRC0;			    // access pc value
    	      src1sel_w = IMMJAL_2SRC1;			// jal immediate (will add 4 in alu)
    	      jal_instr_w = 1;
    	      rf_we_w = 1;
    	    end

    	    // Jump and link reg instruction
    	    JALR: begin
            rf_re0_w = 1;
    	      src0sel_w = RF2SRC0;
    	      src1sel_w = IMM12_2SRC1;			// access data immediate
    	      jalr_instr_w = 1;
    	      rf_we_w = 1;
    	    end

    	    // Add upper immediate to PC instruction TBD
    	    AUIPC: begin
              // rd <= PC + {[31:12],12'h0}
    	      src0sel_w = PC2SRC0;	            // access pc value
    	      src1sel_w = IMM20_2SRC1;		    // access data immediate
    	      rf_we_w = 1;
    	    end

    	    // Load upper immediate instruction
    	    LUI: begin
    	      // rd <= zero logic + {[31:12], 12'h0}
    	      rf_re0_w = 1;					    // access zero from reg0 and ADD
    	      rf_p0_addr_w = 8'h0;			    // reg0 contains zero
    	      src1sel_w = IMM20_2SRC1;		    // access 20-bit immediate
    	      rf_we_w = 1;                      // reg write enabled
    	    end

        endcase
    end

    //////////////////////////////////////////////////////////////////
    /////////////////// Assign Output ///////////////////////////////
    ////////////////////////////////////////////////////////////////

    assign mul_div = mul_div_w;
	assign to_sub = to_sub_w;
    assign br_instr = br_instr_w;
    assign jal_instr = jal_instr_w;
    assign jalr_instr = jalr_instr_w;
    assign rf_re0 = rf_re0_w;
    assign rf_re1 = rf_re1_w;
    assign rf_we = rf_we_w;
    assign rf_p0_addr = rf_p0_addr_w;
    assign rf_p1_addr = rf_p1_addr_w;
    assign rf_dst_addr = rf_dst_addr_w;
    assign alu_func1 = alu_func1_w;
    assign alu_func2 = alu_func2_w;
    assign word_size = word_size_w;
    assign br_cc = br_cc_w;
    assign src0sel = src0sel_w;
    assign src1sel = src1sel_w;
    assign dm_re = dm_re_w;
    assign dm_we = dm_we_w;

endmodule