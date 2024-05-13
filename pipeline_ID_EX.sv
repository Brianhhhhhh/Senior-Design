module pipeline_ID_EX #(parameter PIPE_EN = 1) (clk,rst_n,stall,instr_i,p1_i,addr_i,src0_i,src1_i,mul_div_i,to_sub_i,jal_instr_i,jalr_instr_i,rf_we_i,rf_dst_addr_i,alu_func1_i,alu_func2_i,word_size_i,dm_re_i,dm_we_i,rf_p0_addr_i,rf_p1_addr_i,rf_re0_i,rf_re1_i
                                                               ,instr_o,p1_o,addr_o,src0_o,src1_o,mul_div_o,to_sub_o,jal_instr_o,jalr_instr_o,rf_we_o,rf_dst_addr_o,alu_func1_o,alu_func2_o,word_size_o,dm_re_o,dm_we_o,rf_p0_addr_o,rf_p1_addr_o,rf_re0_o,rf_re1_o);

//////////////////////
// include defines //
////////////////////
import common::*;       // import all encoding definitions

input clk;
input rst_n;
input stall;

input [31:0] instr_i;                                // instruction
input [31:0] p1_i;                                   // reg data from port 1
input [31:0] addr_i;                                 // PC value
input [31:0] src0_i;                                 // source 0
input [31:0] src1_i;                                 // source 1
input mul_div_i;                                     // if the instruction is mul/div
input to_sub_i;										 // if the instruction is sub/sra
input jal_instr_i;                                   // JAL jump
input jalr_instr_i;                                  // JALR jump
input rf_we_i;                                       // reg file write enable
input [4:0] rf_dst_addr_i;                           // reg file write address
input func_code_t alu_func1_i;                       // ALU fundamental function
input MUL_DIV_t alu_func2_i;                         // ALU EXTENDED function (MUL & DIV)
input wrd_size_t word_size_i;                        // word size for LD/STR
input logic dm_re_i;                                 // data memory read enable
input logic dm_we_i;                                 // data memory write enable
input [4:0] rf_p0_addr_i;
input [4:0] rf_p1_addr_i;
input rf_re0_i;
input rf_re1_i;

output [31:0] instr_o;                                // instruction
output [31:0] p1_o;                                   // reg data from port 1
output [31:0] addr_o;                                 // PC value
output [31:0] src0_o;                                 // source 0
output [31:0] src1_o;                                 // source 1
output mul_div_o;                                     // if the instruction is mul/div
output to_sub_o;									  // if the instruction is sub/sra
output jal_instr_o;                                   // JAL jump
output jalr_instr_o;                                  // JALR jump
output rf_we_o;                                       // reg file write enable
output [4:0] rf_dst_addr_o;                           // reg file write address
output func_code_t alu_func1_o;                       // ALU fundamental function
output MUL_DIV_t alu_func2_o;                         // ALU EXTENDED function (MUL & DIV)
output wrd_size_t word_size_o;                        // word size for LD/STR
output logic dm_re_o;                                 // data memory read enable
output logic dm_we_o;                                 // data memory write enable
output [4:0] rf_p0_addr_o;
output [4:0] rf_p1_addr_o;
output rf_re0_o;
output rf_re1_o;

generate
    if(PIPE_EN) begin
        reg [31:0] instr_o_reg;
        reg [31:0] p1_o_reg;
        reg [31:0] addr_o_reg;
        reg [31:0] src0_o_reg;     
        reg [31:0] src1_o_reg;
        reg mul_div_o_reg;              
        reg to_sub_o_reg;                           
        reg jal_instr_o_reg;            
        reg jalr_instr_o_reg;                      
        reg rf_we_o_reg;                    
        reg [4:0] rf_dst_addr_o_reg;            
        func_code_t alu_func1_o_reg;                
        MUL_DIV_t alu_func2_o_reg;                
        wrd_size_t word_size_o_reg;                           
        reg dm_re_o_reg;                
        reg dm_we_o_reg; 
        reg rf_re0_o_reg;                
        reg rf_re1_o_reg;        
        reg [4:0] rf_p0_addr_o_reg;   
        reg [4:0] rf_p1_addr_o_reg;          
        always@ (posedge clk, negedge rst_n) begin
            if(!rst_n) begin
                instr_o_reg <= '0;
                p1_o_reg <= '0;
                addr_o_reg <= '0;
                src0_o_reg <= '0;
                src1_o_reg <= '0;    
                mul_div_o_reg <= '0;          
                to_sub_o_reg <= '0;                    
                jal_instr_o_reg <= '0;        
                jalr_instr_o_reg <= '0;            
                rf_we_o_reg <= '0;            
                rf_dst_addr_o_reg <= '0;
                alu_func1_o_reg <= ADD_SUBf;        
                alu_func2_o_reg <= MULf;        
                word_size_o_reg <= WORD;                  
                dm_re_o_reg <= '0;            
                dm_we_o_reg <= '0;   
                rf_re0_o_reg <= '0;
                rf_re1_o_reg <= '0;
                rf_p0_addr_o_reg <= '0;
                rf_p1_addr_o_reg <= '0;         
            end
            else begin 
                if(!stall) begin
                    instr_o_reg <= instr_i; 
                    p1_o_reg <= p1_i;
                    addr_o_reg <= addr_i;
                    src0_o_reg <= src0_i;
                    src1_o_reg <= src1_i;     
                    mul_div_o_reg <= mul_div_i;          
                    to_sub_o_reg <= to_sub_i;                   
                    jal_instr_o_reg <= jal_instr_i;        
                    jalr_instr_o_reg <= jalr_instr_i;           
                    rf_we_o_reg <= rf_we_i;            
                    rf_dst_addr_o_reg <= rf_dst_addr_i;
                    alu_func1_o_reg <= alu_func1_i;        
                    alu_func2_o_reg <= alu_func2_i;        
                    word_size_o_reg <= word_size_i;                   
                    dm_re_o_reg <= dm_re_i;            
                    dm_we_o_reg <= dm_we_i;   
                    rf_re0_o_reg <= rf_re0_i;
                    rf_re1_o_reg <= rf_re1_i;                
                    rf_p0_addr_o_reg <= rf_p0_addr_i;
                    rf_p1_addr_o_reg <= rf_p1_addr_i;
                end
                else begin
                    instr_o_reg <= '0;
                    p1_o_reg <= '0;
                    addr_o_reg <= '0;
                    src0_o_reg <= '0;
                    src1_o_reg <= '0;    
                    mul_div_o_reg <= '0;          
                    to_sub_o_reg <= '0;                    
                    jal_instr_o_reg <= '0;        
                    jalr_instr_o_reg <= '0;            
                    rf_we_o_reg <= '0;            
                    rf_dst_addr_o_reg <= '0;
                    alu_func1_o_reg <= ADD_SUBf;        
                    alu_func2_o_reg <= MULf;        
                    word_size_o_reg <= WORD;                  
                    dm_re_o_reg <= '0;            
                    dm_we_o_reg <= '0;   
                    rf_re0_o_reg <= '0;
                    rf_re1_o_reg <= '0;
                    rf_p0_addr_o_reg <= '0;
                    rf_p1_addr_o_reg <= '0;  
                end
            end
        end
        assign instr_o = instr_o_reg;
        assign p1_o = p1_o_reg;
        assign addr_o = addr_o_reg;  
        assign src0_o = src0_o_reg;
        assign src1_o = src1_o_reg;    
        assign mul_div_o = mul_div_o_reg;              
        assign to_sub_o = to_sub_o_reg;	            
        assign jal_instr_o = jal_instr_o_reg;            
        assign jalr_instr_o = jalr_instr_o_reg;                     
        assign rf_we_o = rf_we_o_reg;                
        assign rf_dst_addr_o = rf_dst_addr_o_reg;    
        assign alu_func1_o = alu_func1_o_reg;
        assign alu_func2_o = alu_func2_o_reg;  
        assign word_size_o = word_size_o_reg;      
        assign dm_re_o = dm_re_o_reg;          
        assign dm_we_o = dm_we_o_reg;  
        assign rf_re0_o = rf_re0_o_reg;
        assign rf_re1_o = rf_re1_o_reg;
        assign rf_p0_addr_o = rf_p0_addr_o_reg;
        assign rf_p1_addr_o = rf_p1_addr_o_reg;        
    end
    else begin
        assign instr_o = instr_i;
        assign p1_o = p1_i;
        assign addr_o = addr_i;     
        assign src0_o = src0_i;
        assign src1_o = src1_i;  
        assign mul_div_o = mul_div_i;        
        assign to_sub_o = to_sub_i;									      
        assign jal_instr_o = jal_instr_i;    
        assign jalr_instr_o = jalr_instr_i;  
        assign rf_we_o = rf_we_i;            
        assign rf_dst_addr_o = rf_dst_addr_i;
        assign alu_func1_o = alu_func1_i;
        assign alu_func2_o = alu_func2_i;  
        assign word_size_o = word_size_i;     
        assign dm_re_o = dm_re_i;          
        assign dm_we_o = dm_we_i;
        assign rf_re0_o = rf_re0_i;
        assign rf_re1_o = rf_re1_i;      
        assign rf_p0_addr_o = rf_p0_addr_i;
        assign rf_p1_addr_o = rf_p1_addr_i;      
    end
endgenerate
endmodule