`ifndef WIDE
  `define WIDE(len) [len-1:0]
`endif
module bp_unit (
  input rst,
  input clk,
  input wen,
  input `WIDE(12) pc_w,
  input `WIDE(12) pc_r,
  input `WIDE(32) addr_in,
  output `WIDE(32) addr_out,
  input taken_w,
  output taken_r
);

  reg `WIDE((2**12)) `WIDE(32) btb;
  reg `WIDE((2**12)) `WIDE(2) bht;
  
  wire nouse;
  assign {taken_r, nouse} = bht[pc_r];
  // assign taken_r = 1'b0;

  wire [1:0] watch = bht[12'h220];

  assign addr_out = btb[pc_r];
  integer i;
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      for (i = 0; i < 2**12; i = i + 1) begin
        bht[i] <= 2'b01;
        btb[i] <= 32'b0;
      end
    end else if (wen) begin
      if (taken_w) begin
        btb[pc_w] <= addr_in;
      end
      if (taken_w) begin
        if (bht[pc_w] != 2'b11)
          bht[pc_w] <= bht[pc_w] + 1;
      end else begin
        if (bht[pc_w] != 2'b00)
          bht[pc_w] <= bht[pc_w] - 1;
      end
    end
  end

  
endmodule