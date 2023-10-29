`timescale 1ps/1ps

module HazardDetectionUnit(
    input Branch_ID, rs1use_ID, rs2use_ID,
    input RegWrite_EX, RegWrite_MEM, MemRead_EX, MemRead_MEM, MemWrite_EX, MemWrite_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output reg forward_ctrl_ls,
    output reg [1:0] forward_ctrl_A,
    output reg [1:0] forward_ctrl_B
);

    wire stall = ((rs1use_ID && rs1_ID == rd_EXE) || (rs2use_ID && ~MemWrite_ID && rs2_ID == rd_EXE))
               && MemRead_EX;

    assign reg_EM_flush = 1'b0;

    assign reg_EM_EN = 1'b1;
    assign reg_DE_EN = 1'b1;
    assign reg_MW_EN = 1'b1;
    assign reg_FD_EN = 1'b1;

    assign reg_FD_flush = Branch_ID;
    assign reg_FD_stall = stall;
    assign reg_DE_flush = stall;
    assign PC_EN_IF = ~stall;

    // forward_ctrl_ls
    always @(*) begin
        // save after load  
        if ((|rs2_EXE) & MemWrite_EX) begin
            // MEM is load
            if (rs2_EXE == rd_MEM && MemRead_MEM)
                forward_ctrl_ls = 1'b1;
            else forward_ctrl_ls = 1'b0;
        end
        // EX is not save
        else forward_ctrl_ls = 1'b0;
    end

    // forward_ctrl_A
    always @(*) begin
        // need rs1
        if (rs1use_ID) begin
            // read after write (no load)
            if (rs1_ID == rd_EXE && RegWrite_EX && ~MemRead_EX) begin
                forward_ctrl_A = 2'b01;
            end else if (rs1_ID == rd_MEM && RegWrite_MEM) begin
                // MEM is load
                if (MemRead_MEM) begin
                    forward_ctrl_A = 2'b11;
                end else forward_ctrl_A = 2'b10; // MEM is write other than load
            end else forward_ctrl_A = 2'b00;
        end
        else forward_ctrl_A = 2'b00;
    end

    // forward_ctrl_B
    always @(*) begin
        // not save and need rs2
        if (rs2use_ID && ~MemWrite_ID) begin
            if (rs2_ID == rd_EXE && RegWrite_EX && ~MemRead_EX) begin
                // write and not load
                forward_ctrl_B = 2'b01;
            end else if (rs2_ID == rd_MEM && RegWrite_MEM) begin
                // MEM is load
                if (MemRead_MEM) begin
                    forward_ctrl_B = 2'b11;
                end else forward_ctrl_B = 2'b10; // MEM is write other than load
            end else forward_ctrl_B = 2'b00;
        end
        else forward_ctrl_B = 2'b00;
    end

endmodule