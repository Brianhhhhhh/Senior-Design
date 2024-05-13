module pipeline_DM_WB #(parameter PIPE_EN = 1) (clk, rst_n,addr_i,rf_dst_addr_i,dm_re_i,rf_we_i,mem_data_i,alu_rslt_i,rf_dst_addr_o,rf_we_o,addr_o,dm_re_o,mem_data_o,alu_rslt_o);

//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions

input clk;
input rst_n;

input [31:0] addr_i;
input [4:0] rf_dst_addr_i;
input rf_we_i;
input dm_re_i;
input [31:0] mem_data_i;
input [31:0] alu_rslt_i;

output [4:0] rf_dst_addr_o;
output rf_we_o;
output dm_re_o;
output [31:0] mem_data_o;
output [31:0] alu_rslt_o;
output [31:0] addr_o;

generate
    if(PIPE_EN) begin
        reg [31:0] rf_dst_addr_o_reg;
        reg [31:0] mem_data_o_reg;
        reg [31:0] alu_rslt_o_reg;
        reg [31:0] addr_o_reg;
        reg rf_we_o_reg;
        reg dm_re_o_reg;
        always@ (posedge clk, negedge rst_n) begin
            if(!rst_n) begin
                rf_dst_addr_o_reg <= '0;
                mem_data_o_reg <= '0;
                addr_o_reg <= '0;
                alu_rslt_o_reg <= '0;
                dm_re_o_reg <= '0;
                rf_we_o_reg <= '0;
            end
            else begin
                rf_dst_addr_o_reg <= rf_dst_addr_i;
                mem_data_o_reg <= mem_data_i;
                addr_o_reg <= addr_i;
                alu_rslt_o_reg <= alu_rslt_i;
                dm_re_o_reg <= dm_re_i;
                rf_we_o_reg <= rf_we_i;
            end
        end
        assign rf_dst_addr_o = rf_dst_addr_o_reg;
        assign mem_data_o = mem_data_o_reg;
        assign alu_rslt_o = alu_rslt_o_reg;
        assign addr_o = addr_o_reg;
        assign dm_re_o = dm_re_o_reg;
        assign rf_we_o = rf_we_o_reg;
    end
    else begin
        assign rf_dst_addr_o = rf_dst_addr_i;
        assign mem_data_o = mem_data_i;
        assign alu_rslt_o = alu_rslt_i;
        assign addr_o = addr_i;
        assign dm_re_o = dm_re_i;
        assign rf_we_o = rf_we_i;
    end
endgenerate

endmodule