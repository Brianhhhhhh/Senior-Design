module src_mux(src0sel,src1sel,p0,p1,pc,imm, ,src0,src1);


//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions


input src0sel_t src0sel;        // mux selectors for src0 bus
input src1sel_t src1sel;		// mux selectors for src1 bus
input [31:0] p0;				// port 0 from register file
input [31:0] p1;				// port 1 from register file
input [31:0] pc;				// Next PC for JAL instruction
input [31:0] imm;				// immediate from instruction stream goes on src1
output [31:0] src0,src1;		// source busses


//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions

assign src0 = (src0sel == RF2SRC0) ? p0 : 
              (src0sel == PC2SRC0) ? pc :
			  '0;

assign src1 = (src1sel == RF2SRC1) ? p1 : 
              imm;

endmodule

