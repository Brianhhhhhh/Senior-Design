package common;
    // opcode types
    typedef enum logic [6:0] {REGREG = 7'h33, REGIMM = 7'h13, STR = 7'h23, LD = 7'h03, BR = 7'h63, JALR = 7'h67, JAL = 7'h6F, AUIPC = 7'h17, LUI = 7'h37, ECALL = 7'h73} opcode_t; 

    // sub function codes (ALU operation)
    typedef enum logic [2:0] {ADD_SUBf,SLLf,SLTf,SLTUf,XORf,SRL_Af,ORf,ANDf} func_code_t;

    // Src0 sources
    typedef enum logic [1:0] {RF2SRC0, PC2SRC0, ZERO2SRC0} src0sel_t;

    // Src1 sources
    typedef enum logic [2:0] {RF2SRC1, IMM12_2SRC1, IMM12_2_2SRC1, IMMBR_2SRC1, IMMJAL_2SRC1, IMM20_2SRC1, ZERO2SRC1} src1sel_t;

    // types for memory transaction widths 
    typedef enum logic [2:0] {BYTE = 3'h0,HALF = 3'h1,WORD = 3'h2,BYTE_UNSIGN = 3'h4,HALF_UNSIGN = 3'h5} wrd_size_t;       //8-bit, 16-bit, 32-bit

    // types for branch instruction
    typedef enum logic [2:0] {BEQ = 3'h00, BNE = 3'h01, BLT = 3'h04, BGE = 3'h05, BLTU = 3'h06, BGEU = 3'h07} br_code_t;
    
    // MUL/DIV function codes (ALU operation)
    typedef enum logic [2:0] {MULf,MULHf,MULHSUf,MULHUf,DIVf,DIVUf,REMf,REMUf} MUL_DIV_t;

    function [0:0] less_than_signed;
        input  [31:0] x;
        input  [31:0] y;
        reg [31:0] z;
    begin
        z = x - y;
        if (x[31] != y[31])
            less_than_signed = x[31];
        else
            less_than_signed = z[31];
    end
    endfunction
    
    
    function [0:0] greater_than_signed;
        input  [31:0] x;
        input  [31:0] y;
        reg [31:0] z;
    begin
        z = (y - x);
        if (x[31] != y[31])
            greater_than_signed = y[31];
        else
            greater_than_signed = z[31];
    end
    endfunction


endpackage
