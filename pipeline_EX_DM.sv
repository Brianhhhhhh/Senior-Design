module pipeline_EX_DM #(parameter PIPE_EN = 1) (clk,rst_n,instr_i,addr_i,alu_rslt_i,p1_i,rf_we_i,rf_dst_addr_i,dm_re_i,dm_we_i,word_size_i,rf_p1_addr_i,instr_o,addr_o,alu_rslt_o,p1_o,rf_we_o,rf_dst_addr_o,dm_re_o,dm_we_o,word_size_o,rf_p1_addr_o);

//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions

input clk;
input rst_n;

input [31:0] instr_i;
input [31:0] alu_rslt_i;
input [31:0] p1_i;
input rf_we_i;
input [4:0] rf_dst_addr_i;                           // reg file write address
input dm_re_i;
input dm_we_i;
input wrd_size_t word_size_i;
input [4:0] rf_p1_addr_i;
input [31:0] addr_i;

output [31:0] instr_o;
output [31:0] alu_rslt_o;
output [31:0] p1_o;
output rf_we_o;
output [4:0] rf_dst_addr_o;                           // reg file write address
output dm_re_o;
output dm_we_o;
output wrd_size_t word_size_o;
output [4:0] rf_p1_addr_o;
output [31:0] addr_o;
generate
    if(PIPE_EN) begin
        reg [31:0] instr_o_reg;
        reg [31:0] alu_rslt_o_reg;
        reg [31:0] p1_o_reg;
        reg rf_we_o_reg;
        reg [4:0] rf_dst_addr_o_reg;    
        reg dm_re_o_reg;
        reg dm_we_o_reg;
        wrd_size_t word_size_o_reg;
        reg [4:0] rf_p1_addr_o_reg;   
        reg [31:0] addr_o_reg;
        always@ (posedge clk, negedge rst_n) begin
            if(!rst_n) begin
                instr_o_reg <= '0;
                alu_rslt_o_reg <= '0;
                p1_o_reg <= '0;
                rf_we_o_reg <= '0;
                rf_dst_addr_o_reg <= '0;
                dm_re_o_reg <= '0;
                dm_we_o_reg <= '0;
                word_size_o_reg <= WORD;
                rf_p1_addr_o_reg <='0;
                addr_o_reg <= '0;
            end
            else begin
                instr_o_reg <= instr_i;
                alu_rslt_o_reg <= alu_rslt_i;
                p1_o_reg <= p1_i;
                rf_we_o_reg <= rf_we_i;
                rf_dst_addr_o_reg <= rf_dst_addr_i;
                dm_re_o_reg <= dm_re_i;
                dm_we_o_reg <= dm_we_i;
                word_size_o_reg <= word_size_i;
                rf_p1_addr_o_reg <= rf_p1_addr_i;
                addr_o_reg <= addr_i;
            end
        end
        assign instr_o = instr_o_reg;
        assign alu_rslt_o = alu_rslt_o_reg;
        assign p1_o = p1_o_reg;
        assign rf_we_o = rf_we_o_reg;
        assign rf_dst_addr_o = rf_dst_addr_o_reg; 
        assign dm_re_o = dm_re_o_reg;
        assign dm_we_o = dm_we_o_reg;
        assign word_size_o = word_size_o_reg;
        assign rf_p1_addr_o = rf_p1_addr_o_reg;
        assign addr_o = addr_o_reg;
    end
    else begin
        assign instr_o = instr_i;
        assign alu_rslt_o = alu_rslt_i;
        assign p1_o = p1_i;
        assign rf_we_o = rf_we_i;
        assign rf_dst_addr_o = rf_dst_addr_i;
        assign dm_re_o = dm_re_i;
        assign dm_we_o = dm_we_i;
        assign word_size_o = word_size_i;
        assign rf_p1_addr_o = rf_p1_addr_i;
        assign addr_o = addr_i;
    end
endgenerate
endmodule

