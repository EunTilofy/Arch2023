`timescale 1ns / 1ps

module cmp_32(  input [31:0] a,
                input [31:0] b,
                input [2:0] ctrl,
                output reg c
    );

    parameter cmp_EQ  = 3'b000;
    parameter cmp_NE  = 3'b001;
    parameter cmp_LT  = 3'b100;
    parameter cmp_LTU = 3'b110;
    parameter cmp_GE  = 3'b101;
    parameter cmp_GEU = 3'b111;

    wire res_EQ  = a == b;
    wire res_NE  = ~res_EQ;
    wire res_LT  = (a[31] & ~b[31]) || (~(a[31] ^ b[31]) && a < b);
    wire res_LTU = a < b;
    wire res_GE  = ~res_LT;
    wire res_GEU = ~res_LTU;

    always @(*) begin
        case (ctrl)
            cmp_EQ: c = res_EQ;
            cmp_NE: c = res_NE;
            cmp_LT: c = res_LT;
            cmp_LTU: c = res_LTU;
            cmp_GE: c = res_GE;
            cmp_GEU: c = res_GEU;
            default: c = 1'b0;
        endcase
    end

endmodule