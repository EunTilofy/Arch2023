`timescale 1ns / 1ps

module CSRRegs(
    input clk, rst,
    input[11:0] raddr, waddr,
    input[31:0] wdata,
    input csr_w,
    input[1:0] csr_wsc_mode,
    input[31:0] epc_in,
    input[31:0] mtval_data,
    input mtval_data_in,

    output[31:0] rdata,
    output[31:0] mstatus,
    output[31:0] mepc,
    output[31:0] mtvec
);
    // You may need to modify this module for better efficiency
    
    reg[31:0] CSR [0:15];

    assign mepc = CSR[1];
    assign mtvec = CSR[5];

    // Address mapping. The address is 12 bits, but only 4 bits are used in this module.
    wire raddr_valid = raddr[11:7] == 5'h6 && raddr[5:3] == 3'h0;
    wire[3:0] raddr_map = (raddr[6] << 3) + raddr[2:0];
    wire waddr_valid = waddr[11:7] == 5'h6 && waddr[5:3] == 3'h0;
    wire[3:0] waddr_map = (waddr[6] << 3) + waddr[2:0];

    assign mstatus = CSR[0];
    reg [31:0] mtval;
    reg [31:0] rdata_val;
    
    assign rdata = rdata_val;

    always@(*) begin
        if(raddr_map == 3) begin
            rdata_val = mtval;
        end else begin
            rdata_val = CSR[raddr_map];
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            mtval <= 0;
        end
        else if(mtval_data_in) begin
            mtval <= mtval_data;
        end else if(csr_w & waddr_map == 3) begin
            case(csr_wsc_mode)
                2'b01: mtval <= wdata;
                2'b10: mtval <= mtval | wdata;
                2'b11: mtval <= mtval & ~wdata;
                default: mtval <= wdata;
            endcase    
        end
    end

    always@(posedge clk or posedge rst) begin
        if(rst) begin
			CSR[0] <= 32'h88;
			CSR[1] <= 0;
			CSR[2] <= 0;
			CSR[4] <= 32'hfff;
			CSR[5] <= 0;
			CSR[6] <= 0;
			CSR[7] <= 0;
			CSR[8] <= 0;
			CSR[9] <= 0;
			CSR[10] <= 0;
			CSR[11] <= 0;
			CSR[12] <= 0;
			CSR[13] <= 0;
			CSR[14] <= 0;
			CSR[15] <= 0;
		end
        else if(csr_w && waddr_map != 3) begin
            case(csr_wsc_mode)
                2'b01: CSR[waddr_map] <= wdata;
                2'b10: CSR[waddr_map] <= CSR[waddr_map] | wdata;
                2'b11: CSR[waddr_map] <= CSR[waddr_map] & ~wdata;
                default: CSR[waddr_map] <= wdata;
            endcase            
        end
    end
endmodule