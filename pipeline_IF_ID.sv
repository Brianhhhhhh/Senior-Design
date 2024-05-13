module pipeline_IF_ID #(parameter PIPE_EN = 1) (clk, rst_n, stall, flush, addr_i,instr_i,addr_o,instr_o);

//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions

input clk;
input rst_n;
input stall;
input flush;
input [31:0] addr_i;
input [31:0] instr_i;
output [31:0] addr_o;
output [31:0] instr_o;

generate
    if(PIPE_EN) begin
        logic [31:0] addr_o_reg;
        logic [31:0] instr_o_reg;

        always@ (posedge clk, negedge rst_n) begin
            if(!rst_n) begin
                addr_o_reg <= '0;
                instr_o_reg <= '0;
            end
            //if flush, execute instruction ADD x0, x0, x0
            else if (flush) begin
                addr_o_reg <= '0;
                instr_o_reg <= 32'h00000000;
            end    
            else if (!stall) begin
                addr_o_reg <= addr_i;
                instr_o_reg <= instr_i;
            end
        end
        assign addr_o = addr_o_reg;
        assign instr_o = instr_o_reg;
    end
    else begin
        assign addr_o = addr_i;
        assign instr_o = instr_i;
    end
endgenerate
endmodule