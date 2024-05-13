module br_bool(jal_instr,stall,jalr_instr,br_instr,br_cc,src0,src1,imm,pc,flow_change,br_addr);


//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions


//////////////////////////////////////////////////////
//////// determines branch or not based on cc ///////
////////////////////////////////////////////////////
input jal_instr;				// 1 for JAL instruction
input jalr_instr;				// 1 for JALR instruction
input br_instr;		            // from ID, tell us if this is a branch instruction
input br_code_t br_cc;		    // condition code from instr[14:12]
input [31:0] src0, src1;
input [31:0] imm;
input [31:0] pc;
input stall;

output flow_change;		        // asserted if we should take branch or jumping
output [31:0] br_addr;          // branch target address

logic        branch_taken;
logic [31:0] branch_target;
logic [31:0] jal_addr;

always @(*)
begin
    branch_taken  = 1'b0;
    branch_target = pc + imm;

    case (br_cc)
    BEQ:

        branch_taken= (src0 == src1);

    BNE:

        branch_taken= (src0 != src1);

    BLT:

        branch_taken= less_than_signed(src0, src1);

    BGE:

        branch_taken= greater_than_signed(src0, src1) | (src0 == src1);

    BLTU:

        branch_taken= (src0 < src1);

    BGEU:

        branch_taken= (src0 >= src1);

    endcase

end


assign jal_addr = src0 + src1;
assign flow_change = (stall)                     ? 1'b0             :
                     (br_instr)                  ? branch_taken     :   
                     (jal_instr | jalr_instr)    ? 1'b1             :
                                                   1'b0;
assign br_addr = (jal_instr | jalr_instr)        ? jal_addr         : branch_target;



endmodule



