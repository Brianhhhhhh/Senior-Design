module imm_decoder(instr, imm);

//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions


    input [31:0] instr;

    output [31:0] imm;

    //////////////////////////////////////////////
    //////////// Intermediate Logic //////////////
    //////////////////////////////////////////////
    opcode_t opcode;
	logic [31:0] imm_tmp;

always_comb begin
	imm_tmp = '0;
    opcode = opcode_t'(instr[6:0]);
	case(opcode)
		REGIMM:
			imm_tmp = {{20{instr[31]}},instr[31:20]};
		STR:
			imm_tmp = {{20{instr[31]}},instr[31:25],instr[11:7]};
		LD:
			imm_tmp = {{20{instr[31]}},instr[31:20]};
		BR:
			imm_tmp = {{20{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
		JAL:
			imm_tmp = {{12{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
        JALR:
            imm_tmp = {{20{instr[31]}},instr[31:20]};
		AUIPC:
			imm_tmp = {instr[31:12], 12'b0};	
		LUI:
			imm_tmp = {instr[31:12], 12'b0};
		default:
			imm_tmp = '0;	
	endcase
end

assign imm = imm_tmp;


endmodule
