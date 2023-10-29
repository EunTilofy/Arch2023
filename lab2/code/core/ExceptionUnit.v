`timescale 1ns / 1ps

module ExceptionUnit(
    input clk, rst,
    input csr_rw_in,
    // write/set/clear (funct bits from instruction)
    input[1:0] csr_wsc_mode_in,
    input csr_w_imm_mux,
    input[11:0] csr_rw_addr_in,
    input[31:0] csr_w_data_reg,
    input[4:0] csr_w_data_imm,
    output[31:0] csr_r_data_out,
    input[4:0] mem_err_addr,
    input[31:0] illegal_inst_val, 

    input interrupt,
    input illegal_inst,
    input l_access_fault,
    input s_access_fault,
    input ecall_m,

    input mret,

    input[31:0] epc_cur,
    input[31:0] epc_next,
    output[31:0] PC_redirect,
    output redirect_mux,

    output reg_FD_flush, reg_DE_flush, reg_EM_flush, reg_MW_flush, 
    output RegWrite_cancel,
    output MemWrite_cancel
);
    // According to the diagram, design the Exception Unit
    // You can modify any code in this file if needed!
    wire[11:0] csr_waddr = trap ? 12'b1 : csr_rw_addr_in;
    reg[31:0] csr_wdata;
    reg csr_w;
    reg[1:0] csr_wsc;
    wire[11:0] csr_raddr = csr_rw_addr_in;

    wire[31:0] mstatus;
    wire[31:0] csr_rdata;
    wire[31:0] mtvec;
    wire[31:0] mepc;

    always @(*) begin
        if (trap) begin
            csr_w = 1'b1;
        end else begin
            csr_w = csr_rw_in;
        end
    end

    always @(*) begin
        if (trap) begin
            csr_wsc = 2'b01;
        end else begin
            csr_wsc = csr_wsc_mode_in;
        end
    end

    always @(*) begin
        if (trap) begin
            if (interrupt) begin
                csr_wdata = epc_cur;
            end else begin
                csr_wdata = epc_next;
            end
        end else begin
            csr_wdata = csr_w_imm_mux ?  {27'b0, csr_w_data_imm} : csr_w_data_reg;
        end
    end

    wire trap = |{interrupt, illegal_inst, l_access_fault, s_access_fault, ecall_m};
    reg[31:0] mtval_data;
    always @(*) begin
        if(illegal_inst) begin
            mtval_data = illegal_inst_val;
        end else if(l_access_fault | s_access_fault) begin
            mtval_data = {27'b0, mem_err_addr};
        end
        else begin
            mtval_data = 32'b0;
        end
    end

    CSRRegs csr(.clk(clk),.rst(rst),.csr_w(csr_w),.raddr(csr_raddr),.waddr(csr_waddr),
        .wdata(csr_wdata),.rdata(csr_rdata),.mstatus(mstatus),.csr_wsc_mode(csr_wsc),
        .mtvec(mtvec), .mepc(mepc), .mtval_data(mtval_data), 
        .mtval_data_in(illegal_inst | l_access_fault | s_access_fault));

    assign csr_r_data_out = csr_rdata;

    assign PC_redirect = mret ? mepc : (trap ? mtvec : 32'h80000000);
    assign redirect_mux = mret | trap;
    assign MemWrite_cancel = trap;
    assign RegWrite_cancel = trap;
    assign reg_FD_flush = trap;
    assign reg_DE_flush = trap;
    assign reg_EM_flush = trap;
    assign reg_MW_flush = trap;

endmodule
